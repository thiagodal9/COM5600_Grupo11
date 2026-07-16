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

IF OBJECT_ID('tempdb..#ventaEntradas') IS NULL
BEGIN
	CREATE TABLE #ventaEntradas
	(
		IDvEntrada INT IDENTITY(1, 1) PRIMARY KEY,
		Entrada INT,
		Cantidad INT,
		FechaAcceso DATE,
		ID INT
	)
END;
GO

IF OBJECT_ID('tempdb..#ventaActividades') IS NULL
BEGIN
	CREATE TABLE #ventaActividades
	(
		IDvActividad INT IDENTITY(1, 1) PRIMARY KEY,
		Actividad INT,
		FechaActividad DATE,
		HoraInicio TIME,
		Cantidad INT,
		ID INT
	)
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
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Iguazu', @ubicacion = 1, @latitud = '45.67', @longitud = '20.56', @Superficie = 2000, @tipo = 1;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Pochoclo', @ubicacion = 10, @latitud = '35.67', @longitud = '20.55',@Superficie = 1500, @tipo = 2;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Belgrano', @ubicacion = 8, @latitud = '26.77', @longitud = '45.78',@Superficie = 3500, @tipo = 1;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Nahuel Huapi', @ubicacion = 5, @latitud = '54.54', @longitud = '56.20',@Superficie = 7050, @tipo = 1;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Los Glaciares', @ubicacion = 2, @latitud = '25.87', @longitud = '31.35',@Superficie = 7269, @tipo = 1;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque El Palmar', @ubicacion = 3, @latitud = '55.55', @longitud = '51.52',@Superficie = 8500, @tipo = 2;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Lanin', @ubicacion = 6, @latitud = '44.22', @longitud = '20.16',@Superficie = 4127, @tipo = 1;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Los Alerces', @ubicacion = 5, @latitud = '34.85', @longitud = '23.34',@Superficie = 2630, @tipo = 1;
	EXECUTE PnSPabm.altaParque @nombre = 'Reserva Costanera Sur', @ubicacion = 3, @latitud = '56.41', @longitud = '35.64',@Superficie = 350, @tipo = 3;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Chaco', @ubicacion = 4, @latitud = '41.23', @longitud = '45.52',@Superficie = 1500, @tipo = 2;
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

