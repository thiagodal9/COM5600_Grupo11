/*
09/07/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

Testing de los SPs Transaccionales asociados a HistorialPago,
incluyendo restricciones de eliminacion en cascada.

PRERREQUISITOS:
  1) Haber ejecutado CreacionSPtransConcesion.sql
  2) HABER EJECUTADO TestingSPabmConcesion.sql previamente para tener
     las Empresas (1 y 2) y las Concesiones (1 y 2) cargadas.
*/

SET NOCOUNT ON;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--'
END;
GO

DECLARE @fechaAyer DATE = DATEADD(day, -1, GETDATE());
DECLARE @fechaManana DATE = DATEADD(day, 1, GETDATE());
DECLARE @fechaMesQueViene DATE = DATEADD(month, 1, GETDATE());

-------------------------------------------------------------------------------------
---- TESTING HistorialPago (Facturas)

--RESULTADOS ESPERADOS: Insercion Fallida (Factura)
EXECUTE PnSPtrans.altaFacturaConcesion @concesion = 1, @vencimiento = @fechaAyer;
EXECUTE PnSPtrans.altaFacturaConcesion @concesion = 999, @vencimiento = @fechaManana;
GO

--RESULTADO ESPERADO: Insercion Exitosa (Factura)
DECLARE @fechaManana DATE = DATEADD(day, 1, GETDATE());
DECLARE @fechaMesQueViene DATE = DATEADD(month, 1, GETDATE());

-- Se generan dos facturas para la concesion 1
EXECUTE PnSPtrans.altaFacturaConcesion @concesion = 1, @vencimiento = @fechaManana;
EXECUTE PnSPtrans.altaFacturaConcesion @concesion = 1, @vencimiento = @fechaMesQueViene;
-- Se genera una factura para la concesion 2
EXECUTE PnSPtrans.altaFacturaConcesion @concesion = 2, @vencimiento = @fechaManana;
GO

SELECT * FROM PnTablas.HistorialPago;
GO

--RESULTADOS ESPERADOS: Insercion Fallida (Duplicidad Factura)
DECLARE @fechaManana DATE = DATEADD(day, 1, GETDATE());
EXECUTE PnSPtrans.altaFacturaConcesion @concesion = 1, @vencimiento = @fechaManana;
GO

--RESULTADOS ESPERADOS: Pago Factura Fallido
EXECUTE PnSPtrans.pagoFactura @idFactura = NULL;
EXECUTE PnSPtrans.pagoFactura @idFactura = 999;
GO

--RESULTADO ESPERADO: Pago Factura Exitoso
-- Pagamos la factura 1 (Concesion 1) y la factura 3 (Concesion 2)
EXECUTE PnSPtrans.pagoFactura @idFactura = 1;
EXECUTE PnSPtrans.pagoFactura @idFactura = 3;
GO

SELECT * FROM PnTablas.HistorialPago;
GO

--RESULTADOS ESPERADOS: Pago Factura Fallido (Ya pagada)
-- Falla porque la Factura 1 acaba de ser pagada
EXECUTE PnSPtrans.pagoFactura @idFactura = 1;
GO

-------------------------------------------------------------------------------------
---- TESTING Bajas con Referencias Transaccionales (Cascada controlada)

--RESULTADOS ESPERADOS: Baja Empresa Fallida (Tiene concesiones)
-- Empresa 1 tiene la Concesion 1 activa
EXECUTE PnSPabm.bajaEmpresa @idEmpresa = 1;
GO

--RESULTADOS ESPERADOS: Baja Concesion Fallida (Tiene facturas)
-- Concesion 1 tiene facturas en HistorialPago
EXECUTE PnSPabm.bajaConcesion @idConcesion = 1;
GO

--RESULTADO ESPERADO: Baja Facturas (Limpieza batch) Exitosa
DECLARE @fechaLimite DATE = DATEADD(day, 2, GETDATE()); 
-- Deberia borrar la Factura 1 y 3 (que estan PAGAS y vencen manana), 
-- pero dejar la 2 (que vence en un mes y esta Impaga)
EXECUTE PnSPtrans.bajaFacturaConcesionMany @fecha = @fechaLimite;
GO

SELECT * FROM PnTablas.HistorialPago;
GO

--RESULTADO ESPERADO: Preparacion para Bajas Finales
-- Para poder borrar la Concesion 1, debemos eliminar manualmente la factura 2 que quedo 'Impaga'
EXECUTE PnSPtrans.pagoFactura @idFactura = 2;

DECLARE @fechaLejana DATE = DATEADD(year, 1, GETDATE());
EXECUTE PnSPtrans.bajaFacturaConcesionMany @fecha = @fechaLejana;
GO

--RESULTADO ESPERADO: Bajas Finales Exitosas (Cascada liberada)
-- Ahora que la Concesion 1 no tiene facturas, se puede dar de baja
EXECUTE PnSPabm.bajaConcesion @idConcesion = 1;
GO
SELECT * FROM PnTablas.Concesion;
GO

-- Ahora que la Empresa 1 no tiene concesiones, se puede dar de baja
EXECUTE PnSPabm.bajaEmpresa @idEmpresa = 1;
GO
SELECT * FROM PnTablas.Empresa;
GO