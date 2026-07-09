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

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----TipoActividad
--Alta
--se permite costo de actividad = 0 para representar el caso de que dicha actividad sea gratis
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaTipoActividad'))
    DROP PROCEDURE PnSPabm.altaTipoActividad
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
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo ya presente.'
	END

	IF(@errorCount = 0)
	BEGIN
		INSERT INTO PnTablas.TipoActividad (DescripcionAct, CostoAct) VALUES (@descripcion, @costo)
	END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: altaTipoActividad--';
GO

--Modificacion (Descripcion)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarDescripcionTipoActividad'))
    DROP PROCEDURE PnSPabm.modificarDescripcionTipoActividad
GO
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
	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.TipoActividad WHERE IDTipoAct = @tipo) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo inexistente.'
	END

	--controlDuplicidad
	IF ( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.TipoActividad WHERE DescripcionAct LIKE @descripcionNEW AND IDTipoAct != @tipo) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- La nueva descripcion ya esta presente para otro tipo.'
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
PRINT '--Creado SP: modificarDescripcionTipoActividad--';
GO

--Modificacion (Costo)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarCostoTipoActividad'))
    DROP PROCEDURE PnSPabm.modificarCostoTipoActividad
GO
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
PRINT '--Creado SP: modificarCostoTipoActividad--';
GO

--Baja
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaTipoActividad'))
    DROP PROCEDURE PnSPabm.bajaTipoActividad
GO
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
		PRINT 'ERROR: Existe al menos una actividad relacionada a este Tipo. Eliminela para continuar.'
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.TipoActividad
		WHERE IDTipoAct = @tipo
	END
END;
GO
PRINT '--Creado SP: bajaTipoActividad--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Actividad
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaActividad'))
    DROP PROCEDURE PnSPabm.altaActividad
GO
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
	IF(@errorCount = 0)
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque LIKE @parque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
		END

		IF NOT EXISTS(SELECT 1 FROM PnTablas.TipoActividad WHERE IDTipoAct LIKE @tipo)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Tipo inexistente.'
		END
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
PRINT '--Creado SP: altaActividad--';
GO

--Modificacion (Nombre)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarNombreActividad'))
    DROP PROCEDURE PnSPabm.modificarNombreActividad
GO
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

	--controlDuplicidad
	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE NombreActividad LIKE @nombreNEW AND IDActividad != @actividad) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nuevo nombre ya presente para otra actividad.'
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
PRINT '--Creado SP: modificarNombreActividad--';
GO

--Modificacion (Duracion)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarDuracionActividad'))
    DROP PROCEDURE PnSPabm.modificarDuracionActividad
GO
CREATE PROCEDURE PnSPabm.modificarDuracionActividad (@actividad INT, @duracionNEW INT)
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
		SET @errorLine = @errorLine + CHAR(13) + '- Duracion invalida.'
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
		WHERE IDActividad = @actividad
	END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: modificarDuracionActividad--';
GO

--Modificacion (Cupo)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificarCupoActividad'))
    DROP PROCEDURE PnSPabm.modificarCupoActividad
GO
CREATE PROCEDURE PnSPabm.modificarCupoActividad (@actividad INT, @cupoNEW INT)
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
		SET @errorLine = @errorLine + CHAR(13) + '- Cupo invalido.'
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
		WHERE IDActividad = @actividad
	END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: modificarCupoActividad--';
GO

--Baja
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaActividad'))
    DROP PROCEDURE PnSPabm.bajaActividad
GO
CREATE PROCEDURE PnSPabm.bajaActividad (@actividad INT)
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
PRINT '--Creado SP: bajaActividad--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----HorarioActividad
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaHActividad'))
    DROP PROCEDURE PnSPabm.altaHActividad
