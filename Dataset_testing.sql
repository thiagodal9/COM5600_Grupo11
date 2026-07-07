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

--Se hace el llenado de tablas para testing
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----TipoParque
IF 
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TipoParque')
AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaTipoParque'))
BEGIN
	EXECUTE PnSPabm.altaTipoParque @tipo = 'Reserva';
	EXECUTE PnSPabm.altaTipoParque @tipo = 'Reserva Aviaria';
	EXECUTE PnSPabm.altaTipoParque @tipo = 'Centro Pescador';
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla TipoParque--';
GO

-------------------------------------------------------------------------------------
----Provincia
IF 
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Provincia')
AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaProvincia'))
BEGIN
	EXECUTE PnSPabm.altaProvincia @nombre = 'rio negro';
	EXECUTE PnSPabm.altaProvincia @nombre = 'Santa Cruz';
	EXECUTE PnSPabm.altaProvincia @nombre = 'Buenos Aires';
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla Provincia--';
GO

-------------------------------------------------------------------------------------
----Parque
IF 
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Parque')
AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaParque'))
BEGIN
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Iguazu', @ubicacion = 1, @Superficie = 2000, @tipo = 1;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Pochoclo', @ubicacion = 1, @Superficie = 1500, @tipo = 2;
	EXECUTE PnSPabm.altaParque @nombre = 'Parque Belgrano', @ubicacion = 2, @Superficie = 3500, @tipo = 1;
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla Parque--';
GO

-------------------------------------------------------------------------------------
----TelefonoParque
IF 
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TelefonoParque')
AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaTelefonoParque'))
BEGIN
	EXECUTE PnSPabm.altaTelefonoParque @numero = '4567-0345', @parque = 1;
	EXECUTE PnSPabm.altaTelefonoParque @numero = '4567-0352', @parque = 1;
	EXECUTE PnSPabm.altaTelefonoParque @numero = '345-0223', @parque = 2;
END;
ELSE
	PRINT '--No se pudo cargar datos en tabla TelefonoParque--';
GO

-------------------------------------------------------------------------------------
----Dia
IF
EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Dia')
AND
EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaDias'))
BEGIN
	EXECUTE PnSPabm.altaDias
END;
GO