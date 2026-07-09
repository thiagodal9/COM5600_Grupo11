/*
09/07/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

PRERREQUISITOS :
  1) TestingSPabmEntrada.sql debe haberse corrido antes, en la misma conexion:
    #ventaEntradas y #ventaActividades son tablas temporales LOCALES,
     por lo que solo son visibles dentro de la conexion que las creo. Si
     este script se corre en una ventana de consulta nueva, hay que volver
     a correr TestingSPabmEntrada.sql primero en esa misma ventana.
  2) Este script asume una base de datos limpia (IDENTITY de PagoVenta
     arranca en 1). Al final de este script la tabla PagoVenta queda
     vacia otra vez, asi que el proximo IDPagoVenta generado sera 4.
*/

SET NOCOUNT ON;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--'
END;
GO


-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING altaPagoVenta

DECLARE @pago1 INT, @pago2 INT, @pago3 INT;

EXECUTE @pago1 = PnSPabm.altaPagoVenta @importe = 1500.00, @fechaHora = '2026-07-01T10:00:00', @item = 'Entradas',    @metodo = 'Efectivo', @moneda = 'Dolar';
EXECUTE @pago2 = PnSPabm.altaPagoVenta @importe = 900.00,  @fechaHora = '2026-07-01T11:30:00', @item = 'Actividades', @metodo = 'Tarjeta', @moneda = 'Peso';
EXECUTE @pago3 = PnSPabm.altaPagoVenta @importe = 300.00,  @fechaHora = '2026-07-01T12:15:00', @item = 'Entradas',    @metodo = 'Efectivo', @moneda = 'Peso';

PRINT CONCAT('IDs generados: ', @pago1, ', ', @pago2, ', ', @pago3);
GO

SELECT * FROM PnTablas.PagoVenta;
GO

-------------------------------------------------------------------------------------
---- TESTING bajaPagoVentaOne

--RESULTADOS ESPERADOS: Baja Fallida (validaciones)

EXECUTE PnSPabm.bajaPagoVentaOne @pago = NULL;
EXECUTE PnSPabm.bajaPagoVentaOne @pago = -1;
EXECUTE PnSPabm.bajaPagoVentaOne @pago = 999;
GO


EXECUTE PnSPabm.bajaPagoVentaOne @pago = 1;
GO

-- Se espera que el Pago 1 siga existiendo pese al "exito" esperable, evidenciando el bug
SELECT * FROM PnTablas.PagoVenta;
GO

-------------------------------------------------------------------------------------
---- TESTING bajaPagoVentaMany

--RESULTADOS ESPERADOS: Baja Fallida

EXECUTE PnSPabm.bajaPagoVentaMany @fecha = NULL;
-- Falla porque la fecha no puede ser hoy o futura
EXECUTE PnSPabm.bajaPagoVentaMany @fecha = '2026-07-09';
GO

SELECT * FROM PnTablas.PagoVenta;
GO

--RESULTADO ESPERADO: Baja Exitosa

EXECUTE PnSPabm.bajaPagoVentaMany @fecha = '2026-07-08';
GO

SELECT * FROM PnTablas.PagoVenta;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING #ventaEntradas 

EXECUTE PnSPabm.altaVentaEntradas @Entrada = 1, @Cantidad = 2, @FechaAcceso = '2026-08-01';
EXECUTE PnSPabm.altaVentaEntradas @Entrada = 2, @Cantidad = 1, @FechaAcceso = '2026-08-01';
GO

SELECT * FROM #ventaEntradas;
GO

-- Acumula cantidad sobre la fila existente
EXECUTE PnSPabm.modificarVentaEntradas @entrada = 1, @cantidadNEW = 3, @fechaAcceso = '2026-08-01';
GO

SELECT * FROM #ventaEntradas;
GO

EXECUTE PnSPabm.bajaAllVentaEntradas;
GO

--Se espera vacio
SELECT * FROM #ventaEntradas;
GO

-------------------------------------------------------------------------------------
---- TESTING #ventaActividades

EXECUTE PnSPabm.altaVentaActividades @Actividad = 1, @FechaActividad = '2026-08-01', @HoraInicio = '09:00', @Cantidad = 2;
EXECUTE PnSPabm.altaVentaActividades @Actividad = 1, @FechaActividad = '2026-08-01', @HoraInicio = '14:00', @Cantidad = 4;
GO

SELECT * FROM #ventaActividades;
GO

-- Acumula cantidad sobre la fila existente
EXECUTE PnSPabm.modificarVentaActividades @actividad = 1, @fechaActividad = '2026-08-01', @horaInicio = '09:00', @cantidadNew = 1;
GO

SELECT * FROM #ventaActividades;
GO

EXECUTE PnSPabm.bajaAllVentaActividades;
GO

--Se espera vacio
SELECT * FROM #ventaActividades;
GO
