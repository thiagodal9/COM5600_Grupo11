/*
-/-/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL


Este script carga su propia base de Actividad (TipoActividad, Actividad,
HorarioActividad), ya que no hay seed data propia para estas tablas.
*/

SET NOCOUNT ON;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--'
END;
GO

-------------------------------------------------------------------------------------
---- Carga base de Actividad

EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Trekking', @costo = 500.00;
GO
EXECUTE PnSPabm.altaActividad @nombre = 'Trekking Cerro Test', @duracion = 120, @cupo = 10, @parque = 1, @tipo = 1;
GO
EXECUTE PnSPabm.altaHActividad @actividad = 1, @fechaAct = '2026-08-01', @hInicio = '09:00';
EXECUTE PnSPabm.altaHActividad @actividad = 1, @fechaAct = '2026-08-01', @hInicio = '14:00';
GO

SELECT * FROM PnTablas.HorarioActividad WHERE Actividad = 1;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING reservarEntradas / cancelarReservaEntradas / confirmarCompraE

--RESULTADOS ESPERADOS: Reserva Fallida

EXECUTE PnSPabm.reservarEntradas @entrada = NULL, @cantidad = NULL, @fecha = NULL;
EXECUTE PnSPabm.reservarEntradas @entrada = 1, @cantidad = 0, @fecha = '2026-08-01';
EXECUTE PnSPabm.reservarEntradas @entrada = 1, @cantidad = 2, @fecha = '2020-01-01';
-- Falla porque no existe un TipoEntrada con ese ID
EXECUTE PnSPabm.reservarEntradas @entrada = 999, @cantidad = 2, @fecha = '2026-08-01';
GO

SELECT * FROM #ventaEntradas;
GO

--RESULTADO ESPERADO: Confirmacion Fallida (carrito vacio)

EXECUTE PnSPtrans.confirmarCompraE @metodo = 'Efectivo';
GO

-------------------------------------------------------------------------------------
--RESULTADO ESPERADO: Reserva Exitosa

-- Entrada 1 (TipoEntrada 1 'General'), 2 lugares
EXECUTE PnSPabm.reservarEntradas @entrada = 1, @cantidad = 2, @fecha = '2026-08-01';
-- Mismo entrada+fecha: se acumula (2 + 3 = 5)
EXECUTE PnSPabm.reservarEntradas @entrada = 1, @cantidad = 3, @fecha = '2026-08-01';
-- Entrada 2 (TipoEntrada 2 'Jubilados'), 1 lugar
EXECUTE PnSPabm.reservarEntradas @entrada = 2, @cantidad = 1, @fecha = '2026-08-01';
GO

SELECT * FROM #ventaEntradas;
GO

--RESULTADOS ESPERADOS: Confirmacion Fallida (metodo invalido, carrito no vacio)

EXECUTE PnSPtrans.confirmarCompraE @metodo = 'Cripto';
EXECUTE PnSPtrans.confirmarCompraE @metodo = NULL;
GO

SELECT * FROM #ventaEntradas;
GO

--RESULTADO ESPERADO: Confirmacion Exitosa
-- Total esperado: Entrada1($1500) x 5 + Entrada2($950) x 1 = 7500 + 950 = $8450.00

EXECUTE PnSPtrans.confirmarCompraE @metodo = 'Efectivo';
GO

-- Se espera un PagoVenta nuevo (importe 8450.00, item 'Entradas') y dos filas
-- en PoseeEntrada; el carrito debe haber quedado vacio.
SELECT * FROM PnTablas.PagoVenta WHERE item = 'Entradas';
SELECT * FROM PnTablas.PoseeEntrada;
SELECT * FROM #ventaEntradas;
GO

-------------------------------------------------------------------------------------

EXECUTE PnSPabm.altaTipoEntrada @DescripcionTipoEntrada = 'VIP';
GO
SELECT * FROM PnTablas.TipoEntrada;
GO

-- Pasa la validacion de reservarEntradas (el TipoEntrada 4 SI existe)
EXECUTE PnSPabm.reservarEntradas @entrada = 4, @cantidad = 1, @fecha = '2026-08-15';
GO