-------------------------------------------------------------------------------------
----Persona / Guardaparque / Guia / Especialidad
IF
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Persona') AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaPersona'))
BEGIN
	--20 Guardaparques (Persona 1-20)
	EXECUTE PnSPabm.altaPersona @dni = 30100001, @nombre = 'Martin',     @apellido = 'Sosa',      @telefono = '11-5000-0001', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100002, @nombre = 'Lucia',      @apellido = 'Fernandez', @telefono = '11-5000-0002', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100003, @nombre = 'Diego',      @apellido = 'Alvarez',   @telefono = '11-5000-0003', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100004, @nombre = 'Sofia',      @apellido = 'Romero',    @telefono = '11-5000-0004', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100005, @nombre = 'Nicolas',    @apellido = 'Torres',    @telefono = '11-5000-0005', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100006, @nombre = 'Valentina',  @apellido = 'Castro',    @telefono = '11-5000-0006', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100007, @nombre = 'Franco',     @apellido = 'Molina',    @telefono = '11-5000-0007', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100008, @nombre = 'Camila',     @apellido = 'Ortiz',     @telefono = '11-5000-0008', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100009, @nombre = 'Ezequiel',   @apellido = 'Rios',      @telefono = '11-5000-0009', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100010, @nombre = 'Julieta',    @apellido = 'Medina',    @telefono = '11-5000-0010', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100011, @nombre = 'Ivan',       @apellido = 'Aguirre',   @telefono = '11-5000-0011', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100012, @nombre = 'Rocio',      @apellido = 'Herrera',   @telefono = '11-5000-0012', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100013, @nombre = 'Bruno',      @apellido = 'Acosta',    @telefono = '11-5000-0013', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100014, @nombre = 'Milagros',   @apellido = 'Suarez',    @telefono = '11-5000-0014', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100015, @nombre = 'Tomas',      @apellido = 'Benitez',   @telefono = '11-5000-0015', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100016, @nombre = 'Agostina',   @apellido = 'Paez',      @telefono = '11-5000-0016', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100017, @nombre = 'Federico',   @apellido = 'Nunez',     @telefono = '11-5000-0017', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100018, @nombre = 'Antonella',  @apellido = 'Vega',      @telefono = '11-5000-0018', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100019, @nombre = 'Gonzalo',    @apellido = 'Ibanez',    @telefono = '11-5000-0019', @rol = 'Guardaparque';
	EXECUTE PnSPabm.altaPersona @dni = 30100020, @nombre = 'Micaela',    @apellido = 'Flores',    @telefono = '11-5000-0020', @rol = 'Guardaparque';

	--20 Guias (Persona 21-40)
	EXECUTE PnSPabm.altaPersona @dni = 30200001, @nombre = 'Santiago',    @apellido = 'Cabrera',    @telefono = '11-5100-0001', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200002, @nombre = 'Florencia',   @apellido = 'Gimenez',    @telefono = '11-5100-0002', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200003, @nombre = 'Matias',      @apellido = 'Correa',     @telefono = '11-5100-0003', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200004, @nombre = 'Daniela',     @apellido = 'Peralta',    @telefono = '11-5100-0004', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200005, @nombre = 'Emiliano',    @apellido = 'Vargas',     @telefono = '11-5100-0005', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200006, @nombre = 'Carolina',    @apellido = 'Silva',      @telefono = '11-5100-0006', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200007, @nombre = 'Joaquin',     @apellido = 'Ramos',      @telefono = '11-5100-0007', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200008, @nombre = 'Yamila',      @apellido = 'Cardozo',    @telefono = '11-5100-0008', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200009, @nombre = 'Maximiliano', @apellido = 'Luna',       @telefono = '11-5100-0009', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200010, @nombre = 'Brenda',      @apellido = 'Godoy',      @telefono = '11-5100-0010', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200011, @nombre = 'Rodrigo',     @apellido = 'Chavez',     @telefono = '11-5100-0011', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200012, @nombre = 'Estefania',   @apellido = 'Duarte',     @telefono = '11-5100-0012', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200013, @nombre = 'Lautaro',     @apellido = 'Bravo',      @telefono = '11-5100-0013', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200014, @nombre = 'Abril',       @apellido = 'Sanchez',    @telefono = '11-5100-0014', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200015, @nombre = 'Ignacio',     @apellido = 'Farias',     @telefono = '11-5100-0015', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200016, @nombre = 'Ornella',     @apellido = 'Quiroga',    @telefono = '11-5100-0016', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200017, @nombre = 'Alan',        @apellido = 'Escobar',    @telefono = '11-5100-0017', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200018, @nombre = 'Guadalupe',   @apellido = 'Villa',      @telefono = '11-5100-0018', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200019, @nombre = 'Cristian',    @apellido = 'Maldonado',  @telefono = '11-5100-0019', @rol = 'Guia';
	EXECUTE PnSPabm.altaPersona @dni = 30200020, @nombre = 'Paula',       @apellido = 'Rojas',      @telefono = '11-5100-0020', @rol = 'Guia';
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla Persona--';
GO

--Alta de los 20 Guardaparques y asignacion, 2 por parque
IF
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaGuardaParque')) AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.asignarGuardaparque'))
BEGIN
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 1;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 2;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 3;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 4;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 5;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 6;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 7;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 8;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 9;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 10;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 11;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 12;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 13;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 14;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 15;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 16;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 17;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 18;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 19;
	EXECUTE PnSPabm.altaGuardaParque @IDPersona = 20;

	--2 guardaparques por parque (Parque 1..10)
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 1,  @Parque = 1;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 2,  @Parque = 1;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 3,  @Parque = 2;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 4,  @Parque = 2;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 5,  @Parque = 3;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 6,  @Parque = 3;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 7,  @Parque = 4;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 8,  @Parque = 4;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 9,  @Parque = 5;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 10, @Parque = 5;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 11, @Parque = 6;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 12, @Parque = 6;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 13, @Parque = 7;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 14, @Parque = 7;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 15, @Parque = 8;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 16, @Parque = 8;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 17, @Parque = 9;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 18, @Parque = 9;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 19, @Parque = 10;
	EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 20, @Parque = 10;
