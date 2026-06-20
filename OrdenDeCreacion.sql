/*
-/-/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

ejecuta la creacion completa de la base de datos en el orden correcto.
A diferencia de los SP, un CREATE TABLE con FK necesita que la tabla referenciada ya exista,
por eso el orden de ejecucion de estos 4 scripts no es arbitrario.

ORDEN OBLIGATORIO (por dependencias de FK):
1) CreacionInicial.sql         -> crea la BD y los schemas
2) CreacionTablasParque.sql    -> no depende de otras tablas del proyecto
3) CreacionTablasPersona.sql   -> Guardaparque depende de Parque
4) CreacionTablasActividad.sql -> Actividad depende de Parque y de Guia (definida en Persona)

USO: requiere Modo SQLCMD activado en SSMS (menu Consulta > Modo SQLCMD).
Los 4 archivos deben estar guardados en la misma carpeta que este script.
*/

/*
para que esto funcione se deberia crear un .bat que le diga a SQL Server donde esta parado antes de correr el script.

:r CreacionInicial.sql
:r CreacionTablasParque.sql
:r CreacionTablasPersona.sql
:r CreacionTablasActividad.sql

PRINT '--Base de datos creada completamente--';
GO
*/
