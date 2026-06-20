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

/*
----Tablas Principales: TipoParque, Provincia, Parque, HorarioParque, Dia
----Tablas Intermedias: Abre
*/

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

PRINT '--Creando SPabm para tablas Parque...--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaTipoParque'))
    DROP PROCEDURE PnSPabm.altaTipoParque
GO
CREATE PROCEDURE PnSPabm.altaTipoParque (@tipo varchar(30))
AS
BEGIN
	IF( NOT EXISTS (SELECT 1 FROM PnTablas.TipoParque WHERE DescripcionParque = @tipo) )
		INSERT INTO PnTablas.TipoParque (DescripcionParque) VALUES (@tipo)
	ELSE
		PRINT 'ERROR: Tipo ya existente.'
END
GO
PRINT '--Creado SP: altaTipoParque--'
GO

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaTipoParque'))
    DROP PROCEDURE PnSPabm.bajaTipoParque
GO
CREATE PROCEDURE PnSPabm.bajaTipoParque (@tipo INT)
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF(@tipo <= 0)
	BEGIN
		PRINT 'ERROR: tipo invalido'
		SET @errorCount = @errorCount + 1
	END

	IF( EXISTS(SELECT 1 FROM PnTablas.Parque WHERE Tipo = @tipo) )
	BEGIN
		PRINT 'ERROR: Existen parques de este tipo. Elimine los parques para continuar.'
		SET @errorCount = @errorCount + 1
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.TipoParque
		WHERE IDTipoParque LIKE @tipo
	END
END;
GO
PRINT '--Creado SP: bajaTipoParque--';
GO

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionDescripcionTipoParque'))
    DROP PROCEDURE PnSPabm.modificacionDescripcionTipoParque
GO
CREATE PROCEDURE PnSPabm.modificacionDescripcionTipoParque (@tipo INT, @descripcionNEW varchar(30))
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	IF(@tipo <= 0)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo invalido.'
	END

	IF EXISTS(SELECT 1 FROM PnTablas.TipoParque WHERE DescripcionParque LIKE @descripcionNEW)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Descripcion ya presente para otro tipo.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.TipoParque
		SET DescripcionParque = @descripcionNEW
		WHERE DescripcionParque = @tipo
	END
END;
GO
PRINT '--Creado SP: modificacionDescripcionTipoParque--';
GO

PRINT '--Creados SP para tabla TipoParque--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Provincia
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaProvincia'))
    DROP PROCEDURE PnSPabm.altaProvincia
GO
CREATE PROCEDURE PnSPabm.altaProvincia (@nombre varchar(15))
AS
BEGIN
	IF(NOT EXISTS (SELECT 1 FROM PnTablas.Provincia WHERE NombreProv LIKE @nombre))
		INSERT INTO PnTablas.Provincia (NombreProv) VALUES (@nombre)
	ELSE
		PRINT 'ERROR: Provincia ya existente.'
END;
GO
PRINT '--Creado SP: altaProvincia--';
GO

--Baja
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaProvincia'))
    DROP PROCEDURE PnSPabm.bajaProvincia
GO
CREATE PROCEDURE PnSPabm.bajaProvincia (@provincia INT)
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF(@provincia <= 0)
	BEGIN
		PRINT 'ERROR: provincia invalida'
		SET @errorCount = @errorCount + 1
	END

	IF( EXISTS(SELECT 1 FROM PnTablas.Parque WHERE Ubicacion = @provincia) )
	BEGIN
		PRINT 'ERROR: Existen parques en esta provincia. Elimine los parques para continuar.'
		SET @errorCount = @errorCount + 1
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.Provincia
		WHERE IDProv = @provincia
	END
END;
GO
PRINT '--Creado SP: bajaProvincia--';
GO

--Modificacion
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarNombreProvincia'))
    DROP PROCEDURE PnSPabm.modificarNombreProvincia
GO
CREATE PROCEDURE PnSPabm.modificarNombreProvincia (@provincia INT, @nombreNEW varchar(15))
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	IF(@provincia <= 0)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Provincia invalida.'
	END

	IF EXISTS(SELECT 1 FROM PnTablas.Provincia WHERE NombreProv LIKE @nombreNEW)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nombre ya presente para otra provincia.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.Provincia
		SET NombreProv = @nombreNEW
		WHERE IDProv = @provincia
	END
END;
GO
PRINT '--Creado SP: modificarNombreProvincia--';
GO

PRINT '--Creados SP para tabla Provincia--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Parque
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaParque'))
    DROP PROCEDURE PnSPabm.altaParque
