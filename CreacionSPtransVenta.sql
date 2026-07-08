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
--Baja
create procedure PnSPabm.bajaVenta
@idPagoVenta int
as
begin
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF( (@idPagoVenta IS NULL) OR (@idPagoVenta <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: ID del pago invalido.'
	END

	if( (@errorCount = 0) AND not exists (select 1 from PnTablas.PagoVenta where idPagoVenta = @idPagoVenta) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Pago inexistente.'
	END
		
	BEGIN TRANSACTION
	BEGIN TRY
		DELETE FROM PnTablas.PoseeEntrada
		WHERE Pago = @idPagoVenta

		DELETE FROM PnTablas.TieneHActividad
		WHERE Pago  = @idPagoVenta

		DELETE FROM PnTablas.PagoVenta
		WHERE idPagoVenta = @idPagoVenta

		COMMIT TRANSACTION
	END TRY
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

/*
================================================================
Compra de Entradas
================================================================
*/
-------------------------------------------------------------------------------------
--apilar compra
CREATE PROCEDURE PnSPabm.reservarEntradas (@entrada INT, @cantidad INT, @fecha DATE)
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF( (@entrada IS NULL) OR (@entrada <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo de entrada invalida.'
	END

	IF( (@cantidad IS NULL) OR (@cantidad <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Cantidad invalida.'
	END

	IF( (@fecha IS NULL) OR (@fecha < CONVERT(DATE, GETDATE())) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Fecha invalida.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.TipoEntrada WHERE IDTipoEntrada = @entrada) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Entrada inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		IF EXISTS(SELECT 1 FROM #ventaEntradas WHERE Entrada = @entrada AND FechaAcceso = @fecha)
			EXECUTE PnSPabm.modificarVentaEntradas @entrada = @entrada, @cantidadNew = @cantidad, @fechaAcceso = @fecha
		ELSE
			EXECUTE PnSPabm.altaVentaEntradas @entrada = @entrada, @cantidadNew = @cantidad, @fechaAcceso = @fecha
	END
	ELSE
		PRINT @errorLine
END;
GO

--retroceder compra
CREATE PROCEDURE PnSPabm.cancelarReservaEntradas
AS
BEGIN
	EXECUTE PnSPabm.bajaAllVentaEntradas
END;
GO

--confirmar compra
CREATE PROCEDURE PnSPtrans.confirmarCompraE @metodo varchar(9)
AS
BEGIN
	DECLARE @errorCount INT

	DECLARE @total DECIMAL(10, 2)
	DECLARE @fechaHoraT DATETIME
	DECLARE @id INT

	SET @errorCount = 0

	IF( (@metodo IS NULL) OR (@metodo NOT IN ('Efectivo', 'Tarjeta')) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Metodo de pago invalido.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM #ventaEntradas) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: No hay reservas hechas.'
	END

	IF(@errorCount = 0)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			
			SET @total = (SELECT SUM(t.subTotal)
						 FROM
						 (
							SELECT (E.Precio * CAST(totalEntradas AS DECIMAL(10, 2))) AS subTotal
							FROM
							(
								SELECT Entrada, FechaAcceso, SUM(Cantidad) AS totalEntradas
								FROM #ventaEntradas
								GROUP BY Entrada, FechaAcceso
							) AS tE
							JOIN
							PnTablas.Entrada AS E
							ON (tE.Entrada = E.IDEntrada)
						 ) AS t)

			SET @fechaHoraT = GETDATE()

			EXECUTE @id = PnSPabm.altaPagoVenta
							@importe = @total,
							@fechaHora = @fechaHoraT,
							@item = 'Entradas',
							@metodo = @metodo

			UPDATE #ventaEntradas
			SET ID = @id
			WHERE ID IS NULL

			INSERT INTO PnTablas.PoseeEntrada (Pago, Entrada, FechaAcceso, Cantidad)
			SELECT ID, Entrada, FechaAcceso, totalEntradas
			FROM
			(
				SELECT ID, Entrada, FechaAcceso, SUM(Cantidad) AS totalEntradas
				FROM #ventaEntradas
				GROUP BY ID, Entrada, FechaAcceso
			) AS t

			EXECUTE PnSPabm.bajaAllVentaEntradas

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

			DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
			DECLARE @Num INT           = ERROR_NUMBER();
			PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
		END CATCH
	END
END;
GO

/*
================================================================
Venta de Actividades
================================================================
*/
-------------------------------------------------------------------------------------
--apilar compra
CREATE PROCEDURE PnSPabm.reservarActividad (@actividad INT, @cantidad INT, @fecha DATE, @hora TIME)
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF( (@actividad IS NULL) OR (@actividad <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Actividad invalida.'
	END

	IF( (@cantidad IS NULL) OR (@cantidad <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Cantidad invalida.'
	END

	IF( (@fecha IS NULL) OR (@fecha < CONVERT(DATE, GETDATE())) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Fecha invalida.'
	END

	IF((@hora IS NULL)
	OR
	((@fecha = CONVERT(DATE, GETDATE())) AND (@hora <= CONVERT(TIME, GETDATE()))))
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Hora invalida.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE IDActividad = @actividad) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Actividad inexistente.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actividad AND FechaActividad = @fecha AND HoraInicio = @hora) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Fecha para actividad inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		IF EXISTS(SELECT 1 FROM #ventaActividades WHERE Actividad = @actividad AND FechaActividad = @fecha AND HoraInicio = @hora)
			EXECUTE PnSPabm.modificarVentaActividades @actividad = @actividad, @fechaActividad = @fecha, @horaInicio = @hora, @cantidadNew = @cantidad
		ELSE
			EXECUTE PnSPabm.altaVentaActividades @actividad = @actividad, @fechaActividad = @fecha, @HoraInicio = @hora, @cantidad = @cantidad
	END
	ELSE
		PRINT @errorLine
END;
GO

-------------------------------------------------------------------------------------
--retroceder reserva
CREATE PROCEDURE PnSPabm.cancelarReservaActividades
AS
BEGIN
	EXECUTE PnSPabm.bajaAllVentaActividades
END;
GO

-------------------------------------------------------------------------------------
--confirmar compra
CREATE PROCEDURE PnSPtrans.confirmarCompraA @metodo varchar(9)
AS
BEGIN
	DECLARE @errorCount INT

	DECLARE @total DECIMAL(10, 2)
	DECLARE @fechaHoraT DATETIME
	DECLARE @id INT

	SET @errorCount = 0

	IF( (@metodo IS NULL) OR (@metodo NOT IN ('Efectivo', 'Tarjeta')) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Metodo de pago invalido.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM #ventaActividades) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: No hay reservas hechas.'
	END

	IF(@errorCount = 0)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			
			IF EXISTS(
			SELECT 1
			FROM
			(
				SELECT Actividad, FechaActividad, HoraInicio, SUM(Cantidad) AS tReservado 
				FROM #ventaActividades 
				GROUP BY Actividad, FechaActividad, HoraInicio
			) AS Reserva
			JOIN
			(
				SELECT Vendido.Actividad, Vendido.FechaActividad, Vendido.HoraInicio, (Cupo.CupoMax - Vendido.tVendido) AS Sobrante
				FROM
				(
					SELECT Actividad, FechaActividad, HoraInicio, SUM(Cantidad) AS tVendido 
					FROM PnTablas.tieneHActividad 
					GROUP BY Actividad, FechaActividad, HoraInicio
				) AS Vendido
				JOIN
				PnTablas.Actividad AS Cupo
				ON (Vendido.Actividad = Cupo.IDActividad)
			) AS Libre
			ON 
			(Reserva.Actividad = Libre.Actividad 
			AND Reserva.FechaActividad = Libre.FechaActividad 
			AND Reserva.HoraInicio = Libre.HoraInicio)
			WHERE Reserva.tReservado > Libre.Sobrante)
				THROW 50000, 'La capacidad a comprar supera al cupo libre para alguna actividad.', 1

			SET @total = (
						SELECT SUM(subTotal)
						FROM
						(
							SELECT (CAct.CostoAct * CAST(tl.totalLugares AS DECIMAL(7, 2))) AS subTotal
							FROM
							(
								SELECT Actividad, SUM(Cantidad) AS totalLugares
								FROM #ventaActividades
								GROUP BY Actividad
							) AS tL
							JOIN
							(
								SELECT Act.IDActividad, TAct.CostoAct
								FROM
								(SELECT IDActividad, Tipo FROM PnTablas.Actividad) AS Act
								JOIN
								(SELECT IDTipoAct, CostoAct FROM PnTablas.TipoActividad) AS TAct
								ON (Act.Tipo = TAct.IDTipoAct)
							) AS CAct
							ON (tL.Actividad = CAct.IDActividad)
						) AS t)

			SET @fechaHoraT = GETDATE()

			EXECUTE @id = PnSPabm.altaPagoVenta
							@importe = @total,
							@fechaHora = @fechaHoraT,
							@item = 'Actividades',
							@metodo = @metodo

			UPDATE #ventaActividades
			SET ID = @id
			WHERE ID IS NULL

			INSERT INTO PnTablas.TieneHActividad (Pago, Actividad, FechaActividad, Cantidad, HoraInicio)
			SELECT ID, Actividad, FechaActividad, totalLugares, HoraInicio
			FROM
			(
				SELECT ID, Actividad, FechaActividad, HoraInicio, SUM(Cantidad) AS totalLugares
				FROM #ventaActividades
				GROUP BY ID, Actividad, FechaActividad, HoraInicio
			) AS t

			EXECUTE PnSPabm.bajaAllVentaActividades

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

			DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
			DECLARE @Num INT           = ERROR_NUMBER();
			PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
		END CATCH
	END
END;
GO