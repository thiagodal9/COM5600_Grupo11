/*
10/07/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL
*/

SET NOCOUNT ON;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--'
END;
GO

PRINT '--Iniciando limpieza de datos (se conserva el esquema)...--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Venta (nivel mas hijo primero)

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'PoseeEntrada')
BEGIN
	DELETE FROM PnTablas.PoseeEntrada;
	PRINT '--Limpiada tabla: PoseeEntrada--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TieneHActividad')
BEGIN
	DELETE FROM PnTablas.TieneHActividad;
	PRINT '--Limpiada tabla: TieneHActividad--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'PagoVenta')
BEGIN
	DELETE FROM PnTablas.PagoVenta;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.PagoVenta'))
		DBCC CHECKIDENT ('PnTablas.PagoVenta', RESEED, 0);
	PRINT '--Limpiada tabla: PagoVenta--';
END;
GO

-------------------------------------------------------------------------------------
----Entrada / TipoEntrada

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Entrada')
BEGIN
	DELETE FROM PnTablas.Entrada;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.Entrada'))
		DBCC CHECKIDENT ('PnTablas.Entrada', RESEED, 0);
	PRINT '--Limpiada tabla: Entrada--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TipoEntrada')
BEGIN
	DELETE FROM PnTablas.TipoEntrada;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.TipoEntrada'))
		DBCC CHECKIDENT ('PnTablas.TipoEntrada', RESEED, 0);
	PRINT '--Limpiada tabla: TipoEntrada--';
END;
GO

-------------------------------------------------------------------------------------
----Concesion / Empresa / Facturas

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'HistorialPago')
BEGIN
	DELETE FROM PnTablas.HistorialPago;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.HistorialPago'))
		DBCC CHECKIDENT ('PnTablas.HistorialPago', RESEED, 0);
	PRINT '--Limpiada tabla: HistorialPago--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Concesion')
BEGIN
	DELETE FROM PnTablas.Concesion;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.Concesion'))
		DBCC CHECKIDENT ('PnTablas.Concesion', RESEED, 0);
	PRINT '--Limpiada tabla: Concesion--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Empresa')
BEGIN
	DELETE FROM PnTablas.Empresa;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.Empresa'))
		DBCC CHECKIDENT ('PnTablas.Empresa', RESEED, 0);
	PRINT '--Limpiada tabla: Empresa--';
END;
GO

-------------------------------------------------------------------------------------
----Parque: tablas intermedias/dependientes

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TelefonoParque')
BEGIN
	DELETE FROM PnTablas.TelefonoParque;
	PRINT '--Limpiada tabla: TelefonoParque--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Abre')
BEGIN
	DELETE FROM PnTablas.Abre;
	PRINT '--Limpiada tabla: Abre--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'HorarioParque')
BEGIN
	DELETE FROM PnTablas.HorarioParque;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.HorarioParque'))
		DBCC CHECKIDENT ('PnTablas.HorarioParque', RESEED, 0);
	PRINT '--Limpiada tabla: HorarioParque--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Dia')
BEGIN
	DELETE FROM PnTablas.Dia;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.Dia'))
		DBCC CHECKIDENT ('PnTablas.Dia', RESEED, 0);
	PRINT '--Limpiada tabla: Dia--';
END;
GO

-------------------------------------------------------------------------------------
----Persona: tablas intermedias/dependientes

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TieneEspecialidad')
BEGIN
	DELETE FROM PnTablas.TieneEspecialidad;
	PRINT '--Limpiada tabla: TieneEspecialidad--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TieneHistorial')
BEGIN
	DELETE FROM PnTablas.TieneHistorial;
	PRINT '--Limpiada tabla: TieneHistorial--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Historial')
BEGIN
	DELETE FROM PnTablas.Historial;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.Historial'))
		DBCC CHECKIDENT ('PnTablas.Historial', RESEED, 0);
	PRINT '--Limpiada tabla: Historial--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Especialidad')
BEGIN
	DELETE FROM PnTablas.Especialidad;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.Especialidad'))
		DBCC CHECKIDENT ('PnTablas.Especialidad', RESEED, 0);
	PRINT '--Limpiada tabla: Especialidad--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Guia')
BEGIN
	DELETE FROM PnTablas.Guia;
	PRINT '--Limpiada tabla: Guia--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'GuardaParque')
BEGIN
	DELETE FROM PnTablas.GuardaParque;
	PRINT '--Limpiada tabla: GuardaParque--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Persona')
BEGIN
	DELETE FROM PnTablas.Persona;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.Persona'))
		DBCC CHECKIDENT ('PnTablas.Persona', RESEED, 0);
	PRINT '--Limpiada tabla: Persona--';
END;
GO

-------------------------------------------------------------------------------------
----Actividad: tablas dependientes

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'HorarioActividad')
BEGIN
	DELETE FROM PnTablas.HorarioActividad;
	PRINT '--Limpiada tabla: HorarioActividad--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Actividad')
BEGIN
	DELETE FROM PnTablas.Actividad;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.Actividad'))
		DBCC CHECKIDENT ('PnTablas.Actividad', RESEED, 0);
	PRINT '--Limpiada tabla: Actividad--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TipoActividad')
BEGIN
	DELETE FROM PnTablas.TipoActividad;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.TipoActividad'))
		DBCC CHECKIDENT ('PnTablas.TipoActividad', RESEED, 0);
	PRINT '--Limpiada tabla: TipoActividad--';
END;
GO

-------------------------------------------------------------------------------------
----Parque / Provincia / TipoParque (tablas raiz de este bloque)

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Parque')
BEGIN
	DELETE FROM PnTablas.Parque;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.Parque'))
		DBCC CHECKIDENT ('PnTablas.Parque', RESEED, 0);
	PRINT '--Limpiada tabla: Parque--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Provincia')
BEGIN
	DELETE FROM PnTablas.Provincia;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.Provincia'))
		DBCC CHECKIDENT ('PnTablas.Provincia', RESEED, 0);
	PRINT '--Limpiada tabla: Provincia--';
END;
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TipoParque')
BEGIN
	DELETE FROM PnTablas.TipoParque;
	IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('PnTablas.TipoParque'))
		DBCC CHECKIDENT ('PnTablas.TipoParque', RESEED, 0);
	PRINT '--Limpiada tabla: TipoParque--';
END;
GO

PRINT '--Limpieza de datos finalizada. Esquema, SPs y cifrado preservados.--';
GO
