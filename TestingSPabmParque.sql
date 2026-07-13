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

-- Testing de los SPs de ABM asociados a las tablas Parque
-- Los SP ABM de la tabla HorarioParque se testean junto a los SP transaccionales de dicha tabla

SET NOCOUNT ON;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

-------------------------------------------------------------------------------------
---- Chequeo de datos cargados inicialmente
SELECT * FROM PnTablas.TipoParque;
GO
SELECT * FROM PnTablas.Provincia;
GO
SELECT * FROM PnTablas.Parque;
GO
SELECT * FROM PnTablas.Dia;
GO
SELECT * FROM PnTablas.TelefonoParque;
GO

-------------------------------------------------------------------------------------
---- TESTING TipoParque

--RESULTADOS ESPERADOS: Inserción fallida

-- Falla por parámetro nulo
EXECUTE PnSPabm.altaTipoParque @tipo = NULL;
-- Falla por tipo de dato incorrecto (espera numérico, recibe varchar)
EXECUTE PnSPabm.altaTipoParque @tipo = 'reserva';
GO

SELECT * FROM PnTablas.TipoParque;
GO

--RESULTADO ESPERADO: Modificación exitosa

EXECUTE PnSPabm.modificacionDescripcionTipoParque @tipo = 1, @descripcionNEW = 'Reserva Animaaaal';
GO

SELECT * FROM PnTablas.TipoParque;
GO

--RESULTADOS ESPERADOS: Modificación fallida

-- Falla por descripción nula
EXECUTE PnSPabm.modificacionDescripcionTipoParque @tipo = 1, @descripcionNEW = NULL;
-- Falla por parámetros nulos
EXECUTE PnSPabm.modificacionDescripcionTipoParque @tipo = NULL, @descripcionNEW = NULL;
-- Falla por ID nulo
EXECUTE PnSPabm.modificacionDescripcionTipoParque @tipo = NULL, @descripcionNEW = 'Reserva Pesquera';
-- Falla por registro idéntico (sin cambios reales)
EXECUTE PnSPabm.modificacionDescripcionTipoParque @tipo = 1, @descripcionNEW = 'Reserva Animaaaal';
GO

SELECT * FROM PnTablas.TipoParque;
GO

--RESULTADOS ESPERADOS: Borrado fallido

-- Falla por parámetro nulo
EXECUTE PnSPabm.bajaTipoParque @tipo = NULL;
-- Falla por ID inexistente
EXECUTE PnSPabm.bajaTipoParque @tipo = 8;
-- Falla por integridad referencial (ID en uso por otra tabla)
EXECUTE PnSPabm.bajaTipoParque @tipo = 2;
GO

SELECT * FROM PnTablas.TipoParque;
GO

--RESULTADO ESPERADO: Borrado exitoso

EXECUTE PnSPabm.bajaTipoParque @tipo = 4;
GO

SELECT * FROM PnTablas.TipoParque;
GO

-------------------------------------------------------------------------------------
---- TESTING Provincia

--RESULTADOS ESPERADOS: Inserción Fallida

-- Falla por parámetro nulo
EXECUTE PnSPabm.altaProvincia @nombre = NULL;
-- Falla por registro duplicado (violación de UNIQUE)
EXECUTE PnSPabm.altaProvincia @nombre = 'Rio Negro';
GO

SELECT * FROM PnTablas.Provincia;
GO

--RESULTADO ESPERADO: Modificación Exitosa

EXECUTE PnSPabm.modificarNombreProvincia @provincia = 1, @nombreNEW = 'Rio Negro';
GO

SELECT * FROM PnTablas.Provincia;
GO

--RESULTADOS ESPERADOS: Modificación Fallida

-- Falla por parámetros nulos
EXECUTE PnSPabm.modificarNombreProvincia @provincia = NULL, @nombreNEW = NULL;
-- Falla por ID nulo
EXECUTE PnSPabm.modificarNombreProvincia @provincia = NULL, @nombreNEW = 'La Pampa';
-- Falla por nuevo nombre nulo
EXECUTE PnSPabm.modificarNombreProvincia @provincia = 1, @nombreNEW = NULL;
-- Falla por error de formato o regla de negocio
EXECUTE PnSPabm.modificarNombreProvincia @provincia = 1, @nombreNEW = 'saNta CrUz';
GO

SELECT * FROM PnTablas.Provincia;
GO

--RESULTADOS ESPERADOS: Borrado Fallido

-- Falla por ID nulo
EXECUTE PnSPabm.bajaProvincia @provincia = NULL;
-- Falla por ID inexistente
EXECUTE PnSPabm.bajaProvincia @provincia = 4;
-- Falla por integridad referencial
EXECUTE PnSPabm.bajaProvincia @provincia = 1;
GO

SELECT * FROM PnTablas.Provincia;
GO

--RESULTADO ESPERADO: Borrado Exitoso

EXECUTE PnSPabm.bajaProvincia @provincia = 3;
GO

SELECT * FROM PnTablas.Provincia;
GO

-------------------------------------------------------------------------------------
---- TESTING Parque

--RESULTADOS ESPERADOS: Inserción Fallida

