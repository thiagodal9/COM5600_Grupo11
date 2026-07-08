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
FROM PnTablas.TipoParque;
GO

SELECT *
FROM PnTablas.Provincia;
GO

SELECT *
FROM PnTablas.Parque;
GO

SELECT *
FROM PnTablas.Dia;
GO

SELECT *
FROM PnTablas.TelefonoParque;
GO
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----TESTING

----TipoParque
--Insercion fallida
EXECUTE PnSPabm.altaTipoParque @tipo = NULL;
EXECUTE PnSPabm.altaTipoParque @tipo = 'reserva';

SELECT *
FROM PnTablas.TipoParque;
GO

----Modificacion
--Modificacion exitosa
EXECUTE PnSPabm.modificacionDescripcionTipoParque @tipo = 1, @descripcionNEW = 'Reserva Animal';

SELECT *
FROM PnTablas.TipoParque;
GO

--Modificacion fallida
EXECUTE PnSPabm.modificacionDescripcionTipoParque @tipo = 1, @descripcionNEW = NULL;
EXECUTE PnSPabm.modificacionDescripcionTipoParque @tipo = NULL, @descripcionNEW = NULL;
EXECUTE PnSPabm.modificacionDescripcionTipoParque @tipo = NULL, @descripcionNEW = 'Reserva Pesquera';
EXECUTE PnSPabm.modificacionDescripcionTipoParque @tipo = 1, @descripcionNEW = 'Reserva Animal';

SELECT *
FROM PnTablas.TipoParque;
GO

--Borrado fallido
EXECUTE PnSPabm.bajaTipoParque @tipo = NULL;
EXECUTE PnSPabm.bajaTipoParque @tipo = 8;
EXECUTE PnSPabm.bajaTipoParque @tipo = 2;

SELECT *
FROM PnTablas.TipoParque;
GO

--Borrado exitoso
EXECUTE PnSPabm.bajaTipoParque @tipo = 3;

SELECT *
FROM PnTablas.TipoParque;
GO

-------------------------------------------------------------------------------------
----Provincia
--Insercion Fallida
EXECUTE PnSPabm.altaProvincia @nombre = NULL;
EXECUTE PnSPabm.altaProvincia @nombre = 'Rio Negro';

SELECT *
FROM PnTablas.Provincia
GO;

--Modificacion Exitosa
EXECUTE PnSPabm.modificarNombreProvincia @provincia = 1, @nombreNEW = 'Rio Negro';

SELECT *
FROM PnTablas.Provincia;
GO

--Modificacion Fallida
EXECUTE PnSPabm.modificarNombreProvincia @provincia = NULL, @nombreNEW = NULL;
EXECUTE PnSPabm.modificarNombreProvincia @provincia = NULL, @nombreNEW = 'La Pampa';
EXECUTE PnSPabm.modificarNombreProvincia @provincia = 1, @nombreNEW = NULL;
EXECUTE PnSPabm.modificarNombreProvincia @provincia = 1, @nombreNEW = 'saNta CrUz';

SELECT *
FROM PnTablas.Provincia
GO

--Borrado Fallido
EXECUTE PnSPabm.bajaProvincia @provincia = NULL;
EXECUTE PnSPabm.bajaProvincia @provincia = 4;
EXECUTE PnSPabm.bajaProvincia @provincia = 1;

SELECT *
FROM PnTablas.Provincia;
GO

--Borrado Exitoso
EXECUTE PnSPabm.bajaProvincia @provincia = 3;

SELECT *
FROM PnTablas.Provincia;
GO

-------------------------------------------------------------------------------------
--Parque

--Insercion Fallida
EXECUTE PnSPabm.altaParque @nombre = NULL, @ubicacion = NULL, @Superficie = NULL, @tipo = NULL;
EXECUTE PnSPabm.altaParque @nombre = NULL, @ubicacion = NULL, @Superficie = NULL, @tipo = 1;
EXECUTE PnSPabm.altaParque @nombre = NULL, @ubicacion = NULL, @Superficie = 1000, @tipo = 1;
EXECUTE PnSPabm.altaParque @nombre = NULL, @ubicacion = 2, @Superficie = 1000, @tipo = 1;
EXECUTE PnSPabm.altaParque @nombre = 'Parque Iguazu', @ubicacion = 40, @Superficie = 1000, @tipo = 10;
EXECUTE PnSPabm.altaParque @nombre = 'Parque Iguazu', @ubicacion = 2, @Superficie = -1000, @tipo = 1;
EXECUTE PnSPabm.altaParque @nombre = 'Parque Iguazu', @ubicacion = 2, @Superficie = 1000, @tipo = 1;

