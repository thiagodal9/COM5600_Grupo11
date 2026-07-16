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
-- RESULTADO ESPERADO: Un archivo .xml fisico en el path especificado.
--NOTA 1: requiere activar la ejecucion de lineas de comando para poder generar el archivo de salida
--NOTA 2: verificar el path de salida antes de ejecutar. 
--Para facilitar la ejecucion, el path de salida es una carpeta 
--en escritorio (C:\Users\Usuario\Desktop\outputSQL\rptVisitas.xml). Crearla antes de ejecutar y 
--otorgar permisos de escritura a SQL. Si se desconoce el usuario al que se debe otorgar el permiso, correr la
--siguiente linea de comando (EXEC xp_cmdshell 'whoami') en SQL y copiar el resultado obtenido.

--Habilitacion de lineas de comando en SQL
EXEC master.dbo.sp_configure 'show advanced options', 1
RECONFIGURE
EXEC master.dbo.sp_configure 'xp_cmdshell', 1
RECONFIGURE

EXEC PnSP.rptVisitasPorPeriodoXML
GO

--Vuelvo a poner todo como estaba
EXEC master.dbo.sp_configure 'xp_cmdshell', 0
RECONFIGURE
EXEC master.dbo.sp_configure 'show advanced options', 0
RECONFIGURE

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