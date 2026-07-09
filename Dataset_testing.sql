/*
08/07/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

Descripcion: Script de carga de datos de testing (seed data) para ejecutar
operaciones sobre la base ParquesNacionales.

*/
SET NOCOUNT ON;

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
	EXECUTE PnSPabm.altaProvincia @nombre = 'Rio Negro';
	EXECUTE PnSPabm.altaProvincia @nombre = 'Santa Cruz';
	EXECUTE PnSPabm.altaProvincia @nombre = 'Buenos Aires';
	EXECUTE PnSPabm.altaProvincia @nombre = 'Misiones';
	EXECUTE PnSPabm.altaProvincia @nombre = 'Chubut';
	EXECUTE PnSPabm.altaProvincia @nombre = 'Neuquen';
	EXECUTE PnSPabm.altaProvincia @nombre = 'Cordoba';
	EXECUTE PnSPabm.altaProvincia @nombre = 'Chaco';
	EXECUTE PnSPabm.altaProvincia @nombre = 'Mendoza';
	EXECUTE PnSPabm.altaProvincia @nombre = 'Uruguay';
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
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Pochoclo', @ubicacion = 10, @Superficie = 1500, @tipo = 2;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Belgrano', @ubicacion = 8, @Superficie = 3500, @tipo = 1;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Nahuel Huapi', @ubicacion = 5, @Superficie = 7050, @tipo = 1;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Los Glaciares', @ubicacion = 2, @Superficie = 7269, @tipo = 1;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque El Palmar', @ubicacion = 3, @Superficie = 8500, @tipo = 2;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Lanin', @ubicacion = 6, @Superficie = 4127, @tipo = 1;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Los Alerces', @ubicacion = 5, @Superficie = 2630, @tipo = 1;
	EXECUTE PnSPabm.altaParque @nombre = 'Reserva Costanera Sur', @ubicacion = 3, @Superficie = 350, @tipo = 3;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Chaco', @ubicacion = 4, @Superficie = 1500, @tipo = 2;
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
	EXECUTE PnSPabm.altaTelefonoParque @numero = '4567-9981', @parque = 3;
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
ELSE
	PRINT '--No se pudo cargar datos en tabla Dia--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
--HorarioParque
IF
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.altaHorario'))
BEGIN
	EXECUTE PnSPtrans.altaHorario @parque = 1, @dia = 1, @hapertura = '10:30', @hcierre = '17:00', @temporada = 'Invierno';
	EXECUTE PnSPtrans.altaHorario @parque = 1, @dia = 2, @hapertura = '09:00', @hcierre = '15:00', @temporada = 'Verano';
	EXECUTE PnSPtrans.altaHorario @parque = 1, @dia = 1, @hapertura = '09:00', @hcierre = '15:00', @temporada = 'Verano';
	EXECUTE PnSPtrans.altaHorario @parque = 2, @dia = 1, @hapertura = '09:00', @hcierre = '11:00', @temporada = 'Primavera';
	EXECUTE PnSPtrans.altaHorario @parque = 2, @dia = 2, @hapertura = '09:00', @hcierre = '11:00', @temporada = 'Primavera';
	EXECUTE PnSPtrans.altaHorario @parque = 2, @dia = 3, @hapertura = '09:00', @hcierre = '11:00', @temporada = 'Primavera';
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla HorarioParque--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
--TipoActividad
IF
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaTipoActividad'))
BEGIN
	EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Taller', @costo = 100;
	EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Caminata Guiada', @costo = 1000.50;
	EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Caminata Grupal sin Guia', @costo = 500;
	EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Avistaje de Aves', @costo = 800;
	EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Cabalgata', @costo = 1200;
	EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Kayak', @costo = 1500;
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla TipoActividad--';
GO

