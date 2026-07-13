/*
-/-/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

SP de los respectivos Reportes 
*/

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

PRINT '--Creando SPs...--';
GO

--Reporte de visitas por semana, mes y año, por parque.
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSP.rptVisitasPorPeriodo'))
	DROP PROCEDURE PnSP.rptVisitasPorPeriodo
GO
CREATE PROCEDURE PnSP.rptVisitasPorPeriodo
AS
BEGIN
    SET NOCOUNT ON;
	SELECT 
		P.NombreParque AS NombreParque,
		YEAR(PE.FechaAcceso) AS Anio,
		MONTH(PE.FechaAcceso) AS Mes,
		DATEPART(week, PE.FechaAcceso) AS Semana,
		SUM(PE.Cantidad) AS CantidadVisitas
	FROM PnTablas.Parque P
	INNER JOIN PnTablas.Entrada E ON P.IDParque = E.Parque
	INNER JOIN PnTablas.PoseeEntrada PE ON E.IDEntrada = PE.Entrada
	GROUP BY P.NombreParque, YEAR(PE.FechaAcceso), MONTH(PE.FechaAcceso), DATEPART(week, PE.FechaAcceso)
	ORDER BY NombreParque, Anio, Mes, Semana;
END;
GO
PRINT '--Creado SP: rptVisitasPorPeriodo--';
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


--Deudores (Concesiones atrasadas, detallando meses y montos)
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


-- Parques y concesiones: Listado de parques y vector anidado
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