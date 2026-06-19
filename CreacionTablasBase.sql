/*
-/-/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

En este script se realiza la creacion de la base de datos, 
del SCHEMA que contendra las tablas y 
de las tablas de acuerdo al DER entregado.
*/

----Creacion de la base de datos

--DROP DATABASE ParquesNacionales;

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
CREATE DATABASE ParquesNacionales;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
USE ParquesNacionales;
GO

----Creacion de Schema
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'PnTablas')
EXECUTE('CREATE SCHEMA PnTablas');
GO

----Creación de tablas

--Tabla TipoParque
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TipoParque')
BEGIN
CREATE TABLE PnTablas.TipoParque
(
	IDTipoParque INT IDENTITY(1, 1) PRIMARY KEY,
	DescripcionParque char(30)
);
END
GO

--Tabla Provincia
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Provincia')
BEGIN
CREATE TABLE PnTablas.Provincia
(
	IDProv INT IDENTITY(1, 1) PRIMARY KEY,
	NombreProv char(15)
);
END
GO

--Tabla Parque
--La superficie se toma en hectareas(INT). Ejem: 17.000h
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Parque')
BEGIN
CREATE TABLE PnTablas.Parque
(
	IDParque INT IDENTITY(1, 1) PRIMARY KEY,
	NombreParque varchar(30),
	Ubicacion INT,
	Superficie INT,
	Tipo INT,
	FOREIGN KEY(Ubicacion) REFERENCES PnTablas.Provincia(IDProv),
	FOREIGN KEY(Tipo) REFERENCES PnTablas.TipoParque(IDTipoParque)
);
END
GO

--Tabla Dia
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Dia')
BEGIN
CREATE TABLE PnTablas.Dia
(
	IDDia INT IDENTITY(1, 1) PRIMARY KEY,
	NombreDia char(10)
);
END
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
);
END
GO

--Tabla Abre
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Abre')
BEGIN
CREATE TABLE PnTablas.Abre
(
	Parque INT,
	Dia INT,
	Horario INT,
	FOREIGN KEY(Parque) REFERENCES PnTablas.Parque(IDParque),
	FOREIGN KEY(Dia) REFERENCES PnTablas.Dia(IDDia),
	FOREIGN KEY(Horario) REFERENCES PnTablas.HorarioParque(IDHorarioP)
);
END
GO

--Tabla TelefonoParque
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TelefonoParque')
BEGIN
CREATE TABLE PnTablas.TelefonoParque
(
	NumeroParque varchar(12),
	Parque INT,
	FOREIGN KEY(Parque) REFERENCES PnTablas.Parque(IDParque),
	PRIMARY KEY(NumeroParque, Parque)
);
END
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
END
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
END
GO

--Tabla Especialidad
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Especialidad')
BEGIN
	CREATE TABLE PnTablas.Especialidad
	(
		IDEspecialidad INT IDENTITY(1,1) PRIMARY KEY,
		DescripcionEspecialidad varchar(20)
	)
END
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
END
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
END;
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
END;
GO

--Tabla TieneHistorial
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TieneHistorial')
BEGIN
	CREATE TABLE TieneHistorial
	(
		Guardaparque INT,
		Parque INT,
		Registro INT,
		FOREIGN KEY(Guardaparque) REFERENCES PnTablas.Guardaparque(IDGuardaparque),
		FOREIGN KEY(Parque) REFERENCES PnTablas.Parque(IDParque),
		FOREIGN KEY(Registro) REFERENCES PnTablas.Historial(IDregistro),
		PRIMARY KEY(Registro, Parque)
	)
END

--Tabla TipoActividad
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TipoActividad')
BEGIN
CREATE TABLE PnTablas.TipoActividad
(
	IDTipoAct INT IDENTITY (1, 1) PRIMARY KEY,
	DescripcionAct char(30),
	CostoAct DECIMAL(7, 2)
);
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
	Guia INT NULL,
	FOREIGN KEY (Parque) REFERENCES PnTablas.Parque(IDParque),
	FOREIGN KEY (Tipo) REFERENCES PnTablas.TipoActividad(IDTipoAct),
	FOREIGN KEY (Guia) REFERENCES PnTablas.Guia(IDGuia)
);
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
		FOREIGN KEY(Actividad) REFERENCES PnTablas.Actividad(IDActividad),
		PRIMARY KEY(Actividad, FechaActividad)
	)
END;
GO

--Tabla Venta
--IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Venta')
--BEGIN
--	CREATE TABLE PnTablas.Venta
--	(
--		IDVenta INT IDENTITY(1,1) PRIMARY KEY,
--		FechaVenta DATE,
--		TotalVenta DECIMAL(10,2),
--		Parque INT,
--		FOREIGN KEY(Parque) REFERENCES PnTablas.Parque(IDParque)
--	)
--END;
--GO

