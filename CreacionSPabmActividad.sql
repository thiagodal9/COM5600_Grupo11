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

PRINT '--Creando SPabm para tablas Actividad...--';
GO

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaTipoActividad'))
    DROP PROCEDURE PnSPabm.altaTipoActividad
GO;
CREATE PROCEDURE PnSPabm.altaTipoActividad (@descripcion varchar(30), @costo DECIMAL(7, 2))
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidezDatos
	IF( (@costo IS NULL) OR (@costo < 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Costo invalido.'
	END

	IF(@descripcion IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Descripcion invalida.'
	END

	--controlDuplicidad
	IF ( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.TipoActividad WHERE DescripcionAct LIKE @descripcion) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT '- Tipo ya presente.'
	END

	IF(@errorCount = 0)
	BEGIN
		INSERT INTO PnTablas.TipoActividad (DescripcionAct, CostoAct) VALUES (@descripcion, @costo)
	END
	ELSE
		PRINT @errorLine
END;
GO

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarDescripcionTipoActividad'))
    DROP PROCEDURE PnSPabm.modificarDescripcionTipoActividad
GO;
CREATE PROCEDURE PnSPabm.modificarDescripcionTipoActividad (@tipo INT, @descripcionNEW varchar(30))
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidezDatos
	IF( (@tipo IS NULL) OR (@tipo <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo invalido.'
	END

	IF(@descripcionNEW IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Descripcion invalida.'
	END

	--controlExistencia
	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.TipoActividad WHERE IDTipoAct LIKE @tipo) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo inexistente.'
	END

	--controlDuplicidad
	IF ( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.TipoActividad WHERE DescripcionAct LIKE @descripcionNEW) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT '- La nueva descripcion ya esta presente para otro tipo.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.TipoActividad
		SET DescripcionAct = @descripcionNEW
		WHERE IDTipoAct = @tipo
	END
	ELSE
		PRINT @errorLine
END;
GO

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarCostoTipoActividad'))
    DROP PROCEDURE PnSPabm.modificarCostoTipoActividad
GO;
CREATE PROCEDURE PnSPabm.modificarCostoTipoActividad (@tipo INT, @costoNEW DECIMAL(7, 2))
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidezDatos
	IF( (@costoNEW IS NULL) OR (@costoNEW < 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Costo invalido.'
	END

	IF( (@tipo IS NULL) OR (@tipo <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo invalido.'
	END

	--controlExistencia
	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.TipoActividad WHERE IDTipoAct LIKE @tipo) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.TipoActividad
		SET CostoAct = @costoNEW
		WHERE IDTipoAct = @tipo
	END
	ELSE
		PRINT @errorLine
END;
GO

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaTipoActividad'))
    DROP PROCEDURE PnSPabm.bajaTipoActividad
GO;
CREATE PROCEDURE PnSPabm.bajaTipoActividad (@tipo INT)
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	--controlValidezDatos
	IF( (@tipo IS NULL) OR (@tipo <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Tipo invalido.'
	END

	--controlExistencia
	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.TipoActividad WHERE IDTipoAct LIKE @tipo) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Tipo inexistente.'
	END

	--controlReferencias
	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE Tipo = @tipo) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Existe al menos una actividad relacionada a este Tipo. Desasigne para continuar.'
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.TipoActividad
		WHERE DescripcionAct = @tipo
	END
	ELSE
		PRINT @errorLine
END;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaActividad'))
    DROP PROCEDURE PnSPabm.altaActividad
GO;
CREATE PROCEDURE PnSPabm.altaActividad (@nombre varchar(30), @duracion INT, @cupo INT, @parque INT, @tipo INT)
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

	IF( (@tipo IS NULL) OR (@tipo <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo invalido.'
	END

	IF( (@cupo IS NULL) OR (@cupo <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Cupo invalido.'
	END

	IF( (@duracion IS NULL) OR (@duracion <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Duracion invalida.'
	END

	IF(@nombre IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nombre invalido.'
	END

	--controlExistencia
	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque LIKE @parque) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
	END

	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.TipoActividad WHERE IDTipoAct LIKE @tipo) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo inexistente.'
	END

	--controlDuplicidad
	IF ( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE NombreActividad LIKE @nombre) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Actividad ya presente.'
	END

	IF(@errorCount = 0)
	BEGIN
		INSERT INTO PnTablas.Actividad (NombreActividad, Duracion, CupoMax, Parque, Tipo)
		VALUES (@nombre, @duracion, @cupo, @parque, @tipo)
	END
	ELSE
		PRINT @errorLine
END;
GO

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarNombreActividad'))
    DROP PROCEDURE PnSPabm.modificarNombreActividad
GO;
CREATE PROCEDURE PnSPabm.modificarNombreActividad (@actividad INT, @nombreNEW varchar(30))
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidezDatos
	IF( (@actividad IS NULL) OR (@actividad <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Actividad invalida.'
	END

	IF(@nombreNEW IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nombre invalido.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE IDActividad = @actividad) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Actividad inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.Actividad
		SET NombreActividad = @nombreNEW
		WHERE IDActividad = @actividad
	END
	ELSE
		PRINT @errorLine
END;
GO

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarDuracionActividadParque'))
    DROP PROCEDURE PnSPabm.modificarDuracionActividadParque
GO;
CREATE PROCEDURE PnSPabm.modificarDuracionActividadParque (@actividad INT, @duracionNEW INT)
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidezDatos
	IF( (@actividad IS NULL) OR (@actividad <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Actividad invalida.'
	END

	IF( (@duracionNEW IS NULL) OR (@duracionNEW <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Actividad invalida.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE IDActividad = @actividad) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Actividad inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.Actividad
		SET Duracion = @duracionNEW
		WHERE IDActividad LIKE @actividad
	END
	ELSE
		PRINT @errorLine
END;
GO

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarCupoActividadParque'))
    DROP PROCEDURE PnSPabm.modificarCupoActividadParque
GO;
CREATE PROCEDURE PnSPabm.modificarCupoActividadParque (@actividad INT, @cupoNEW INT)
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidezDatos
	IF( (@actividad IS NULL) OR (@actividad <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Actividad invalida.'
	END

	IF( (@cupoNEW IS NULL) OR (@cupoNEW <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Actividad invalida.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE IDActividad = @actividad) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Actividad inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.Actividad
		SET CupoMax  = @cupoNEW
		WHERE IDActividad LIKE @actividad
	END
	ELSE
		PRINT @errorLine
END;
GO

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaActividadParque'))
    DROP PROCEDURE PnSPabm.bajaActividadParque
GO;
CREATE PROCEDURE PnSPabm.bajaActividadParque (@actividad INT)
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	--controlValidezDatos
	IF( (@actividad IS NULL) OR (@actividad <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Actividad invalida.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE IDActividad = @actividad) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Actividad inexistente.'
	END

	--controlReferencias
	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actividad) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Existe al menos un horario asociado a esta actividad. Eliminelo antes de continuar.'
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.Actividad
		WHERE IDActividad = @actividad
	END
END;
GO