SELECT * FROM #ventaEntradas;
GO

EXECUTE PnSPtrans.confirmarCompraE @metodo = 'Efectivo';
GO

SELECT * FROM PnTablas.PagoVenta WHERE item = 'Entradas' ORDER BY IDPagoVenta DESC;
SELECT * FROM PnTablas.PoseeEntrada;
GO

EXECUTE PnSPabm.cancelarReservaEntradas;
GO
SELECT * FROM #ventaEntradas;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING reservarActividad / cancelarReservaActividades / confirmarCompraA

--RESULTADOS ESPERADOS: Reserva Fallida

EXECUTE PnSPabm.reservarActividad @actividad = NULL, @cantidad = NULL, @fecha = NULL, @hora = NULL;
EXECUTE PnSPabm.reservarActividad @actividad = 999, @cantidad = 1, @fecha = '2026-08-01', @hora = '09:00';
EXECUTE PnSPabm.reservarActividad @actividad = 1, @cantidad = 0, @fecha = '2026-08-01', @hora = '09:00';
EXECUTE PnSPabm.reservarActividad @actividad = 1, @cantidad = 1, @fecha = '2020-01-01', @hora = '09:00';
-- Falla porque no existe ese horario para la actividad
EXECUTE PnSPabm.reservarActividad @actividad = 1, @cantidad = 1, @fecha = '2026-08-01', @hora = '20:00';
GO

SELECT * FROM #ventaActividades;
GO

--RESULTADO ESPERADO: Confirmacion Fallida

EXECUTE PnSPtrans.confirmarCompraA @metodo = 'Efectivo';
GO

-------------------------------------------------------------------------------------
--RESULTADO ESPERADO: Reserva Exitosa

EXECUTE PnSPabm.reservarActividad @actividad = 1, @cantidad = 2, @fecha = '2026-08-01', @hora = '09:00';
-- Mismo turno: se acumula (2 + 1 = 3)
EXECUTE PnSPabm.reservarActividad @actividad = 1, @cantidad = 1, @fecha = '2026-08-01', @hora = '09:00';
EXECUTE PnSPabm.reservarActividad @actividad = 1, @cantidad = 5, @fecha = '2026-08-01', @hora = '14:00';
GO

SELECT * FROM #ventaActividades;
GO

--RESULTADOS ESPERADOS: Confirmacion Fallida (metodo invalido)

EXECUTE PnSPtrans.confirmarCompraA @metodo = 'Cheque';
GO

SELECT * FROM #ventaActividades;
GO

--RESULTADO ESPERADO: Confirmacion Exitosa
-- Total esperado: CostoAct(500) x (3 + 5) lugares = $4000.00
EXECUTE PnSPtrans.confirmarCompraA @metodo = 'Efectivo';
GO

SELECT * FROM PnTablas.PagoVenta WHERE item = 'Actividades';
SELECT * FROM PnTablas.TieneHActividad;
SELECT * FROM #ventaActividades;
GO

-------------------------------------------------------------------------------------
--RESULTADO ESPERADO: Confirmacion Fallida (supera el cupo libre)
EXECUTE PnSPabm.reservarActividad @actividad = 1, @cantidad = 8, @fecha = '2026-08-01', @hora = '09:00';
GO

SELECT * FROM #ventaActividades;
GO

EXECUTE PnSPtrans.confirmarCompraA @metodo = 'Efectivo';
GO

-- La transaccion debe haberse revertido: ningun PagoVenta ni TieneHActividad
-- nuevos, y el carrito NO se vacia
SELECT * FROM PnTablas.PagoVenta WHERE item = 'Actividades';
SELECT * FROM #ventaActividades;
GO

EXECUTE PnSPabm.cancelarReservaActividades;
GO
SELECT * FROM #ventaActividades;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING bajaTHActividadOne / bajaTHActividadMany
DECLARE @pagoActividad INT = (SELECT MAX(IDPagoVenta) FROM PnTablas.PagoVenta WHERE item = 'Actividades');
SELECT @pagoActividad AS PagoActividadUsado;
GO

--RESULTADOS ESPERADOS: Baja Fallida

