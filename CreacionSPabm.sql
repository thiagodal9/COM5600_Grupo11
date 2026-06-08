USE ParquesNacionales;
GO

CREATE SCHEMA PnSPabm;
GO

-------------------------------------------------------------------------------------

CREATE PROCEDURE PnSPabm.nuevoTipoParque (@tipo varchar(30))
AS
BEGIN
	IF( NOT EXISTS (SELECT DescripcionParque FROM PnTablas.TipoParque WHERE DescripcionParque LIKE @tipo) )
		INSERT INTO PnTablas.TipoParque (DescripcionParque) VALUES (@tipo)
	ELSE
		PRINT 'ERROR: Tipo ya existente.'
END;
GO

CREATE PROCEDURE PnSPabm.borrarTipoParque (@tipo varchar(30))
AS
BEGIN
	DELETE FROM PnTablas.TipoParque
	WHERE DescripcionParque LIKE @tipo
END;
GO

CREATE PROCEDURE PnSPabm.cambiarTipoParque (@tipoOLD varchar(30), @tipoNEW varchar(30))
AS
BEGIN
	UPDATE PnTablas.TipoParque
	SET DescripcionParque = @tipoNEW
	WHERE DescripcionParque LIKE @tipoOLD
END;
GO

-------------------------------------------------------------------------------------

CREATE PROCEDURE PnSPabm.nuevoProvincia (@nombre varchar(15))
AS
BEGIN
	IF(NOT EXISTS (SELECT NombreProv FROM PnTablas.Provincia WHERE NombreProv LIKE @nombre))
		INSERT INTO PnTablas.Provincia (NombreProv) VALUES (@nombre)
	ELSE
		PRINT 'ERROR: Provincia ya existente.'
END;
GO

CREATE PROCEDURE PnSPabm.borrarProvincia (@nombre varchar(15))
AS
BEGIN
	DELETE FROM PnTablas.Provincia
	WHERE NombreProv LIKE @nombre
END;
GO

CREATE PROCEDURE PnSPabm.cambiarProvincia (@nombreOLD varchar(15), @nombreNEW varchar(15))
AS
BEGIN
	UPDATE PnTablas.Provincia
	SET NombreProv = @nombreNEW
	WHERE NombreProv LIKE @nombreOLD
END;
GO

-------------------------------------------------------------------------------------

