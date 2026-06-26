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

PRINT '--Creando SPabm para tablas Entrada...--';
GO

/*
================================================================
abm PagoVenta
================================================================
*/
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaPagoVenta'))
	DROP PROCEDURE PnSPabm.altaPagoVenta
GO
create procedure PnSPabm.altaPagoVenta
@importe decimal(10,2),
@fechaHora DATETIME,
@item char(30),
@metodo char(30)
as
begin
	DECLARE @IDout TABLE(ID INT)

	insert into PnTablas.PagoVenta(importe, FechaHoraTransaccion, item, metodo)
	OUTPUT inserted.idPagoVenta INTO @IDout(ID)
	values (@importe, @fechaHora, @item, @metodo)

	RETURN (SELECT ID FROM @IDout)
end
go

/*
================================================================
abm #ventaEntradas
================================================================
*/
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaVentaEntradas'))
	DROP PROCEDURE PnSPabm.altaVentaEntradas
GO
create procedure PnSPabm.altaVentaEntradas
@Entrada INT,
@Cantidad INT,
@FechaAcceso DATE
as
begin
	insert #ventaEntradas(Entrada, Cantidad, FechaAcceso) 
	values (@Entrada, @Cantidad, @FechaAcceso)
end
go

-------------------------------------------------------------------------------------
--Modificacion
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarVentaEntradas'))
	DROP PROCEDURE PnSPabm.modificarVentaEntradas
GO
CREATE PROCEDURE PnSPabm.modificarVentaEntradas
@entrada INT,
@cantidadNEW INT,
@fechaAcceso DATE
AS
BEGIN
	UPDATE #ventaEntradas
	SET Cantidad = Cantidad + @cantidadNEW
	WHERE Entrada = @entrada AND FechaAcceso = @fechaAcceso
END;
GO

-------------------------------------------------------------------------------------
--Baja
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaAllVentaEntradas'))
	DROP PROCEDURE PnSPabm.bajaAllVentaEntradas
GO
CREATE PROCEDURE PnSPabm.bajaAllVentaEntradas
AS
BEGIN
	TRUNCATE TABLE #ventaEntradas
END;
GO

/*
================================================================
abm #ventaActividades
================================================================
*/
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaVentaActividades'))
	DROP PROCEDURE PnSPabm.altaVentaActividades
GO
create procedure PnSPabm.altaVentaActividades
@Actividad INT,
@FechaActividad DATE,
@HoraInicio TIME,
@Cantidad INT
as
begin
	insert #ventaActividades(Actividad, HoraInicio, FechaActividad, Cantidad)
	values (@Actividad, @HoraInicio, @FechaActividad, @Cantidad)
end
go

-------------------------------------------------------------------------------------
--Modificacion
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarVentaActividades'))
	DROP PROCEDURE PnSPabm.modificarVentaActividades
GO
CREATE PROCEDURE PnSPabm.modificarVentaActividades
@actividad INT,
@fechaActividad DATE,
@horaInicio TIME,
@cantidadNew INT
AS
BEGIN
	UPDATE #ventaActividades
	SET Cantidad = Cantidad + @cantidadNew
	WHERE Actividad = @actividad AND FechaActividad = @fechaActividad AND HoraInicio = @horaInicio
END;
GO

-------------------------------------------------------------------------------------
--Baja
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaAllVentaActividades'))
	DROP PROCEDURE PnSPabm.bajaAllVentaActividades
GO
CREATE PROCEDURE PnSPabm.bajaAllVentaActividades
AS
BEGIN
	TRUNCATE TABLE #ventaActividades
END;
GO