-- Falla por parámetros nulos requeridos
EXECUTE PnSPabm.altaParque @nombre = NULL, @ubicacion = NULL, @Superficie = NULL, @tipo = NULL;
EXECUTE PnSPabm.altaParque @nombre = NULL, @ubicacion = NULL, @Superficie = NULL, @tipo = 1;
EXECUTE PnSPabm.altaParque @nombre = NULL, @ubicacion = NULL, @Superficie = 1000, @tipo = 1;
EXECUTE PnSPabm.altaParque @nombre = NULL, @ubicacion = 2, @Superficie = 1000, @tipo = 1;
-- Falla por ID de tipo inexistente (Violación de FK)
EXECUTE PnSPabm.altaParque @nombre = 'Parque Iguazu', @ubicacion = 40, @Superficie = 1000, @tipo = 10;
-- Falla por superficie negativa (Violación de Constraint CHECK)
EXECUTE PnSPabm.altaParque @nombre = 'Parque Iguazu', @ubicacion = 2, @Superficie = -1000, @tipo = 1;
-- Falla por duplicidad
EXECUTE PnSPabm.altaParque @nombre = 'Parque Iguazu', @ubicacion = 2, @Superficie = 1000, @tipo = 1;
GO

SELECT * FROM PnTablas.Parque;
GO

--RESULTADO ESPERADO: Modificación (Nombre) Exitosa

EXECUTE PnSPabm.modificarNombreParque @parque = 2, @nombreNEW = 'Parque Pochoclero';
GO

SELECT * FROM PnTablas.Parque;
GO

--RESULTADOS ESPERADOS: Modificación (Nombre) Fallida

-- Falla por ID inválido/negativo
EXECUTE PnSPabm.modificarNombreParque @parque = -2, @nombreNEW = NULL;
-- Falla por parámetros nulos
EXECUTE PnSPabm.modificarNombreParque @parque = 2, @nombreNEW = NULL;
EXECUTE PnSPabm.modificarNombreParque @parque = NULL, @nombreNEW = 'Parque Pochoclero';
-- Falla por registro inexistente o idéntico
EXECUTE PnSPabm.modificarNombreParque @parque = 1, @nombreNEW = 'Parque Pochoclero';
GO

SELECT * FROM PnTablas.Parque;
GO

--RESULTADO ESPERADO: Modificación (Superficie) Exitosa

EXECUTE PnSPabm.modificarSuperficieParque @parque = 2, @SuperficieNEW = 2000;
GO

SELECT * FROM PnTablas.Parque;
GO

--RESULTADOS ESPERADOS: Modificación (Superficie) Fallida

-- Fallas por nulos, negativos (CHECK constraint) o ID inexistente
EXECUTE PnSPabm.modificarSuperficieParque @parque = NULL, @SuperficieNEW = NULL;
EXECUTE PnSPabm.modificarSuperficieParque @parque = NULL, @SuperficieNEW = 2000;
EXECUTE PnSPabm.modificarSuperficieParque @parque = 2, @SuperficieNEW = NULL;
EXECUTE PnSPabm.modificarSuperficieParque @parque = 2, @SuperficieNEW = -2000;
EXECUTE PnSPabm.modificarSuperficieParque @parque = 10, @SuperficieNEW = 2000;
GO

SELECT * FROM PnTablas.Parque;
GO

--RESULTADOS ESPERADOS: Borrado Fallido

-- Falla por nulo, inexistente o integridad referencial
EXECUTE PnSPabm.bajaParque @parque = NULL;
EXECUTE PnSPabm.bajaParque @parque = 6;
EXECUTE PnSPabm.bajaParque @parque = 2;
GO

SELECT * FROM PnTablas.Parque;
GO

--RESULTADO ESPERADO: Borrado Exitoso

EXECUTE PnSPabm.bajaParque @parque = 3;
GO

SELECT * FROM PnTablas.Parque;
GO

-------------------------------------------------------------------------------------
---- TESTING TelefonoParque

--RESULTADOS ESPERADOS: Inserción Fallida

-- Falla por parámetro nulo o FK inválida
EXECUTE PnSPabm.altaTelefonoParque @numero = NULL, @parque = -1;
EXECUTE PnSPabm.altaTelefonoParque @numero = '4567-0352', @parque = NULL;
EXECUTE PnSPabm.altaTelefonoParque @numero = NULL, @parque = 1;
EXECUTE PnSPabm.altaTelefonoParque @numero = '4567-0352', @parque = 2;
GO

SELECT * FROM PnTablas.TelefonoParque;
GO

--RESULTADO ESPERADO: Modificación Exitosa

EXECUTE PnSPabm.modificarTelefonoParque @numeroOLD = '4567-0352', @numeroNEW = '11 4567-0352';
GO

SELECT * FROM PnTablas.TelefonoParque;
GO

--RESULTADOS ESPERADOS: Modificación Fallida

-- Falla por parámetros nulos, nros inexistentes o duplicidad
EXECUTE PnSPabm.modificarTelefonoParque @numeroOLD = NULL, @numeroNEW = NULL;
EXECUTE PnSPabm.modificarTelefonoParque @numeroOLD = NULL, @numeroNEW = '11 4567-0352';
EXECUTE PnSPabm.modificarTelefonoParque @numeroOLD = '4567-0352', @numeroNEW = NULL;
EXECUTE PnSPabm.modificarTelefonoParque @numeroOLD = '4567-0352', @numeroNEW = '11 4567-0352';
EXECUTE PnSPabm.modificarTelefonoParque @numeroOLD = '11 4567-0352', @numeroNEW = '4567-0345';
GO

SELECT * FROM PnTablas.TelefonoParque;
GO

--RESULTADOS ESPERADOS: Borrado Fallido

-- Falla por valor nulo o registro inexistente
EXECUTE PnSPabm.bajaTelefonoParque @numero = NULL;
EXECUTE PnSPabm.bajaTelefonoParque @numero = '4567-0300';
GO

SELECT * FROM PnTablas.TelefonoParque;
GO

--RESULTADO ESPERADO: Borrado Exitoso

EXECUTE PnSPabm.bajaTelefonoParque @numero = '4567-0345';
GO

SELECT * FROM PnTablas.TelefonoParque;
GO