CREATE PROCEDURE PnSPabm.nuevoParque (@nombre varchar(30), @ubicacion varchar(15), @superficie INT, @tipo varchar(30))
AS
BEGIN
	DECLARE @IDUbicacion INT
	DECLARE @IDTipoParque INT
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'
	SET @IDUbicacion = (SELECT IDProv FROM PnTablas.Provincia WHERE NombreProv LIKE @ubicacion)
	SET @IDTipoParque = (SELECT IDTipoParque FROM PnTablas.TipoParque WHERE DescripcionParque LIKE @tipo)

	IF(EXISTS (SELECT NombreParque FROM PnTablas.Parque WHERE NombreParque LIKE @nombre))
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Parque ya presente.'
	END

	IF(@IDUbicacion IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Ubicacion inexistente.'
	END

	IF(@superficie < 0)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Superficie negativa.'
	END

	IF(@IDTipoParque IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo inexistente.'
	END

	IF(@errorCount = 0)
		INSERT INTO PnTablas.Parque (NombreParque, Ubicacion, Superficie, Tipo) VALUES (@nombre, @IDUbicacion, @Superficie, @IDTipoParque)
	ELSE
		PRINT @errorLine
END;
GO

CREATE PROCEDURE PnSPabm.borrarParque (@nombre varchar(30))
AS
BEGIN
	DELETE FROM PnTablas.Parque
	WHERE NombreParque LIKE @nombre
END;
GO

CREATE PROCEDURE PnSPabm.cambiarNombreParque (@nombreOLD varchar(30), @nombreNEW varchar(30))
AS
BEGIN
	UPDATE PnTablas.Parque
	SET NombreParque = @nombreNEW
	WHERE NombreParque = @nombreOLD
END;
GO

CREATE PROCEDURE PnSPabm.cambiarSuperficieParque (@nombre varchar(30), @SuperficieNEW INT)
AS
BEGIN
	UPDATE PnTablas.Parque
	SET Superficie = @SuperficieNEW
	WHERE NombreParque LIKE @nombre
END;
GO

-------------------------------------------------------------------------------------

CREATE PROCEDURE PnSPabm.llenarTablaDia
AS
BEGIN
	INSERT INTO PnTablas.Dia (NombreDia) 
	VALUES 
	('Lunes'), ('Martes'), ('Miercoles'), 
	('Jueves'), ('Viernes'), ('Sabado'), 
	('Domingo')
END
GO

-------------------------------------------------------------------------------------

CREATE PROCEDURE PnSPabm.nuevoHorario (@parque varchar(30), @dia varchar(10), @hapertura TIME, @hcierre TIME, @temporada varchar(10))
AS
BEGIN
	DECLARE @IDParque INT
	DECLARE @IDDia INT
	DECLARE @IDout TABLE(ID INT)

	SET @IDParque = (SELECT IDParque FROM PnTablas.Parque WHERE NombreParque LIKE @parque)

	IF(@IDParque IS NULL)
		PRINT 'ERROR: Parque inexistente.'
	ELSE
	BEGIN
		SET @IDDia = (SELECT IDDia FROM PnTablas.Dia WHERE NombreDia LIKE @dia)

		IF
		(NOT EXISTS(
			SELECT A.Horario
			FROM 
			(SELECT Horario FROM PnTablas.Abre WHERE (Parque = @IDParque) AND (Dia = @IDDia)) AS A 
			JOIN 
			PnTablas.HorarioParque AS B 
			ON (A.Horario = B.IDHorarioP)
			WHERE (B.HoraApertura = @hapertura) AND (B.HoraCierre = @hcierre) AND (Temporada LIKE @temporada)
		))
		BEGIN
			INSERT INTO PnTablas.HorarioParque (HoraApertura, HoraCierre, Temporada)
			OUTPUT inserted.IDHorarioP INTO @IDout(ID)
			VALUES (@hapertura, @hcierre, @temporada)

			INSERT INTO PnTablas.Abre (Parque, Dia, Horario)
			VALUES (@IDParque, @IDDia, (SELECT ID FROM @IDout))
		END
		ELSE
			PRINT 'ERROR: Horario ya presente.'
	END
END;
GO

CREATE PROCEDURE PnSPabm.borrarHorario (@parque varchar(30), @dia varchar(10), @hapertura TIME, @hcierre TIME, @temporada varchar(10))
AS
BEGIN
	DECLARE @IDParque INT
	DECLARE @IDDia INT
	DECLARE @IDHorario INT

	SET @IDParque = (SELECT IDParque FROM PnTablas.Parque WHERE NombreParque LIKE @parque)
	SET @IDDia = (SELECT IDDia FROM PnTablas.Dia WHERE NombreDia LIKE @dia)

	SET @IDHorario = (
	SELECT ID
	FROM
	(
		SELECT H.IDHorarioP AS ID, H.HoraApertura AS Ha, H.HoraCierre AS Hc, H.Temporada AS Tem
		FROM
		(SELECT Horario FROM PnTablas.Abre WHERE (Parque = @IDParque) AND (Dia = @IDDia)) AS A
		JOIN
		PnTablas.HorarioParque AS H
		ON (A.Horario = H.IDHorarioP)
	) AS t
	WHERE (Ha = @hapertura) AND (Hc = @hcierre) AND (Tem LIKE @temporada)
	)

	DELETE FROM PnTablas.Abre
	WHERE (Parque = @IDParque) AND (Dia = @IDDia) AND (Horario = @IDHorario)

	DELETE FROM PnTablas.HorarioParque
	WHERE IDHorarioP = @IDHorario
END;
GO

CREATE PROCEDURE PnSPabm.cambiarHorario 
(@parque varchar(30), @dia varchar(10), @temporada varchar(10), 
@haperturaOLD TIME, @hcierreOLD TIME, 
@haperturaNEW TIME, @hcierreNEW TIME)
AS
BEGIN
	DECLARE @IDParque INT
	DECLARE @IDDia INT

	SET @IDParque = (SELECT IDParque FROM PnTablas.Parque WHERE NombreParque LIKE @parque)
	SET @IDDia = (SELECT IDDia FROM PnTablas.Dia WHERE NombreDia LIKE @dia);

	WITH t AS
	(
		SELECT H.HoraApertura AS Ha, H.HoraCierre AS Hc, H.Temporada AS Tem
		FROM
		(SELECT Horario FROM PnTablas.Abre WHERE (Parque = @IDParque) AND (Dia = @IDDia)) AS A
		JOIN
		PnTablas.HorarioParque AS H
		ON (A.Horario = H.IDHorarioP)
	)
	UPDATE t
	SET Ha = @haperturaNEW, Hc = @hcierreNEW
	WHERE (Ha = @haperturaOLD) AND (Hc = @hcierreOLD) AND (Tem LIKE @temporada)
END;
GO

-------------------------------------------------------------------------------------
CREATE PROCEDURE PnSPabm.nuevoTelefonoParque (@numero varchar(12), @parque varchar(30))
AS
BEGIN
	DECLARE @IDParque INT

	SET @IDParque = (SELECT IDParque FROM PnTablas.Parque WHERE NombreParque LIKE @parque)

	IF(@IDParque IS NULL)
		PRINT 'ERROR: Parque inexistente.'
	ELSE
	BEGIN
		IF(EXISTS (SELECT NumeroParque FROM PnTablas.TelefonoParque WHERE NumeroParque LIKE @numero))
			PRINT 'ERROR: Numero ya existente para ese parque.'
		ELSE
			INSERT INTO PnTablas.TelefonoParque VALUES (@numero, @IDParque)
	END
END;
GO

CREATE PROCEDURE PnSPabm.borrarTelefonoParque (@numero varchar(12), @parque varchar(30))
AS
BEGIN
	DECLARE @IDParque INT

	SET @IDParque = (SELECT IDParque FROM PnTablas.Parque WHERE NombreParque LIKE @parque)

	DELETE FROM PnTablas.TelefonoParque
	WHERE (NumeroParque LIKE @numero) AND (Parque = @IDParque)
END;
GO

CREATE PROCEDURE PnSPabm.cambiarTelefonoParque (@numeroOLD varchar(12), @numeroNEW varchar(12), @parque varchar(30))
AS
BEGIN
	DECLARE @IDParque INT

	SET @IDParque = (SELECT IDParque FROM PnTablas.Parque WHERE NombreParque LIKE @parque)

	UPDATE PnTablas.TelefonoParque
	SET NumeroParque = @numeroNEW
	WHERE (NumeroParque LIKE @numeroOLD) AND (Parque = @IDParque)
END;
GO

-------------------------------------------------------------------------------------

CREATE PROCEDURE PnSPabm.nuevoTipoActividad (@descripcion varchar(30), @costo DECIMAL(7, 2))
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	IF( EXISTS (SELECT * FROM PnTablas.TipoActividad WHERE DescripcionAct LIKE @descripcion) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo ya presente.'
	END

	IF(@costo < 0)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Costo negativo.'
	END

	IF(@errorCount = 0)
		INSERT INTO PnTablas.TipoActividad (DescripcionAct, CostoAct) VALUES (@descripcion, @costo)
	ELSE
		PRINT @errorLine
END;
GO

CREATE PROCEDURE PnSPabm.cambiarDescripcionTipoActividad (@descripcionOLD varchar(30), @descripcionNEW varchar(30))
AS
BEGIN
	UPDATE PnTablas.TipoActividad
	SET DescripcionAct = @descripcionNEW
	WHERE DescripcionAct = @descripcionOLD
END;
GO

CREATE PROCEDURE PnSPabm.cambiarCostoTipoActividad (@descripcion varchar(30), @costoNEW DECIMAL(7, 2))
AS
BEGIN
	UPDATE PnTablas.TipoActividad
	SET CostoAct = @costoNEW
	WHERE DescripcionAct = @descripcion
END;
GO

CREATE PROCEDURE PnSPabm.borrarTipoActividad (@descripcion varchar(30))
AS
BEGIN
	DELETE FROM PnTablas.TipoActividad
	WHERE DescripcionAct = @descripcion
END;
GO

-------------------------------------------------------------------------------------

CREATE PROCEDURE PnSPabm.nuevoActividadParque (@nombre varchar(30), @duracion INT, @cupo INT, @parque varchar(30), @tipo varchar(30), @guia varchar(20))
AS
BEGIN
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)
	DECLARE @IDParque INT
	DECLARE @IDTipo INT
	DECLARE @IDGuia INT

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'
	SET @IDParque = (SELECT IDParque FROM PnTablas.Parque WHERE NombreParque LIKE @parque)
	SET @IDTipo = (SELECT IDTipoAct FROM PnTablas.TipoActividad WHERE DescripcionAct LIKE @tipo)
	SET @IDGuia = (
					SELECT G.IDGuia
					FROM
					PnTablas.Guia AS G
					JOIN
					PnTablas.Persona AS P
					ON (G.IDGuia = P.IDPersona)
					WHERE P.Nombre LIKE @guia)

	IF( EXISTS(SELECT NombreActividad FROM PnTablas.ActividadParque WHERE NombreActividad LIKE @nombre) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Actividad ya presente.'
	END

	IF(@IDParque IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
	END

	IF(@IDTipo IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo inexistente.'
	END

	IF(@duracion <= 0)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Duracion negativa/cero.'
	END

	IF(@cupo <= 0)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Cupo negativo/cero.'
	END

	IF(@IDGuia IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Guia inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		INSERT INTO PnTablas.ActividadParque (NombreActividad, Duracion, CupoMax, Parque, Tipo)
		VALUES (@nombre, @duracion, @cupo, @IDParque, @IDTipo)
	END
	ELSE
		PRINT @errorLine
END;
GO

CREATE PROCEDURE PnSPabm.cambiarNombreActividadParque (@nombreOLD varchar(30), @nombreNEW varchar(30))
AS
BEGIN
	UPDATE PnTablas.ActividadParque
	SET NombreActividad = @nombreNEW
	WHERE NombreActividad LIKE @nombreOLD
END;
GO

CREATE PROCEDURE PnSPabm.cambiarDuracionActividadParque (@nombre varchar(30), @duracionNEW INT)
AS
BEGIN
	UPDATE PnTablas.ActividadParque
	SET Duracion = @duracionNEW
	WHERE NombreActividad LIKE @nombre
END;
GO

CREATE PROCEDURE PnSPabm.cambiarCupoActividadParque (@nombre varchar(30), @cupoNEW INT)
AS
BEGIN
	UPDATE PnTablas.ActividadParque
	SET CupoMax  = @cupoNEW
	WHERE NombreActividad LIKE @nombre
END;
GO

CREATE PROCEDURE PnSPabm.cambiarGuiaActividadParque (@nombre varchar(30), @guia varchar(20))
AS
BEGIN
	DECLARE @IDGuia INT

	SET @IDGuia = (
					SELECT G.IDGuia
					FROM
					PnTablas.Guia AS G
					JOIN
					PnTablas.Persona AS P
					ON (G.IDGuia = P.IDPersona)
					WHERE P.Nombre LIKE @guia)

	IF(@IDGuia IS NULL)
		PRINT 'Error: Guia Inexistente.'
	ELSE
	BEGIN
		UPDATE PnTablas.ActividadParque
		SET Guia  = @guia
		WHERE NombreActividad LIKE @nombre
	END
END;
GO

CREATE PROCEDURE PnSPabm.borrarActividadParque (@nombre varchar(30))
AS
BEGIN
	DELETE FROM PnTablas.ActividadParque
	WHERE NombreActividad LIKE @nombre
END;
GO