GO
CREATE PROCEDURE PnSPabm.altaParque (@nombre varchar(30), @ubicacion INT, @superficie INT, @tipo INT)
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidezDatos
	IF( (@ubicacion IS NULL) OR (@ubicacion <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Ubicacion invalida.'
	END

	IF( (@superficie IS NULL) OR (@superficie <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Superficie invalida.'
	END

	IF( (@tipo IS NULL) OR (@tipo <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo invalido.'
	END

	--controlExistencia
	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.TipoParque WHERE IDTipoParque = @tipo) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo inexistente.'
	END

	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Provincia WHERE IDProv = @ubicacion) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Ubicacion inexistente.'
	END

	--controlDuplicidad
	IF( (@errorCount = 0) AND EXISTS(SELECT NombreParque FROM PnTablas.Parque WHERE NombreParque LIKE @nombre) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Parque ya presente.'
	END

	IF(@errorCount = 0)
		INSERT INTO PnTablas.Parque (NombreParque, Ubicacion, Superficie, Tipo) VALUES (@nombre, @ubicacion, @Superficie, @tipo)
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: altaParque--';
GO

--ModificarNombre
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarNombreParque'))
    DROP PROCEDURE PnSPabm.modificarNombreParque
GO
CREATE PROCEDURE PnSPabm.modificarNombreParque (@parque INT, @nombreNEW varchar(30))
AS
BEGIN
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

	IF(@nombreNEW IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nuevo nombre invalido.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @parque) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
	END

	--controlDuplicidad
	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Parque WHERE NombreParque = @nombreNEW) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Ya hay otro parque con el nuevo nombre.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.Parque
		SET NombreParque = @nombreNEW
		WHERE IDParque = @parque
	END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: modificarNombreParque--';
GO

--modificarSuperficie
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarSuperficieParque'))
    DROP PROCEDURE PnSPabm.modificarSuperficieParque
GO
CREATE PROCEDURE PnSPabm.modificarSuperficieParque (@parque INT, @SuperficieNEW INT)
AS
BEGIN
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

	IF( (@SuperficieNEW IS NULL) OR (@SuperficieNEW <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Superficie invalida.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @parque) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.Parque
		SET Superficie = @SuperficieNEW
		WHERE IDParque LIKE @parque
	END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: modificarSuperficieParque--';
GO

--bajaParque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaParque'))
    DROP PROCEDURE PnSPabm.bajaParque
GO
CREATE PROCEDURE PnSPabm.bajaParque (@parque INT)
AS
BEGIN
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

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @parque) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
	END

	--controlReferencias
	IF(@errorCount = 0)
	BEGIN
		IF EXISTS(SELECT 1 FROM PnTablas.GuardaParque WHERE Parque = @parque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos un guardaparques asociado a este parque. Delo de baja para continuar.'
		END

		IF EXISTS(SELECT 1 FROM PnTablas.Abre WHERE Parque = @parque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Existen horarios asociados a este parque. Delo de baja para continuar.'
		END

		IF EXISTS(SELECT 1 FROM PnTablas.Historial WHERE Parque = @parque) -- CAMBIO AQUÍ
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos una entrada de historial asociada a este parque.'
		END

		IF EXISTS(SELECT 1 FROM PnTablas.Entrada WHERE Parque = @parque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos una entrada asociada a este parque. Dela de baja para continuar.'
		END

		IF EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE Parque = @parque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos una actividad asociada a este parque. Dela de baja para continuar.'
		END

		IF EXISTS(SELECT 1 FROM PnTablas.Concesion WHERE IDParque = @parque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos una concesion asociada a este parque. Dela de baja para continuar.'
		END
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.Parque
		WHERE IDParque = @parque
		END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: bajaParque--';
GO

PRINT '--Creados SP para tabla Provincia--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

--altaDias
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaDias'))
    DROP PROCEDURE PnSPabm.altaDias
GO
CREATE PROCEDURE PnSPabm.altaDias
AS
BEGIN
	INSERT INTO PnTablas.Dia (NombreDia) 
	VALUES 
	('Lunes'), ('Martes'), ('Miercoles'), 
	('Jueves'), ('Viernes'), ('Sabado'), 
	('Domingo')
END;
GO
PRINT '--Creado SP: altaDias--';
GO

PRINT '--Creados SP para tabla Provincia--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

--altaHorario
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaHorario'))
    DROP PROCEDURE PnSPabm.altaHorario
GO
CREATE PROCEDURE PnSPabm.altaHorario (@parque INT, @dia INT, @hapertura TIME, @hcierre TIME, @temporada varchar(10))
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

	IF (@temporada NOT IN ('Verano', 'Invierno', 'Otoño', 'Primavera'))
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Temporada invalida.'
    END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @parque) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Dia WHERE IDDia = @dia) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Dia inexistente.'
	END

	--controlDuplicidad
	IF((@errorCount = 0) AND EXISTS(
		SELECT 1
		FROM
		(SELECT Horario FROM PnTablas.Abre WHERE (Parque = @parque) AND (Dia = @dia)) AS A
		JOIN PnTablas.HorarioParque AS H ON (A.Horario = H.IDHorarioP)
		WHERE (H.HoraApertura = @hapertura) AND (H.HoraCierre = @hcierre) AND (Temporada LIKE @temporada)
	))
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
END;
GO
PRINT '--Creado SP: altaHorario--';
GO

--bajaHorario
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaHorarioOne'))
    DROP PROCEDURE PnSPabm.bajaHorarioOne
GO
CREATE PROCEDURE PnSPabm.bajaHorarioOne (@horario INT)
AS
BEGIN
	--controlValidezDatos
	IF( (@horario IS NULL) OR (@horario <= 0) )
		PRINT 'ERROR: Horario invalido.'
	ELSE
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

--bajaHorario
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaHorarioAll'))
    DROP PROCEDURE PnSPabm.bajaHorarioAll
GO
CREATE PROCEDURE PnSPabm.bajaHorarioAll (@parque INT)
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

	IF NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @parque)
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

--modificarHorario
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarHorario'))
    DROP PROCEDURE PnSPabm.modificarHorario
GO
CREATE PROCEDURE PnSPabm.modificarHorario (@horario INT, @haperturaNEW TIME, @hcierreNEW TIME)
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidezDatos
	IF( (@horario IS NULL) OR (@horario <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Horario invalido.'
	END

	IF(
	( (@hcierreNEW IS NULL) OR (@haperturaNEW IS NULL) )
	OR
	(@hcierreNEW <= @haperturaNEW))
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Franja horaria invalida.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.HorarioParque WHERE IDHorarioP = @horario) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Horario inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.HorarioParque
		SET HoraApertura = @haperturaNEW, HoraCierre = @hcierreNEW
		WHERE IDHorarioP = @horario
	END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: modificarHorario--';
GO

PRINT '--Creados SP para tabla HorarioParque/Abre--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

--altaTelefono
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaTelefonoParque'))
    DROP PROCEDURE PnSPabm.altaTelefonoParque
GO
CREATE PROCEDURE PnSPabm.altaTelefonoParque (@numero varchar(12), @parque INT)
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF( (@parque IS NULL) OR (@parque <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT '- Parque invalido.'
	END

	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @parque) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT '- Parque inexistente.'
	END

	IF ( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.TelefonoParque WHERE Parque = @parque AND NumeroParque = @numero) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT '- Numero ya existente para ese parque.'
	END

	IF(@errorCount = 0)
		INSERT INTO PnTablas.TelefonoParque VALUES (@numero, @parque)
END;
GO
PRINT '--Creado SP: altaTelefonoParque--';
GO

--bajaTelefono
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaTelefonoParque'))
    DROP PROCEDURE PnSPabm.bajaTelefonoParque
GO
CREATE PROCEDURE PnSPabm.bajaTelefonoParque (@numero varchar(12), @parque INT)
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF( (@parque IS NULL) OR (@parque <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT '- Parque invalido.'
	END

	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @parque) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT '- Parque inexistente.'
	END

	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.TelefonoParque WHERE Parque = @parque AND NumeroParque = @numero) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT '- No existe ese numero para ese parque.'
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.TelefonoParque
		WHERE NumeroParque = @numero AND Parque = @parque
	END
END;
GO
PRINT '--Creado SP: bajaTelefonoParque--';
GO

--modificarTelefono
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarTelefonoParque'))
    DROP PROCEDURE PnSPabm.modificarTelefonoParque
GO
CREATE PROCEDURE PnSPabm.modificarTelefonoParque (@numeroOLD varchar(12), @numeroNEW varchar(12), @parque INT)
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF( (@parque IS NULL) OR (@parque <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT '- Parque invalido.'
	END

	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @parque) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT '- Parque inexistente.'
	END

	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.TelefonoParque WHERE Parque = @parque AND NumeroParque = @numeroOLD) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT '- No existe ese numero para ese parque.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.TelefonoParque
		SET NumeroParque = @numeroNEW
		WHERE NumeroParque = @numeroOLD AND Parque = @parque
	END
END;
GO
PRINT '--Creado SP: modificarTelefonoParque--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

