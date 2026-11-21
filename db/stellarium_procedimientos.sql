-- =====================================================================
-- Stellarium Observatorio y Planetario - Entrega 05
-- Procedimientos almacenados y triggers que consume el aplicativo.
-- Ejecutar DESPUES de crear las tablas y cargar los datos de prueba.
-- =====================================================================
USE stellarium_db;

-- ---------------------------------------------------------------------
-- 1. BORRADO LOGICO (ejecutar estas 2 lineas UNA sola vez)
-- ---------------------------------------------------------------------
ALTER TABLE cliente ADD COLUMN estado TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE reserva ADD COLUMN estado TINYINT(1) NOT NULL DEFAULT 1;

DELIMITER $$

-- ---------------------------------------------------------------------
-- 2. VALIDACION COMPARTIDA DE RESERVA (la usan los triggers)
--    Pendientes del informe: reprogramacion completa, grupo = turno efectivo
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_validar_reserva$$
CREATE PROCEDURE sp_validar_reserva(
  IN p_cant INT,
  IN p_srv_p VARCHAR(100), IN p_f_p DATE, IN p_h_p TIME,
  IN p_srv_r VARCHAR(100), IN p_f_r DATE, IN p_h_r TIME,
  IN p_srv_g VARCHAR(100), IN p_f_g DATE, IN p_h_g TIME, IN p_id_g VARCHAR(20))
