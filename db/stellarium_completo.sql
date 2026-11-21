-- =====================================================================
-- STELLARIUM OBSERVATORIO Y PLANETARIO - SCRIPT COMPLETO (Entrega 05)
-- Ejecutar de una sola vez en MySQL Workbench. Contiene, en orden:
--   1) Estructura de las 9 tablas y datos de prueba iniciales (entrega 04)
--   2) Borrado logico, triggers y procedimientos almacenados
--   3) Datos de prueba ampliados (28 clientes, 60 reservas y mas)
-- ATENCION: recrea las tablas (DROP TABLE IF EXISTS), por lo que borra los
-- datos que hubiera en stellarium_db antes de volver a cargarlos.
-- =====================================================================

-- ===== 1) ESTRUCTURA Y DATOS INICIALES =====
CREATE DATABASE  IF NOT EXISTS `stellarium_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `stellarium_db`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: stellarium_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `numero_documento_identidad` varchar(20) NOT NULL,
  `tipo_documento` varchar(25) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido_paterno` varchar(60) DEFAULT NULL,
  `apellido_materno` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`numero_documento_identidad`),
  CONSTRAINT `chk_cliente_dni` CHECK (((`tipo_documento` <> _utf8mb4'DNI Peruano') or regexp_like(`numero_documento_identidad`,_utf8mb4'^[0-9]{8}$'))),
  CONSTRAINT `chk_cliente_tipo` CHECK ((`tipo_documento` in (_utf8mb4'DNI Peruano',_utf8mb4'Pasaporte',_utf8mb4'Carné de Extranjería')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
INSERT INTO `cliente` VALUES ('45159364','DNI Peruano','Maria Elena','Salcedo','Torres'),('70492618','DNI Peruano','Fernando Jose','Garcia','Nunez'),('70845129','DNI Peruano','Carlos Eduardo','Huaman','Rojas'),('71582640','DNI Peruano','Valeria Sofia','Mamani','Lopez'),('72518463','DNI Peruano','Luis Alberto','Ramirez','Quispe'),('73461920','DNI Peruano','Lucia Fernanda','Castro','Paredes'),('74268319','DNI Peruano','Miguel Angel','Rojas','Vega'),('74859632','DNI Peruano','Juan Carlos','Perez','Flores'),('75613824','DNI Peruano','Paola Milagros','Flores','Diaz'),('76392015','DNI Peruano','Ana Lucia','Vargas','Mendoza'),('76920315','DNI Peruano','Diego Alonso','Torres','Ramos'),('78315420','DNI Peruano','Andrea Isabel','Quispe','Salas'),('K52874196','Pasaporte','Lukas','Schneider','Muller'),('P78451236','Pasaporte','James','Anderson','Smith'),('X96325874','Pasaporte','Sophie','Martin','Dubois');
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `composicion_servicio`
--

DROP TABLE IF EXISTS `composicion_servicio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `composicion_servicio` (
  `servicio_combo` varchar(100) NOT NULL,
  `servicio_actividad` varchar(100) NOT NULL,
  PRIMARY KEY (`servicio_combo`,`servicio_actividad`),
  KEY `idx_composicion_actividad` (`servicio_actividad`),
  CONSTRAINT `fk_composicion_actividad` FOREIGN KEY (`servicio_actividad`) REFERENCES `servicio` (`nombre_servicio`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_composicion_combo` FOREIGN KEY (`servicio_combo`) REFERENCES `servicio` (`nombre_servicio`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `composicion_servicio`
--

LOCK TABLES `composicion_servicio` WRITE;
/*!40000 ALTER TABLE `composicion_servicio` DISABLE KEYS */;
INSERT INTO `composicion_servicio` VALUES ('Combo Planetario y Observatorio','Observatorio'),('Combo Planetario y Observatorio','Planetario');
/*!40000 ALTER TABLE `composicion_servicio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `espacio`
--

DROP TABLE IF EXISTS `espacio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `espacio` (
  `nombre_servicio` varchar(100) NOT NULL,
  `fecha` date NOT NULL,
  `horario` time NOT NULL,
  `numero_espacio` int NOT NULL,
  `numero_reserva` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`nombre_servicio`,`fecha`,`horario`,`numero_espacio`),
  KEY `idx_espacio_reserva` (`numero_reserva`),
  CONSTRAINT `fk_espacio_reserva` FOREIGN KEY (`numero_reserva`) REFERENCES `reserva` (`numero_reserva`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_espacio_turno` FOREIGN KEY (`nombre_servicio`, `fecha`, `horario`) REFERENCES `turno` (`nombre_servicio`, `fecha`, `horario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_espacio_numero` CHECK ((`numero_espacio` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `espacio`
--

LOCK TABLES `espacio` WRITE;
/*!40000 ALTER TABLE `espacio` DISABLE KEYS */;
INSERT INTO `espacio` VALUES ('Planetario','2026-11-03','17:00:00',1,'R001'),('Planetario','2026-11-03','17:00:00',2,'R001'),('Observatorio','2026-11-03','19:00:00',1,'R002'),('Observatorio','2026-11-03','19:00:00',2,'R002'),('Combo Planetario y Observatorio','2026-11-03','18:00:00',1,'R003'),('Combo Planetario y Observatorio','2026-11-03','18:00:00',2,'R003'),('Combo Planetario y Observatorio','2026-11-03','18:00:00',3,'R003'),('Planetario','2026-11-04','17:00:00',1,'R004'),('Observatorio','2026-11-04','19:00:00',1,'R005'),('Observatorio','2026-11-04','19:00:00',2,'R005'),('Planetario','2026-11-04','17:00:00',2,'R006'),('Planetario','2026-11-04','17:00:00',3,'R006'),('Combo Planetario y Observatorio','2026-11-05','18:00:00',1,'R007'),('Combo Planetario y Observatorio','2026-11-05','18:00:00',2,'R007'),('Observatorio','2026-11-05','19:00:00',1,'R008'),('Observatorio','2026-11-05','19:00:00',2,'R008'),('Observatorio','2026-11-05','19:00:00',3,'R008'),('Observatorio','2026-11-05','19:00:00',4,'R008'),('Planetario','2026-11-03','17:00:00',3,'R009'),('Planetario','2026-11-03','17:00:00',4,'R009'),('Observatorio','2026-11-03','19:00:00',3,'R010'),('Combo Planetario y Observatorio','2026-11-03','18:00:00',4,'R011'),('Combo Planetario y Observatorio','2026-11-03','18:00:00',5,'R011'),('Planetario','2026-11-04','17:00:00',4,'R012'),('Planetario','2026-11-04','17:00:00',5,'R012'),('Planetario','2026-11-04','17:00:00',6,'R012'),('Observatorio','2026-11-04','19:00:00',3,'R013'),('Observatorio','2026-11-04','19:00:00',4,'R013'),('Observatorio','2026-11-04','19:00:00',5,'R014'),('Combo Planetario y Observatorio','2026-11-05','18:00:00',3,'R015'),('Combo Planetario y Observatorio','2026-11-05','18:00:00',4,'R015'),('Observatorio','2026-11-05','19:00:00',5,'R016'),('Observatorio','2026-11-05','19:00:00',6,'R016'),('Observatorio','2026-11-08','19:00:00',1,'R019'),('Observatorio','2026-11-08','19:00:00',2,'R019'),('Planetario','2026-11-08','17:00:00',1,'R020'),('Planetario','2026-11-08','17:00:00',2,'R020');
/*!40000 ALTER TABLE `espacio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grupo`
--

DROP TABLE IF EXISTS `grupo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `grupo` (
  `nombre_servicio` varchar(100) NOT NULL,
  `fecha` date NOT NULL,
  `horario` time NOT NULL,
  `identificador_grupo` varchar(20) NOT NULL,
  PRIMARY KEY (`nombre_servicio`,`fecha`,`horario`,`identificador_grupo`),
  CONSTRAINT `fk_grupo_turno` FOREIGN KEY (`nombre_servicio`, `fecha`, `horario`) REFERENCES `turno` (`nombre_servicio`, `fecha`, `horario`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grupo`
--

LOCK TABLES `grupo` WRITE;
/*!40000 ALTER TABLE `grupo` DISABLE KEYS */;
INSERT INTO `grupo` VALUES ('Combo Planetario y Observatorio','2026-11-03','18:00:00','G01'),('Combo Planetario y Observatorio','2026-11-05','18:00:00','G01'),('Observatorio','2026-11-03','19:00:00','G01'),('Observatorio','2026-11-04','19:00:00','G02'),('Observatorio','2026-11-05','19:00:00','G01'),('Observatorio','2026-11-08','19:00:00','G01'),('Planetario','2026-11-03','17:00:00','G01'),('Planetario','2026-11-04','17:00:00','G01'),('Planetario','2026-11-08','17:00:00','G01');
/*!40000 ALTER TABLE `grupo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guia_grupo`
--

DROP TABLE IF EXISTS `guia_grupo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guia_grupo` (
  `nombre_servicio` varchar(100) NOT NULL,
  `fecha` date NOT NULL,
  `horario` time NOT NULL,
  `identificador_grupo` varchar(20) NOT NULL,
  `guia_asignado` varchar(100) NOT NULL,
  PRIMARY KEY (`nombre_servicio`,`fecha`,`horario`,`identificador_grupo`,`guia_asignado`),
  CONSTRAINT `fk_guia_grupo` FOREIGN KEY (`nombre_servicio`, `fecha`, `horario`, `identificador_grupo`) REFERENCES `grupo` (`nombre_servicio`, `fecha`, `horario`, `identificador_grupo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guia_grupo`
--

LOCK TABLES `guia_grupo` WRITE;
/*!40000 ALTER TABLE `guia_grupo` DISABLE KEYS */;
INSERT INTO `guia_grupo` VALUES ('Combo Planetario y Observatorio','2026-11-03','18:00:00','G01','Guia Carlos'),('Combo Planetario y Observatorio','2026-11-05','18:00:00','G01','Guia Gabriel'),('Observatorio','2026-11-03','19:00:00','G01','Guia Beatriz'),('Observatorio','2026-11-04','19:00:00','G02','Guia Eduardo'),('Observatorio','2026-11-05','19:00:00','G01','Guia Helena'),('Observatorio','2026-11-08','19:00:00','G01','Guia Isabel'),('Planetario','2026-11-03','17:00:00','G01','Guia Alejandro'),('Planetario','2026-11-04','17:00:00','G01','Guia Daniela'),('Planetario','2026-11-08','17:00:00','G01','Guia Jorge');
/*!40000 ALTER TABLE `guia_grupo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reserva`
--

DROP TABLE IF EXISTS `reserva`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reserva` (
  `numero_reserva` varchar(20) NOT NULL,
  `numero_documento_identidad` varchar(20) NOT NULL,
  `servicio_programado` varchar(100) NOT NULL,
  `fecha_programada` date NOT NULL,
  `horario_programado` time NOT NULL,
  `servicio_reprogramado` varchar(100) DEFAULT NULL,
  `fecha_reprogramada` date DEFAULT NULL,
  `horario_reprogramado` time DEFAULT NULL,
  `servicio_grupo` varchar(100) DEFAULT NULL,
  `fecha_grupo` date DEFAULT NULL,
  `horario_grupo` time DEFAULT NULL,
  `identificador_grupo` varchar(20) DEFAULT NULL,
  `cantidad_personas` int NOT NULL,
  `canal_origen` varchar(30) NOT NULL,
  `medio_pago` varchar(30) DEFAULT NULL,
  `estado_pago` varchar(20) NOT NULL,
  `monto_pagado` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`numero_reserva`),
  KEY `idx_reserva_cliente` (`numero_documento_identidad`),
  KEY `idx_reserva_programado` (`servicio_programado`,`fecha_programada`,`horario_programado`),
  KEY `idx_reserva_reprogramado` (`servicio_reprogramado`,`fecha_reprogramada`,`horario_reprogramado`),
  KEY `idx_reserva_grupo` (`servicio_grupo`,`fecha_grupo`,`horario_grupo`,`identificador_grupo`),
  KEY `idx_reserva_canal` (`canal_origen`),
  KEY `idx_reserva_estado_pago` (`estado_pago`),
  KEY `idx_reserva_fecha_programada` (`fecha_programada`),
  KEY `idx_reserva_fecha_reprogramada` (`fecha_reprogramada`),
  CONSTRAINT `fk_reserva_cliente` FOREIGN KEY (`numero_documento_identidad`) REFERENCES `cliente` (`numero_documento_identidad`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_reserva_grupo` FOREIGN KEY (`servicio_grupo`, `fecha_grupo`, `horario_grupo`, `identificador_grupo`) REFERENCES `grupo` (`nombre_servicio`, `fecha`, `horario`, `identificador_grupo`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_reserva_programado` FOREIGN KEY (`servicio_programado`, `fecha_programada`, `horario_programado`) REFERENCES `turno` (`nombre_servicio`, `fecha`, `horario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_reserva_reprogramado` FOREIGN KEY (`servicio_reprogramado`, `fecha_reprogramada`, `horario_reprogramado`) REFERENCES `turno` (`nombre_servicio`, `fecha`, `horario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_reserva_canal` CHECK ((`canal_origen` in (_utf8mb4'Oficina',_utf8mb4'WhatsApp',_utf8mb4'Viator',_utf8mb4'Airbnb',_utf8mb4'Cuponidad'))),
  CONSTRAINT `chk_reserva_cantidad` CHECK ((`cantidad_personas` > 0)),
  CONSTRAINT `chk_reserva_medio` CHECK (((`medio_pago` is null) or (`medio_pago` in (_utf8mb4'Yape',_utf8mb4'Transferencia',_utf8mb4'Tarjeta',_utf8mb4'Efectivo')))),
  CONSTRAINT `chk_reserva_monto` CHECK (((`monto_pagado` is null) or (`monto_pagado` >= 0)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reserva`
--

LOCK TABLES `reserva` WRITE;
/*!40000 ALTER TABLE `reserva` DISABLE KEYS */;
INSERT INTO `reserva` VALUES ('R001','74859632','Planetario','2026-11-03','17:00:00',NULL,NULL,NULL,'Planetario','2026-11-03','17:00:00','G01',2,'WhatsApp','Yape','Pagado',70.00),('R002','45159364','Observatorio','2026-11-03','19:00:00',NULL,NULL,NULL,'Observatorio','2026-11-03','19:00:00','G01',2,'Oficina','Efectivo','Pagado',100.00),('R003','72518463','Combo Planetario y Observatorio','2026-11-03','18:00:00',NULL,NULL,NULL,'Combo Planetario y Observatorio','2026-11-03','18:00:00','G01',3,'Viator','Tarjeta','Pagado',225.00),('R004','76392015','Planetario','2026-11-04','17:00:00',NULL,NULL,NULL,'Planetario','2026-11-04','17:00:00','G01',1,'Airbnb','Tarjeta','Pagado',35.00),('R005','70845129','Observatorio','2026-11-04','19:00:00',NULL,NULL,NULL,'Observatorio','2026-11-04','19:00:00','G02',2,'Cuponidad','Yape','Pagado',100.00),('R006','73461920','Planetario','2026-11-04','17:00:00',NULL,NULL,NULL,'Planetario','2026-11-04','17:00:00','G01',2,'WhatsApp','Transferencia','Pagado',70.00),('R007','76920315','Combo Planetario y Observatorio','2026-11-05','18:00:00',NULL,NULL,NULL,'Combo Planetario y Observatorio','2026-11-05','18:00:00','G01',2,'Oficina','Efectivo','Pagado',150.00),('R008','71582640','Observatorio','2026-11-05','19:00:00',NULL,NULL,NULL,'Observatorio','2026-11-05','19:00:00','G01',4,'Viator','Tarjeta','Pagado',200.00),('R009','74268319','Planetario','2026-11-03','17:00:00',NULL,NULL,NULL,'Planetario','2026-11-03','17:00:00','G01',2,'WhatsApp','Yape','Pagado',70.00),('R010','78315420','Observatorio','2026-11-03','19:00:00',NULL,NULL,NULL,'Observatorio','2026-11-03','19:00:00','G01',1,'Airbnb','Tarjeta','Pagado',50.00),('R011','70492618','Combo Planetario y Observatorio','2026-11-03','18:00:00',NULL,NULL,NULL,'Combo Planetario y Observatorio','2026-11-03','18:00:00','G01',2,'Cuponidad','Transferencia','Pagado',150.00),('R012','75613824','Planetario','2026-11-04','17:00:00',NULL,NULL,NULL,'Planetario','2026-11-04','17:00:00','G01',3,'Oficina','Efectivo','Pagado',105.00),('R013','74859632','Observatorio','2026-11-04','19:00:00',NULL,NULL,NULL,'Observatorio','2026-11-04','19:00:00','G02',2,'WhatsApp','Yape','Pagado',100.00),('R014','45159364','Observatorio','2026-11-04','19:00:00',NULL,NULL,NULL,'Observatorio','2026-11-04','19:00:00','G02',1,'Viator','Tarjeta','Pagado',50.00),('R015','72518463','Combo Planetario y Observatorio','2026-11-05','18:00:00',NULL,NULL,NULL,'Combo Planetario y Observatorio','2026-11-05','18:00:00','G01',2,'Airbnb','Tarjeta','Pagado',150.00),('R016','76392015','Observatorio','2026-11-05','19:00:00',NULL,NULL,NULL,'Observatorio','2026-11-05','19:00:00','G01',2,'WhatsApp','Yape','Pagado',100.00),('R017','70845129','Planetario','2026-11-06','17:00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,'WhatsApp',NULL,'Pendiente',0.00),('R018','73461920','Observatorio','2026-11-06','19:00:00',NULL,NULL,NULL,NULL,NULL,NULL,NULL,3,'Oficina',NULL,'Pendiente',0.00),('R019','76920315','Observatorio','2026-11-07','19:00:00','Observatorio','2026-11-08','19:00:00','Observatorio','2026-11-08','19:00:00','G01',2,'Viator','Tarjeta','Pagado',100.00),('R020','71582640','Planetario','2026-11-07','17:00:00','Planetario','2026-11-08','17:00:00','Planetario','2026-11-08','17:00:00','G01',2,'WhatsApp','Yape','Pagado',70.00);
/*!40000 ALTER TABLE `reserva` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servicio`
--

DROP TABLE IF EXISTS `servicio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `servicio` (
  `nombre_servicio` varchar(100) NOT NULL,
  `tipo_servicio` varchar(30) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `capacidad_maxima` int DEFAULT NULL,
  PRIMARY KEY (`nombre_servicio`),
  CONSTRAINT `chk_servicio_capacidad` CHECK (((`capacidad_maxima` is null) or (`capacidad_maxima` > 0))),
  CONSTRAINT `chk_servicio_precio` CHECK ((`precio` > 0)),
  CONSTRAINT `chk_servicio_tipo` CHECK ((`tipo_servicio` in (_utf8mb4'Actividad',_utf8mb4'Combo')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servicio`
--

LOCK TABLES `servicio` WRITE;
/*!40000 ALTER TABLE `servicio` DISABLE KEYS */;
INSERT INTO `servicio` VALUES ('Combo Planetario y Observatorio','Combo',75.00,NULL),('Observatorio','Actividad',50.00,20),('Planetario','Actividad',35.00,30);
/*!40000 ALTER TABLE `servicio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `telefono_cliente`
--

DROP TABLE IF EXISTS `telefono_cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `telefono_cliente` (
  `numero_documento_identidad` varchar(20) NOT NULL,
  `telefono` varchar(16) NOT NULL,
  PRIMARY KEY (`numero_documento_identidad`,`telefono`),
  CONSTRAINT `fk_telefono_cliente` FOREIGN KEY (`numero_documento_identidad`) REFERENCES `cliente` (`numero_documento_identidad`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_telefono_formato` CHECK (regexp_like(`telefono`,_utf8mb4'^\\+?[0-9]{7,15}$'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `telefono_cliente`
--

LOCK TABLES `telefono_cliente` WRITE;
/*!40000 ALTER TABLE `telefono_cliente` DISABLE KEYS */;
INSERT INTO `telefono_cliente` VALUES ('45159364','900000002'),('70492618','900000011'),('70845129','900000005'),('71582640','900000008'),('72518463','900000003'),('73461920','900000006'),('74268319','900000009'),('74859632','900000001'),('75613824','900000012'),('76392015','900000004'),('76920315','900000007'),('78315420','900000010');
/*!40000 ALTER TABLE `telefono_cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `turno`
--

DROP TABLE IF EXISTS `turno`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `turno` (
  `nombre_servicio` varchar(100) NOT NULL,
  `fecha` date NOT NULL,
  `horario` time NOT NULL,
  PRIMARY KEY (`nombre_servicio`,`fecha`,`horario`),
  KEY `idx_turno_fecha` (`fecha`),
  CONSTRAINT `fk_turno_servicio` FOREIGN KEY (`nombre_servicio`) REFERENCES `servicio` (`nombre_servicio`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `turno`
--

LOCK TABLES `turno` WRITE;
/*!40000 ALTER TABLE `turno` DISABLE KEYS */;
INSERT INTO `turno` VALUES ('Combo Planetario y Observatorio','2026-11-03','18:00:00'),('Observatorio','2026-11-03','19:00:00'),('Planetario','2026-11-03','17:00:00'),('Observatorio','2026-11-04','19:00:00'),('Planetario','2026-11-04','17:00:00'),('Combo Planetario y Observatorio','2026-11-05','18:00:00'),('Observatorio','2026-11-05','19:00:00'),('Observatorio','2026-11-06','19:00:00'),('Planetario','2026-11-06','17:00:00'),('Observatorio','2026-11-07','19:00:00'),('Planetario','2026-11-07','17:00:00'),('Observatorio','2026-11-08','19:00:00'),('Planetario','2026-11-08','17:00:00');
/*!40000 ALTER TABLE `turno` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-18 22:11:25


-- ===== 2) BORRADO LOGICO, TRIGGERS Y PROCEDIMIENTOS =====
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


-- ===== 3) DATOS DE PRUEBA AMPLIADOS =====
-- =====================================================================
-- Stellarium Observatorio y Planetario - Entrega 05
-- Datos de prueba ampliados (se SUMAN a los datos ya existentes).
-- Ejecutar DESPUES de stellarium_procedimientos.sql (los triggers validan
-- cada reserva insertada).
-- =====================================================================
USE stellarium_db;

-- Clientes nuevos
INSERT INTO cliente (numero_documento_identidad, tipo_documento, nombre, apellido_paterno, apellido_materno) VALUES
  ('47994000', 'DNI Peruano', 'Jorge Luis', 'Condori', 'Mamani'),
  ('61440241', 'DNI Peruano', 'Rosa Maria', 'Apaza', 'Quispe'),
  ('73723261', 'DNI Peruano', 'Pedro Pablo', 'Choque', 'Flores'),
  ('74347840', 'DNI Peruano', 'Carmen Rosa', 'Cutipa', 'Rodriguez'),
  ('46887842', 'DNI Peruano', 'Raul Antonio', 'Huanca', 'Chambi'),
  ('54984372', 'DNI Peruano', 'Gabriela', 'Valdivia', 'Ticona'),
  ('77350043', 'DNI Peruano', 'Sebastian', 'Zegarra', 'Alarcon'),
  ('68226991', 'DNI Peruano', 'Mariana', 'Cervantes', 'Nina'),
  ('78424442', 'DNI Peruano', 'Jhon Edwar', 'Medina', 'Yucra'),
  ('76763004', 'DNI Peruano', 'Karen Liliana', 'Salazar', 'Paucar'),
  ('72944036', 'DNI Peruano', 'Oscar David', 'Bustamante', 'Sanchez'),
  ('69601384', 'DNI Peruano', 'Fiorella', 'Delgado', 'Cruz'),
  ('56101703', 'DNI Peruano', 'Renzo', 'Ccama', 'Mollo'),
  ('40170110', 'DNI Peruano', 'Camila Andrea', 'Gutierrez', 'Aguilar'),
  ('45417273', 'DNI Peruano', 'Victor Hugo', 'Pinto', 'Zeballos'),
  ('47431403', 'DNI Peruano', 'Daniela Estefany', 'Villanueva', 'Tapia'),
  ('59276364', 'DNI Peruano', 'Edgar', 'Linares', 'Rivera'),
  ('46580132', 'DNI Peruano', 'Milagros', 'Cabrera', 'Coaquira'),
  ('70175825', 'DNI Peruano', 'Brayan', 'Lazo', 'Vilca'),
  ('40771002', 'DNI Peruano', 'Yessenia', 'Ponce', 'Poma'),
  ('72902585', 'DNI Peruano', 'Alonso', 'Arenas', 'Soto'),
  ('61087828', 'DNI Peruano', 'Lizbeth', 'Benavides', 'Luque'),
  ('C84521963', 'Pasaporte', 'Emma', 'Johnson', 'Brown'),
  ('AAF234891', 'Pasaporte', 'Mateo', 'Gimenez', 'Ruiz'),
  ('FR8845210', 'Pasaporte', 'Camille', 'Laurent', NULL),
  ('NL5521047', 'Pasaporte', 'Daan', 'De Vries', NULL),
  ('CE004478215', 'Carné de Extranjería', 'Andrea', 'Rondon', 'Perez'),
  ('CE002936184', 'Carné de Extranjería', 'Jose Gregorio', 'Salazar', 'Mejias');

-- Telefonos (algunos clientes con dos numeros)
INSERT INTO telefono_cliente (numero_documento_identidad, telefono) VALUES
  ('47994000', '936455681'),
  ('61440241', '951884472'),
  ('73723261', '994055761'),
  ('74347840', '969871689'),
  ('46887842', '976846978'),
  ('54984372', '980932081'),
  ('77350043', '996727317'),
  ('68226991', '978486488'),
  ('78424442', '976634400'),
  ('76763004', '929787534'),
  ('72944036', '977876804'),
  ('69601384', '957178472'),
  ('56101703', '967147513'),
  ('40170110', '962701079'),
  ('45417273', '981933190'),
  ('47431403', '984520599'),
  ('59276364', '972837929'),
  ('46580132', '984162294'),
  ('70175825', '986628360'),
  ('40771002', '916105500'),
  ('72902585', '987547517'),
  ('61087828', '979922983'),
  ('C84521963', '+695793186032'),
  ('FR8845210', '+080737028382'),
  ('47994000', '922646861'),
  ('54984372', '964252477'),
  ('69601384', '964725877'),
  ('74859632', '918841330'),
  ('45159364', '917568205');

-- Turnos: 10 al 22 de noviembre de 2026 (martes a domingo; los lunes no se atiende)
INSERT INTO turno (nombre_servicio, fecha, horario) VALUES
  ('Planetario', '2026-11-10', '17:00:00'),
  ('Combo Planetario y Observatorio', '2026-11-10', '18:00:00'),
  ('Observatorio', '2026-11-10', '19:00:00'),
  ('Planetario', '2026-11-11', '17:00:00'),
  ('Combo Planetario y Observatorio', '2026-11-11', '18:00:00'),
  ('Observatorio', '2026-11-11', '19:00:00'),
  ('Planetario', '2026-11-12', '17:00:00'),
  ('Combo Planetario y Observatorio', '2026-11-12', '18:00:00'),
  ('Observatorio', '2026-11-12', '19:00:00'),
  ('Planetario', '2026-11-13', '17:00:00'),
  ('Combo Planetario y Observatorio', '2026-11-13', '18:00:00'),
  ('Observatorio', '2026-11-13', '19:00:00'),
  ('Planetario', '2026-11-14', '17:00:00'),
  ('Combo Planetario y Observatorio', '2026-11-14', '18:00:00'),
  ('Observatorio', '2026-11-14', '19:00:00'),
  ('Planetario', '2026-11-15', '17:00:00'),
  ('Combo Planetario y Observatorio', '2026-11-15', '18:00:00'),
  ('Observatorio', '2026-11-15', '19:00:00'),
  ('Planetario', '2026-11-17', '17:00:00'),
  ('Combo Planetario y Observatorio', '2026-11-17', '18:00:00'),
  ('Observatorio', '2026-11-17', '19:00:00'),
  ('Planetario', '2026-11-18', '17:00:00'),
  ('Combo Planetario y Observatorio', '2026-11-18', '18:00:00'),
  ('Observatorio', '2026-11-18', '19:00:00'),
  ('Planetario', '2026-11-19', '17:00:00'),
  ('Combo Planetario y Observatorio', '2026-11-19', '18:00:00'),
  ('Observatorio', '2026-11-19', '19:00:00'),
  ('Planetario', '2026-11-20', '17:00:00'),
  ('Combo Planetario y Observatorio', '2026-11-20', '18:00:00'),
  ('Observatorio', '2026-11-20', '19:00:00'),
  ('Planetario', '2026-11-21', '17:00:00'),
  ('Combo Planetario y Observatorio', '2026-11-21', '18:00:00'),
  ('Observatorio', '2026-11-21', '19:00:00'),
  ('Planetario', '2026-11-22', '17:00:00'),
  ('Combo Planetario y Observatorio', '2026-11-22', '18:00:00'),
  ('Observatorio', '2026-11-22', '19:00:00');

-- Grupos
INSERT INTO grupo (nombre_servicio, fecha, horario, identificador_grupo) VALUES
  ('Planetario', '2026-11-10', '17:00:00', 'G01'),
  ('Observatorio', '2026-11-10', '19:00:00', 'G01'),
  ('Combo Planetario y Observatorio', '2026-11-11', '18:00:00', 'G01'),
  ('Observatorio', '2026-11-11', '19:00:00', 'G01'),
  ('Planetario', '2026-11-12', '17:00:00', 'G01'),
  ('Combo Planetario y Observatorio', '2026-11-12', '18:00:00', 'G01'),
  ('Observatorio', '2026-11-12', '19:00:00', 'G01'),
  ('Planetario', '2026-11-13', '17:00:00', 'G01'),
  ('Combo Planetario y Observatorio', '2026-11-13', '18:00:00', 'G01'),
  ('Observatorio', '2026-11-13', '19:00:00', 'G01'),
  ('Planetario', '2026-11-14', '17:00:00', 'G01'),
  ('Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 'G01'),
  ('Observatorio', '2026-11-14', '19:00:00', 'G01'),
  ('Observatorio', '2026-11-14', '19:00:00', 'G02'),
  ('Planetario', '2026-11-15', '17:00:00', 'G01'),
  ('Combo Planetario y Observatorio', '2026-11-15', '18:00:00', 'G01'),
  ('Observatorio', '2026-11-15', '19:00:00', 'G01'),
  ('Planetario', '2026-11-17', '17:00:00', 'G01'),
  ('Planetario', '2026-11-18', '17:00:00', 'G01'),
  ('Combo Planetario y Observatorio', '2026-11-18', '18:00:00', 'G01'),
  ('Observatorio', '2026-11-18', '19:00:00', 'G01'),
  ('Planetario', '2026-11-19', '17:00:00', 'G01'),
  ('Observatorio', '2026-11-19', '19:00:00', 'G01'),
  ('Planetario', '2026-11-20', '17:00:00', 'G01'),
  ('Combo Planetario y Observatorio', '2026-11-20', '18:00:00', 'G01'),
  ('Observatorio', '2026-11-20', '19:00:00', 'G01'),
  ('Planetario', '2026-11-21', '17:00:00', 'G01'),
  ('Combo Planetario y Observatorio', '2026-11-21', '18:00:00', 'G01'),
  ('Observatorio', '2026-11-21', '19:00:00', 'G01'),
  ('Planetario', '2026-11-22', '17:00:00', 'G01'),
  ('Combo Planetario y Observatorio', '2026-11-22', '18:00:00', 'G01'),
  ('Observatorio', '2026-11-22', '19:00:00', 'G01');

-- Guias asignados a los grupos
INSERT INTO guia_grupo (nombre_servicio, fecha, horario, identificador_grupo, guia_asignado) VALUES
  ('Planetario', '2026-11-10', '17:00:00', 'G01', 'Guia Carlos'),
  ('Observatorio', '2026-11-10', '19:00:00', 'G01', 'Guia Gabriel'),
  ('Combo Planetario y Observatorio', '2026-11-11', '18:00:00', 'G01', 'Guia Beatriz'),
  ('Observatorio', '2026-11-11', '19:00:00', 'G01', 'Guia Eduardo'),
  ('Planetario', '2026-11-12', '17:00:00', 'G01', 'Guia Helena'),
  ('Combo Planetario y Observatorio', '2026-11-12', '18:00:00', 'G01', 'Guia Isabel'),
  ('Observatorio', '2026-11-12', '19:00:00', 'G01', 'Guia Alejandro'),
  ('Planetario', '2026-11-13', '17:00:00', 'G01', 'Guia Daniela'),
  ('Combo Planetario y Observatorio', '2026-11-13', '18:00:00', 'G01', 'Guia Jorge'),
  ('Observatorio', '2026-11-13', '19:00:00', 'G01', 'Guia Lucia'),
  ('Planetario', '2026-11-14', '17:00:00', 'G01', 'Guia Mateo'),
  ('Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 'G01', 'Guia Renata'),
  ('Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 'G01', 'Guia Diego'),
  ('Observatorio', '2026-11-14', '19:00:00', 'G01', 'Guia Valeria'),
  ('Observatorio', '2026-11-14', '19:00:00', 'G01', 'Guia Carlos'),
  ('Observatorio', '2026-11-14', '19:00:00', 'G02', 'Guia Gabriel'),
  ('Planetario', '2026-11-15', '17:00:00', 'G01', 'Guia Beatriz'),
  ('Combo Planetario y Observatorio', '2026-11-15', '18:00:00', 'G01', 'Guia Eduardo'),
  ('Observatorio', '2026-11-15', '19:00:00', 'G01', 'Guia Helena'),
  ('Planetario', '2026-11-17', '17:00:00', 'G01', 'Guia Isabel'),
  ('Planetario', '2026-11-18', '17:00:00', 'G01', 'Guia Alejandro'),
  ('Combo Planetario y Observatorio', '2026-11-18', '18:00:00', 'G01', 'Guia Daniela'),
  ('Observatorio', '2026-11-18', '19:00:00', 'G01', 'Guia Jorge'),
  ('Planetario', '2026-11-19', '17:00:00', 'G01', 'Guia Lucia'),
  ('Observatorio', '2026-11-19', '19:00:00', 'G01', 'Guia Mateo'),
  ('Planetario', '2026-11-20', '17:00:00', 'G01', 'Guia Renata'),
  ('Combo Planetario y Observatorio', '2026-11-20', '18:00:00', 'G01', 'Guia Diego'),
  ('Observatorio', '2026-11-20', '19:00:00', 'G01', 'Guia Valeria'),
  ('Planetario', '2026-11-21', '17:00:00', 'G01', 'Guia Carlos'),
  ('Planetario', '2026-11-21', '17:00:00', 'G01', 'Guia Gabriel'),
  ('Combo Planetario y Observatorio', '2026-11-21', '18:00:00', 'G01', 'Guia Beatriz'),
  ('Observatorio', '2026-11-21', '19:00:00', 'G01', 'Guia Eduardo'),
  ('Planetario', '2026-11-22', '17:00:00', 'G01', 'Guia Helena'),
  ('Combo Planetario y Observatorio', '2026-11-22', '18:00:00', 'G01', 'Guia Isabel'),
  ('Observatorio', '2026-11-22', '19:00:00', 'G01', 'Guia Alejandro'),
  ('Observatorio', '2026-11-22', '19:00:00', 'G01', 'Guia Daniela');

-- Reservas R021 a R080 (6 pendientes de pago y 8 reprogramadas)
INSERT INTO reserva (numero_reserva, numero_documento_identidad, servicio_programado, fecha_programada, horario_programado, servicio_reprogramado, fecha_reprogramada, horario_reprogramado, servicio_grupo, fecha_grupo, horario_grupo, identificador_grupo, cantidad_personas, canal_origen, medio_pago, estado_pago, monto_pagado) VALUES
  ('R021', '61087828', 'Combo Planetario y Observatorio', '2026-11-14', '18:00:00', NULL, NULL, NULL, 'Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 'G01', 3, 'Viator', 'Tarjeta', 'Pagado', 225),
  ('R022', 'CE002936184', 'Planetario', '2026-11-21', '17:00:00', NULL, NULL, NULL, 'Planetario', '2026-11-21', '17:00:00', 'G01', 2, 'WhatsApp', 'Yape', 'Pagado', 70),
  ('R023', '56101703', 'Combo Planetario y Observatorio', '2026-11-11', '18:00:00', NULL, NULL, NULL, 'Combo Planetario y Observatorio', '2026-11-11', '18:00:00', 'G01', 2, 'Cuponidad', 'Tarjeta', 'Pagado', 150),
  ('R024', '78315420', 'Planetario', '2026-11-17', '17:00:00', NULL, NULL, NULL, 'Planetario', '2026-11-17', '17:00:00', 'G01', 3, 'WhatsApp', 'Yape', 'Pagado', 105),
  ('R025', 'C84521963', 'Combo Planetario y Observatorio', '2026-11-22', '18:00:00', NULL, NULL, NULL, 'Combo Planetario y Observatorio', '2026-11-22', '18:00:00', 'G01', 4, 'Oficina', 'Efectivo', 'Pagado', 300),
  ('R026', '61440241', 'Planetario', '2026-11-15', '17:00:00', NULL, NULL, NULL, 'Planetario', '2026-11-15', '17:00:00', 'G01', 2, 'WhatsApp', 'Yape', 'Pagado', 70),
  ('R027', '69601384', 'Combo Planetario y Observatorio', '2026-11-12', '18:00:00', NULL, NULL, NULL, 'Combo Planetario y Observatorio', '2026-11-12', '18:00:00', 'G01', 6, 'WhatsApp', 'Yape', 'Pagado', 450),
  ('R028', '46887842', 'Observatorio', '2026-11-19', '19:00:00', 'Observatorio', '2026-11-22', '19:00:00', 'Observatorio', '2026-11-22', '19:00:00', 'G01', 1, 'Cuponidad', 'Tarjeta', 'Pagado', 50),
  ('R029', '54984372', 'Planetario', '2026-11-20', '17:00:00', NULL, NULL, NULL, 'Planetario', '2026-11-20', '17:00:00', 'G01', 4, 'Airbnb', 'Transferencia', 'Pagado', 140),
  ('R030', '70845129', 'Observatorio', '2026-11-19', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-19', '19:00:00', 'G01', 5, 'Oficina', 'Tarjeta', 'Pagado', 250),
  ('R031', '45417273', 'Planetario', '2026-11-22', '17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, 'Cuponidad', NULL, 'Pendiente', 0.00),
  ('R032', '78424442', 'Observatorio', '2026-11-22', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-22', '19:00:00', 'G01', 4, 'Cuponidad', 'Tarjeta', 'Pagado', 200),
  ('R033', '76763004', 'Combo Planetario y Observatorio', '2026-11-11', '18:00:00', NULL, NULL, NULL, 'Combo Planetario y Observatorio', '2026-11-11', '18:00:00', 'G01', 2, 'Oficina', 'Tarjeta', 'Pagado', 150),
  ('R034', '70492618', 'Combo Planetario y Observatorio', '2026-11-14', '18:00:00', NULL, NULL, NULL, 'Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 'G01', 2, 'Oficina', 'Efectivo', 'Pagado', 150),
  ('R035', '46887842', 'Planetario', '2026-11-20', '17:00:00', 'Planetario', '2026-11-21', '17:00:00', 'Planetario', '2026-11-21', '17:00:00', 'G01', 4, 'Oficina', 'Tarjeta', 'Pagado', 140),
  ('R036', '77350043', 'Observatorio', '2026-11-20', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-20', '19:00:00', 'G01', 2, 'WhatsApp', 'Yape', 'Pagado', 100),
  ('R037', '76920315', 'Observatorio', '2026-11-10', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-10', '19:00:00', 'G01', 3, 'WhatsApp', 'Yape', 'Pagado', 150),
  ('R038', 'AAF234891', 'Combo Planetario y Observatorio', '2026-11-14', '18:00:00', NULL, NULL, NULL, 'Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 'G01', 3, 'Airbnb', 'Tarjeta', 'Pagado', 225),
  ('R039', 'C84521963', 'Planetario', '2026-11-17', '17:00:00', 'Planetario', '2026-11-21', '17:00:00', 'Planetario', '2026-11-21', '17:00:00', 'G01', 1, 'Oficina', 'Efectivo', 'Pagado', 35),
  ('R040', '69601384', 'Planetario', '2026-11-13', '17:00:00', NULL, NULL, NULL, 'Planetario', '2026-11-13', '17:00:00', 'G01', 3, 'Cuponidad', 'Yape', 'Pagado', 105),
  ('R041', '70492618', 'Combo Planetario y Observatorio', '2026-11-20', '18:00:00', NULL, NULL, NULL, 'Combo Planetario y Observatorio', '2026-11-20', '18:00:00', 'G01', 3, 'Viator', 'Tarjeta', 'Pagado', 225),
  ('R042', '61440241', 'Observatorio', '2026-11-10', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-10', '19:00:00', 'G01', 4, 'WhatsApp', 'Yape', 'Pagado', 200),
  ('R043', '40771002', 'Observatorio', '2026-11-22', '19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, 'WhatsApp', NULL, 'Pendiente', 0.00),
  ('R044', '75613824', 'Planetario', '2026-11-12', '17:00:00', NULL, NULL, NULL, 'Planetario', '2026-11-12', '17:00:00', 'G01', 5, 'Airbnb', 'Tarjeta', 'Pagado', 175),
  ('R045', '72902585', 'Observatorio', '2026-11-21', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-21', '19:00:00', 'G01', 1, 'Viator', 'Tarjeta', 'Pagado', 50),
  ('R046', 'NL5521047', 'Combo Planetario y Observatorio', '2026-11-14', '18:00:00', NULL, NULL, NULL, 'Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 'G01', 2, 'Cuponidad', 'Yape', 'Pagado', 150),
  ('R047', '45159364', 'Observatorio', '2026-11-15', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-15', '19:00:00', 'G01', 3, 'WhatsApp', 'Yape', 'Pagado', 150),
  ('R048', '46580132', 'Planetario', '2026-11-22', '17:00:00', NULL, NULL, NULL, 'Planetario', '2026-11-22', '17:00:00', 'G01', 4, 'Cuponidad', 'Tarjeta', 'Pagado', 140),
  ('R049', '78424442', 'Combo Planetario y Observatorio', '2026-11-18', '18:00:00', NULL, NULL, NULL, 'Combo Planetario y Observatorio', '2026-11-18', '18:00:00', 'G01', 6, 'WhatsApp', 'Yape', 'Pagado', 450),
  ('R050', '77350043', 'Observatorio', '2026-11-14', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-14', '19:00:00', 'G01', 4, 'Oficina', 'Tarjeta', 'Pagado', 200),
  ('R051', '72902585', 'Observatorio', '2026-11-18', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-18', '19:00:00', 'G01', 4, 'Cuponidad', 'Transferencia', 'Pagado', 200),
  ('R052', '76920315', 'Observatorio', '2026-11-15', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-15', '19:00:00', 'G01', 3, 'WhatsApp', 'Yape', 'Pagado', 150),
  ('R053', '68226991', 'Observatorio', '2026-11-20', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-20', '19:00:00', 'G01', 4, 'Viator', 'Tarjeta', 'Pagado', 200),
  ('R054', 'NL5521047', 'Observatorio', '2026-11-14', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-14', '19:00:00', 'G01', 2, 'Oficina', 'Efectivo', 'Pagado', 100),
  ('R055', '75613824', 'Observatorio', '2026-11-22', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-22', '19:00:00', 'G01', 3, 'WhatsApp', 'Yape', 'Pagado', 150),
  ('R056', '40771002', 'Observatorio', '2026-11-18', '19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, 'Cuponidad', NULL, 'Pendiente', 0.00),
  ('R057', '61087828', 'Planetario', '2026-11-15', '17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 'Oficina', NULL, 'Pendiente', 0.00),
  ('R058', '70175825', 'Planetario', '2026-11-13', '17:00:00', NULL, NULL, NULL, 'Planetario', '2026-11-13', '17:00:00', 'G01', 4, 'Airbnb', 'Transferencia', 'Pagado', 140),
  ('R059', '74268319', 'Planetario', '2026-11-17', '17:00:00', 'Planetario', '2026-11-20', '17:00:00', 'Planetario', '2026-11-20', '17:00:00', 'G01', 1, 'Cuponidad', 'Yape', 'Pagado', 35),
  ('R060', '61440241', 'Planetario', '2026-11-20', '17:00:00', 'Planetario', '2026-11-21', '17:00:00', 'Planetario', '2026-11-21', '17:00:00', 'G01', 2, 'Cuponidad', 'Transferencia', 'Pagado', 70),
  ('R061', '74347840', 'Observatorio', '2026-11-14', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-14', '19:00:00', 'G01', 2, 'Oficina', 'Tarjeta', 'Pagado', 100),
  ('R062', 'K52874196', 'Planetario', '2026-11-10', '17:00:00', NULL, NULL, NULL, 'Planetario', '2026-11-10', '17:00:00', 'G01', 6, 'Airbnb', 'Transferencia', 'Pagado', 210),
  ('R063', 'CE004478215', 'Observatorio', '2026-11-14', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-14', '19:00:00', 'G01', 2, 'Oficina', 'Tarjeta', 'Pagado', 100),
  ('R064', '76920315', 'Combo Planetario y Observatorio', '2026-11-13', '18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 3, 'WhatsApp', NULL, 'Pendiente', 0.00),
  ('R065', '40771002', 'Observatorio', '2026-11-11', '19:00:00', 'Observatorio', '2026-11-21', '19:00:00', 'Observatorio', '2026-11-21', '19:00:00', 'G01', 1, 'WhatsApp', 'Yape', 'Pagado', 50),
  ('R066', '78424442', 'Observatorio', '2026-11-13', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-13', '19:00:00', 'G01', 1, 'Oficina', 'Efectivo', 'Pagado', 50),
  ('R067', 'AAF234891', 'Observatorio', '2026-11-12', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-12', '19:00:00', 'G01', 3, 'WhatsApp', 'Yape', 'Pagado', 150),
  ('R068', '59276364', 'Observatorio', '2026-11-11', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-11', '19:00:00', 'G01', 1, 'Cuponidad', 'Tarjeta', 'Pagado', 50),
  ('R069', 'FR8845210', 'Observatorio', '2026-11-14', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-14', '19:00:00', 'G02', 2, 'WhatsApp', 'Transferencia', 'Pagado', 100),
  ('R070', '74859632', 'Observatorio', '2026-11-21', '19:00:00', NULL, NULL, NULL, 'Observatorio', '2026-11-21', '19:00:00', 'G01', 2, 'WhatsApp', 'Transferencia', 'Pagado', 100),
  ('R071', 'C84521963', 'Planetario', '2026-11-11', '17:00:00', 'Planetario', '2026-11-20', '17:00:00', 'Planetario', '2026-11-20', '17:00:00', 'G01', 2, 'WhatsApp', 'Yape', 'Pagado', 70),
  ('R072', '61440241', 'Combo Planetario y Observatorio', '2026-11-13', '18:00:00', NULL, NULL, NULL, 'Combo Planetario y Observatorio', '2026-11-13', '18:00:00', 'G01', 4, 'WhatsApp', 'Transferencia', 'Pagado', 300),
  ('R073', '46580132', 'Planetario', '2026-11-22', '17:00:00', NULL, NULL, NULL, 'Planetario', '2026-11-22', '17:00:00', 'G01', 2, 'Oficina', 'Tarjeta', 'Pagado', 70),
  ('R074', '72944036', 'Combo Planetario y Observatorio', '2026-11-21', '18:00:00', NULL, NULL, NULL, 'Combo Planetario y Observatorio', '2026-11-21', '18:00:00', 'G01', 2, 'WhatsApp', 'Yape', 'Pagado', 150),
  ('R075', '68226991', 'Planetario', '2026-11-15', '17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 4, 'Oficina', NULL, 'Pendiente', 0.00),
  ('R076', 'C84521963', 'Combo Planetario y Observatorio', '2026-11-15', '18:00:00', NULL, NULL, NULL, 'Combo Planetario y Observatorio', '2026-11-15', '18:00:00', 'G01', 2, 'WhatsApp', 'Yape', 'Pagado', 150),
  ('R077', '56101703', 'Planetario', '2026-11-15', '17:00:00', 'Planetario', '2026-11-19', '17:00:00', 'Planetario', '2026-11-19', '17:00:00', 'G01', 2, 'WhatsApp', 'Transferencia', 'Pagado', 70),
  ('R078', '61440241', 'Planetario', '2026-11-14', '17:00:00', NULL, NULL, NULL, 'Planetario', '2026-11-14', '17:00:00', 'G01', 1, 'Airbnb', 'Tarjeta', 'Pagado', 35),
  ('R079', '76392015', 'Planetario', '2026-11-14', '17:00:00', NULL, NULL, NULL, 'Planetario', '2026-11-14', '17:00:00', 'G01', 2, 'WhatsApp', 'Transferencia', 'Pagado', 70),
  ('R080', 'NL5521047', 'Planetario', '2026-11-18', '17:00:00', NULL, NULL, NULL, 'Planetario', '2026-11-18', '17:00:00', 'G01', 2, 'WhatsApp', 'Yape', 'Pagado', 70);

-- Espacios ocupados por las reservas
INSERT INTO espacio (nombre_servicio, fecha, horario, numero_espacio, numero_reserva) VALUES
  ('Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 1, 'R021'),
  ('Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 2, 'R021'),
  ('Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 3, 'R021'),
  ('Planetario', '2026-11-21', '17:00:00', 1, 'R022'),
  ('Planetario', '2026-11-21', '17:00:00', 2, 'R022'),
  ('Combo Planetario y Observatorio', '2026-11-11', '18:00:00', 1, 'R023'),
  ('Combo Planetario y Observatorio', '2026-11-11', '18:00:00', 2, 'R023'),
  ('Planetario', '2026-11-17', '17:00:00', 1, 'R024'),
  ('Planetario', '2026-11-17', '17:00:00', 2, 'R024'),
  ('Planetario', '2026-11-17', '17:00:00', 3, 'R024'),
  ('Combo Planetario y Observatorio', '2026-11-22', '18:00:00', 1, 'R025'),
  ('Combo Planetario y Observatorio', '2026-11-22', '18:00:00', 2, 'R025'),
  ('Combo Planetario y Observatorio', '2026-11-22', '18:00:00', 3, 'R025'),
  ('Combo Planetario y Observatorio', '2026-11-22', '18:00:00', 4, 'R025'),
  ('Planetario', '2026-11-15', '17:00:00', 1, 'R026'),
  ('Planetario', '2026-11-15', '17:00:00', 2, 'R026'),
  ('Combo Planetario y Observatorio', '2026-11-12', '18:00:00', 1, 'R027'),
  ('Combo Planetario y Observatorio', '2026-11-12', '18:00:00', 2, 'R027'),
  ('Combo Planetario y Observatorio', '2026-11-12', '18:00:00', 3, 'R027'),
  ('Combo Planetario y Observatorio', '2026-11-12', '18:00:00', 4, 'R027'),
  ('Combo Planetario y Observatorio', '2026-11-12', '18:00:00', 5, 'R027'),
  ('Combo Planetario y Observatorio', '2026-11-12', '18:00:00', 6, 'R027'),
  ('Observatorio', '2026-11-22', '19:00:00', 1, 'R028'),
  ('Planetario', '2026-11-20', '17:00:00', 1, 'R029'),
  ('Planetario', '2026-11-20', '17:00:00', 2, 'R029'),
  ('Planetario', '2026-11-20', '17:00:00', 3, 'R029'),
  ('Planetario', '2026-11-20', '17:00:00', 4, 'R029'),
  ('Observatorio', '2026-11-19', '19:00:00', 1, 'R030'),
  ('Observatorio', '2026-11-19', '19:00:00', 2, 'R030'),
  ('Observatorio', '2026-11-19', '19:00:00', 3, 'R030'),
  ('Observatorio', '2026-11-19', '19:00:00', 4, 'R030'),
  ('Observatorio', '2026-11-19', '19:00:00', 5, 'R030'),
  ('Observatorio', '2026-11-22', '19:00:00', 2, 'R032'),
  ('Observatorio', '2026-11-22', '19:00:00', 3, 'R032'),
  ('Observatorio', '2026-11-22', '19:00:00', 4, 'R032'),
  ('Observatorio', '2026-11-22', '19:00:00', 5, 'R032'),
  ('Combo Planetario y Observatorio', '2026-11-11', '18:00:00', 3, 'R033'),
  ('Combo Planetario y Observatorio', '2026-11-11', '18:00:00', 4, 'R033'),
  ('Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 4, 'R034'),
  ('Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 5, 'R034'),
  ('Planetario', '2026-11-21', '17:00:00', 3, 'R035'),
  ('Planetario', '2026-11-21', '17:00:00', 4, 'R035'),
  ('Planetario', '2026-11-21', '17:00:00', 5, 'R035'),
  ('Planetario', '2026-11-21', '17:00:00', 6, 'R035'),
  ('Observatorio', '2026-11-20', '19:00:00', 1, 'R036'),
  ('Observatorio', '2026-11-20', '19:00:00', 2, 'R036'),
  ('Observatorio', '2026-11-10', '19:00:00', 1, 'R037'),
  ('Observatorio', '2026-11-10', '19:00:00', 2, 'R037'),
  ('Observatorio', '2026-11-10', '19:00:00', 3, 'R037'),
  ('Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 6, 'R038'),
  ('Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 7, 'R038'),
  ('Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 8, 'R038'),
  ('Planetario', '2026-11-21', '17:00:00', 7, 'R039'),
  ('Planetario', '2026-11-13', '17:00:00', 1, 'R040'),
  ('Planetario', '2026-11-13', '17:00:00', 2, 'R040'),
  ('Planetario', '2026-11-13', '17:00:00', 3, 'R040'),
  ('Combo Planetario y Observatorio', '2026-11-20', '18:00:00', 1, 'R041'),
  ('Combo Planetario y Observatorio', '2026-11-20', '18:00:00', 2, 'R041'),
  ('Combo Planetario y Observatorio', '2026-11-20', '18:00:00', 3, 'R041'),
  ('Observatorio', '2026-11-10', '19:00:00', 4, 'R042'),
  ('Observatorio', '2026-11-10', '19:00:00', 5, 'R042'),
  ('Observatorio', '2026-11-10', '19:00:00', 6, 'R042'),
  ('Observatorio', '2026-11-10', '19:00:00', 7, 'R042'),
  ('Planetario', '2026-11-12', '17:00:00', 1, 'R044'),
  ('Planetario', '2026-11-12', '17:00:00', 2, 'R044'),
  ('Planetario', '2026-11-12', '17:00:00', 3, 'R044'),
  ('Planetario', '2026-11-12', '17:00:00', 4, 'R044'),
  ('Planetario', '2026-11-12', '17:00:00', 5, 'R044'),
  ('Observatorio', '2026-11-21', '19:00:00', 1, 'R045'),
  ('Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 9, 'R046'),
  ('Combo Planetario y Observatorio', '2026-11-14', '18:00:00', 10, 'R046'),
  ('Observatorio', '2026-11-15', '19:00:00', 1, 'R047'),
  ('Observatorio', '2026-11-15', '19:00:00', 2, 'R047'),
  ('Observatorio', '2026-11-15', '19:00:00', 3, 'R047'),
  ('Planetario', '2026-11-22', '17:00:00', 1, 'R048'),
  ('Planetario', '2026-11-22', '17:00:00', 2, 'R048'),
  ('Planetario', '2026-11-22', '17:00:00', 3, 'R048'),
  ('Planetario', '2026-11-22', '17:00:00', 4, 'R048'),
  ('Combo Planetario y Observatorio', '2026-11-18', '18:00:00', 1, 'R049'),
  ('Combo Planetario y Observatorio', '2026-11-18', '18:00:00', 2, 'R049'),
  ('Combo Planetario y Observatorio', '2026-11-18', '18:00:00', 3, 'R049'),
  ('Combo Planetario y Observatorio', '2026-11-18', '18:00:00', 4, 'R049'),
  ('Combo Planetario y Observatorio', '2026-11-18', '18:00:00', 5, 'R049'),
  ('Combo Planetario y Observatorio', '2026-11-18', '18:00:00', 6, 'R049'),
  ('Observatorio', '2026-11-14', '19:00:00', 1, 'R050'),
  ('Observatorio', '2026-11-14', '19:00:00', 2, 'R050'),
  ('Observatorio', '2026-11-14', '19:00:00', 3, 'R050'),
  ('Observatorio', '2026-11-14', '19:00:00', 4, 'R050'),
  ('Observatorio', '2026-11-18', '19:00:00', 1, 'R051'),
  ('Observatorio', '2026-11-18', '19:00:00', 2, 'R051'),
  ('Observatorio', '2026-11-18', '19:00:00', 3, 'R051'),
  ('Observatorio', '2026-11-18', '19:00:00', 4, 'R051'),
  ('Observatorio', '2026-11-15', '19:00:00', 4, 'R052'),
  ('Observatorio', '2026-11-15', '19:00:00', 5, 'R052'),
  ('Observatorio', '2026-11-15', '19:00:00', 6, 'R052'),
  ('Observatorio', '2026-11-20', '19:00:00', 3, 'R053'),
  ('Observatorio', '2026-11-20', '19:00:00', 4, 'R053'),
  ('Observatorio', '2026-11-20', '19:00:00', 5, 'R053'),
  ('Observatorio', '2026-11-20', '19:00:00', 6, 'R053'),
  ('Observatorio', '2026-11-14', '19:00:00', 5, 'R054'),
  ('Observatorio', '2026-11-14', '19:00:00', 6, 'R054'),
  ('Observatorio', '2026-11-22', '19:00:00', 6, 'R055'),
  ('Observatorio', '2026-11-22', '19:00:00', 7, 'R055'),
  ('Observatorio', '2026-11-22', '19:00:00', 8, 'R055'),
  ('Planetario', '2026-11-13', '17:00:00', 4, 'R058'),
  ('Planetario', '2026-11-13', '17:00:00', 5, 'R058'),
  ('Planetario', '2026-11-13', '17:00:00', 6, 'R058'),
  ('Planetario', '2026-11-13', '17:00:00', 7, 'R058'),
  ('Planetario', '2026-11-20', '17:00:00', 5, 'R059'),
  ('Planetario', '2026-11-21', '17:00:00', 8, 'R060'),
  ('Planetario', '2026-11-21', '17:00:00', 9, 'R060'),
  ('Observatorio', '2026-11-14', '19:00:00', 7, 'R061'),
  ('Observatorio', '2026-11-14', '19:00:00', 8, 'R061'),
  ('Planetario', '2026-11-10', '17:00:00', 1, 'R062'),
  ('Planetario', '2026-11-10', '17:00:00', 2, 'R062'),
  ('Planetario', '2026-11-10', '17:00:00', 3, 'R062'),
  ('Planetario', '2026-11-10', '17:00:00', 4, 'R062'),
  ('Planetario', '2026-11-10', '17:00:00', 5, 'R062'),
  ('Planetario', '2026-11-10', '17:00:00', 6, 'R062'),
  ('Observatorio', '2026-11-14', '19:00:00', 9, 'R063'),
  ('Observatorio', '2026-11-14', '19:00:00', 10, 'R063'),
  ('Observatorio', '2026-11-21', '19:00:00', 2, 'R065'),
  ('Observatorio', '2026-11-13', '19:00:00', 1, 'R066'),
  ('Observatorio', '2026-11-12', '19:00:00', 1, 'R067'),
  ('Observatorio', '2026-11-12', '19:00:00', 2, 'R067'),
  ('Observatorio', '2026-11-12', '19:00:00', 3, 'R067'),
  ('Observatorio', '2026-11-11', '19:00:00', 1, 'R068'),
  ('Observatorio', '2026-11-14', '19:00:00', 11, 'R069'),
  ('Observatorio', '2026-11-14', '19:00:00', 12, 'R069'),
  ('Observatorio', '2026-11-21', '19:00:00', 3, 'R070'),
  ('Observatorio', '2026-11-21', '19:00:00', 4, 'R070'),
  ('Planetario', '2026-11-20', '17:00:00', 6, 'R071'),
  ('Planetario', '2026-11-20', '17:00:00', 7, 'R071'),
  ('Combo Planetario y Observatorio', '2026-11-13', '18:00:00', 1, 'R072'),
  ('Combo Planetario y Observatorio', '2026-11-13', '18:00:00', 2, 'R072'),
  ('Combo Planetario y Observatorio', '2026-11-13', '18:00:00', 3, 'R072'),
  ('Combo Planetario y Observatorio', '2026-11-13', '18:00:00', 4, 'R072'),
  ('Planetario', '2026-11-22', '17:00:00', 5, 'R073'),
  ('Planetario', '2026-11-22', '17:00:00', 6, 'R073'),
  ('Combo Planetario y Observatorio', '2026-11-21', '18:00:00', 1, 'R074'),
  ('Combo Planetario y Observatorio', '2026-11-21', '18:00:00', 2, 'R074'),
  ('Combo Planetario y Observatorio', '2026-11-15', '18:00:00', 1, 'R076'),
  ('Combo Planetario y Observatorio', '2026-11-15', '18:00:00', 2, 'R076'),
  ('Planetario', '2026-11-19', '17:00:00', 1, 'R077'),
  ('Planetario', '2026-11-19', '17:00:00', 2, 'R077'),
  ('Planetario', '2026-11-14', '17:00:00', 1, 'R078'),
  ('Planetario', '2026-11-14', '17:00:00', 2, 'R079'),
  ('Planetario', '2026-11-14', '17:00:00', 3, 'R079'),
  ('Planetario', '2026-11-18', '17:00:00', 1, 'R080'),
  ('Planetario', '2026-11-18', '17:00:00', 2, 'R080');