EXECUTE PnSPabm.bajaTHActividadOne @pago = NULL, @actividad = NULL, @fechaActividad = NULL, @horaInicio = NULL;
GO
-- Falla porque no existe un registro para ese turno (17:00 nunca se vendio)
DECLARE @pagoActividad INT = (SELECT MAX(IDPagoVenta) FROM PnTablas.PagoVenta WHERE item = 'Actividades');
EXECUTE PnSPabm.bajaTHActividadOne @pago = @pagoActividad, @actividad = 1, @fechaActividad = '2026-08-01', @horaInicio = '17:00';
GO

SELECT * FROM PnTablas.TieneHActividad;
GO

--RESULTADO ESPERADO: Baja Exitosa (un solo turno)

DECLARE @pagoActividad INT = (SELECT MAX(IDPagoVenta) FROM PnTablas.PagoVenta WHERE item = 'Actividades');
EXECUTE PnSPabm.bajaTHActividadOne @pago = @pagoActividad, @actividad = 1, @fechaActividad = '2026-08-01', @horaInicio = '09:00';
GO

-- Debe quedar unicamente el turno de las 14:00
SELECT * FROM PnTablas.TieneHActividad;
GO

--RESULTADOS ESPERADOS: bajaTHActividadMany Fallida

EXECUTE PnSPabm.bajaTHActividadMany @fecha = NULL;
EXECUTE PnSPabm.bajaTHActividadMany @fecha = '2026-07-09';
GO

--RESULTADO ESPERADO: bajaTHActividadMany Exitosa

DECLARE @pagoActividad INT = (SELECT MAX(IDPagoVenta) FROM PnTablas.PagoVenta WHERE item = 'Actividades');
UPDATE PnTablas.PagoVenta SET FechaHoraTransaccion = '2020-01-01T10:00:00' WHERE IDPagoVenta = @pagoActividad;
GO

EXECUTE PnSPabm.bajaTHActividadMany @fecha = '2026-07-08';
GO

-- Se espera TieneHActividad vacia
SELECT * FROM PnTablas.TieneHActividad;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING bajaVenta (baja integral de una venta: PoseeEntrada/TieneHActividad + PagoVenta)

--RESULTADOS ESPERADOS: Baja Fallida (validaciones)

EXECUTE PnSPabm.bajaVenta @idPagoVenta = NULL;
EXECUTE PnSPabm.bajaVenta @idPagoVenta = -1;
GO

EXECUTE PnSPabm.bajaVenta @idPagoVenta = 999;
GO

--RESULTADO ESPERADO: Baja Exitosa (venta de Entradas, con PoseeEntrada asociado)

DECLARE @pagoEntradas INT = (SELECT MAX(IDPagoVenta) FROM PnTablas.PagoVenta WHERE item = 'Entradas');
SELECT @pagoEntradas AS PagoEntradasUsado;
GO
DECLARE @pagoEntradas INT = (SELECT MAX(IDPagoVenta) FROM PnTablas.PagoVenta WHERE item = 'Entradas');
EXECUTE PnSPabm.bajaVenta @idPagoVenta = @pagoEntradas;
GO

-- Se espera que ese PagoVenta y sus filas de PoseeEntrada hayan desaparecido
SELECT * FROM PnTablas.PagoVenta WHERE item = 'Entradas';
SELECT * FROM PnTablas.PoseeEntrada;
GO

--RESULTADO ESPERADO: Baja Exitosa

DECLARE @pagoActividad INT = (SELECT MAX(IDPagoVenta) FROM PnTablas.PagoVenta WHERE item = 'Actividades');
EXECUTE PnSPabm.bajaVenta @idPagoVenta = @pagoActividad;
GO

SELECT * FROM PnTablas.PagoVenta;
GO

--RESULTADOS ESPERADOS: Baja Fallida

DECLARE @pagoActividad INT = (SELECT MAX(IDPagoVenta) FROM PnTablas.PagoVenta WHERE item = 'Actividades');
EXECUTE PnSPabm.bajaVenta @idPagoVenta = ISNULL(@pagoActividad, 1);
GO