END;
ELSE
	PRINT '--No se pudo cargar/asignar datos en tabla Guardaparque--';
GO

--Alta de los 20 Guias
IF
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaGuia'))
BEGIN
	EXECUTE PnSPabm.altaGuia @idPersona = 21, @titulo = 'Guia Nacional de Turismo', @vencimientoHabilitacion = '2029-03-31', @numeroHabilitacion = 2001;
	EXECUTE PnSPabm.altaGuia @idPersona = 22, @titulo = 'Guia de Montania',         @vencimientoHabilitacion = '2029-06-30', @numeroHabilitacion = 2002;
	EXECUTE PnSPabm.altaGuia @idPersona = 23, @titulo = 'Licenciado en Turismo',    @vencimientoHabilitacion = '2030-01-15', @numeroHabilitacion = 2003;
	EXECUTE PnSPabm.altaGuia @idPersona = 24, @titulo = 'Guia de Trekking',         @vencimientoHabilitacion = '2028-11-30', @numeroHabilitacion = 2004;
	EXECUTE PnSPabm.altaGuia @idPersona = 25, @titulo = 'Guia Nacional de Turismo', @vencimientoHabilitacion = '2030-05-20', @numeroHabilitacion = 2005;
	EXECUTE PnSPabm.altaGuia @idPersona = 26, @titulo = 'Guia de Montania',         @vencimientoHabilitacion = '2029-09-10', @numeroHabilitacion = 2006;
	EXECUTE PnSPabm.altaGuia @idPersona = 27, @titulo = 'Licenciado en Turismo',    @vencimientoHabilitacion = '2028-08-01', @numeroHabilitacion = 2007;
	EXECUTE PnSPabm.altaGuia @idPersona = 28, @titulo = 'Guia de Trekking',         @vencimientoHabilitacion = '2030-02-28', @numeroHabilitacion = 2008;
	EXECUTE PnSPabm.altaGuia @idPersona = 29, @titulo = 'Guia Nacional de Turismo', @vencimientoHabilitacion = '2029-12-01', @numeroHabilitacion = 2009;
	EXECUTE PnSPabm.altaGuia @idPersona = 30, @titulo = 'Guia de Montania',         @vencimientoHabilitacion = '2028-07-15', @numeroHabilitacion = 2010;
	EXECUTE PnSPabm.altaGuia @idPersona = 31, @titulo = 'Licenciado en Turismo',    @vencimientoHabilitacion = '2030-10-10', @numeroHabilitacion = 2011;
	EXECUTE PnSPabm.altaGuia @idPersona = 32, @titulo = 'Guia de Trekking',         @vencimientoHabilitacion = '2029-04-04', @numeroHabilitacion = 2012;
	EXECUTE PnSPabm.altaGuia @idPersona = 33, @titulo = 'Guia Nacional de Turismo', @vencimientoHabilitacion = '2028-06-06', @numeroHabilitacion = 2013;
	EXECUTE PnSPabm.altaGuia @idPersona = 34, @titulo = 'Guia de Montania',         @vencimientoHabilitacion = '2030-03-03', @numeroHabilitacion = 2014;
	EXECUTE PnSPabm.altaGuia @idPersona = 35, @titulo = 'Licenciado en Turismo',    @vencimientoHabilitacion = '2029-08-08', @numeroHabilitacion = 2015;
	EXECUTE PnSPabm.altaGuia @idPersona = 36, @titulo = 'Guia de Trekking',         @vencimientoHabilitacion = '2028-09-09', @numeroHabilitacion = 2016;
	EXECUTE PnSPabm.altaGuia @idPersona = 37, @titulo = 'Guia Nacional de Turismo', @vencimientoHabilitacion = '2030-07-07', @numeroHabilitacion = 2017;
	EXECUTE PnSPabm.altaGuia @idPersona = 38, @titulo = 'Guia de Montania',         @vencimientoHabilitacion = '2029-01-01', @numeroHabilitacion = 2018;
	EXECUTE PnSPabm.altaGuia @idPersona = 39, @titulo = 'Licenciado en Turismo',    @vencimientoHabilitacion = '2028-12-12', @numeroHabilitacion = 2019;
	EXECUTE PnSPabm.altaGuia @idPersona = 40, @titulo = 'Guia de Trekking',         @vencimientoHabilitacion = '2030-11-11', @numeroHabilitacion = 2020;
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla Guia--';
GO