GO
CREATE PROCEDURE PnSPabm.altaHActividad (@actividad INT, @fechaAct DATE, @hInicio TIME)
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

	IF ( (@fechaAct IS NULL) OR (@fechaAct < CONVERT(DATE, GETDATE())) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Fecha invalida.'
	END

	IF (@hInicio IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Hora invalida.'
	END

	--controlExistencia
	IF ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE IDActividad = @actividad) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Actividad inexistente.'
	END

	--controlDuplicidad
	IF ( 
	(@errorCount = 0) 
	AND 
	EXISTS(SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actividad AND FechaActividad = @fechaAct AND HoraInicio = @hInicio))
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Horario ya presente.'
	END

	IF(@errorCount = 0)
	BEGIN
		INSERT INTO PnTablas.HorarioActividad (Actividad, FechaActividad, HoraInicio)
		VALUES (@actividad, @fechaAct, @hInicio)
	END
	ELSE
		PRINT @errorLine;
END;
GO
PRINT '--Creado SP: altaHActividad--';
GO

--Modificacion (Fecha)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionFechaActividad'))
    DROP PROCEDURE PnSPabm.modificacionFechaActividad
GO
CREATE PROCEDURE PnSPabm.modificacionFechaActividad (@actividad INT, @fechaAct DATE, @hInicio TIME, @fechaNEW DATE)
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

	IF ( (@fechaAct IS NULL) OR (@fechaAct < CONVERT(DATE, GETDATE())) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Fecha invalida.'
	END

	IF (@hInicio IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Hora invalida.'
	END

	IF ( (@fechaNEW IS NULL) OR (@fechaNEW < CONVERT(DATE, GETDATE())) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nueva fecha invalida.'
	END

	--controlExistencia
	IF ( 
	(@errorCount = 0) 
	AND 
	NOT EXISTS(SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actividad AND FechaActividad = @fechaAct AND HoraInicio = @hInicio) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- El horario a modificar no existe.'
	END

	--controlDuplicidad
	IF ( 
	(@errorCount = 0) 
	AND 
	EXISTS(SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actividad AND FechaActividad = @fechaNEW AND HoraInicio = @hInicio) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Ya existe esa fecha con ese horario.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.HorarioActividad
		SET FechaActividad = @fechaNEW
		WHERE Actividad = @actividad AND FechaActividad = @fechaAct AND HoraInicio = @hInicio
	END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: modificacionFechaActividad--';
GO

--Modificacion (Hora)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionHoraActividad'))
    DROP PROCEDURE PnSPabm.modificacionHoraActividad
GO
CREATE PROCEDURE PnSPabm.modificacionHoraActividad (@actividad INT, @fechaAct DATE, @hInicio TIME, @hInicioNEW TIME)
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

	IF ( (@fechaAct IS NULL) OR (@fechaAct < CONVERT(DATE, GETDATE())) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Fecha invalida.'
	END

	IF (@hInicio IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Hora invalida.'
	END

	IF( 
	(@hInicio IS NULL) 
	OR
	( (@fechaAct = CONVERT(DATE, GETDATE())) AND (@hInicioNEW <= CONVERT(TIME, GETDATE())) ))
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nueva hora invalida.'
	END

	--controlExistencia
	IF ( 
	(@errorCount = 0) 
	AND 
	NOT EXISTS(SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actividad AND FechaActividad = @fechaAct AND HoraInicio = @hInicio) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- El horario a modificar no existe.'
	END

	--controlDuplicidad
	IF ( 
	(@errorCount = 0) 
	AND 
	EXISTS(SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actividad AND FechaActividad = @fechaAct AND HoraInicio = @hInicioNEW) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Ya existe ese horario.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.HorarioActividad
		SET HoraInicio = @hInicioNEW
		WHERE Actividad = @actividad AND FechaActividad = @fechaAct AND HoraInicio = @hInicio
	END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: modificacionHoraActividad--';
GO

--Baja
--Borra un solo horario de una determinada actividad para cierta fecha dada.
--Se asume que ya han sido limpiados aquellos horarios de actividades cuya fecha ya paso.
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaHActividadOne'))
    DROP PROCEDURE PnSPabm.bajaHActividadOne
GO
CREATE PROCEDURE PnSPabm.bajaHActividadOne (@actividad INT, @fecha DATE, @hInicio TIME)
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

	IF ( (@fecha IS NULL) OR (@fecha < CONVERT(DATE, GETDATE())) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Fecha invalida.'
	END

	IF (@hInicio IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Hora invalida.'
	END

	--controlExistencia
	IF ( 
	(@errorCount = 0) 
	AND 
	NOT EXISTS(SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actividad AND FechaActividad = @fecha AND HoraInicio = @hInicio) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- El horario a eliminar no existe.'
	END

	--controlReferencia
	IF(
	(@errorCount = 0)
	AND
	EXISTS(SELECT 1 FROM PnTablas.TieneHActividad WHERE Actividad = @actividad AND FechaActividad = @fecha AND HoraInicio = @hInicio))
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos un pago hecho sobre ese horario. Elimine el registro para continuar.'
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.HorarioActividad
		WHERE Actividad = @actividad AND FechaActividad = @fecha AND HoraInicio = @hInicio 
	END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: bajaHActividadOne--';
GO

--BajaMuchos (para eliminar todas las actividades cuya fecha ya paso - anterior a la fecha actual)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaHActividadAll'))
    DROP PROCEDURE PnSPabm.bajaHActividadAll
GO
CREATE PROCEDURE PnSPabm.bajaHActividadAll
AS
BEGIN
	DECLARE @errorCount INT;

	SET @errorCount = 0;

	IF EXISTS(SELECT 1 FROM PnTablas.TieneHActividad WHERE FechaActividad < CONVERT(DATE, GETDATE()))
	BEGIN
		PRINT 'ERROR: existe al menos un pago realizado anterior a la fecha actual. Elimine el registro para continuar.'
		SET @errorCount = @errorCount + 1
	END

	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.HorarioActividad
		WHERE FechaActividad < CONVERT(DATE, GETDATE()) 
	END
END;
GO
PRINT '--Creado SP: bajaHActividadAll--';
GO

IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaTHActividadOne'))
    DROP PROCEDURE PnSPabm.bajaTHActividadOne
GO
CREATE PROCEDURE PnSPabm.bajaTHActividadOne (@pago INT, @actividad INT, @fechaActividad DATE, @horaInicio TIME)
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
 
	IF(@fechaActividad IS NULL)
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
	IF( 
	(@errorCount = 0) 
	AND 
	NOT EXISTS(
		SELECT 1 FROM PnTablas.TieneHActividad 
		WHERE Pago = @pago AND Actividad = @actividad AND FechaActividad = @fechaActividad AND HoraInicio = @horaInicio) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- El registro a eliminar no existe.'
	END
 
	IF(@errorCount = 0)
	BEGIN
		DELETE FROM PnTablas.TieneHActividad
		WHERE Pago = @pago AND Actividad = @actividad AND FechaActividad = @fechaActividad AND HoraInicio = @horaInicio
	END
	ELSE
		PRINT @errorLine
END;
GO
PRINT '--Creado SP: bajaTHActividadOne--';
GO