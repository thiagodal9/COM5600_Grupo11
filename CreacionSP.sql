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

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

PRINT '--Creando SPs...--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
--verParques(ID + Nombre)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.verParques'))
	DROP PROCEDURE PnSP.verParques
GO
CREATE PROCEDURE PnSP.verParques
AS
BEGIN
	SELECT *
	FROM PnTablas.Parque
END;
GO
PRINT '--Creado SP: verParques--';
GO

--verTipoParque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.verTipoParque'))
	DROP PROCEDURE PnSP.verTipoParque
GO
CREATE PROCEDURE PnSP.verTipoParque
AS
BEGIN
	SELECT *
	FROM PnTablas.TipoParque
END;
GO
PRINT '--Creado SP: verTipoParque--';
GO

--verProvincia
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.verProvincia'))
	DROP PROCEDURE PnSP.verProvincia
GO
CREATE PROCEDURE PnSP.verProvincia
AS
BEGIN
	SELECT *
	FROM PnTablas.Provincia
END;
GO
PRINT '--Creado SP: verProvincia--';
GO