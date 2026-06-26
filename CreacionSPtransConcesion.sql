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
-------------------------------------------------------------------------------------
----Concesion
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.altaConcesion'))
    DROP PROCEDURE PnSPtrans.altaConcesion
GO
create procedure PnSPtrans.altaConcesion
@idEmpresa int,
@idParque int,
@rubro varchar(20),
@fechaInicio date,
@fechaFin date,
@precioAlquiler decimal(10,2)
as 
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF( (@idEmpresa IS NULL) OR (@idEmpresa <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Empresa invalida.'
	END

	IF( (@idParque IS NULL) OR (@idParque <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Parque invalido.'
	END

	if (@rubro IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Rubro invalido.'
	END

	IF(
	((@fechaInicio IS NULL) OR (@fechaFin IS NULL))
	OR
	(@fechaInicio >= @fechaFin))
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Fechas invalidas.'
	END

	IF( (@precioAlquiler IS NULL) OR (@precioAlquiler <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Costo de alquiler invalido.'
	END

	--controlExistencia
	IF(@errorCount = 0)
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @idParque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
		END

		IF NOT EXISTS(SELECT 1 FROM PnTablas.Empresa WHERE IDEmpresa = @idEmpresa)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Empresa inexistente.'
		END
	END

	IF(@errorCount = 0)
	BEGIN
		begin transaction
		begin try
			insert into PnTablas.Concesion(Empresa, Parque, Rubro, FechaInicioConcesion, FechaFinConcesion, CostoAlquiler) values
			(@idEmpresa, @idParque, @rubro, @fechaInicio, @fechaFin, @precioAlquiler);
			commit transaction;
		end try
		begin catch
			if @@TRANCOUNT > 0
				rollback transaction;
			declare @msj nvarchar(100) = error_message();
			declare @numError int = error_number();
			print concat('ERROR (', @numError,')',@msj);
		end catch
	END
end;
go
PRINT '--Creado SP: altaConcesion--';
GO

-------------------------------------------------------------------------------------
--Baja
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.bajaConcesion'))
    DROP PROCEDURE PnSPtrans.bajaConcesion
GO
create procedure PnSPtrans.bajaConcesion
@idConcesion int
as
begin
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF( (@idConcesion IS NULL) OR (@idConcesion <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Concesion invalida.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Concesion WHERE IDConcesion = @idConcesion) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Concesion inexistente.'
	END

	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.HistorialPago WHERE Concesion = @idConcesion) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Existe al menos una entrada en el Historial de Pago relacionada a esta concesion. Eliminela para continuar.'
	END

	IF(@errorCount = 0)
	BEGIN
		begin transaction
		begin try
			delete from PnTablas.Concesion
			where idConcesion = @idConcesion;
			commit transaction;
		end try
		begin catch
			if @@TRANCOUNT > 0
				rollback transaction;
			declare @msj nvarchar(100) = error_message();
			declare @numError int = error_number();
			print concat('ERROR (', @numError,')',@msj);
		end catch
	END
end;
go
PRINT '--Creado SP: bajaConcesion--';
GO

-------------------------------------------------------------------------------------
--Modificacion (Fecha Fin)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.modificacionFechaFConcesion'))
    DROP PROCEDURE PnSPtrans.modificacionFechaFConcesion
GO
create procedure PnSPtrans.modificacionFechaFConcesion
@idConcesion int,
@fechaFinNEW DATE
as
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)
	DECLARE @fecha DATE

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF( (@idConcesion IS NULL) OR (@idConcesion <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Concesion invalida.'
	END

	IF( (@fechaFinNEW IS NULL) OR (@fechaFinNEW < CONVERT(DATE, GETDATE())) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nueva fecha invalida.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Concesion WHERE IDConcesion = @idConcesion) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Concesion inexistente.'
	END

	--controlExtra
	SET @fecha = (SELECT FechaInicioConcesion FROM PnTablas.Concesion WHERE IDConcesion = @idConcesion)

	IF( (@errorCount = 0) AND (@fechaFinNEW < @fecha) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- La nueva fecha no puede ser anterior a la de inicio.'
	END

	IF(@errorCount = 0)
	BEGIN
		begin transaction
		begin try
			UPDATE PnTablas.Concesion
			SET FechaFinConcesion = @fechaFinNEW
			where idConcesion = @idConcesion;
			commit transaction;
		end try
		begin catch
			if @@TRANCOUNT > 0
				rollback transaction;
			declare @msj nvarchar(100) = error_message();
			declare @numError int = error_number();
			print concat('ERROR (', @numError,')',@msj);
		end catch
	END
end;
go
PRINT '--Creado SP: modificacionFechaFConcesion--';
GO

-------------------------------------------------------------------------------------
--Modificacion (Costo)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.modificacionCostoConcesion'))
    DROP PROCEDURE PnSPtrans.modificacionCostoConcesion
GO
create procedure PnSPtrans.modificacionCostoConcesion
@idConcesion int,
@costo DECIMAL(10,2)
as
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF( (@idConcesion IS NULL) OR (@idConcesion <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Concesion invalida.'
	END

	IF( (@costo IS NULL) OR (@costo <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nuevo costo invalido.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Concesion WHERE IDConcesion = @idConcesion) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Concesion inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		begin transaction
		begin try
			UPDATE PnTablas.Concesion
			SET CostoAlquiler = @costo
			where idConcesion = @idConcesion;
			commit transaction;
		end try
		begin catch
			if @@TRANCOUNT > 0
				rollback transaction;
			declare @msj nvarchar(100) = error_message();
			declare @numError int = error_number();
			print concat('ERROR (', @numError,')',@msj);
		end catch
	END
end;
go
PRINT '--Creado SP: modificacionCostoConcesion--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----HistorialPago
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
	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.HistorialPago WHERE IDConcesion = @concesion AND Vencimiento = @vencimiento) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Factura ya presente.'
	END

	IF(@errorCount = 0)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			SET @importe = (SELECT Costo FROM PnTablas.Concesion WHERE IDConcesion = @concesion)

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

	SET @errorCount = 0

	IF(@fecha IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Vencimiento invalido.'
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

	SET @errorCount = 0

	--controlValidez
	IF( (@idFactura IS NULL) OR (@idFactura <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Factura invalida.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.HistorialPago WHERE IDPagoConcesion = @idFactura) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Factura inexistente.'
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
END;
GO
PRINT '--Creado SP: pagoFactura--';
GO