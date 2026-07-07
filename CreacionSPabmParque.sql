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

PRINT '--Creando SPabm para tablas Parque...--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----TipoParque
--altaTipoParque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaTipoParque'))
	DROP PROCEDURE PnSPabm.altaTipoParque
GO
CREATE PROCEDURE PnSPabm.altaTipoParque (@tipo varchar(30))
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF(@tipo IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Tipo invalido.'
	END

	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.TipoParque WHERE DescripcionParque LIKE @tipo) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Tipo ya existente.'
	END

	IF(@errorCount = 0)
		INSERT INTO PnTablas.TipoParque (DescripcionParque) VALUES (@tipo)
END;
GO
PRINT '--Creado SP: altaTipoParque--';
GO

-------------------------------------------------------------------------------------
--Baja
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaTipoParque'))
    DROP PROCEDURE PnSPabm.bajaTipoParque
GO
CREATE PROCEDURE PnSPabm.bajaTipoParque (@tipo INT)
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF( (@tipo IS NULL) OR (@tipo <= 0) )
	BEGIN
		PRINT 'ERROR: Tipo invalido'
		SET @errorCount = @errorCount + 1
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.TipoParque WHERE IDTipoParque = @tipo) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: No existe este tipo.'
	END

	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Parque WHERE Tipo = @tipo) )
	BEGIN
		PRINT 'ERROR: Existe al menos un parque de este tipo. Eliminelo para continuar.'
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

-------------------------------------------------------------------------------------
--Modificacion
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

	IF( (@tipo IS NULL) OR (@tipo <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo invalido.'
	END

	IF(@descripcionNEW IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nueva descripcion invalida.'
	END

	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.TipoParque WHERE DescripcionParque LIKE @descripcionNEW AND IDTipoParque = @tipo) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Descripcion ya presente.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.TipoParque
		SET DescripcionParque = @descripcionNEW
		WHERE IDTipoParque = @tipo
	END
	ELSE
		PRINT @errorLine
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
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF(@nombre IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Nombre invalido.'
	END

	IF( (@errorCount = 0) AND EXISTS (SELECT 1 FROM PnTablas.Provincia WHERE NombreProv LIKE @nombre) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Provincia ya existente.'
	END

	IF(@errorCount = 0)
		INSERT INTO PnTablas.Provincia (NombreProv) VALUES (@nombre)
END;
GO
PRINT '--Creado SP: altaProvincia--';
GO

-------------------------------------------------------------------------------------
--Baja
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaProvincia'))
    DROP PROCEDURE PnSPabm.bajaProvincia
GO
CREATE PROCEDURE PnSPabm.bajaProvincia (@provincia INT)
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF( (@provincia IS NULL) OR (@provincia <= 0) )
	BEGIN
		PRINT 'ERROR: Provincia invalida.'
		SET @errorCount = @errorCount + 1
	END

	--controlExistencia
	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Provincia WHERE IDProv = @provincia) )
	BEGIN
		PRINT 'ERROR: Provincia inexistente.'
		SET @errorCount = @errorCount + 1
	END

	--controlReferencia
	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Parque WHERE Ubicacion = @provincia) ) 
	BEGIN
		PRINT 'ERROR: Existe al menos un parque en esta provincia. Eliminelo para continuar.'
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

-------------------------------------------------------------------------------------
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

	--controlValidez
	IF( (@provincia IS NULL) OR (@provincia <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Provincia invalida.'
	END

	IF (@nombreNEW IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nuevo nombre invalido.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Provincia WHERE IDProv = @provincia) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Provincia inexistente.'
	END

	--controlDuplicidad
	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Provincia WHERE NombreProv LIKE @nombreNEW AND IDProv != @provincia) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nombre ya presente.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.Provincia
		SET NombreProv = @nombreNEW
		WHERE IDProv = @provincia
	END
	ELSE
		PRINT @errorLine
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
CREATE PROCEDURE PnSPabm.altaParque (@nombre varchar(100), @ubicacion INT, @superficie INT, @tipo INT)
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidezDatos
	IF (@nombre IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nombre invalido.'
	END

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
	BEGIN
		INSERT INTO PnTablas.Parque (NombreParque, Ubicacion, Superficie, Tipo) VALUES (@nombre, @ubicacion, @Superficie, @tipo)

		PRINT '--Operacion exitosa.--'
	END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: altaParque--';
GO

-------------------------------------------------------------------------------------
--Modificacion
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarNombreParque'))
    DROP PROCEDURE PnSPabm.modificarNombreParque
GO
CREATE PROCEDURE PnSPabm.modificarNombreParque (@parque INT, @nombreNEW varchar(100))
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
	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Parque WHERE NombreParque LIKE @nombreNEW AND IDParque != @parque) )
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

