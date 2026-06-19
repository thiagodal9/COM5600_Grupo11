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

PRINT '--Creando SPabm para tablas Actividad...--';
GO

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

CREATE PROCEDURE PnSPabm.cambiarDescripcionTipoActividad (@tipo INT, @descripcionNEW varchar(30))
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

CREATE PROCEDURE PnSPabm.cambiarCostoTipoActividad (@tipo INT, @costoNEW DECIMAL(7, 2))
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

CREATE PROCEDURE PnSPabm.borrarTipoActividad (@tipo INT)
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
		PRINT 'ERROR: Existe al menos una actividad relacionada a este Tipo. Desasigne'
	END

	DELETE FROM PnTablas.TipoActividad
	WHERE DescripcionAct = @descripcion
END;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

