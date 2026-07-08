/*
-/-/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL
*/

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

PRINT '--Llenando tablas con datos para ejecutar operaciones de testing...--';
GO

--Se hace el llenado de tablas para testing
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----TipoParque
IF 
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TipoParque')
AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaTipoParque'))
BEGIN
	EXECUTE PnSPabm.altaTipoParque @tipo = 'Reserva';
	EXECUTE PnSPabm.altaTipoParque @tipo = 'Reserva Aviaria';
	EXECUTE PnSPabm.altaTipoParque @tipo = 'Centro Pescador';
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla TipoParque--';
GO

-------------------------------------------------------------------------------------
----Provincia
IF 
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Provincia')
AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaProvincia'))
BEGIN
	EXECUTE PnSPabm.altaProvincia @nombre = 'rio negro';
	EXECUTE PnSPabm.altaProvincia @nombre = 'Santa Cruz';
	EXECUTE PnSPabm.altaProvincia @nombre = 'Buenos Aires';
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla Provincia--';
GO

-------------------------------------------------------------------------------------
----Parque
IF 
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Parque')
AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaParque'))
BEGIN
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Iguazu', @ubicacion = 1, @Superficie = 2000, @tipo = 1;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Pochoclo', @ubicacion = 1, @Superficie = 1500, @tipo = 2;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Belgrano', @ubicacion = 2, @Superficie = 3500, @tipo = 1;
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla Parque--';
GO

-------------------------------------------------------------------------------------
----TelefonoParque
IF 
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TelefonoParque')
AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaTelefonoParque'))
BEGIN
	EXECUTE PnSPabm.altaTelefonoParque @numero = '4567-0345', @parque = 1;
	EXECUTE PnSPabm.altaTelefonoParque @numero = '4567-0352', @parque = 1;
	EXECUTE PnSPabm.altaTelefonoParque @numero = '345-0223', @parque = 2;
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla TelefonoParque--';
GO

-------------------------------------------------------------------------------------
----Dia
IF
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Dia')
AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaDias'))
BEGIN
	EXECUTE PnSPabm.altaDias
END;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
--HorarioParque
EXECUTE PnSPtrans.altaHorario
@parque = 1,
@dia = 1, 
@hapertura = '10:30',
@hcierre = '17:00',
@temporada = 'Invierno';
EXECUTE PnSPtrans.altaHorario
@parque = 1,
@dia = 2,
@hapertura = '09:00',
@hcierre = '15:00',
@temporada = 'Verano';
EXECUTE PnSPtrans.altaHorario
@parque = 1,
@dia = 1,
@hapertura = '09:00',
@hcierre = '15:00',
@temporada = 'Verano';
EXECUTE PnSPtrans.altaHorario
@parque = 2,
@dia = 1,
@hapertura = '09:00',
@hcierre = '11:00',
@temporada = 'Primavera';
GO
EXECUTE PnSPtrans.altaHorario
@parque = 2,
@dia = 2,
@hapertura = '09:00',
@hcierre = '11:00',
@temporada = 'Primavera';
GO
EXECUTE PnSPtrans.altaHorario
@parque = 2,
@dia = 3,
@hapertura = '09:00',
@hcierre = '11:00',
@temporada = 'Primavera';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
--TipoActividad
EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Taller', @costo = 100;
EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Caminata Guiada', @costo = 1000.50;
EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Caminata Grupal sin Guia', @costo = 500;
GO

-------------------------------------------------------------------------------------
--Actividad
EXECUTE PnSPabm.altaActividad 
@nombre = 'Pesca en Rio Salado', 
@duracion = 360, 
@cupo = 10, 
@parque = 1, 
@tipo = 1;
EXECUTE PnSPabm.altaActividad 
@nombre = 'Caminata por Bosque Salado', 
@duracion = 240, 
@cupo = 25, 
@parque = 1, 
@tipo = 2;
EXECUTE PnSPabm.altaActividad 
@nombre = 'Caminata por Bosque Pochoclo', 
@duracion = 240, 
@cupo = 25, 
@parque = 2, 
@tipo = 2;
GO

-------------------------------------------------------------------------------------
--HorarioActividad
--PnSPabm.altaHActividad (@actividad INT, @fechaAct DATE, @hInicio TIME)
EXECUTE PnSPabm.altaHActividad @actividad = 1, @fechaAct = '2026-12-29', @hInicio = '18:00';
EXECUTE PnSPabm.altaHActividad @actividad = 1, @fechaAct = '2026-12-07', @hInicio = '10:00';
EXECUTE PnSPabm.altaHActividad @actividad = 1, @fechaAct = '2026-12-07', @hInicio = '12:00';
EXECUTE PnSPabm.altaHActividad @actividad = 2, @fechaAct = '2026-12-26', @hInicio = '17:00';
EXECUTE PnSPabm.altaHActividad @actividad = 2, @fechaAct = '2026-12-26', @hInicio = '18:00';
EXECUTE PnSPabm.altaHActividad @actividad = 2, @fechaAct = '2026-12-29', @hInicio = '17:00';
EXECUTE PnSPabm.altaHActividad @actividad = 2, @fechaAct = '2026-12-29', @hInicio = '18:00';--asociado a pago a traves tieneHActividad
GO

--datos forzados para probar SPs
INSERT INTO PnTablas.HorarioActividad (Actividad, FechaActividad, HoraInicio)
VALUES
(2, '2025-12-29', '18:00'),
(2, '2025-12-29', '17:00'),
(2, '2025-12-15', '17:00'),
(1, '2025-12-29', '17:00');--asociado a pago a traves tieneHActividad
GO