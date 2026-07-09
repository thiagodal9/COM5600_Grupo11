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
----Tablas Principales: Persona, Guardaparque, Guia
----Subtablas: Especialidad, Historial
----Tablas Intermedias: tieneEspecialidad
*/

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

PRINT '--CreacionTablasPersona--' + CHAR(13) + '--Creando tablas principales...';
GO

--Tabla Persona
--El proyecto es nacional asi que se asume el DNI como documento de identificacion unico.
--No se marca ninguna consideracion en cuanto al telefono por lo que se asume solo uno por persona.
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Persona')
BEGIN
	CREATE TABLE PnTablas.Persona
	(
		IDPersona INT IDENTITY(1,1) PRIMARY KEY,
		DNI int not null constraint UQ_Persona_DNI unique,
		NombrePersona varchar(20),
		Apellido varchar(20),
		Telefono varchar(12),
		Rol varchar(10) NOT NULL CHECK (Rol IN ('Guardaparque', 'Guia'))
	)
	PRINT '--Creada Tabla: Persona--'
END;
GO

--Tabla Guardaparque
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'GuardaParque')
BEGIN
	CREATE TABLE PnTablas.GuardaParque
	(
		IDGuardaParque INT,
		Parque INT NULL,
		Estado varchar(10),
		FechaInicio DATE,
		FOREIGN KEY(IDGuardaParque) REFERENCES PnTablas.Persona(IDPersona),
		FOREIGN KEY(Parque) REFERENCES PnTablas.Parque(IDParque),
		PRIMARY KEY(IDGuardaParque)
	)
	PRINT '--Creada Tabla: Guardaparque--'
END;
GO

--Tabla Guia
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Guia')
BEGIN
	CREATE TABLE PnTablas.Guia
	(
		IDGuia INT,
		Titulo varchar(100),
		VencimientoHabilitacion DATE,
		NumeroHabilitacion INT,
		FOREIGN KEY(IDGuia) REFERENCES PnTablas.Persona(IDPersona),
		PRIMARY KEY (IDGuia)
	)
	PRINT '--Creada Tabla: Guia--'
END;
GO

PRINT '--Creando subtablas...';
GO

--Tabla Especialidad
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Especialidad')
BEGIN
	CREATE TABLE PnTablas.Especialidad
	(
		IDEspecialidad INT IDENTITY(1,1) PRIMARY KEY,
		DescripcionEspecialidad varchar(20) NOT NULL UNIQUE
	)
	PRINT '--Creada Tabla: Especialidad--';
END
GO

--Tabla Historial
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TieneHistorial')
BEGIN
	CREATE TABLE PnTablas.TieneHistorial
	(
		IDregistro INT IDENTITY(1, 1) PRIMARY KEY,
		Guardaparque INT NOT NULL,
		Parque INT NOT NULL,
		FechaInicio DATE,
		FechaEgreso DATE,
		RazonEgreso varchar(40),
		FOREIGN KEY(Guardaparque) REFERENCES PnTablas.GuardaParque(IDGuardaParque),
		FOREIGN KEY(Parque) REFERENCES PnTablas.Parque(IDParque)
	)
	PRINT '--Creada Tabla: TieneHistorial--';
END;
GO

PRINT '--Creando tablas intermedias...';
GO

--Tabla TieneEspecialidad
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TieneEspecialidad')
BEGIN
	CREATE TABLE PnTablas.TieneEspecialidad
	(
		Guia INT,
		Especialidad INT,
		FOREIGN KEY(Guia) REFERENCES PnTablas.Guia(IDGuia),
		FOREIGN KEY(Especialidad) REFERENCES PnTablas.Especialidad(IDEspecialidad),
		PRIMARY KEY(Guia, Especialidad)
	)
	PRINT '--Creada Tabla: TieneEspecialidad--'
END;
GO