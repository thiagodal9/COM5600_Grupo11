/*
09/07/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

Testing de los SPs de ABM asociados a las tablas TipoEntrada y Entrada.

antes de correr este script:
  1) Este script asume una base de datos limpia (IDENTITY arranca en 1);
     si se re-ejecuta sobre una BD con datos previos, los IDs hardcodeados
     mas abajo van a dejar de corresponder a las filas esperadas.

Los Parques y TipoEntrada-Entrada creados aca (Parque 1 y 2, TipoEntrada
1/2/4, Entrada 1/2) son reutilizados por TestingSPabmVenta.sql y
TestingSPtransVenta.sql, por lo que este script debe correrse primero y
en la misma sesion que esos.
*/

SET NOCOUNT ON;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--'
END;
GO

-------------------------------------------------------------------------------------
---- Carga base (Provincia, TipoParque, Parque) para poder dar de alta Entradas

EXECUTE PnSPabm.altaProvincia @nombre = 'Buenos Aires';
GO
EXECUTE PnSPabm.altaTipoParque @tipo = 'Nacional';
GO
EXECUTE PnSPabm.altaParque @nombre = 'Parque Test Norte', @ubicacion = 1, @superficie = 5000, @tipo = 1;
EXECUTE PnSPabm.altaParque @nombre = 'Parque Test Sur',   @ubicacion = 1, @superficie = 8000, @tipo = 1;
GO

SELECT * FROM PnTablas.Parque;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING TipoEntrada

--RESULTADOS ESPERADOS: Insercion Fallida

-- Falla por descripcion nula
EXECUTE PnSPabm.altaTipoEntrada @DescripcionTipoEntrada = NULL;
GO

SELECT * FROM PnTablas.TipoEntrada;
GO

--RESULTADO ESPERADO: Insercion Exitosa

EXECUTE PnSPabm.altaTipoEntrada @DescripcionTipoEntrada = 'General';
EXECUTE PnSPabm.altaTipoEntrada @DescripcionTipoEntrada = 'Jubilados';
GO

SELECT * FROM PnTablas.TipoEntrada;
GO

--RESULTADOS ESPERADOS: Insercion Fallida (duplicidad)

-- Falla porque 'General' ya esta cargado
EXECUTE PnSPabm.altaTipoEntrada @DescripcionTipoEntrada = 'General';
GO

SELECT * FROM PnTablas.TipoEntrada;
GO

-------------------------------------------------------------------------------------
--RESULTADOS ESPERADOS: Modificacion Fallida

-- Falla por ID nulo/invalido
EXECUTE PnSPabm.modificacionTipoEntrada @idTipoEntrada = NULL, @descripcionNueva = 'X';
EXECUTE PnSPabm.modificacionTipoEntrada @idTipoEntrada = -1, @descripcionNueva = 'X';
-- Falla por tipo inexistente
EXECUTE PnSPabm.modificacionTipoEntrada @idTipoEntrada = 999, @descripcionNueva = 'X';
-- Falla por descripcion nueva nula
EXECUTE PnSPabm.modificacionTipoEntrada @idTipoEntrada = 2, @descripcionNueva = NULL;
GO

SELECT * FROM PnTablas.TipoEntrada;
GO

EXECUTE PnSPabm.modificacionTipoEntrada @idTipoEntrada = 2, @descripcionNueva = 'General';
GO

SELECT * FROM PnTablas.TipoEntrada;
GO

--RESULTADO ESPERADO: Modificacion Exitosa

EXECUTE PnSPabm.modificacionTipoEntrada @idTipoEntrada = 2, @descripcionNueva = 'Jubilados';
GO

SELECT * FROM PnTablas.TipoEntrada;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING Entrada

--RESULTADOS ESPERADOS: Insercion Fallida

-- Falla por parametros nulos
EXECUTE PnSPabm.altaEntrada @idTipoEntrada = NULL, @precio = NULL, @parque = NULL;
-- Falla por tipo invalido (<= 0)
EXECUTE PnSPabm.altaEntrada @idTipoEntrada = -1, @precio = 100, @parque = 1;
-- Falla por parque invalido (<= 0)
EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 100, @parque = -1;
-- Falla por precio invalido (<= 0)
EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 0, @parque = 1;
-- Falla por tipo inexistente
EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 999, @precio = 100, @parque = 1;
-- Falla por parque inexistente
EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 100, @parque = 999;
GO

