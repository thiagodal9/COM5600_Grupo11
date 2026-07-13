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

PRINT '--Creando SPs...--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----SPs usados por la APP
--verParques (no join)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.verParques'))
	DROP PROCEDURE PnSP.verParques
GO
CREATE PROCEDURE PnSP.verParques
AS
BEGIN
	SELECT *
	FROM PnTablas.Parque
END;
GO
PRINT '--Creado SP: verParques--';
GO

--verTipoParque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.verTipoParque'))
	DROP PROCEDURE PnSP.verTipoParque
GO
CREATE PROCEDURE PnSP.verTipoParque
AS
BEGIN
	SELECT *
	FROM PnTablas.TipoParque
END;
GO
PRINT '--Creado SP: verTipoParque--';
GO

--verProvincia
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.verProvincia'))
	DROP PROCEDURE PnSP.verProvincia
GO
CREATE PROCEDURE PnSP.verProvincia
AS
BEGIN
	SELECT *
	FROM PnTablas.Provincia
END;
GO
PRINT '--Creado SP: verProvincia--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----SPs que cubren requisitos
--verInformacionGeneralParques
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.verInfoGeneralParques'))
    DROP PROCEDURE PnSP.verInfoGeneralParques
GO
CREATE PROCEDURE PnSP.verInfoGeneralParques
AS
BEGIN
	SELECT 
	PaPr.IDParque AS [ID], PaPr.NombreParque AS [Parque], PaPr.NombreProv AS [Ubicacion], 
	PaPr.Superficie AS [Superficie(en hectareas)], Tp.DescripcionParque AS [Tipo]
	FROM
	(
		SELECT Pa.IDParque, Pa.NombreParque, Pr.NombreProv, Pa.Superficie, Pa.Tipo
		FROM 
		PnTablas.Parque AS Pa
		JOIN
		PnTablas.Provincia AS Pr
		ON (Pa.Ubicacion = Pr.IDProv)
	) AS PaPr
	JOIN
	PnTablas.TipoParque AS Tp
	ON (PaPr.Tipo = Tp.IDTipoParque)
END;
GO
PRINT '--Creado SP: verInfoGeneralParques--';
GO

-------------------------------------------------------------------------------------
--verContactoParques
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.verContactoParques'))
    DROP PROCEDURE PnSP.verContactoParques
GO
CREATE PROCEDURE PnSP.verContactoParques
AS
BEGIN
	SELECT P.NombreParque AS [Nombre del Parque], T.NumeroParque AS [Telefono]
	FROM
	PnTablas.Parque AS P
	LEFT JOIN
	PnTablas.TelefonoParque AS T
	ON (P.IDParque = T.Parque)
END;
GO
PRINT '--Creado SP: verContactoParques--';
GO

-------------------------------------------------------------------------------------
--verInfoOperativaParques
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.verInfoOperativaParques'))
    DROP PROCEDURE PnSP.verInfoOperativaParques
GO
CREATE PROCEDURE PnSP.verInfoOperativaParques
AS
BEGIN
	SELECT 
	Pa.NombreParque AS [Parque], B.NombreDia AS [Dia], 
	CONVERT(char(5), B.HoraApertura) AS [Hora de Apertura], 
	CONVERT(char(5), B.HoraCierre) AS [Hora de Cierre], B.Temporada
	FROM
	(
		SELECT A.Parque, A.NombreDia, Hp.HoraApertura, Hp.HoraCierre, Hp.Temporada
		FROM
		(
			SELECT Ab.Parque, D.NombreDia, Ab.Horario
			FROM
			PnTablas.Abre AS Ab
			JOIN
			PnTablas.Dia AS D
			ON (Ab.Dia = D.IDDia)
		) AS A
		JOIN
		PnTablas.HorarioParque AS Hp
		ON (A.Horario = Hp.IDHorarioP)
	) AS B
	JOIN
	PnTablas.Parque AS Pa
	ON (Pa.IDParque = B.Parque)
END;
GO
PRINT '--Creado SP: verInfoOperativaParques--';
GO

-------------------------------------------------------------------------------------
--proximosVence 
--(solo se consultan por vencimientos del mes actual y sin monto. Los montos se cubren con SP para reporte)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.proximosVence'))
    DROP PROCEDURE PnSP.proximosVence
