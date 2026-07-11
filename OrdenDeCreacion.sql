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

:r CreacionInicial.sql
:r CreacionTablasParque.sql
:r CreacionTablasPersona.sql
:r CreacionTablasActividad.sql
:r CreacionTablasConcesion.sql
:r CreacionTablasVenta.sql
:r CreacionSP.sql
:r CreacionSPabmParque.sql
:r CreacionSPabmPersona.sql
:r CreacionSPabmActividad.sql
:r CreacionSPabmConcesion.sql
:r CreacionSPabmEntrada.sql
:r CreacionSPabmVenta.sql
:r CreacionSPtransParque.sql
:r CreacionSPtransPersona.sql
:r CreacionSPtransConcesion.sql
:r CreacionSPtransVenta.sql
:r CreacionLoginUserApp.sql
:r CreacionRoles.sql
:r Cifrado.sql
:r InsercionDatos.sql

PRINT '--Base de datos creada completamente--';
GO
*/