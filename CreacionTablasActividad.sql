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
		DescripcionAct varchar(30) NOT NULL UNIQUE,
		CostoAct DECIMAL(7, 2) NOT NULL
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
		NombreActividad varchar(30),
		Duracion INT NOT NULL,
		CupoMax INT NOT NULL,
		Parque INT NOT NULL,
		Tipo INT NOT NULL,
		Guia INT NULL,
		FOREIGN KEY (Parque) REFERENCES PnTablas.Parque(IDParque),
		FOREIGN KEY (Tipo) REFERENCES PnTablas.TipoActividad(IDTipoAct),
		FOREIGN KEY (Guia) REFERENCES PnTablas.Guia(IDGuia)
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
		HoraInicio TIME NOT NULL,
		FOREIGN KEY(Actividad) REFERENCES PnTablas.Actividad(IDActividad),
		PRIMARY KEY(Actividad, FechaActividad, HoraInicio)
	)
	PRINT '--Creada Tabla: HorarioActividad--'
END;
GO