-------------------------------------------------------------------------------------
--Actividad
IF
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaActividad'))
BEGIN
	EXECUTE PnSPabm.altaActividad @nombre = 'Pesca en Rio Salado', @duracion = 360, @cupo = 10, @parque = 1, @tipo = 1;
	EXECUTE PnSPabm.altaActividad @nombre = 'Caminata por Bosque Salado', @duracion = 240, @cupo = 25, @parque = 1, @tipo = 2;
	EXECUTE PnSPabm.altaActividad @nombre = 'Caminata por Bosque Pochoclo', @duracion = 240, @cupo = 25, @parque = 2, @tipo = 2;
	EXECUTE PnSPabm.altaActividad @nombre = 'Taller de Fotografia', @duracion = 120, @cupo = 15, @parque = 1, @tipo = 1;
	EXECUTE PnSPabm.altaActividad @nombre = 'Avistaje Nocturno', @duracion = 180, @cupo = 12, @parque = 2, @tipo = 4;
	EXECUTE PnSPabm.altaActividad @nombre = 'Cabalgata al Cerro', @duracion = 300, @cupo = 8, @parque = 3, @tipo = 5;
	EXECUTE PnSPabm.altaActividad @nombre = 'Kayak en el Lago', @duracion = 150, @cupo = 6, @parque = 4, @tipo = 6;
	EXECUTE PnSPabm.altaActividad @nombre = 'Caminata Glaciares', @duracion = 300, @cupo = 20, @parque = 5, @tipo = 2;
	EXECUTE PnSPabm.altaActividad @nombre = 'Taller de Flora Nativa', @duracion = 90, @cupo = 30, @parque = 6, @tipo = 1;
	EXECUTE PnSPabm.altaActividad @nombre = 'Caminata Lanin', @duracion = 240, @cupo = 25, @parque = 7, @tipo = 2;
	EXECUTE PnSPabm.altaActividad @nombre = 'Trekking Los Alerces', @duracion = 360, @cupo = 15, @parque = 8, @tipo = 2;
	EXECUTE PnSPabm.altaActividad @nombre = 'Recorrida Costanera', @duracion = 90, @cupo = 40, @parque = 9, @tipo = 3;
	EXECUTE PnSPabm.altaActividad @nombre = 'Avistaje Aves Chaco', @duracion = 150, @cupo = 10, @parque = 10, @tipo = 4;
	EXECUTE PnSPabm.altaActividad @nombre = 'Pesca Deportiva Nahuel Huapi', @duracion = 300, @cupo = 8, @parque = 4, @tipo = 1;
	EXECUTE PnSPabm.altaActividad @nombre = 'Caminata Nocturna Iguazu', @duracion = 180, @cupo = 20, @parque = 1, @tipo = 2;
	EXECUTE PnSPabm.altaActividad @nombre = 'Kayak Glaciares', @duracion = 200, @cupo = 6, @parque = 5, @tipo = 6;
	EXECUTE PnSPabm.altaActividad @nombre = 'Taller de Reciclaje', @duracion = 60, @cupo = 30, @parque = 2, @tipo = 1;
	EXECUTE PnSPabm.altaActividad @nombre = 'Cabalgata Costanera', @duracion = 120, @cupo = 10, @parque = 9, @tipo = 5;
	EXECUTE PnSPabm.altaActividad @nombre = 'Caminata El Palmar', @duracion = 200, @cupo = 25, @parque = 6, @tipo = 2;
	EXECUTE PnSPabm.altaActividad @nombre = 'Avistaje Fauna Lanin', @duracion = 150, @cupo = 12, @parque = 7, @tipo = 4;
	EXECUTE PnSPabm.altaActividad @nombre = 'Taller Astronomico', @duracion = 120, @cupo = 20, @parque = 8, @tipo = 1;
	EXECUTE PnSPabm.altaActividad @nombre = 'Kayak Costanera Sur', @duracion = 90, @cupo = 6, @parque = 9, @tipo = 6;
	EXECUTE PnSPabm.altaActividad @nombre = 'Caminata Chaco', @duracion = 240, @cupo = 20, @parque = 10, @tipo = 2;
	EXECUTE PnSPabm.altaActividad @nombre = 'Pesca Los Alerces', @duracion = 300, @cupo = 10, @parque = 8, @tipo = 1;
	EXECUTE PnSPabm.altaActividad @nombre = 'Cabalgata Nahuel Huapi', @duracion = 240, @cupo = 8, @parque = 4, @tipo = 5;
	EXECUTE PnSPabm.altaActividad @nombre = 'Taller Fotografia Nocturna', @duracion = 120, @cupo = 15, @parque = 5, @tipo = 1;
	EXECUTE PnSPabm.altaActividad @nombre = 'Avistaje Aves Iguazu', @duracion = 150, @cupo = 12, @parque = 1, @tipo = 4;
	EXECUTE PnSPabm.altaActividad @nombre = 'Trekking Belgrano', @duracion = 300, @cupo = 20, @parque = 3, @tipo = 2;
	EXECUTE PnSPabm.altaActividad @nombre = 'Kayak Pochoclo', @duracion = 100, @cupo = 6, @parque = 2, @tipo = 6;
	EXECUTE PnSPabm.altaActividad @nombre = 'Caminata Grupal Chaco', @duracion = 200, @cupo = 25, @parque = 10, @tipo = 3;
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla Actividad--';
GO

