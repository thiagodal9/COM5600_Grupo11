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

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----SP de API
--verClimaEnParque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.verClimaParque'))
    DROP PROCEDURE PnSP.verClimaParque
GO
CREATE PROCEDURE PnSP.verClimaParque (@parque INT)
AS
BEGIN
	DECLARE @errorCount INT

	DECLARE @TempActual DECIMAL(5,2);
	DECLARE @Lluvia BIT
	DECLARE @EstadoClima VARCHAR(50)
	DECLARE @Latitud VARCHAR(20)
    DECLARE @Longitud VARCHAR(20)

	SET @errorCount = 0

	IF( (@parque IS NULL) OR (@parque <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Parque invalido.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @parque) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Parque inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		SET @Latitud = (SELECT Latitud FROM PnTablas.Parque WHERE IDParque = @parque)
		SET @Longitud = (SELECT Longitud FROM PnTablas.Parque WHERE IDParque = @parque)

		EXEC PnSPapi.ObtenerClimaActual @Latitud = @Latitud, @Longitud = @Longitud, @Temperatura = @TempActual OUTPUT, @EsLluvioso = @Lluvia OUTPUT

		IF @Lluvia = 1 SET @EstadoClima = 'Jornada Lluviosa'; ELSE SET @EstadoClima = 'Condiciones Favorables'

		SELECT 
			@TempActual AS [Temperatura Actual (°C)],
			@EstadoClima AS [Estado del Clima]
	END
END;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----SP de reportes

--Reporte de visitas por semana, mes y año, por parque. Devuelve un .xml fisico.
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.rptVisitasPorPeriodoXML'))
	DROP PROCEDURE PnSP.rptVisitasPorPeriodoXML
GO
CREATE PROCEDURE PnSP.rptVisitasPorPeriodoXML
AS
BEGIN
    SET NOCOUNT ON;
	EXEC xp_cmdshell 'bcp "SELECT P.NombreParque AS [Parque],YEAR(PE.FechaAcceso) AS [Anio], MONTH(PE.FechaAcceso) AS [Mes],DATEPART(week, PE.FechaAcceso) AS [Semana], SUM(PE.Cantidad) AS [Visitas] FROM ParquesNacionales.PnTablas.Parque P INNER JOIN ParquesNacionales.PnTablas.Entrada E ON P.IDParque = E.Parque INNER JOIN ParquesNacionales.PnTablas.PoseeEntrada PE ON E.IDEntrada = PE.Entrada GROUP BY P.NombreParque, YEAR(PE.FechaAcceso), MONTH(PE.FechaAcceso), DATEPART(week, PE.FechaAcceso) ORDER BY NombreParque, Anio, Mes, Semana FOR XML PATH(''Visitas''), ROOT (''VisitasPeriodo'')" queryout "C:\Users\Usuario\Desktop\outputSQL\rptVisitas.xml" -T -c -t,'
END;
GO
PRINT '--Creado SP: rptVisitasPorPeriodoXML--';
GO

--Ingresos por parque por semana, mes y año (entradas y concesiones)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.rptIngresosTotales'))
	DROP PROCEDURE PnSP.rptIngresosTotales
GO
CREATE PROCEDURE PnSP.rptIngresosTotales
AS
BEGIN
    SET NOCOUNT ON;
	WITH TodoElIngreso AS (
		--Ingresos por Ventas de Entradas 
		SELECT 
			E.Parque AS IDParque, 
			PV.FechaHoraTransaccion AS Fecha, 
			(PE.Cantidad * E.Precio) AS Monto 
		FROM PnTablas.PagoVenta PV
		INNER JOIN PnTablas.PoseeEntrada PE ON PV.IDPagoVenta = PE.Pago
		INNER JOIN PnTablas.Entrada E ON PE.Entrada = E.IDEntrada
		
		UNION ALL
		
		-- Ingresos por Pagos de Concesiones
		SELECT 
			C.Parque AS IDParque, 
			HP.Vencimiento AS Fecha, 
			HP.Importe AS Monto
		FROM PnTablas.HistorialPago HP
		INNER JOIN PnTablas.Concesion C ON HP.Concesion = C.IDConcesion
		WHERE HP.Estado = 'Pago'
	)
	SELECT 
		P.NombreParque AS NombreParque,
		YEAR(I.Fecha) AS Anio,
		MONTH(I.Fecha) AS Mes,
		DATEPART(week, I.Fecha) AS Semana,
		SUM(I.Monto) AS TotalIngresos
	FROM PnTablas.Parque P
	INNER JOIN TodoElIngreso I ON P.IDParque = I.IDParque
	GROUP BY P.NombreParque, YEAR(I.Fecha), MONTH(I.Fecha), DATEPART(week, I.Fecha)
	ORDER BY NombreParque, Anio, Mes, Semana;
END;
GO
PRINT '--Creado SP: rptIngresosTotales--';
GO

--Deudores (Concesiones atrasadas, detallando meses y montos). Devuelve un hipervinculo.
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.rptConcesionesDeudorasXML'))
	DROP PROCEDURE PnSP.rptConcesionesDeudorasXML
GO
CREATE PROCEDURE PnSP.rptConcesionesDeudorasXML
AS
BEGIN
    SET NOCOUNT ON;
	SELECT 
		P.NombreParque AS 'Parque',
		Emp.NombreEmpresa AS 'Titular',
		C.Rubro AS 'Actividad',
		C.CostoAlquiler AS 'CanonMensual',
		COUNT(HP.IDPagoConcesion) AS 'MesesAtraso',
		SUM(HP.Importe) AS 'MontoDeuda'
	FROM PnTablas.Concesion C
	INNER JOIN PnTablas.Empresa Emp ON C.Empresa = Emp.IDEmpresa
	INNER JOIN PnTablas.Parque P ON C.Parque = P.IDParque
	INNER JOIN PnTablas.HistorialPago HP ON C.IDConcesion = HP.Concesion
	-- Filtra los pagos vencidos que no tienen estado 'Pago'
	WHERE HP.Estado <> 'Pago' AND HP.Vencimiento < GETDATE()
	GROUP BY P.NombreParque, Emp.NombreEmpresa, C.Rubro, C.CostoAlquiler
	FOR XML PATH('Deudor'), ROOT('DeudoresAtrasados'), ELEMENTS;
END;
GO
PRINT '--Creado SP: rptConcesionesDeudorasXML--';
GO

-- Matriz de visitas: Tabla cruzada mostrando visitas por mes y parque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.rptMatrizVisitasPivot'))
	DROP PROCEDURE PnSP.rptMatrizVisitasPivot
GO
CREATE PROCEDURE PnSP.rptMatrizVisitasPivot
	@anio INT = NULL 
AS
BEGIN
    SET NOCOUNT ON;
	IF @anio IS NULL SET @anio = YEAR(GETDATE());

	SELECT NombreParque, 
		   ISNULL([1], 0) AS Ene, ISNULL([2], 0) AS Feb, ISNULL([3], 0) AS Mar, 
		   ISNULL([4], 0) AS Abr, ISNULL([5], 0) AS May, ISNULL([6], 0) AS Jun, 
		   ISNULL([7], 0) AS Jul, ISNULL([8], 0) AS Ago, ISNULL([9], 0) AS Sep, 
		   ISNULL([10], 0) AS Oct, ISNULL([11], 0) AS Nov, ISNULL([12], 0) AS Dic
	FROM (
		SELECT 
			P.NombreParque AS NombreParque, 
			MONTH(PE.FechaAcceso) AS Mes, 
			PE.Cantidad
		FROM PnTablas.Parque P
		INNER JOIN PnTablas.Entrada E ON P.IDParque = E.Parque
		INNER JOIN PnTablas.PoseeEntrada PE ON E.IDEntrada = PE.Entrada
		WHERE YEAR(PE.FechaAcceso) = @anio
	) AS DatosOrigen
	PIVOT (
		SUM(Cantidad)
		FOR Mes IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
	) AS TablaPivotada;
END;
GO
PRINT '--Creado SP: rptMatrizVisitasPivot--';
GO

-- Parques y concesiones: Listado de parques y vector anidado. Devuelve un hipervinculo.
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.rptParquesConcesionesAnidadoXML'))
	DROP PROCEDURE PnSP.rptParquesConcesionesAnidadoXML
GO
CREATE PROCEDURE PnSP.rptParquesConcesionesAnidadoXML
AS
BEGIN
    SET NOCOUNT ON;
	SELECT 
		P.NombreParque AS '@NombreParque',
		(
			SELECT 
				Emp.NombreEmpresa AS 'Titular',
				C.FechaInicioConcesion AS 'FechaInicio',
				C.FechaFinConcesion AS 'FechaFin',
				C.Rubro AS 'ServicioPrestado'
			FROM PnTablas.Concesion C
			INNER JOIN PnTablas.Empresa Emp ON C.Empresa = Emp.IDEmpresa
			WHERE C.Parque = P.IDParque
			FOR XML PATH('Concesion'), TYPE
		)
	FROM PnTablas.Parque P
	FOR XML PATH('Parque'), ROOT('ReporteParquesConcesiones');
END;
GO
PRINT '--Creado SP: rptParquesConcesionesAnidadoXML--';
GO