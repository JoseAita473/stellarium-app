-- =====================================================================
-- PARCHE: control de capacidad y lista de turnos disponibles
-- Ejecutar sobre stellarium_db ya cargada. NO borra datos y se puede repetir.
-- =====================================================================
USE stellarium_db;

DELIMITER $$

-- ---------------------------------------------------------------------
-- ESPACIOS: control de capacidad y asignacion automatica
-- Capacidad de un combo = la menor capacidad de las actividades que lo componen.
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_asignar_espacios$$
CREATE PROCEDURE sp_asignar_espacios(IN p_num VARCHAR(20), IN p_srv VARCHAR(100),
  IN p_fecha DATE, IN p_hora TIME, IN p_cant INT)
BEGIN
  DECLARE v_cap INT;
  DECLARE v_ocup INT;
  DECLARE v_asig INT DEFAULT 0;
  DECLARE v_sig INT;
  DECLARE v_msg VARCHAR(128);

  SELECT COALESCE(s.capacidad_maxima,
           (SELECT MIN(a.capacidad_maxima) FROM composicion_servicio cs
            JOIN servicio a ON a.nombre_servicio = cs.servicio_actividad
            WHERE cs.servicio_combo = s.nombre_servicio))
    INTO v_cap FROM servicio s WHERE s.nombre_servicio = p_srv;

  SELECT COUNT(*) INTO v_ocup FROM espacio
   WHERE nombre_servicio = p_srv AND fecha = p_fecha AND horario = p_hora AND numero_reserva IS NOT NULL;

  IF v_cap IS NOT NULL AND v_ocup + p_cant > v_cap THEN
    SET v_msg = CONCAT('No hay espacios suficientes en el turno. Disponibles: ', v_cap - v_ocup);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
  END IF;

  -- 1) reutiliza espacios liberados del turno
  UPDATE espacio SET numero_reserva = p_num
   WHERE nombre_servicio = p_srv AND fecha = p_fecha AND horario = p_hora AND numero_reserva IS NULL
   ORDER BY numero_espacio LIMIT p_cant;
  SET v_asig = ROW_COUNT();

  -- 2) crea los espacios que falten, con numeracion correlativa
  SELECT COALESCE(MAX(numero_espacio), 0) INTO v_sig FROM espacio
   WHERE nombre_servicio = p_srv AND fecha = p_fecha AND horario = p_hora;
  WHILE v_asig < p_cant DO
    SET v_sig = v_sig + 1;
    INSERT INTO espacio (nombre_servicio, fecha, horario, numero_espacio, numero_reserva)
    VALUES (p_srv, p_fecha, p_hora, v_sig, p_num);
    SET v_asig = v_asig + 1;
  END WHILE;
END$$

-- Turnos con su disponibilidad (lo usa el aplicativo para ayudar a reservar)
DROP PROCEDURE IF EXISTS sp_turno_listar$$
CREATE PROCEDURE sp_turno_listar(IN p_solo_futuros TINYINT)
BEGIN
  SELECT servicio, fecha, horario, capacidad - ocupados AS disponibles
  FROM (
    SELECT t.nombre_servicio AS servicio, t.fecha, t.horario,
           COALESCE(s.capacidad_maxima,
             (SELECT MIN(a.capacidad_maxima) FROM composicion_servicio cs
              JOIN servicio a ON a.nombre_servicio = cs.servicio_actividad
              WHERE cs.servicio_combo = s.nombre_servicio)) AS capacidad,
           COUNT(e.numero_espacio) AS ocupados
    FROM turno t
    JOIN servicio s ON s.nombre_servicio = t.nombre_servicio
    LEFT JOIN espacio e ON e.nombre_servicio = t.nombre_servicio AND e.fecha = t.fecha
                       AND e.horario = t.horario AND e.numero_reserva IS NOT NULL
    WHERE p_solo_futuros = 0 OR t.fecha >= CURDATE()
    GROUP BY t.nombre_servicio, t.fecha, t.horario, s.nombre_servicio, s.capacidad_maxima
  ) x
  ORDER BY fecha, horario;
END$$

DROP PROCEDURE IF EXISTS sp_reserva_insertar$$
CREATE PROCEDURE sp_reserva_insertar(IN p_num VARCHAR(20), IN p_doc VARCHAR(20),
  IN p_srv VARCHAR(100), IN p_fecha DATE, IN p_hora TIME, IN p_cant INT,
  IN p_canal VARCHAR(30), IN p_medio VARCHAR(30), IN p_estado_pago VARCHAR(20), IN p_monto DECIMAL(10,2))