SELECT * FROM PnTablas.Entrada;
GO

--RESULTADO ESPERADO: Insercion Exitosa

-- Entrada 1: TipoEntrada 1 (General) en el Parque 1
EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 1500.00, @parque = 1;
-- Entrada 2: TipoEntrada 2 (Jubilados) en el Parque 1
EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 2, @precio = 800.00, @parque = 1;
GO

SELECT * FROM PnTablas.Entrada;
GO

--RESULTADOS ESPERADOS: Insercion Fallida (duplicidad)

-- Falla porque ya existe una Entrada para el par (Parque 1, TipoEntrada 1)
EXECUTE PnSPabm.altaEntrada @idTipoEntrada = 1, @precio = 1600.00, @parque = 1;
GO

SELECT * FROM PnTablas.Entrada;
GO

-------------------------------------------------------------------------------------
--RESULTADOS ESPERADOS: Baja Fallida

-- Falla por ID nulo/invalido
EXECUTE PnSPabm.bajaTipoEntrada @idTipoEntrada = NULL;
EXECUTE PnSPabm.bajaTipoEntrada @idTipoEntrada = -1;
-- Falla por tipo inexistente
EXECUTE PnSPabm.bajaTipoEntrada @idTipoEntrada = 999;
-- Falla porque el TipoEntrada 1 (General) tiene una Entrada asociada (Entrada 1)
EXECUTE PnSPabm.bajaTipoEntrada @idTipoEntrada = 1;
GO

SELECT * FROM PnTablas.TipoEntrada;
GO

--RESULTADO ESPERADO: Baja Exitosa

-- Se crea un TipoEntrada 'de sobra', sin ninguna Entrada asociada, solo para
-- poder probar la baja exitosa sin afectar los datos usados mas adelante.
EXECUTE PnSPabm.altaTipoEntrada @DescripcionTipoEntrada = 'Descuento Grupal';
GO
SELECT * FROM PnTablas.TipoEntrada;
GO
-- El TipoEntrada recien creado no tiene Entradas asociadas -> baja exitosa
EXECUTE PnSPabm.bajaTipoEntrada @idTipoEntrada = 3;
GO

SELECT * FROM PnTablas.TipoEntrada;
GO

-------------------------------------------------------------------------------------
--RESULTADOS ESPERADOS: Baja Fallida (validaciones)

EXECUTE PnSPabm.bajaEntrada @idEntrada = NULL;
EXECUTE PnSPabm.bajaEntrada @idEntrada = -1;
EXECUTE PnSPabm.bajaEntrada @idEntrada = 999;
GO

EXECUTE PnSPabm.bajaEntrada @idEntrada = 2;
GO

SELECT * FROM PnTablas.Entrada;
GO

-------------------------------------------------------------------------------------
--RESULTADOS ESPERADOS: Modificacion (Precio) Fallida

EXECUTE PnSPabm.modificacionPrecioEntrada @idEntrada = NULL, @precioNuevo = 1000;
EXECUTE PnSPabm.modificacionPrecioEntrada @idEntrada = -1, @precioNuevo = 1000;
EXECUTE PnSPabm.modificacionPrecioEntrada @idEntrada = 1, @precioNuevo = 0;
EXECUTE PnSPabm.modificacionPrecioEntrada @idEntrada = 1, @precioNuevo = -50;
EXECUTE PnSPabm.modificacionPrecioEntrada @idEntrada = 999, @precioNuevo = 1000;
GO

SELECT * FROM PnTablas.Entrada;
GO

--RESULTADO ESPERADO: Modificacion (Precio) Exitosa

EXECUTE PnSPabm.modificacionPrecioEntrada @idEntrada = 2, @precioNuevo = 950.00;
GO

SELECT * FROM PnTablas.Entrada;
GO
