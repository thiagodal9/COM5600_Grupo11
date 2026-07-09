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
----Tablas Principales: Entrada, TipoEntrada, PagoVenta
----Tablas Intermedias: PoseeEntrada, TieneHActividad
----Tablas de Apoyo: #ventaEntradas, #ventaActividades
*/

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

PRINT '--CreacionTablasVenta--' + CHAR(13) + '--Creando tablas principales...';
GO

--Tabla PagoVenta
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'PagoVenta')
BEGIN
	CREATE TABLE PnTablas.PagoVenta
	(
		IDPagoVenta INT IDENTITY(1,1) PRIMARY KEY,
		Importe DECIMAL(10,2),
		FechaHoraTransaccion DATE,
		Item char(30),
		Metodo char(30)
	)
	PRINT '--Creada Tabla: PagoVenta--'
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
	PRINT '--Creada Tabla: TipoEntrada--'
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
	PRINT '--Creada Tabla: Entrada--'
END;
GO

PRINT '--Creando tablas intermedias...';
GO

--Tabla PoseeEntrada
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'PoseeEntrada')
BEGIN
	CREATE TABLE PnTablas.PoseeEntrada
	(
		Pago INT,
		Entrada INT,
		FechaAcceso DATE,
		Cantidad INT,
		FOREIGN KEY(Pago) REFERENCES PnTablas.PagoVenta(IDPagoVenta),
		FOREIGN KEY(Entrada) REFERENCES PnTablas.Entrada(IDEntrada)
	)
	PRINT '--Creada Tabla: PoseeEntrada--'
END;
GO

--Tabla TieneHActividad
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TieneHActividad')
BEGIN
	CREATE TABLE PnTablas.TieneHActividad
	(
		Pago INT,
		Actividad INT,
		FechaActividad DATE,
		HoraInicio TIME,
		Cantidad INT,
		FOREIGN KEY(Pago) REFERENCES PnTablas.PagoVenta(IDPagoVenta),
		FOREIGN KEY(Actividad, FechaActividad, HoraInicio) REFERENCES PnTablas.HorarioActividad(Actividad, FechaActividad, HoraInicio),
		PRIMARY KEY(Pago, Actividad, FechaActividad, HoraInicio)
	)
	PRINT '--Creada Tabla: TieneHActividad--'
END;
GO

PRINT '--Creando tablas de apoyo...';
GO

--Tabla #ventaEntradas
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
	PRINT '--Creada Tabla: #ventaEntradas--'
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
		HoraInicio TIME,
		Cantidad INT,
		ID INT
	)
	PRINT '--Creada Tabla: #ventaActividades--'
END;
GO