-------------------------------------------------------------------------------------
--Modificacion
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

-------------------------------------------------------------------------------------
--Baja
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
			SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos un horario asociados a este parque. Eliminelo para continuar.'
		END

		IF EXISTS(SELECT 1 FROM PnTablas.TieneHistorial WHERE Parque = @parque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos una entrada de historial asociada a este parque. Eliminela para continuar.'
		END

		IF EXISTS(SELECT 1 FROM PnTablas.Entrada WHERE Parque = @parque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos una entrada asociada a este parque. Eliminela para continuar.'
		END

		IF EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE Parque = @parque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos una actividad asociada a este parque. Eliminela para continuar.'
		END

		IF EXISTS(SELECT 1 FROM PnTablas.Concesion WHERE Parque = @parque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos una concesion asociada a este parque. Dela de baja para continuar.'
		END

		IF EXISTS(SELECT 1 FROM PnTablas.TelefonoParque WHERE Parque = @parque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos un telefono asociado a este parque. Eliminelo para continuar.'
		END
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.Parque
		WHERE IDParque LIKE @parque

		PRINT '--Operacion exitosa.--'
	END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: bajaParque--';
GO

PRINT '--Creados SP para tabla Parque--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Dia
--Alta
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

PRINT '--Creados SP para tabla Dia--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
--La tabla Abre sufre cambios simultaneamente con la tabla Horario por lo que las transacciones 
--que involucran a ambas fueron movidas a su respectivo script. La tabla Abre no tiene SPs propios
--por esta razon
----Horario/Abre
--Modificacion
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

PRINT '--Creados SP para tabla HorarioParque--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----TelefonoParque
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaTelefonoParque'))
    DROP PROCEDURE PnSPabm.altaTelefonoParque
GO
CREATE PROCEDURE PnSPabm.altaTelefonoParque (@numero varchar(12), @parque INT)
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF(@numero IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Numero invalido.'
	END

	IF( (@parque IS NULL) OR (@parque <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Parque invalido.'
	END

	--controlExistencia
	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @parque) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
	END

	--controlDuplicidad
	IF ( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.TelefonoParque WHERE NumeroParque = @numero) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Numero ya existente.'
	END

	IF(@errorCount = 0)
		INSERT INTO PnTablas.TelefonoParque VALUES (@numero, @parque)
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: altaTelefonoParque--';
GO

-------------------------------------------------------------------------------------
--Baja
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaTelefonoParque'))
    DROP PROCEDURE PnSPabm.bajaTelefonoParque
GO
CREATE PROCEDURE PnSPabm.bajaTelefonoParque (@numero varchar(12))
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF(@numero IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Numero invalido.'
	END

	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.TelefonoParque WHERE NumeroParque = @numero) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: No existe ese numero.'
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.TelefonoParque
		WHERE NumeroParque = @numero
	END
END;
GO
PRINT '--Creado SP: bajaTelefonoParque--';
GO

-------------------------------------------------------------------------------------
--Modificacion
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarTelefonoParque'))
    DROP PROCEDURE PnSPabm.modificarTelefonoParque
GO
CREATE PROCEDURE PnSPabm.modificarTelefonoParque (@numeroOLD varchar(12), @numeroNEW varchar(12))
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF(@numeroOLD IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Numero actual invalido.'
	END

	IF(@numeroNEW IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Numero nuevo invalido.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.TelefonoParque WHERE NumeroParque = @numeroOLD) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Numero a cambiar inexistente.'
	END

	--controlDuplicidad
	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.TelefonoParque WHERE NumeroParque = @numeroNEW) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Numero nuevo ya presente.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.TelefonoParque
		SET NumeroParque = @numeroNEW
		WHERE NumeroParque = @numeroOLD
	END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: modificarTelefonoParque--';
GO