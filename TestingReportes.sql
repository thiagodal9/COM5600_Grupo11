/*
-/-/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada
Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

Testing de los SP correspondientes a los Reportes.
*/

USE ParquesNacionales;
GO

PRINT '=============================';
PRINT 'INICIANDO PRUEBAS DE REPORTES';
PRINT '=============================';
GO

---------------------------------------------------
-- PRUEBA 1: Reporte de visitas por semana, mes y año, por parque.
---------------------------------------------------
PRINT 'PRUEBA 1: Ejecutando rptVisitasPorPeriodo...';
-- RESULTADO ESPERADO: Una tabla con el Nombre del Parque, Año, Mes, Semana y la Cantidad total de visitantes en ese período.
EXEC PnSP.rptVisitasPorPeriodo;
GO

---------------------------------------------------
-- PRUEBA 2: Ingresos por parque por semana, mes y año.
---------------------------------------------------
PRINT 'PRUEBA 2: Ejecutando rptIngresosTotales...';
-- RESULTADO ESPERADO: Una tabla similar a la anterior pero sumando los montos recaudados por venta de entradas y pagos de concesiones.
EXEC PnSP.rptIngresosTotales;
GO

---------------------------------------------------
-- PRUEBA 3: Deudores (Concesiones atrasadas).
---------------------------------------------------
PRINT 'PRUEBA 3: Ejecutando rptConcesionesDeudorasXML...';
-- RESULTADO ESPERADO: Un hipervínculo en la grilla de resultados. 
EXEC PnSP.rptConcesionesDeudorasXML;
GO

---------------------------------------------------
-- PRUEBA 4: Matriz de visitas (Pivot).
---------------------------------------------------
PRINT 'PRUEBA 4: Ejecutando rptMatrizVisitasPivot...';
-- RESULTADO ESPERADO: Una tabla de doble entrada. Las filas serán los Parques y las columnas los meses del año y los valores serán la cant de visitas.
EXEC PnSP.rptMatrizVisitasPivot @Anio = 2026; 
GO

---------------------------------------------------
-- PRUEBA 5: Parques y concesiones (XML Anidado).
---------------------------------------------------
PRINT 'PRUEBA 5: Ejecutando rptParquesConcesionesAnidadoXML...';
-- RESULTADO ESPERADO: Un hipervínculo en la grilla de resultados.
EXEC PnSP.rptParquesConcesionesAnidadoXML;
GO