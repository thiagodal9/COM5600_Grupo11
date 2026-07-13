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

IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE name = 'APP')
BEGIN
	CREATE LOGIN APP
	WITH PASSWORD = 'ABCD', 
	CHECK_EXPIRATION = OFF,
	DEFAULT_DATABASE = ParquesNacionales;

	PRINT '--Creado Login: APP--';
END;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'appn')
BEGIN
	CREATE USER appn FOR LOGIN APP;

	GRANT EXECUTE ON PnSP.verTipoParque TO appn;
	GRANT EXECUTE ON PnSP.verProvincia TO appn;
	GRANT EXECUTE ON PnSP.verParques TO appn;
	GRANT EXECUTE ON PnSPabm.altaParque TO appn;
	GRANT EXECUTE ON PnSPabm.modificarNombreParque TO appn;
	GRANT EXECUTE ON PnSPabm.modificarSuperficieParque TO appn;
	GRANT EXECUTE ON PnSPabm.bajaParque TO appn;

	PRINT 'Creado User: appn y asignados permisos.--';
END;
GO