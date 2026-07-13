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
--Alta(sin validaciones, los datos de entrada los da un SP superior)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaPagoVenta'))
    DROP PROCEDURE PnSPabm.altaPagoVenta
GO
create procedure PnSPabm.altaPagoVenta
@importe decimal(10,2),
@fechaHora DATETIME,
@item varchar(12),
@metodo varchar(9),
@moneda varchar(9)
as
begin
	DECLARE @IDout TABLE(ID INT)

	insert into PnTablas.PagoVenta(importe, FechaHoraTransaccion, item, metodo, moneda)
	OUTPUT inserted.idPagoVenta INTO @IDout(ID)
	values (@importe, @fechaHora, @item, @metodo, @moneda)

	RETURN (SELECT ID FROM @IDout)
end
go
PRINT '--Creado SP: altaPagoVenta--';
GO

--Baja (para limpieza de registros segun sea necesario)
--BajaOne
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaPagoVentaOne'))
    DROP PROCEDURE PnSPabm.bajaPagoVentaOne
GO
CREATE PROCEDURE PnSPabm.bajaPagoVentaOne (@pago INT)
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF( (@pago IS NULL) OR (@pago <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Pago invalido.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.PagoVenta WHERE IDPagoVenta = @pago) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Pago inexistente.'
	END

	IF
	((@errorCount = 0)
	OR EXISTS(SELECT 1 FROM PnTablas.TieneHActividad WHERE Pago = @pago)
	OR EXISTS(SELECT 1 FROM PnTablas.PoseeEntrada WHERE Pago = @pago))
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 
		'ERROR: Existe al menos un registro asociado a ese pago para la venta de una entrada/actividad. 
				Elimine dicho registro para continuar.'
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.PagoVenta
		WHERE IDPagoVenta = @pago
	END
END;
GO
PRINT '--Creado SP: bajaPagoVentaOne--';
GO

--BajaMany
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaPagoVentaMany'))
    DROP PROCEDURE PnSPabm.bajaPagoVentaMany
GO
CREATE PROCEDURE PnSPabm.bajaPagoVentaMany (@fecha DATE)
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF( (@fecha IS NULL) OR (@fecha >= CONVERT(DATE, GETDATE())) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Fecha invalida.'
	END

	IF
	((@errorCount = 0)
	AND
	(
		EXISTS(
		SELECT 1
		FROM PnTablas.TieneHActividad
		WHERE Pago IN (SELECT IDPagoVenta FROM PnTablas.PagoVenta WHERE FechaHoraTransaccion <= @fecha))
		OR
		EXISTS(
		SELECT 1
		FROM PnTablas.PoseeEntrada
		WHERE Pago IN (SELECT IDPagoVenta FROM PnTablas.PagoVenta WHERE FechaHoraTransaccion <= @fecha))
	))
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 
		'ERROR: Existe al menos un registro asociado a algun pago para la venta de una entrada/actividad. 
				Elimine dicho registro para continuar.'
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.PagoVenta
		WHERE CONVERT(DATE, FechaHoraTransaccion) <= @fecha
	END
END;
GO
PRINT '--Creado SP: bajaPagoVentaMany--';
GO

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
PRINT '--Creado SP: altaVentaEntradas--';
GO

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
PRINT '--Creado SP: modificarVentaEntradas--';
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
PRINT '--Creado SP: bajaAllVentaEntradas--';
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
PRINT '--Creado SP: altaVentaActividades--';
GO

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
PRINT '--Creado SP: modificarVentaActividades--';
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
PRINT '--Creado SP: bajaAllVentaActividades--';
GO

/*
================================================================
abm tieneHActividad
================================================================
*/
--Alta: solo registra un SP superior y no se permite por fuera del proceso de compra.

--Baja: se permite hacer baja con el fin de limpiar registros cuando sea necesario.
--Baja(One)
--No se permite borrar registros donde la fecha 
--sea de una actividad que aun no se ha realizado (se incluye el dia actual)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaTHActividadOne'))
    DROP PROCEDURE PnSPabm.bajaTHActividadOne
GO
CREATE PROCEDURE PnSPabm.bajaTHActividadOne
@pago INT,
@actividad INT,
@fechaActividad DATE,
@horaInicio TIME
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF( (@pago IS NULL) OR (@pago <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Pago invalido.'
	END

	IF( (@actividad IS NULL) OR (@actividad <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Actividad invalida.'
	END

	IF( (@fechaActividad IS NULL) OR (@fechaActividad >= CONVERT(DATE, GETDATE())) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Fecha invalida.'
	END

	IF(@horaInicio IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Hora invalida.'
	END

	--controlExistencia
	IF
	((@errorCount = 0) 
	AND 
	NOT EXISTS
	(
		SELECT 1 
		FROM PnTablas.TieneHActividad 
		WHERE 
		Pago = @pago 
		AND 
		Actividad = @actividad 
		AND 
		FechaActividad = @fechaActividad
		AND
		HoraInicio = @horaInicio
	))
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Registro inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.TieneHActividad
		WHERE
		Pago = @pago 
		AND 
		Actividad = @actividad 
		AND 
		FechaActividad = @fechaActividad
		AND
		HoraInicio = @horaInicio
	END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: bajaTHActividadOne--';
GO

--Baja(Many)
--para limpiar registros que preceden a una
--determinada fecha de uno o mas pagos
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaTHActividadMany'))
    DROP PROCEDURE PnSPabm.bajaTHActividadMany
GO
CREATE PROCEDURE PnSPabm.bajaTHActividadMany
@fecha DATE
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF( (@fecha IS NULL) OR (@fecha >= CONVERT(DATE, GETDATE())) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Fecha invalida.'
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.TieneHActividad
		WHERE Pago IN
		(SELECT IDPagoVenta FROM PnTablas.PagoVenta WHERE CONVERT(DATE, FechaHoraTransaccion) <= @fecha)
	END
END;
GO
PRINT '--Creado SP: bajaTHActividadMany--';
GO
