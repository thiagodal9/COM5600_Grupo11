/*
-------------------------------------------------------------------
2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada
Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

DOCUMENTACIÓN DEL ORDEN DE EJECUCIÓN DE SCRIPTS
-------------------------------------------------------------------
Para desplegar la base de datos completa sin errores de dependencias 
los scripts deben ejecutarse en el siguiente orden estricto:

FASE 1: INICIALIZACIÓN 
1) CreacionInicial.sql

FASE 2: TABLAS
2) CreacionTablasParque.sql    (No depende de otras tablas)
3) CreacionTablasPersona.sql   (Depende de Parque)
4) CreacionTablasActividad.sql (Depende de Parque y Persona)
5) CreacionTablasConcesion.sql (Depende de Parque)
6) CreacionTablasVenta.sql     (Depende de Parque, Persona, Actividad, etc.)

FASE 3: STORED PROCEDURES 
7)  CreacionSP.sql
8)  CreacionSPabmParque.sql
9)  CreacionSPabmPersona.sql
10) CreacionSPabmActividad.sql
11) CreacionSPabmConcesion.sql
12) CreacionSPabmEntrada.sql
13) CreacionSPabmVenta.sql
14) CreacionSPtransParque.sql
15) CreacionSPtransPersona.sql
16) CreacionSPtransConcesion.sql
17) CreacionSPtransVenta.sql

FASE 4: SEGURIDAD Y CIFRADO
18) CreacionLoginUserApp.sql
19) CreacionRoles.sql
20) Cifrado.sql

FASE 5: POBLADO DE DATOS Y TESTING
21) InsercionDatos.sql
22) Dataset_testing.sql (solo para testing)
-------------------------------------------------------------------
Para ejecución automatizada requiere Modo SQLCMD activado en SSMS (menú Consulta > Modo SQLCMD).
Los archivos deben estar guardados en la misma carpeta que este script.
*/

/*
-- Para que esto funcione automatizado se debería crear un .bat que le 
-- diga a SQL Server dónde está parado antes de correr el script.

-- Reemplazar PATH con el correspondiente a la carpeta donde se encuentran los scripts a ejecutar.
-- CTRL+F abre para hacer refactor.

:r PATH\CreacionInicial.sql
:r PATH\CreacionTablasParque.sql
:r PATH\CreacionTablasPersona.sql
:r PATH\CreacionTablasActividad.sql
:r PATH\CreacionTablasConcesion.sql
:r PATH\CreacionTablasVenta.sql
:r PATH\CreacionSP.sql
:r PATH\CreacionSPapi.sql
:r PATH\CreacionSPabmParque.sql
:r PATH\CreacionSPabmPersona.sql
:r PATH\CreacionSPabmActividad.sql
:r PATH\CreacionSPabmConcesion.sql
:r PATH\CreacionSPabmEntrada.sql
:r PATH\CreacionSPabmVenta.sql
:r PATH\CreacionSPtransParque.sql
:r PATH\CreacionSPtransPersona.sql
:r PATH\CreacionSPtransConcesion.sql
:r PATH\CreacionSPtransVenta.sql
:r PATH\ConfigOLE.sql
:r PATH\CreacionLoginUserApp.sql
:r PATH\Dataset_testing.sql

PRINT '--Base de datos creada completamente--';
GO
*/

--No correr esta parte automaticamente.
/*
:r PATH\CreacionRoles.sql
:r PATH\Cifrado.sql
*/