GO
CREATE PROCEDURE PnSP.proximosVence
AS
BEGIN
	DECLARE @fecha DATE

	SET @fecha = GETDATE();

	WITH Vence AS
	(
		SELECT Concesion, Vencimiento
		FROM PnTablas.HistorialPago
		WHERE 
		MONTH(Vencimiento) = MONTH(@fecha) AND YEAR(Vencimiento) = YEAR(@fecha)
		AND Estado = 'Impago'
	)
	SELECT 
	PaCoEm.NombreParque AS [Parque], 
	PaCoEm.NombreEmpresa AS [Empresa Deudora], 
	Vence.Vencimiento
	FROM 
	Vence
	JOIN
	(
		SELECT PaCo.IDConcesion, PaCo.NombreParque, Em.NombreEmpresa
		FROM
		(
			SELECT Pa.NombreParque, Co.Empresa, Co.IDConcesion
			FROM
			PnTablas.Parque AS Pa
			JOIN
			PnTablas.Concesion AS Co
			ON (Pa.IDParque = Co.Parque)
		) AS PaCo
		JOIN
		PnTablas.Empresa AS Em
		ON (PaCo.Empresa = Em.IDEmpresa)
	) AS PaCoEm
	ON (Vence.Concesion = PaCoEm.IDConcesion)
END;
GO
PRINT '--Creado SP: proximosVence--';
GO

-------------------------------------------------------------------------------------
--estadoGuardaparque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.estadoGuardaparque'))
    DROP PROCEDURE PnSP.estadoGuardaparque
GO
CREATE PROCEDURE PnSP.estadoGuardaparque @id INT
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF( (@id IS NULL) OR (@id <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: el ID ingresado es invalido.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.GuardaParque WHERE IDGuardaParque = @id) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: no existe ese guardaparque.'
	END

	IF(@errorCount = 0)
	BEGIN
		SELECT P.NombrePersona AS [Nombre], P.Apellido AS [Apellido], GP.Estado, GP.NombreParque AS [Parque Actual]
		FROM 
		(
			SELECT G.IDGuardaParque, G.Estado, P.NombreParque
			FROM
			(SELECT * FROM PnTablas.GuardaParque WHERE IDGuardaParque = @id) AS G
			LEFT JOIN
			PnTablas.Parque AS P
			ON (G.Parque = P.IDParque)
		) AS GP
		JOIN
		PnTablas.Persona AS P
		ON (GP.IDGuardaParque = P.IDPersona)
	END
END;
GO
PRINT '--Creado SP: estadoGuardaparque--';
GO

-------------------------------------------------------------------------------------
--verHistorialGuardaparque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.verHistorialGuardaparque'))
    DROP PROCEDURE PnSP.verHistorialGuardaparque
GO
CREATE PROCEDURE PnSP.verHistorialGuardaparque @id INT
AS
BEGIN
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF( (@id IS NULL) OR (@id <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: el ID ingresado es invalido.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.GuardaParque WHERE IDGuardaParque = @id) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: no existe ese guardaparque.'
	END

	IF(@errorCount = 0)
	BEGIN
		SELECT 
		GPThP.NombrePersona AS [Nombre], GPThP.Apellido AS [Apellido], 
		GPThP.NombreParque AS [Parque], 
		H.FechaInicio AS [Fecha de Inicio], H.FechaEgreso AS [Fecha de Egreso], 
		H.RazonEgreso [Razon de Egreso]
		FROM
		(
			SELECT GPTh.NombrePersona, GPTh.Apellido, P.NombreParque, GPTh.Registro
			FROM
			(
				SELECT GP.NombrePersona, GP.Apellido, Th.Parque, Th.Registro
				FROM
				(
					SELECT G.IDGuardaParque, P.NombrePersona, P.Apellido
					FROM
					(SELECT IDGuardaParque FROM PnTablas.GuardaParque WHERE IDGuardaParque = @id) AS G
					JOIN
					PnTablas.Persona AS P
					ON (G.IDGuardaParque = P.IDPersona)
				) AS GP
				JOIN
				PnTablas.TieneHistorial AS Th
				ON (GP.IDGuardaParque = Th.Guardaparque)
			) AS GPTh
			JOIN
			PnTablas.Parque AS P
			ON (GPTh.Parque = P.IDParque)
		) AS GPThP
		JOIN
		PnTablas.Historial AS H
		ON (GPThP.Registro = H.IDregistro)
	END
END;
GO
PRINT '--Creado SP: verHistorialGuardaparque--';
GO