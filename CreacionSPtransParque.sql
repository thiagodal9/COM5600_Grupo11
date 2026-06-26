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

PRINT '--Creando SPtrans para tablas Parque...--';
GO

--La tabla Abre sufre cambios simultaneamente con la tabla Horario por lo que las transacciones 
--que involucran a ambas fueron movidas a su respectivo script. La tabla Abre no tiene SPs propios
--por esta razon

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Horario/Abre
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.altaHorario'))
    DROP PROCEDURE PnSPtrans.altaHorario
GO
CREATE PROCEDURE PnSPtrans.altaHorario (@parque INT, @dia INT, @hapertura TIME, @hcierre TIME, @temporada varchar(10))
AS
BEGIN
	DECLARE @IDout TABLE(ID INT)
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidezDatos
	IF( (@parque IS NULL) OR (@parque <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Parque invalido.'
	END

	IF( (@dia IS NULL) OR (@dia <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Dia invalido.'
	END

	IF(
	( (@hcierre IS NULL) OR (@hapertura IS NULL) )
	OR
	(@hcierre <= @hapertura))
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Horario invalido.'
	END

	IF( (@temporada IS NULL) OR (@temporada NOT IN ('Verano', 'Invierno', 'Otoño', 'Primavera')) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Temporada invalida.'
	END

	--controlExistencia
	IF(@errorCount = 0)
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @parque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
		END

		IF NOT EXISTS(SELECT 1 FROM PnTablas.Dia WHERE IDDia = @dia)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Dia inexistente.'
		END
	END

	--controlDuplicidad
	IF((@errorCount = 0) 
	AND 
	EXISTS(
	SELECT 1
	FROM
	(SELECT Horario FROM PnTablas.Abre WHERE (Parque = @parque) AND (Dia = @dia)) AS A
	JOIN
	PnTablas.HorarioParque AS H
	ON (A.Horario = H.IDHorarioP)
	WHERE (H.HoraApertura = @hapertura) AND (H.HoraCierre = @hcierre) AND (Temporada LIKE @temporada)))
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Horario ya presente para ese parque.'
	END

	IF(@errorCount = 0)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO PnTablas.HorarioParque (HoraApertura, HoraCierre, Temporada)
			OUTPUT inserted.IDHorarioP INTO @IDout(ID)
			VALUES (@hapertura, @hcierre, @temporada)

			INSERT INTO PnTablas.Abre (Parque, Dia, Horario)
			VALUES (@parque, @dia, (SELECT ID FROM @IDout))

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
PRINT '--Creado SP: altaHorario--';
GO

-------------------------------------------------------------------------------------
--Baja
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.bajaHorarioOne'))
    DROP PROCEDURE PnSPtrans.bajaHorarioOne
GO
CREATE PROCEDURE PnSPtrans.bajaHorarioOne (@horario INT)
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	--controlValidezDatos
	IF( (@horario IS NULL) OR (@horario <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Horario invalido.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.HorarioParque WHERE IDHorarioP = @horario) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Horario inexistente.'
	END

	IF (@errorCount = 0)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			DELETE FROM PnTablas.Abre
			WHERE Horario = @horario

			DELETE FROM PnTablas.HorarioParque
			WHERE IDHorarioP = @horario

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
PRINT '--Creado SP: bajaHorarioOne--';
GO

-------------------------------------------------------------------------------------
--Baja Total
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.bajaHorarioAll'))
    DROP PROCEDURE PnSPtrans.bajaHorarioAll
GO
CREATE PROCEDURE PnSPtrans.bajaHorarioAll (@parque INT)
AS
BEGIN
	DECLARE @IDout TABLE(ID INT)
	DECLARE @errorCount INT

	SET @errorCount = 0

	--controlValidezDatos
	IF( (@parque IS NULL) OR (@parque <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Parque invalido.'
	END

	IF((@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @parque) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Parque inexistente.'
	END
	
	IF(@errorCount = 0)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO @IDout
			SELECT Horario
			FROM PnTablas.Abre
			WHERE Parque = @parque

			DELETE FROM PnTablas.Abre
			WHERE Parque = @parque

			DELETE FROM PnTablas.HorarioParque
			WHERE IDHorarioP IN (SELECT ID FROM @IDout)

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
PRINT '--Creado SP: bajaHorarioAll--';
GO