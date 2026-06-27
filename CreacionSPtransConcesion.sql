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

PRINT '--Creando SPtrans para tablas Concesion...--';
GO

-------------------------------------------------------------------------------------
--HistorialPago
-------------------------------------------------------------------------------------
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.altaFacturaConcesion'))
    DROP PROCEDURE PnSPtrans.altaFacturaConcesion
GO
CREATE PROCEDURE PnSPtrans.altaFacturaConcesion
@concesion INT,
@vencimiento DATE
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)
	DECLARE @importe DECIMAL(10, 2)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF( (@concesion IS NULL) OR (@concesion <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Concesion invalida.'
	END

	IF( (@vencimiento IS NULL) OR (@vencimiento <= CONVERT(DATE, GETDATE())) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Vencimiento invalido.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Concesion WHERE IDConcesion = @concesion) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Concesion inexistente.'
	END

	--controlDuplicidad
	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.HistorialPago WHERE IDPagoConcesion = @concesion AND Vencimiento = @vencimiento) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Factura ya presente.'
	END

	IF(@errorCount = 0)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			SET @importe = (SELECT CostoAlquiler FROM PnTablas.Concesion WHERE IDConcesion = @concesion)

			INSERT INTO PnTablas.HistorialPago (Concesion, Importe, Vencimiento, Estado)
			VALUES (@concesion, @importe, @vencimiento, 'Impago')

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
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: altaFacturaConcesion--';
GO

-------------------------------------------------------------------------------------
--Baja (varias entradas anterior a una fecha dada y solo si estan pagas)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.bajaFacturaConcesionMany'))
    DROP PROCEDURE PnSPtrans.bajaFacturaConcesionMany
GO
CREATE PROCEDURE PnSPtrans.bajaFacturaConcesionMany
@fecha DATE
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	IF(@fecha IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Vencimiento invalido.'
	END

	IF(@errorCount = 0)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			DELETE FROM PnTablas.HistorialPago
			WHERE (Vencimiento <= @fecha) AND (Estado LIKE 'Pago')

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
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: bajaFacturaConcesionMany--';
GO

-------------------------------------------------------------------------------------
--PagarFactura
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.pagoFactura'))
    DROP PROCEDURE PnSPtrans.pagoFactura
GO
CREATE PROCEDURE PnSPtrans.pagoFactura
@idFactura INT
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF( (@idFactura IS NULL) OR (@idFactura <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Factura invalida.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.HistorialPago WHERE IDPagoConcesion = @idFactura) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Factura inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM PnTablas.HistorialPago WHERE IDPagoConcesion = @idFactura AND Estado = 'Pago')
				THROW 50000, 'Esta factura ya se encuentra paga.', 1

			UPDATE PnTablas.HistorialPago
			SET Estado = 'Pago'
			WHERE IDPagoConcesion = @idFactura

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
	ELSE 
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: pagoFactura--';
GO