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
----Tablas Principales: Concesion, Empresa, HistorialPagos
*/

--Tabla Empresa
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Empresa')
BEGIN
	CREATE TABLE PnTablas.Empresa
	(
		IDEmpresa INT IDENTITY(1,1) PRIMARY KEY,
		NombreEmpresa varchar(20),
		DescripcionEmpresa varchar(30)
	)
	PRINT '--Creada Tabla: Empresa--'
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
		Rubro varchar(20),
		FechaInicioConcesion DATE,
		FechaFinConcesion DATE,
		CostoAlquiler DECIMAL(10,2),
		FOREIGN KEY(Parque) REFERENCES PnTablas.Parque(IDParque),
		FOREIGN KEY(Empresa) REFERENCES PnTablas.Empresa(IDEmpresa)
	)
	PRINT '--Creada Tabla: Concesion--'
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
		Estado varchar(7),
		FOREIGN KEY(Concesion) references PnTablas.Concesion(IDConcesion)
	)
	PRINT '--Creada Tabla: HistorialPago--'
END;
GO