--Tabla PagoVenta
--IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'PagoVenta')
--BEGIN
--	CREATE TABLE PnTablas.PagoVenta
--	(
--		IDPagoVenta INT IDENTITY(1,1) PRIMARY KEY,
--		Importe DECIMAL(10,2),
--		FechaTransaccion DATE,
--		Item char(30),
--		Metodo char(30),
--		Venta INT,
--		FOREIGN KEY(Venta) REFERENCES PnTablas.Venta(IDVenta)
--	)
--END;
--GO

--Tabla PagoVenta
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'PagoVenta')
BEGIN
	CREATE TABLE PnTablas.PagoVenta
	(
		IDPagoVenta INT IDENTITY(1,1) PRIMARY KEY,
		Importe DECIMAL(10,2),
		FechaTransaccion DATE,
		Item char(30),
		Metodo char(30),
		Venta INT
	)
END;
GO

--Tabla TipoEntrada
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TipoEntrada')
BEGIN
	CREATE TABLE PnTablas.TipoEntrada
	(
		IDTipoEntrada INT IDENTITY(1, 1) PRIMARY KEY,
		DescripcionTipoEntrada char(20)
	)
END;
GO

--Tabla Entrada
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Entrada')
BEGIN
	CREATE TABLE PnTablas.Entrada
	(
		IDEntrada INT IDENTITY(1,1) PRIMARY KEY,
		Precio DECIMAL(10,2),
		TipoEntrada INT,
		Parque INT,
		FOREIGN KEY(TipoEntrada) REFERENCES PnTablas.TipoEntrada,
		FOREIGN KEY(Parque) REFERENCES PnTablas.Parque(IDParque)
	)
END;
GO

--Tabla Posee
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Posee')
BEGIN
	CREATE TABLE PnTablas.Posee
	(
		Pago INT,
		Entrada INT,
		FechaAcceso DATE,
		Cantidad INT,
		FOREIGN KEY(Pago) REFERENCES PnTablas.PagoVenta(IDPagoVenta),
		FOREIGN KEY(Entrada) REFERENCES PnTablas.Entrada(IDEntrada)
	)
END;
GO

--Tabla Tiene
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Tiene')
BEGIN
	CREATE TABLE PnTablas.Tiene
	(
		Pago INT,
		Actividad INT,
		FechaActividad DATE,
		Cantidad INT,
		FOREIGN KEY(Pago) REFERENCES PnTablas.PagoVenta(IDPagoVenta),
		FOREIGN KEY(Actividad, FechaActividad) REFERENCES PnTablas.HorarioActividad(Actividad, FechaActividad),
		PRIMARY KEY(Pago, Actividad, FechaActividad)
	)
END;
GO

--Tabla #ventaEntradas
IF OBJECT_ID('tempdb..#ventaEntradas') IS NULL
BEGIN
	CREATE TABLE PnTablas.#ventaEntradas
	(
		IDvEntrada INT IDENTITY(1, 1) PRIMARY KEY,
		Entrada INT,
		Cantidad INT,
		FOREIGN KEY(Entrada) REFERENCES PnTablas.Entrada(IDEntrada)
	)
END;
GO

--Tabla #ventaActividades
IF OBJECT_ID('tempdb..#ventaActividades') IS NULL
BEGIN
	CREATE TABLE #ventaActividades
	(
		IDvActividad INT IDENTITY(1, 1) PRIMARY KEY,
		Actividad INT,
		FechaActividad DATE,
		Cantidad INT,
		FOREIGN KEY(Actividad, FechaActividad) REFERENCES PnTablas.HorarioActividad(Actividad, FechaActividad)
	)
END;
GO

--Tabla Empresa
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Empresa')
BEGIN
	CREATE TABLE PnTablas.Empresa
	(
		IDEmpresa INT IDENTITY(1,1) PRIMARY KEY,
		NombreEmpresa char(20),
		DescripcionEmpresa char(30)
	)
END;
GO

--Tabla Concesion
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Concesion')
BEGIN
	CREATE TABLE PnTablas.Concesion
	(
		IDConcesion INT IDENTITY(1,1) PRIMARY KEY,
		Parque INT,
		Empresa INT,
		Rubro char(20),
		FechaInicioConcesion DATE,
		FechaFinConcesion DATE,
		CostoAlquiler DECIMAL(10,2),
		FOREIGN KEY(Parque) REFERENCES PnTablas.Parque(IDParque),
		FOREIGN KEY(Empresa) REFERENCES PnTablas.Empresa(IDEmpresa)
	)
END;
GO

--Tabla HistorialPago
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'HistorialPago')
BEGIN
	CREATE TABLE PnTablas.HistorialPago
	(
		IDPagoConcesion INT IDENTITY(1,1) PRIMARY KEY,
		Concesion INT,
		Importe DECIMAL(10,2),
		Vencimiento DATE,
		Estado char(7),
		FOREIGN KEY(Concesion) references PnTablas.Concesion(IDConcesion)
	)
END;
GO