BEGIN
  DECLARE n_r INT;
  DECLARE n_g INT;
  SET n_r = (p_srv_r IS NOT NULL) + (p_f_r IS NOT NULL) + (p_h_r IS NOT NULL);
  SET n_g = (p_srv_g IS NOT NULL) + (p_f_g IS NOT NULL) + (p_h_g IS NOT NULL) + (p_id_g IS NOT NULL);

  IF p_cant IS NULL OR p_cant <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad de personas debe ser mayor que cero';
  END IF;
  IF n_r NOT IN (0, 3) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La reprogramacion requiere servicio, fecha y horario completos';
  END IF;
  IF n_g NOT IN (0, 4) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La asignacion de grupo debe estar completa o vacia';
  END IF;
  IF n_g = 4 AND NOT (p_srv_g = COALESCE(p_srv_r, p_srv_p)
                  AND p_f_g  = COALESCE(p_f_r, p_f_p)
                  AND p_h_g  = COALESCE(p_h_r, p_h_p)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El grupo asignado debe pertenecer al turno de la reserva';
  END IF;
END$$

-- ---------------------------------------------------------------------
-- 3. TRIGGERS
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_reserva_bi$$
CREATE TRIGGER trg_reserva_bi BEFORE INSERT ON reserva FOR EACH ROW
BEGIN
  CALL sp_validar_reserva(NEW.cantidad_personas,
    NEW.servicio_programado, NEW.fecha_programada, NEW.horario_programado,
    NEW.servicio_reprogramado, NEW.fecha_reprogramada, NEW.horario_reprogramado,
    NEW.servicio_grupo, NEW.fecha_grupo, NEW.horario_grupo, NEW.identificador_grupo);
END$$

DROP TRIGGER IF EXISTS trg_reserva_bu$$
CREATE TRIGGER trg_reserva_bu BEFORE UPDATE ON reserva FOR EACH ROW
BEGIN
  CALL sp_validar_reserva(NEW.cantidad_personas,
    NEW.servicio_programado, NEW.fecha_programada, NEW.horario_programado,
    NEW.servicio_reprogramado, NEW.fecha_reprogramada, NEW.horario_reprogramado,
    NEW.servicio_grupo, NEW.fecha_grupo, NEW.horario_grupo, NEW.identificador_grupo);
END$$

-- No se puede dar de baja a un cliente con reservas activas
DROP TRIGGER IF EXISTS trg_cliente_bu$$
CREATE TRIGGER trg_cliente_bu BEFORE UPDATE ON cliente FOR EACH ROW
BEGIN
  IF OLD.estado = 1 AND NEW.estado = 0 AND EXISTS (
       SELECT 1 FROM reserva
       WHERE numero_documento_identidad = OLD.numero_documento_identidad AND estado = 1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente tiene reservas activas; elimine primero sus reservas';
  END IF;
END$$

-- ---------------------------------------------------------------------
-- 4. PROCEDIMIENTOS DE CLIENTE
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_cliente_insertar$$
CREATE PROCEDURE sp_cliente_insertar(IN p_doc VARCHAR(20), IN p_tipo VARCHAR(25),
  IN p_nombre VARCHAR(100), IN p_ap VARCHAR(60), IN p_am VARCHAR(60))
BEGIN
  INSERT INTO cliente (numero_documento_identidad, tipo_documento, nombre, apellido_paterno, apellido_materno)
  VALUES (p_doc, p_tipo, p_nombre, p_ap, p_am);
END$$

DROP PROCEDURE IF EXISTS sp_cliente_modificar$$
CREATE PROCEDURE sp_cliente_modificar(IN p_doc VARCHAR(20), IN p_tipo VARCHAR(25),
  IN p_nombre VARCHAR(100), IN p_ap VARCHAR(60), IN p_am VARCHAR(60))
BEGIN
  UPDATE cliente SET tipo_documento = p_tipo, nombre = p_nombre,
         apellido_paterno = p_ap, apellido_materno = p_am
  WHERE numero_documento_identidad = p_doc AND estado = 1;
END$$

DROP PROCEDURE IF EXISTS sp_cliente_eliminar$$
CREATE PROCEDURE sp_cliente_eliminar(IN p_doc VARCHAR(20))
BEGIN
  UPDATE cliente SET estado = 0 WHERE numero_documento_identidad = p_doc;
END$$

DROP PROCEDURE IF EXISTS sp_cliente_listar$$
CREATE PROCEDURE sp_cliente_listar()
BEGIN
  SELECT numero_documento_identidad, tipo_documento, nombre, apellido_paterno, apellido_materno
  FROM cliente WHERE estado = 1 ORDER BY apellido_paterno, nombre;
END$$

DROP PROCEDURE IF EXISTS sp_servicio_listar$$
CREATE PROCEDURE sp_servicio_listar()
BEGIN
  SELECT nombre_servicio FROM servicio ORDER BY nombre_servicio;
END$$

-- ---------------------------------------------------------------------
-- 5. PROCEDIMIENTOS DE RESERVA (insertar, modificar y reprogramar estan mas abajo,
--    junto al control de capacidad de espacios)
-- ---------------------------------------------------------------------
-- Eliminar = borrado logico; libera los espacios ocupados
DROP PROCEDURE IF EXISTS sp_reserva_eliminar$$
CREATE PROCEDURE sp_reserva_eliminar(IN p_num VARCHAR(20))
BEGIN
  UPDATE reserva SET estado = 0 WHERE numero_reserva = p_num;
  UPDATE espacio SET numero_reserva = NULL WHERE numero_reserva = p_num;
END$$

DROP PROCEDURE IF EXISTS sp_reserva_listar$$
CREATE PROCEDURE sp_reserva_listar()
BEGIN
  SELECT r.numero_reserva, r.numero_documento_identidad AS documento,
         CONCAT_WS(' ', c.nombre, c.apellido_paterno) AS cliente,
         r.servicio_programado, r.fecha_programada, r.horario_programado,
         r.servicio_reprogramado, r.fecha_reprogramada, r.horario_reprogramado,
         r.cantidad_personas, r.canal_origen, r.medio_pago, r.estado_pago, r.monto_pagado
  FROM reserva r
  JOIN cliente c ON c.numero_documento_identidad = r.numero_documento_identidad
  WHERE r.estado = 1
  ORDER BY r.numero_reserva;
END$$

-- ---------------------------------------------------------------------
-- 6. REPORTES (10 consultas; 8 usan JOIN)
-- ---------------------------------------------------------------------
-- R1 (JOIN) Reservas con datos del cliente
DROP PROCEDURE IF EXISTS sp_rpt_reservas_clientes$$
CREATE PROCEDURE sp_rpt_reservas_clientes()
BEGIN
  SELECT r.numero_reserva, c.numero_documento_identidad AS documento,
         CONCAT_WS(' ', c.nombre, c.apellido_paterno, c.apellido_materno) AS cliente,
         r.servicio_programado AS servicio, r.fecha_programada AS fecha,
         r.horario_programado AS horario, r.cantidad_personas AS personas
  FROM reserva r
  JOIN cliente c ON c.numero_documento_identidad = r.numero_documento_identidad
  WHERE r.estado = 1
  ORDER BY r.fecha_programada, r.horario_programado;
END$$

-- R2 (JOIN) Reservas de una fecha (considera reprogramaciones)
DROP PROCEDURE IF EXISTS sp_rpt_reservas_por_fecha$$
CREATE PROCEDURE sp_rpt_reservas_por_fecha(IN p_fecha DATE)
BEGIN
  SELECT r.numero_reserva,
         CONCAT_WS(' ', c.nombre, c.apellido_paterno) AS cliente,
         COALESCE(r.servicio_reprogramado, r.servicio_programado) AS servicio,
         COALESCE(r.horario_reprogramado, r.horario_programado) AS horario,
         r.cantidad_personas AS personas, r.estado_pago
  FROM reserva r
  JOIN cliente c ON c.numero_documento_identidad = r.numero_documento_identidad
  WHERE r.estado = 1 AND COALESCE(r.fecha_reprogramada, r.fecha_programada) = p_fecha
  ORDER BY horario, r.numero_reserva;
END$$

-- R3 (JOIN) Reservas pendientes de pago con monto esperado
DROP PROCEDURE IF EXISTS sp_rpt_pendientes_pago$$
CREATE PROCEDURE sp_rpt_pendientes_pago()
BEGIN
  SELECT r.numero_reserva,
         CONCAT_WS(' ', c.nombre, c.apellido_paterno) AS cliente,
         r.servicio_programado AS servicio, r.cantidad_personas AS personas,
         s.precio AS precio_unitario, s.precio * r.cantidad_personas AS monto_esperado
  FROM reserva r
  JOIN cliente c ON c.numero_documento_identidad = r.numero_documento_identidad
  JOIN servicio s ON s.nombre_servicio = r.servicio_programado
  WHERE r.estado = 1 AND r.estado_pago = 'Pendiente'
  ORDER BY r.numero_reserva;
END$$

-- R4 Reservas y visitantes por canal de origen
DROP PROCEDURE IF EXISTS sp_rpt_reservas_por_canal$$
CREATE PROCEDURE sp_rpt_reservas_por_canal()
BEGIN
  SELECT canal_origen, COUNT(*) AS total_reservas, SUM(cantidad_personas) AS total_visitantes
  FROM reserva WHERE estado = 1
  GROUP BY canal_origen ORDER BY total_reservas DESC;
END$$

-- R5 Ingresos por medio de pago
DROP PROCEDURE IF EXISTS sp_rpt_ingresos_medio_pago$$
CREATE PROCEDURE sp_rpt_ingresos_medio_pago()
BEGIN
  SELECT medio_pago, COUNT(*) AS reservas_pagadas, SUM(monto_pagado) AS ingresos_totales
  FROM reserva WHERE estado = 1 AND estado_pago = 'Pagado'
  GROUP BY medio_pago ORDER BY ingresos_totales DESC;
END$$

-- R6 (JOIN) Servicios mas solicitados (incluye servicios sin reservas)
DROP PROCEDURE IF EXISTS sp_rpt_servicios_solicitados$$
CREATE PROCEDURE sp_rpt_servicios_solicitados()
BEGIN
  SELECT s.nombre_servicio, s.tipo_servicio,
         COUNT(r.numero_reserva) AS total_reservas,
         COALESCE(SUM(r.cantidad_personas), 0) AS total_visitantes
  FROM servicio s
  LEFT JOIN reserva r ON r.servicio_programado = s.nombre_servicio AND r.estado = 1
  GROUP BY s.nombre_servicio, s.tipo_servicio
  ORDER BY total_reservas DESC;
END$$

-- R7 (JOIN) Clientes con mas de una reserva
DROP PROCEDURE IF EXISTS sp_rpt_clientes_recurrentes$$
CREATE PROCEDURE sp_rpt_clientes_recurrentes()
BEGIN
  SELECT c.numero_documento_identidad AS documento,
         CONCAT_WS(' ', c.nombre, c.apellido_paterno, c.apellido_materno) AS cliente,
         COUNT(*) AS total_reservas
  FROM cliente c
  JOIN reserva r ON r.numero_documento_identidad = c.numero_documento_identidad
  WHERE r.estado = 1
  GROUP BY c.numero_documento_identidad, c.nombre, c.apellido_paterno, c.apellido_materno
  HAVING COUNT(*) > 1
  ORDER BY total_reservas DESC;
END$$

-- R8 (JOIN) Reservas reprogramadas: turno original y nuevo
DROP PROCEDURE IF EXISTS sp_rpt_reprogramadas$$
CREATE PROCEDURE sp_rpt_reprogramadas()
BEGIN
  SELECT r.numero_reserva,
         CONCAT_WS(' ', c.nombre, c.apellido_paterno) AS cliente,
         r.servicio_programado AS servicio_original, r.fecha_programada AS fecha_original,
         r.horario_programado AS horario_original,
         r.servicio_reprogramado AS servicio_nuevo, r.fecha_reprogramada AS fecha_nueva,
         r.horario_reprogramado AS horario_nuevo
  FROM reserva r
  JOIN cliente c ON c.numero_documento_identidad = r.numero_documento_identidad
  WHERE r.estado = 1 AND r.servicio_reprogramado IS NOT NULL
  ORDER BY r.fecha_reprogramada;
END$$

-- R9 (JOIN) Grupos con sus guias y cantidad de personas (atributo derivado)
DROP PROCEDURE IF EXISTS sp_rpt_grupos_guias$$
CREATE PROCEDURE sp_rpt_grupos_guias()
BEGIN
  SELECT g.nombre_servicio, g.fecha, g.horario, g.identificador_grupo,
         gg.guia_asignado, COALESCE(SUM(r.cantidad_personas), 0) AS personas_en_grupo
  FROM grupo g
  JOIN guia_grupo gg ON gg.nombre_servicio = g.nombre_servicio AND gg.fecha = g.fecha
                    AND gg.horario = g.horario AND gg.identificador_grupo = g.identificador_grupo
  LEFT JOIN reserva r ON r.servicio_grupo = g.nombre_servicio AND r.fecha_grupo = g.fecha
                     AND r.horario_grupo = g.horario AND r.identificador_grupo = g.identificador_grupo
                     AND r.estado = 1
  GROUP BY g.nombre_servicio, g.fecha, g.horario, g.identificador_grupo, gg.guia_asignado
  ORDER BY g.fecha, g.horario;
END$$

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
