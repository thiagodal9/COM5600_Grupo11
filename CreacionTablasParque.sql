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
----Tablas Principales: TipoParque, Provincia, Parque, HorarioParque, Dia
----Tablas Intermedias: Abre
*/

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

PRINT '--CreacionTablasParque--' + CHAR(13) + '--Creando tablas principales...';
GO

--Tabla TipoParque
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TipoParque')
BEGIN
	CREATE TABLE PnTablas.TipoParque
	(
		IDTipoParque INT IDENTITY(1, 1) PRIMARY KEY,
		DescripcionParque char(30)
	)
	PRINT '--Creada Tabla: TipoParque--'
END;
GO

--Tabla Provincia
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Provincia')
BEGIN
	CREATE TABLE PnTablas.Provincia
	(
		IDProv INT IDENTITY(1, 1) PRIMARY KEY,
		NombreProv char(15)
	)
	PRINT '--Creada Tabla: Provincia--'
END
GO

--Tabla Parque
--La superficie se toma en hectareas(INT). Ejem: 17.000h
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Parque')
BEGIN
	CREATE TABLE PnTablas.Parque
	(
		IDParque INT IDENTITY(1, 1) PRIMARY KEY,
		NombreParque varchar(100),
		Ubicacion INT,
		Latitud varchar(20), 
		Longitud varchar(20),
		Superficie INT,
		Tipo INT,
		FOREIGN KEY(Ubicacion) REFERENCES PnTablas.Provincia(IDProv),
		FOREIGN KEY(Tipo) REFERENCES PnTablas.TipoParque(IDTipoParque)
	)
	PRINT '--Creada Tabla: Parque--'
END;
GO

--Tabla HorarioParque
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'HorarioParque')
BEGIN
	CREATE TABLE PnTablas.HorarioParque
	(
		IDHorarioP INT IDENTITY(1, 1) PRIMARY KEY,
		HoraApertura TIME,
		HoraCierre TIME,
		Temporada varchar(10)
	)
	PRINT '--Creada Tabla: HorarioParque--'
END;
GO

--Tabla Dia
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Dia')
BEGIN
	CREATE TABLE PnTablas.Dia
	(
		IDDia INT IDENTITY(1, 1) PRIMARY KEY,
		NombreDia char(10)
	)
	PRINT '--Creada Tabla: Dia--'
END;
GO

PRINT '--Creando tablas intermedias...';
GO

--Tabla Abre
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Abre')
BEGIN
	CREATE TABLE PnTablas.Abre
	(
		Parque INT,
		Dia INT,
		Horario INT,

		PRIMARY KEY(Parque, Dia, Horario),
		FOREIGN KEY(Parque) REFERENCES PnTablas.Parque(IDParque),
		FOREIGN KEY(Dia) REFERENCES PnTablas.Dia(IDDia),
		FOREIGN KEY(Horario) REFERENCES PnTablas.HorarioParque(IDHorarioP)
	)
	PRINT '--Creada Tabla: Abre--';
END;
GO

--Tabla TelefonoParque
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TelefonoParque')
BEGIN
	CREATE TABLE PnTablas.TelefonoParque
	(
		NumeroParque varchar(12),
		Parque INT,

		PRIMARY KEY(NumeroParque, Parque),
		FOREIGN KEY(Parque) REFERENCES PnTablas.Parque(IDParque)
	);
	PRINT '--Creada Tabla: TelefonoParque--';
END;
GO