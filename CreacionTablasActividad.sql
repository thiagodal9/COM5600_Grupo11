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

/*
----Tablas Principales: Actividad, TipoActividad
----Tablas Secundarias: HorarioActividad
*/

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

PRINT '--CreacionTablasActividad--' + CHAR(13) + '--Creando tablas principales...';
GO

--Tabla TipoActividad
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TipoActividad')
BEGIN
	CREATE TABLE PnTablas.TipoActividad
	(
		IDTipoAct INT IDENTITY (1, 1) PRIMARY KEY,
		DescripcionAct char(30),
		CostoAct DECIMAL(7, 2)
	);
	PRINT '--Creada Tabla: TipoActividad--'
END;
GO

--Tabla Actividad
--La duracion se toma en minutos. Ejem: 120minutos
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Actividad')
BEGIN
	CREATE TABLE PnTablas.Actividad
	(
		IDActividad INT IDENTITY(1, 1) PRIMARY KEY,
		NombreActividad char(30),
		Duracion INT,
		CupoMax INT,
		Parque INT,
		Tipo INT,
		FOREIGN KEY (Parque) REFERENCES PnTablas.Parque(IDParque),
		FOREIGN KEY (Tipo) REFERENCES PnTablas.TipoActividad(IDTipoAct)
	);
	PRINT '--Creada Tabla: Actividad--'
END;
GO

--Tabla HorarioActividad
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'HorarioActividad')
BEGIN
	CREATE TABLE PnTablas.HorarioActividad
	(
		Actividad INT,
		FechaActividad DATE,
		HoraInicio TIME,
		Guia INT NULL,
		FOREIGN KEY(Actividad) REFERENCES PnTablas.Actividad(IDActividad),
		FOREIGN KEY (Guia) REFERENCES PnTablas.Guia(IDGuia),
		PRIMARY KEY(Actividad, FechaActividad, HoraInicio)
	)
	PRINT '--Creada Tabla: HorarioActividad--'
END;
GO