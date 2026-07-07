/*
-/-/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

En este script se realiza la creacion de la base de datos y esquemas.
*/

----Creacion de BD

--DROP DATABASE ParquesNacionales;

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	CREATE DATABASE ParquesNacionales;
	PRINT '--Creada BD: ParquesNacionales--'
END;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

----Creacion de Schema para Tablas
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'PnTablas')
BEGIN
	EXECUTE('CREATE SCHEMA PnTablas')
	PRINT '--Creado Schema: PnTablas--'
END;
GO

----Creacion de Schema para SPabm
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'PnSPabm')
BEGIN
	EXECUTE('CREATE SCHEMA PnSPabm')
	PRINT '--Creado Schema: PnSPabm--'
END;
GO

----Creacion de Schema para SPtrans
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'PnSPtrans')
BEGIN
	EXECUTE('CREATE SCHEMA PnSPtrans')
	PRINT '--Creado Schema: PnSPtrans--'
END;
GO

----Creacion de Schema para otros SP
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'PnSP')
BEGIN
	EXECUTE('CREATE SCHEMA PnSP')
	PRINT '--Creado Schema: PnSP--'
END;
GO