--Especialidades y asignacion a los 20 Guias
IF
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaEspecialidad')) AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.asignarEspecialidad'))
BEGIN
	EXECUTE PnSPabm.altaEspecialidad @descripcion = 'Flora Nativa';
	EXECUTE PnSPabm.altaEspecialidad @descripcion = 'Fauna Autoctona';
	EXECUTE PnSPabm.altaEspecialidad @descripcion = 'Montanismo';
	EXECUTE PnSPabm.altaEspecialidad @descripcion = 'Espeleologia';
	EXECUTE PnSPabm.altaEspecialidad @descripcion = 'Actividades Acuaticas';

	EXECUTE PnSPabm.asignarEspecialidad @guia = 21, @especialidad = 1;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 22, @especialidad = 2;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 23, @especialidad = 3;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 24, @especialidad = 4;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 25, @especialidad = 5;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 26, @especialidad = 1;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 27, @especialidad = 2;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 28, @especialidad = 3;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 29, @especialidad = 4;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 30, @especialidad = 5;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 31, @especialidad = 1;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 32, @especialidad = 2;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 33, @especialidad = 3;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 34, @especialidad = 4;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 35, @especialidad = 5;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 36, @especialidad = 1;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 37, @especialidad = 2;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 38, @especialidad = 3;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 39, @especialidad = 4;
	EXECUTE PnSPabm.asignarEspecialidad @guia = 40, @especialidad = 5;
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla Especialidad--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Empresa / Concesion / Facturas
IF
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Empresa') AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaEmpresa'))
BEGIN
	EXECUTE PnSPabm.altaEmpresa @nombre = 'EcoTurismo Sur SA',         @descripcion = 'Transporte y excursiones';
	EXECUTE PnSPabm.altaEmpresa @nombre = 'Sabores Patagonicos SRL',   @descripcion = 'Gastronomia regional';
	EXECUTE PnSPabm.altaEmpresa @nombre = 'Aventura Total SA',         @descripcion = 'Turismo aventura y trekking';
	EXECUTE PnSPabm.altaEmpresa @nombre = 'Rutas Nativas SRL',         @descripcion = 'Artesanias y souvenirs';
	EXECUTE PnSPabm.altaEmpresa @nombre = 'Concesionaria del Lago SA', @descripcion = 'Alojamiento y cabanias';
	EXECUTE PnSPabm.altaEmpresa @nombre = 'Turismo Andino SRL',        @descripcion = 'Excursiones guiadas';
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla Empresa--';
GO