-------------------------------------------------------------------------------------
--HorarioActividad
IF
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaHActividad'))
BEGIN
	EXECUTE PnSPabm.altaHActividad @actividad = 1, @fechaAct = '2026-12-29', @hInicio = '18:00';
	EXECUTE PnSPabm.altaHActividad @actividad = 1, @fechaAct = '2026-12-07', @hInicio = '10:00';
	EXECUTE PnSPabm.altaHActividad @actividad = 1, @fechaAct = '2026-12-07', @hInicio = '12:00';
	EXECUTE PnSPabm.altaHActividad @actividad = 2, @fechaAct = '2026-12-26', @hInicio = '17:00';
	EXECUTE PnSPabm.altaHActividad @actividad = 2, @fechaAct = '2026-12-26', @hInicio = '18:00';
	EXECUTE PnSPabm.altaHActividad @actividad = 2, @fechaAct = '2026-12-29', @hInicio = '17:00';
	EXECUTE PnSPabm.altaHActividad @actividad = 2, @fechaAct = '2026-12-29', @hInicio = '18:00'; --asociado a pago a traves tieneHActividad
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla HorarioActividad--';
GO

DECLARE @actCaminataSalado INT = (SELECT IDActividad FROM PnTablas.Actividad WHERE NombreActividad = 'Caminata por Bosque Salado')
DECLARE @actPesca INT = (SELECT IDActividad FROM PnTablas.Actividad WHERE NombreActividad = 'Pesca en Rio Salado')

IF (@actCaminataSalado IS NOT NULL) AND (@actPesca IS NOT NULL)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actCaminataSalado AND FechaActividad = '2026-08-15' AND HoraInicio = '18:00')
		EXECUTE PnSPabm.altaHActividad @actividad = @actCaminataSalado, @fechaAct = '2026-08-15', @hInicio = '18:00';

	IF NOT EXISTS (SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actCaminataSalado AND FechaActividad = '2026-08-15' AND HoraInicio = '17:00')
		EXECUTE PnSPabm.altaHActividad @actividad = @actCaminataSalado, @fechaAct = '2026-08-15', @hInicio = '17:00';

	IF NOT EXISTS (SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actCaminataSalado AND FechaActividad = '2026-09-01' AND HoraInicio = '17:00')
		EXECUTE PnSPabm.altaHActividad @actividad = @actCaminataSalado, @fechaAct = '2026-09-01', @hInicio = '17:00';

	IF NOT EXISTS (SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actPesca AND FechaActividad = '2026-08-15' AND HoraInicio = '17:00')
		EXECUTE PnSPabm.altaHActividad @actividad = @actPesca, @fechaAct = '2026-08-15', @hInicio = '17:00';
END
ELSE
	PRINT 'ERROR: No se encontraron las actividades necesarias para cargar los horarios forzados de testing.'
GO
