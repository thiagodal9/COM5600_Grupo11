/*
09/07/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

Testing de los SPs de ABM asociados a las tablas Empresa y Concesion.

PRERREQUISITOS antes de correr este script:
  1) CreacionInicial, CreacionTablas, CreacionSPabm ya deben haberse ejecutado.
  2) Este script asume que la base de datos está limpia (IDENTITY arranca en 1).
  3) SE ASUME LA EXISTENCIA DEL PARQUE 1 Y 2. Si no hay Parques cargados, las inserciones de Concesiones fallaran por integridad referencial.
*/

SET NOCOUNT ON;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--'
END;
GO

-------------------------------------------------------------------------------------
---- TESTING Empresa

--RESULTADOS ESPERADOS: Insercion Fallida (Empresa)
EXECUTE PnSPabm.altaEmpresa @nombre = NULL, @descripcion = 'Empresa sin nombre';
EXECUTE PnSPabm.altaEmpresa @nombre = 'Empresa Test', @descripcion = NULL;
GO

--RESULTADO ESPERADO: Insercion Exitosa (Empresa)
EXECUTE PnSPabm.altaEmpresa @nombre = 'EcoTurismo SA', @descripcion = 'Viajes guiados y transporte';
EXECUTE PnSPabm.altaEmpresa @nombre = 'Sabores del Sur', @descripcion = 'Gastronomia regional';
-- Empresa 3: Creada exclusivamente para testear la baja exitosa al final del script
EXECUTE PnSPabm.altaEmpresa @nombre = 'Empresa Efimera', @descripcion = 'Para borrar';
GO

SELECT * FROM PnTablas.Empresa;
GO

--RESULTADOS ESPERADOS: Insercion Fallida (Duplicidad Empresa)
EXECUTE PnSPabm.altaEmpresa @nombre = 'EcoTurismo SA', @descripcion = 'Otra descripcion';
GO

--RESULTADOS ESPERADOS: Modificacion Fallida (Empresa)
EXECUTE PnSPabm.modificacionNombreEmpresa @idEmpresa = -1, @nombreNuevo = 'Nuevo Nombre';
EXECUTE PnSPabm.modificacionDescripcionEmpresa @idEmpresa = 999, @descripcionNueva = 'Nueva desc';
EXECUTE PnSPabm.modificacionNombreEmpresa @idEmpresa = 2, @nombreNuevo = 'EcoTurismo SA';
GO

--RESULTADO ESPERADO: Modificacion Exitosa (Empresa)
EXECUTE PnSPabm.modificacionNombreEmpresa @idEmpresa = 1, @nombreNuevo = 'EcoTurismo Group';
EXECUTE PnSPabm.modificacionDescripcionEmpresa @idEmpresa = 2, @descripcionNueva = 'Restaurante y proveeduria';
GO

SELECT * FROM PnTablas.Empresa;
GO

-------------------------------------------------------------------------------------
---- TESTING Concesion

--RESULTADOS ESPERADOS: Insercion Fallida (Concesion)
DECLARE @fechaHoy DATE = CAST(GETDATE() AS DATE);
DECLARE @fechaFinDeAnio DATE = DATEADD(month, 6, GETDATE());

EXECUTE PnSPabm.altaConcesion @idEmpresa = 999, @idParque = 1, @rubro = 'Transporte', @fechaInicio = @fechaHoy, @fechaFin = @fechaFinDeAnio, @precioAlquiler = 50000;
EXECUTE PnSPabm.altaConcesion @idEmpresa = 1, @idParque = 999, @rubro = 'Transporte', @fechaInicio = @fechaHoy, @fechaFin = @fechaFinDeAnio, @precioAlquiler = 50000;
EXECUTE PnSPabm.altaConcesion @idEmpresa = 1, @idParque = 1, @rubro = 'Transporte', @fechaInicio = @fechaHoy, @fechaFin = @fechaFinDeAnio, @precioAlquiler = -100;
EXECUTE PnSPabm.altaConcesion @idEmpresa = 1, @idParque = 1, @rubro = 'Transporte', @fechaInicio = @fechaFinDeAnio, @fechaFin = @fechaHoy, @precioAlquiler = 50000;
GO

--RESULTADO ESPERADO: Insercion Exitosa (Concesion)
DECLARE @fechaHoy DATE = CAST(GETDATE() AS DATE);
DECLARE @fechaFinDeAnio DATE = DATEADD(month, 6, GETDATE());

EXECUTE PnSPabm.altaConcesion @idEmpresa = 1, @idParque = 1, @rubro = 'Transporte', @fechaInicio = @fechaHoy, @fechaFin = @fechaFinDeAnio, @precioAlquiler = 150000.50;
EXECUTE PnSPabm.altaConcesion @idEmpresa = 2, @idParque = 2, @rubro = 'Gastronomia', @fechaInicio = @fechaHoy, @fechaFin = @fechaFinDeAnio, @precioAlquiler = 85000.00;
-- Concesion 3: Creada para testear la baja de Concesion sin afectar el proximo script
EXECUTE PnSPabm.altaConcesion @idEmpresa = 3, @idParque = 1, @rubro = 'Souvenirs', @fechaInicio = @fechaHoy, @fechaFin = @fechaFinDeAnio, @precioAlquiler = 10000.00;
GO

SELECT * FROM PnTablas.Concesion;
GO

--RESULTADOS ESPERADOS: Modificacion Fallida (Concesion)
DECLARE @fechaAyer DATE = DATEADD(day, -1, GETDATE());

EXECUTE PnSPabm.modificacionCostoConcesion @idConcesion = 1, @costo = -500;
EXECUTE PnSPabm.modificacionFechaFConcesion @idConcesion = 1, @fechaFinNEW = @fechaAyer;
EXECUTE PnSPabm.modificacionCostoConcesion @idConcesion = 999, @costo = 10000;
GO

--RESULTADO ESPERADO: Modificacion Exitosa (Concesion)
DECLARE @fechaNueva DATE = DATEADD(year, 1, GETDATE());

EXECUTE PnSPabm.modificacionCostoConcesion @idConcesion = 1, @costo = 200000.00;
EXECUTE PnSPabm.modificacionFechaFConcesion @idConcesion = 2, @fechaFinNEW = @fechaNueva;
GO

SELECT * FROM PnTablas.Concesion;
GO

-------------------------------------------------------------------------------------
---- TESTING Bajas Exitosas (ABM Puro sin dependencias transaccionales)

--RESULTADO ESPERADO: Baja Concesion Exitosa (Eliminamos la concesion 3)
EXECUTE PnSPabm.bajaConcesion @idConcesion = 3;
GO
SELECT * FROM PnTablas.Concesion;
GO

--RESULTADO ESPERADO: Baja Empresa Exitosa (Eliminamos la empresa 3)
EXECUTE PnSPabm.bajaEmpresa @idEmpresa = 3;
GO
SELECT * FROM PnTablas.Empresa;
GO