--10 Concesiones, una por parque. 8 vigentes + 2 vencidas
IF
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Concesion') AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.altaConcesion'))
BEGIN
	DECLARE @hoy DATE = CAST(GETDATE() AS DATE)

	--se precalculan las fechas en variables (antes DATEADD(month,...) tiraba "Incorrect syntax")
	DECLARE @iniV1 DATE = DATEADD(mm, -6,  @hoy)
	DECLARE @finV1 DATE = DATEADD(mm, 6,   @hoy)
	DECLARE @iniV2 DATE = DATEADD(mm, -8,  @hoy)
	DECLARE @finV2 DATE = DATEADD(mm, 4,   @hoy)
	DECLARE @iniV3 DATE = DATEADD(mm, -3,  @hoy)
	DECLARE @finV3 DATE = DATEADD(mm, 9,   @hoy)
	DECLARE @iniV4 DATE = DATEADD(mm, -10, @hoy)
	DECLARE @finV4 DATE = DATEADD(mm, 2,   @hoy)
	DECLARE @iniV5 DATE = DATEADD(mm, -5,  @hoy)
	DECLARE @finV5 DATE = DATEADD(mm, 7,   @hoy)
	DECLARE @iniV6 DATE = DATEADD(mm, -2,  @hoy)
	DECLARE @finV6 DATE = DATEADD(mm, 10,  @hoy)
	DECLARE @iniV7 DATE = DATEADD(mm, -4,  @hoy)
	DECLARE @finV7 DATE = DATEADD(mm, 8,   @hoy)
	DECLARE @iniV8 DATE = DATEADD(mm, -7,  @hoy)
	DECLARE @finV8 DATE = DATEADD(mm, 5,   @hoy)
	DECLARE @iniVenc1 DATE = DATEADD(mm, -18, @hoy)
	DECLARE @finVenc1 DATE = DATEADD(mm, -6,  @hoy)
	DECLARE @iniVenc2 DATE = DATEADD(mm, -24, @hoy)
	DECLARE @finVenc2 DATE = DATEADD(mm, -1,  @hoy)

	--Vigentes (Concesion 1-8)
	EXECUTE PnSPtrans.altaConcesion @idEmpresa = 1, @idParque = 1,  @rubro = 'Transporte',  @fechaInicio = @iniV1, @fechaFin = @finV1, @precioAlquiler = 120000.00
	EXECUTE PnSPtrans.altaConcesion @idEmpresa = 2, @idParque = 2,  @rubro = 'Gastronomia', @fechaInicio = @iniV2, @fechaFin = @finV2, @precioAlquiler = 95000.00
	EXECUTE PnSPtrans.altaConcesion @idEmpresa = 3, @idParque = 3,  @rubro = 'Excursiones', @fechaInicio = @iniV3, @fechaFin = @finV3, @precioAlquiler = 180000.00
	EXECUTE PnSPtrans.altaConcesion @idEmpresa = 4, @idParque = 4,  @rubro = 'Souvenirs',   @fechaInicio = @iniV4, @fechaFin = @finV4, @precioAlquiler = 45000.00
	EXECUTE PnSPtrans.altaConcesion @idEmpresa = 5, @idParque = 5,  @rubro = 'Alojamiento', @fechaInicio = @iniV5, @fechaFin = @finV5, @precioAlquiler = 250000.00
	EXECUTE PnSPtrans.altaConcesion @idEmpresa = 6, @idParque = 6,  @rubro = 'Transporte',  @fechaInicio = @iniV6, @fechaFin = @finV6, @precioAlquiler = 110000.00
	EXECUTE PnSPtrans.altaConcesion @idEmpresa = 1, @idParque = 7,  @rubro = 'Gastronomia', @fechaInicio = @iniV7, @fechaFin = @finV7, @precioAlquiler = 98000.00
	EXECUTE PnSPtrans.altaConcesion @idEmpresa = 2, @idParque = 8,  @rubro = 'Excursiones', @fechaInicio = @iniV8, @fechaFin = @finV8, @precioAlquiler = 175000.00

	--Vencidas (Concesion 9-10)
	EXECUTE PnSPtrans.altaConcesion @idEmpresa = 3, @idParque = 9,  @rubro = 'Souvenirs',   @fechaInicio = @iniVenc1, @fechaFin = @finVenc1, @precioAlquiler = 40000.00
	EXECUTE PnSPtrans.altaConcesion @idEmpresa = 4, @idParque = 10, @rubro = 'Alojamiento', @fechaInicio = @iniVenc2, @fechaFin = @finVenc2, @precioAlquiler = 220000.00
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla Concesion--';
GO

--Facturas de ejemplo para un par de concesiones
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.altaFacturaConcesion'))
BEGIN
	DECLARE @hoy DATE = CAST(GETDATE() AS DATE)
	DECLARE @venc1 DATE = DATEADD(dd, 5,  @hoy)
	DECLARE @venc2 DATE = DATEADD(dd, 10, @hoy)
	DECLARE @venc3 DATE = DATEADD(dd, 15, @hoy)

	EXECUTE PnSPtrans.altaFacturaConcesion @concesion = 1, @vencimiento = @venc1
	EXECUTE PnSPtrans.altaFacturaConcesion @concesion = 2, @vencimiento = @venc2
	EXECUTE PnSPtrans.altaFacturaConcesion @concesion = 3, @vencimiento = @venc3
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla HistorialPago--';
GO

--Pago de la primera factura para tener un caso pagada
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.pagoFactura'))
BEGIN
	EXECUTE PnSPtrans.pagoFactura @idFactura = 1;
END;
GO