SELECT *
FROM PnTablas.Parque;
GO

--Modificacion (Nombre) Exitosa
EXECUTE PnSPabm.modificarNombreParque @parque = 2, @nombreNEW = 'Parque Pochoclero';

SELECT *
FROM PnTablas.Parque;
GO

--Modificacion (Nombre) Fallida
EXECUTE PnSPabm.modificarNombreParque @parque = -2, @nombreNEW = NULL;
EXECUTE PnSPabm.modificarNombreParque @parque = 2, @nombreNEW = NULL
EXECUTE PnSPabm.modificarNombreParque @parque = NULL, @nombreNEW = 'Parque Pochoclero';
EXECUTE PnSPabm.modificarNombreParque @parque = 1, @nombreNEW = 'Parque Pochoclero';

SELECT *
FROM PnTablas.Parque;
GO

--Modificacion (Superficie) Exitosa
EXECUTE PnSPabm.modificarSuperficieParque @parque = 2, @SuperficieNEW = 2000;

SELECT *
FROM PnTablas.Parque;
GO

--Modificacion (Superficie) Fallida
EXECUTE PnSPabm.modificarSuperficieParque @parque = NULL, @SuperficieNEW = NULL;
EXECUTE PnSPabm.modificarSuperficieParque @parque = NULL, @SuperficieNEW = 2000;
EXECUTE PnSPabm.modificarSuperficieParque @parque = 2, @SuperficieNEW = NULL;
EXECUTE PnSPabm.modificarSuperficieParque @parque = 2, @SuperficieNEW = -2000;
EXECUTE PnSPabm.modificarSuperficieParque @parque = 10, @SuperficieNEW = 2000;

SELECT *
FROM PnTablas.Parque;
GO

--Borrado Fallido
EXECUTE PnSPabm.bajaParque @parque = NULL;
EXECUTE PnSPabm.bajaParque @parque = 6;
EXECUTE PnSPabm.bajaParque @parque = 2;

SELECT *
FROM PnTablas.Parque;
GO

--Borrado Exitoso
EXECUTE PnSPabm.bajaParque @parque = 3;

SELECT *
FROM PnTablas.Parque;
GO

-------------------------------------------------------------------------------------
--TelefonoParque

--Insercion Fallida
EXECUTE PnSPabm.altaTelefonoParque @numero = NULL, @parque = -1;
EXECUTE PnSPabm.altaTelefonoParque @numero = '4567-0352', @parque = NULL;
EXECUTE PnSPabm.altaTelefonoParque @numero = NULL, @parque = 1;
EXECUTE PnSPabm.altaTelefonoParque @numero = '4567-0352', @parque = 2;

SELECT *
FROM PnTablas.TelefonoParque;
GO

--Modificacion Exitosa
EXECUTE PnSPabm.modificarTelefonoParque @numeroOLD = '4567-0352', @numeroNEW = '11 4567-0352';

SELECT *
FROM PnTablas.TelefonoParque;
GO

--Modificacion Fallida
EXECUTE PnSPabm.modificarTelefonoParque @numeroOLD = NULL, @numeroNEW = NULL;
EXECUTE PnSPabm.modificarTelefonoParque @numeroOLD = NULL, @numeroNEW = '11 4567-0352';
EXECUTE PnSPabm.modificarTelefonoParque @numeroOLD = '4567-0352', @numeroNEW = NULL;
EXECUTE PnSPabm.modificarTelefonoParque @numeroOLD = '4567-0352', @numeroNEW = '11 4567-0352';
EXECUTE PnSPabm.modificarTelefonoParque @numeroOLD = '11 4567-0352', @numeroNEW = '4567-0345';

SELECT *
FROM PnTablas.TelefonoParque;
GO

--Borrado Fallido
EXECUTE PnSPabm.bajaTelefonoParque @numero = NULL;
EXECUTE PnSPabm.bajaTelefonoParque @numero = '4567-0300';

SELECT *
FROM PnTablas.TelefonoParque;
GO

--Borrado Exitoso
EXECUTE PnSPabm.bajaTelefonoParque @numero = '4567-0345';

SELECT *
FROM PnTablas.TelefonoParque;
GO