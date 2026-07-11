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

--Testing de los SPs de ABM asociados a las tablas Parque
--Los SP ABM de la tabla HorarioParque se testean junto a los SP transaccionales de dicha tabla

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Chequeo de datos cargados
SELECT *
FROM PnTablas.Parque

SELECT *
FROM PnTablas.TipoParque

SELECT *
FROM PnTablas.Provincia

SELECT *
FROM PnTablas.Abre

SELECT *
FROM PnTablas.Dia

SELECT *
FROM PnTablas.HorarioParque

SELECT *
FROM PnTablas.TelefonoParque
-------------------------------------------------------------------------------------
----SPs usados por la APP
EXECUTE PnSP.verParques;
GO

EXECUTE PnSP.verTipoParque;
GO

EXECUTE PnSP.verProvincia;
GO
-------------------------------------------------------------------------------------
----SPs que cubren requisitos
EXECUTE PnSP.verInfoGeneralParques;
GO

EXECUTE PnSP.verContactoParques;
GO

EXECUTE PnSP.verInfoOperativaParques;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Chequeo de datos cargados
SELECT *
FROM PnTablas.Concesion

SELECT *
FROM PnTablas.Empresa

SELECT *
FROM PnTablas.HistorialPago
-------------------------------------------------------------------------------------
----SPs que cubren requisitos
EXECUTE PnSP.proximosVence;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Chequeo de datos cargados
SELECT *
FROM PnTablas.Persona

SELECT *
FROM PnTablas.GuardaParque

SELECT *
FROM PnTablas.TieneHistorial

SELECT *
FROM PnTablas.Historial
-------------------------------------------------------------------------------------
----SPs que cubren requisitos
DECLARE @idTest INT;
SET @idTest = 1

EXECUTE PnSP.estadoGuardaparque @id = @idTest;
GO

EXECUTE PnSP.verHistorialGuardaparque @id = @idTest;
GO