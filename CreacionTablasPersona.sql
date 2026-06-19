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
----Tablas Intermedias: tieneEspecialidad, tieneHistorial
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
		DNI INT,
		NombrePersona varchar(20),
		Apellido varchar(20),
		Telefono varchar(12),
		Rol varchar(10)
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
		Estado char(10),
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
		Titulo char(30),
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
		DescripcionEspecialidad varchar(20)
	)
	PRINT '--Creada Tabla: Especialidad--';
END
GO

--Tabla Historial
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Historial')
BEGIN
	CREATE TABLE PnTablas.Historial
	(
		IDregistro INT IDENTITY(1, 1) PRIMARY KEY,
		FechaInicio DATE,
		FechaEgreso DATE,
		RazonEgreso char(40)
	)
	PRINT '--Creada Tabla: Historial--';
END;
GO

PRINT '--Creando tablas intermedias...';
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TieneHistorial')
BEGIN
	CREATE TABLE PnTablas.TieneHistorial
	(
		Guardaparque INT,
		Parque INT,
		Registro INT,
		FOREIGN KEY(Guardaparque) REFERENCES PnTablas.Guardaparque(IDGuardaparque),
		FOREIGN KEY(Parque) REFERENCES PnTablas.Parque(IDParque),
		FOREIGN KEY(Registro) REFERENCES PnTablas.Historial(IDregistro),
		PRIMARY KEY(Registro, Parque)
	)
	PRINT '--Creada Tabla: TieneHistorial--'
END;
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