-------------------------------------------------------------------------------------
----TipoEntrada / Entrada
IF
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TipoEntrada') AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaTipoEntrada'))
BEGIN
	EXECUTE PnSPabm.altaTipoEntrada @DescripcionTipoEntrada = 'General';
	EXECUTE PnSPabm.altaTipoEntrada @DescripcionTipoEntrada = 'Jubilados';
	EXECUTE PnSPabm.altaTipoEntrada @DescripcionTipoEntrada = 'Estudiante';
	EXECUTE PnSPabm.altaTipoEntrada @DescripcionTipoEntrada = 'Residente Extranjero';
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla TipoEntrada--';
GO

--2 Entradas por cada uno de los 10 parques
IF
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Entrada') AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaEntrada'))
BEGIN
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 1500.00, @parque = 1;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 2, @precio = 800.00,  @parque = 1;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 1200.00, @parque = 2;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 2, @precio = 600.00,  @parque = 2;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 1800.00, @parque = 3;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 2, @precio = 900.00,  @parque = 3;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 2000.00, @parque = 4;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 2, @precio = 1000.00, @parque = 4;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 2200.00, @parque = 5;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 2, @precio = 1100.00, @parque = 5;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 1400.00, @parque = 6;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 2, @precio = 700.00,  @parque = 6;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 1600.00, @parque = 7;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 2, @precio = 800.00,  @parque = 7;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 1300.00, @parque = 8;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 2, @precio = 650.00,  @parque = 8;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 500.00,  @parque = 9;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 2, @precio = 250.00,  @parque = 9;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 900.00,  @parque = 10;
	EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 2, @precio = 450.00,  @parque = 10;
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla Entrada--';
GO

-------------------------------------------------------------------------------------
----Turno adicional para probar 'tour con cupo completo' sin tocar Actividad 1/2
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaHActividad'))
BEGIN
	--Actividad 6 = 'Cabalgata al Cerro', CupoMax = 8, Parque 3
	EXECUTE PnSPabm.altaHActividad @actividad = 6, @fechaAct = '2026-11-15', @hInicio = '09:00';
END;
GO

-------------------------------------------------------------------------------------
----Historial de ventas
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.reservarEntradas'))
AND EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.confirmarCompraE'))
BEGIN
	--Venta 1: Entrada 1 (Parque 1, General)
	EXECUTE PnSPtrans.reservarEntradas @entrada = 1, @cantidad = 15, @fecha = '2026-08-15';
	EXECUTE PnSPtrans.confirmarCompraE @metodo = 'Efectivo', @moneda = 'Dolar';

	--Venta 2: Entradas 3 y 4 en un mismo ticket
	EXECUTE PnSPtrans.reservarEntradas @entrada = 3, @cantidad = 20, @fecha = '2026-08-16';
	EXECUTE PnSPtrans.reservarEntradas @entrada = 4, @cantidad = 5,  @fecha = '2026-08-16';
	EXECUTE PnSPtrans.confirmarCompraE @metodo = 'Tarjeta', @moneda = 'Peso';

	--Venta 3: Entrada 19 (Parque 10, General)
	EXECUTE PnSPtrans.reservarEntradas @entrada = 19, @cantidad = 8, @fecha = '2026-09-01';
	EXECUTE PnSPtrans.confirmarCompraE @metodo = 'Efectivo', @moneda = 'Peso';
END;
GO

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.reservarActividad'))
AND EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.confirmarCompraA'))
BEGIN
	--Caso obligatorio: tour con cupo completo
	EXECUTE PnSPtrans.reservarActividad @actividad = 6, @cantidad = 8, @fecha = '2026-11-15', @hora = '09:00';
	EXECUTE PnSPtrans.confirmarCompraA @metodo = 'Efectivo', @moneda = 'Peso';
END;
GO

--Turno propio para la venta adicional de actividad
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaHActividad'))
BEGIN
	EXECUTE PnSPabm.altaHActividad @actividad = 8, @fechaAct = '2026-11-20', @hInicio = '10:00';
END;
GO

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.reservarActividad'))
AND EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.confirmarCompraA'))
BEGIN
	EXECUTE PnSPtrans.reservarActividad @actividad = 8, @cantidad = 4, @fecha = '2026-11-20', @hora = '10:00';
	EXECUTE PnSPtrans.confirmarCompraA @metodo = 'Tarjeta', @moneda = 'Dolar';
END;
GO