BEGIN
  INSERT INTO reserva (numero_reserva, numero_documento_identidad,
         servicio_programado, fecha_programada, horario_programado,
         cantidad_personas, canal_origen, medio_pago, estado_pago, monto_pagado)
  VALUES (p_num, p_doc, p_srv, p_fecha, p_hora, p_cant, p_canal, p_medio, p_estado_pago, p_monto);
  CALL sp_asignar_espacios(p_num, p_srv, p_fecha, p_hora, p_cant);
END$$

-- Modificar: si cambia la cantidad de personas, se reasignan los espacios
DROP PROCEDURE IF EXISTS sp_reserva_modificar$$
CREATE PROCEDURE sp_reserva_modificar(IN p_num VARCHAR(20), IN p_cant INT,
  IN p_canal VARCHAR(30), IN p_medio VARCHAR(30), IN p_estado_pago VARCHAR(20), IN p_monto DECIMAL(10,2))
BEGIN
  DECLARE v_cant_ant INT;
  DECLARE v_srv VARCHAR(100);
  DECLARE v_fecha DATE;
  DECLARE v_hora TIME;

  SELECT cantidad_personas, COALESCE(servicio_reprogramado, servicio_programado),
         COALESCE(fecha_reprogramada, fecha_programada), COALESCE(horario_reprogramado, horario_programado)
    INTO v_cant_ant, v_srv, v_fecha, v_hora
    FROM reserva WHERE numero_reserva = p_num AND estado = 1;

  UPDATE reserva SET cantidad_personas = p_cant, canal_origen = p_canal, medio_pago = p_medio,
         estado_pago = p_estado_pago, monto_pagado = p_monto
  WHERE numero_reserva = p_num AND estado = 1;

  IF v_cant_ant IS NOT NULL AND v_cant_ant <> p_cant THEN
    UPDATE espacio SET numero_reserva = NULL WHERE numero_reserva = p_num;
    CALL sp_asignar_espacios(p_num, v_srv, v_fecha, v_hora, p_cant);
  END IF;
END$$

-- Reprogramar: nuevo turno; libera grupo y espacios anteriores y asigna espacios en el nuevo turno
DROP PROCEDURE IF EXISTS sp_reserva_reprogramar$$
CREATE PROCEDURE sp_reserva_reprogramar(IN p_num VARCHAR(20), IN p_srv VARCHAR(100),
  IN p_fecha DATE, IN p_hora TIME)
BEGIN
  DECLARE v_cant INT;

  UPDATE reserva SET servicio_reprogramado = p_srv, fecha_reprogramada = p_fecha, horario_reprogramado = p_hora,
         servicio_grupo = NULL, fecha_grupo = NULL, horario_grupo = NULL, identificador_grupo = NULL
  WHERE numero_reserva = p_num AND estado = 1;
  UPDATE espacio SET numero_reserva = NULL WHERE numero_reserva = p_num;

  SELECT cantidad_personas INTO v_cant FROM reserva WHERE numero_reserva = p_num AND estado = 1;
  IF v_cant IS NOT NULL THEN
    CALL sp_asignar_espacios(p_num, p_srv, p_fecha, p_hora, v_cant);
  END IF;
END$$

-- R10 (JOIN) Ocupacion de espacios por turno (capacidad del combo = la menor de sus actividades)
DROP PROCEDURE IF EXISTS sp_rpt_ocupacion_turnos$$
CREATE PROCEDURE sp_rpt_ocupacion_turnos()
BEGIN
  SELECT nombre_servicio, fecha, horario, capacidad_maxima, espacios_ocupados,
         capacidad_maxima - espacios_ocupados AS espacios_disponibles
  FROM (
    SELECT t.nombre_servicio, t.fecha, t.horario,
           COALESCE(s.capacidad_maxima,
             (SELECT MIN(a.capacidad_maxima) FROM composicion_servicio cs
              JOIN servicio a ON a.nombre_servicio = cs.servicio_actividad
              WHERE cs.servicio_combo = s.nombre_servicio)) AS capacidad_maxima,
           COUNT(e.numero_espacio) AS espacios_ocupados
    FROM turno t
    JOIN servicio s ON s.nombre_servicio = t.nombre_servicio
    LEFT JOIN espacio e ON e.nombre_servicio = t.nombre_servicio AND e.fecha = t.fecha
                       AND e.horario = t.horario AND e.numero_reserva IS NOT NULL
    GROUP BY t.nombre_servicio, t.fecha, t.horario, s.nombre_servicio, s.capacidad_maxima
  ) x
  ORDER BY fecha, horario;
END$$

DELIMITER ;
