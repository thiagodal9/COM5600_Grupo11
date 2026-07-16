/*
17/06/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

En este script se realiza la importación de datos
*/


IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'Inserciones'
)
BEGIN
    EXEC('CREATE SCHEMA Inserciones');
END;
GO


--Creo la tabla final
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Inserciones' AND TABLE_NAME = 'Visitas')
begin
create table PnTablas.Visitas(
idVisita int identity(1,1) primary key,
fechaVisita date,
origenVisitante nvarchar(30),
cantVisitas decimal(10,2),
observaciones nvarchar(200)
)
end
go


select * from Inserciones.Visitas
go

/*
===========================================================================================================
INSERCIÓN CSV
===========================================================================================================
*/
CREATE OR ALTER PROCEDURE Inserciones.sp_ImportarVisitas
    @RutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

    -- Elimino la tabla temporal si existe
    IF OBJECT_ID('tempdb..#VisitasTemp') IS NOT NULL
        DROP TABLE #VisitasTemp;

    -- Creo la tabla temporal
    CREATE TABLE #VisitasTemp(
        indice_tiempo NVARCHAR(50),
        origen_visitantes NVARCHAR(30),
        visitas NVARCHAR(50),
        observaciones NVARCHAR(200)
    );

    -- Armo el BULK INSERT dinámicamente (SQLServer no me permite pasar la ruta como parámetro)
    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = '
        BULK INSERT #VisitasTemp
        FROM ''' + @RutaArchivo + '''
        WITH(
            FORMAT = ''CSV'',
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0A'',
            CODEPAGE = ''65001''
        );';

    EXEC sp_executesql @SQL;

    -- Inserto únicamente los registros nuevos
    INSERT INTO Inserciones.Visitas
    (
        fechaVisita,
        origenVisitante,
        cantVisitas,
        observaciones
    )
    SELECT
        CAST(indice_tiempo AS DATE),
        origen_visitantes,
        CAST(visitas AS DECIMAL(10,2)),
        observaciones
    FROM #VisitasTemp t
    WHERE NOT EXISTS (
        SELECT 1
        FROM Inserciones.Visitas v
        WHERE v.fechaVisita = CAST(t.indice_tiempo AS DATE)
          AND v.origenVisitante = t.origen_visitantes
          AND v.cantVisitas = CAST(t.visitas AS DECIMAL(10,2))
          AND ISNULL(v.observaciones,'') = ISNULL(t.observaciones,'')
    );

    DROP TABLE #VisitasTemp;
END;
GO

select * from Inserciones.Visitas
go

--Pruebo el SP
execute Inserciones.sp_ImportarVisitas 'C:\Importar\visitas-residentes-y-no-residentes.csv'
go


/*
===========================================================================================================
INSERCIÓN JSON
===========================================================================================================
*/

CREATE OR ALTER PROCEDURE Inserciones.sp_ImportarVisitasJSON
    @RutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @json NVARCHAR(MAX);

    SET @SQL = '
        SELECT @jsonOUT = BulkColumn
        FROM OPENROWSET(
            BULK ''' + @RutaArchivo + ''',
            SINGLE_CLOB
        ) AS Archivo;';

    EXEC sp_executesql
        @SQL,
        N'@jsonOUT NVARCHAR(MAX) OUTPUT',
        @jsonOUT = @json OUTPUT;

    IF OBJECT_ID('tempdb..#VisitasTemp') IS NOT NULL
        DROP TABLE #VisitasTemp;

    CREATE TABLE #VisitasTemp(
        indice_tiempo DATE,
        origen_visitantes NVARCHAR(30),
        visitas DECIMAL(10,2),
        observaciones NVARCHAR(200)
    );

    INSERT INTO #VisitasTemp
    SELECT
        indice_tiempo,
        origen_visitantes,
        visitas,
        observaciones
    FROM OPENJSON(@json)
    WITH(
        indice_tiempo DATE,
        origen_visitantes NVARCHAR(30),
        visitas DECIMAL(10,2),
        observaciones NVARCHAR(200)
    );

    INSERT INTO Inserciones.Visitas
    (
        fechaVisita,
        origenVisitante,
        cantVisitas,
        observaciones
    )
    SELECT
        indice_tiempo,
        origen_visitantes,
        visitas,
        observaciones
    FROM #VisitasTemp t
    WHERE NOT EXISTS(
        SELECT 1
        FROM Inserciones.Visitas v
        WHERE v.fechaVisita = t.indice_tiempo
          AND v.origenVisitante = t.origen_visitantes
          AND v.cantVisitas = t.visitas
          AND ISNULL(v.observaciones,'') = ISNULL(t.observaciones,'')
    );

    DROP TABLE #VisitasTemp;
END;
GO


IF NOT EXISTS (
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Inserciones'
      AND TABLE_NAME = 'visitasXRegion'
)
BEGIN
create table Inserciones.visitasXRegion(
idVisita int identity(1,1) primary key,
indice_tiempo date,
region_destino nvarchar(100),
origen_visitante char(50),
visitas decimal(10,2),
observaciones nvarchar(MAX)
)
END
go

select * from Inserciones.visitasXRegion
go

/*
===========================================================================================================
INSERCIÓN CSV
===========================================================================================================
*/
CREATE OR ALTER PROCEDURE Inserciones.sp_ImportarVisitasRegion
    @RutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#VisitasTemp') IS NOT NULL
        DROP TABLE #VisitasTemp;

    CREATE TABLE #VisitasTemp(
        indice_tiempo NVARCHAR(50),
        region_destino NVARCHAR(100),
        origen_visitantes NVARCHAR(30),
        visitas NVARCHAR(50),
        observaciones NVARCHAR(MAX)
    );

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = '
        BULK INSERT #VisitasTemp
        FROM ''' + @RutaArchivo + '''
        WITH(
            FORMAT = ''CSV'',
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0A'',
            FIRSTROW = 2,
            CODEPAGE = ''65001''
        );';

    EXEC sp_executesql @SQL;

    INSERT INTO Inserciones.visitasXRegion
    (
        indice_tiempo,
        region_destino,
        origen_visitante,
        visitas,
        observaciones
    )
    SELECT
        CAST(indice_tiempo AS DATE),
        region_destino,
        origen_visitantes,
        CAST(visitas AS DECIMAL(10,2)),
        observaciones
    FROM #VisitasTemp t
    WHERE NOT EXISTS (
        SELECT 1
        FROM Inserciones.visitasXRegion v
        WHERE v.indice_tiempo = CAST(t.indice_tiempo AS DATE)
          AND v.region_destino = t.region_destino
          AND v.origen_visitante = t.origen_visitantes
          AND v.visitas = CAST(t.visitas AS DECIMAL(10,2))
          AND ISNULL(v.observaciones, '') = ISNULL(t.observaciones, '')
    );

    DROP TABLE #VisitasTemp;
END;
GO

--Pruebo el SP
exec Inserciones.sp_ImportarVisitasRegion 'C:\Importar\visitas-residentes-y-no-residentes-por-region.csv'
go

/*
===========================================================================================================
INSERCIÓN JSON
===========================================================================================================
*/
CREATE OR ALTER PROCEDURE Inserciones.sp_ImportarVisitasRegionJSON
    @RutaArchivo NVARCHAR(260)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @json NVARCHAR(MAX);

    SET @SQL = '
        SELECT @jsonOUT = BulkColumn
        FROM OPENROWSET(
            BULK ''' + @RutaArchivo + ''',
            SINGLE_CLOB
        ) AS Archivo;';

    EXEC sp_executesql
        @SQL,
        N'@jsonOUT NVARCHAR(MAX) OUTPUT',
        @jsonOUT = @json OUTPUT;

    IF OBJECT_ID('tempdb..#VisitasTemp') IS NOT NULL
        DROP TABLE #VisitasTemp;

    CREATE TABLE #VisitasTemp(
        indice_tiempo DATE,
        region_destino NVARCHAR(100),
        origen_visitantes NVARCHAR(30),
        visitas DECIMAL(10,2),
        observaciones NVARCHAR(200)
    );

    INSERT INTO #VisitasTemp
    SELECT
        indice_tiempo,
        region_destino,
        origen_visitantes,
        visitas,
        observaciones
    FROM OPENJSON(@json)
    WITH(
        indice_tiempo DATE,
        region_destino NVARCHAR(100),
        origen_visitantes NVARCHAR(30),
        visitas DECIMAL(10,2),
        observaciones NVARCHAR(200)
    );

    INSERT INTO Inserciones.visitasXRegion
    (
        indice_tiempo,
        region_destino,
        origen_visitante,
        visitas,
        observaciones
    )
    SELECT
        indice_tiempo,
        region_destino,
        origen_visitantes,
        visitas,
        observaciones
    FROM #VisitasTemp t
    WHERE NOT EXISTS(
        SELECT 1
        FROM Inserciones.visitasXRegion v
        WHERE v.indice_tiempo = t.indice_tiempo
          AND v.region_destino = t.region_destino
          AND v.origen_visitante = t.origen_visitantes
          AND v.visitas = t.visitas
          AND ISNULL(v.observaciones,'') = ISNULL(t.observaciones,'')
    );

    DROP TABLE #VisitasTemp;
END;
GO

select * from Inserciones.visitasXRegion
go


IF NOT EXISTS (
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'Inserciones'
      AND TABLE_NAME = 'Reclamos'
)
BEGIN
    CREATE TABLE Inserciones.Reclamos(
        id_reclamo INT identity(1,1) primary key,
        reclamo_ano INT,
        reclamo_mes_nro TINYINT,
        reclamo_mes_nombre NVARCHAR(20),
        reclamo_prestadora NVARCHAR(150),
        reclamo_provincia NVARCHAR(100),
        reclamo_grupo NVARCHAR(150),
        reclamo_via_ingreso NVARCHAR(100),
        reclamo_resolucion NVARCHAR(50),
        reclamo_cantidad INT
    );
END;
GO

/*
===========================================================================================================
INSERCIÓN CSV
===========================================================================================================
*/
CREATE OR ALTER PROCEDURE Inserciones.sp_ImportarReclamos2022
AS
BEGIN
    SET NOCOUNT ON;

    -- Elimino la tabla temporal si existe
    IF OBJECT_ID('tempdb..#ReclamosTemp') IS NOT NULL
        DROP TABLE #ReclamosTemp;

    -- Creo la tabla temporal
    CREATE TABLE #ReclamosTemp(
        reclamo_ano NVARCHAR(10),
        reclamo_mes_nro NVARCHAR(10),
        reclamo_mes_nombre NVARCHAR(20),
        reclamo_prestadora NVARCHAR(150),
        reclamo_provincia NVARCHAR(100),
        reclamo_grupo NVARCHAR(150),
        reclamo_via_ingreso NVARCHAR(100),
        reclamo_resolucion NVARCHAR(50),
        reclamo_cantidad NVARCHAR(20)
    );

    -- Cargo el CSV
    BULK INSERT #ReclamosTemp
    FROM 'C:\Importar\reclamos_prestadoras_2022.csv'
    WITH(
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0D0A',
        CODEPAGE = '65001'
    );

    -- Inserto únicamente los registros nuevos
    INSERT INTO Inserciones.Reclamos
    (
        reclamo_ano,
        reclamo_mes_nro,
        reclamo_mes_nombre,
        reclamo_prestadora,
        reclamo_provincia,
        reclamo_grupo,
        reclamo_via_ingreso,
        reclamo_resolucion,
        reclamo_cantidad
    )
    SELECT
        CAST(reclamo_ano AS INT),
        CAST(reclamo_mes_nro AS TINYINT),
        reclamo_mes_nombre,
        reclamo_prestadora,
        reclamo_provincia,
        reclamo_grupo,
        reclamo_via_ingreso,
        reclamo_resolucion,
        CAST(reclamo_cantidad AS INT)
    FROM #ReclamosTemp t
    WHERE NOT EXISTS (
        SELECT 1
        FROM Inserciones.Reclamos r
        WHERE r.reclamo_ano = CAST(t.reclamo_ano AS INT)
          AND r.reclamo_mes_nro = CAST(t.reclamo_mes_nro AS TINYINT)
          AND r.reclamo_mes_nombre = t.reclamo_mes_nombre
          AND r.reclamo_prestadora = t.reclamo_prestadora
          AND r.reclamo_provincia = t.reclamo_provincia
          AND r.reclamo_grupo = t.reclamo_grupo
          AND r.reclamo_via_ingreso = t.reclamo_via_ingreso
          AND r.reclamo_resolucion = t.reclamo_resolucion
          AND r.reclamo_cantidad = CAST(t.reclamo_cantidad AS INT)
    );

    DROP TABLE #ReclamosTemp;
END;
GO

--Pruebo el SP
exec Inserciones.sp_ImportarReclamos2022
go

select * from Inserciones.Reclamos
go

/*
===========================================================================================================
INSERCIÓN JSON
===========================================================================================================
*/
CREATE OR ALTER PROCEDURE Inserciones.sp_ImportarJSON
    @RutaArchivo NVARCHAR(260)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @json NVARCHAR(MAX);

    SET @SQL = '
        SELECT @jsonOUT = BulkColumn
        FROM OPENROWSET(
            BULK ''' + @RutaArchivo + ''',
            SINGLE_CLOB
        ) AS Archivo;';

    EXEC sp_executesql
        @SQL,
        N'@jsonOUT NVARCHAR(MAX) OUTPUT',
        @jsonOUT = @json OUTPUT;

    IF OBJECT_ID('tempdb..#ReclamosTemp') IS NOT NULL
        DROP TABLE #ReclamosTemp;

    CREATE TABLE #ReclamosTemp(
        reclamo_ano INT,
        reclamo_mes_nro TINYINT,
        reclamo_mes_nombre NVARCHAR(20),
        reclamo_prestadora NVARCHAR(150),
        reclamo_provincia NVARCHAR(100),
        reclamo_grupo NVARCHAR(150),
        reclamo_via_ingreso NVARCHAR(100),
        reclamo_resolucion NVARCHAR(50),
        reclamo_cantidad INT
    );

    INSERT INTO #ReclamosTemp
    SELECT *
    FROM OPENJSON(@json)
    WITH(
        reclamo_ano INT,
        reclamo_mes_nro TINYINT,
        reclamo_mes_nombre NVARCHAR(20),
        reclamo_prestadora NVARCHAR(150),
        reclamo_provincia NVARCHAR(100),
        reclamo_grupo NVARCHAR(150),
        reclamo_via_ingreso NVARCHAR(100),
        reclamo_resolucion NVARCHAR(50),
        reclamo_cantidad INT
    );

    INSERT INTO Inserciones.Reclamos(
        reclamo_ano,
        reclamo_mes_nro,
        reclamo_mes_nombre,
        reclamo_prestadora,
        reclamo_provincia,
        reclamo_grupo,
        reclamo_via_ingreso,
        reclamo_resolucion,
        reclamo_cantidad
        )
    select
        reclamo_ano,
        reclamo_mes_nro,
        reclamo_mes_nombre,
        reclamo_prestadora,
        reclamo_provincia,
        reclamo_grupo,
        reclamo_via_ingreso,
        reclamo_resolucion,
        reclamo_cantidad
    FROM #ReclamosTemp t
    WHERE NOT EXISTS(
        SELECT 1
        FROM Inserciones.Reclamos r
        WHERE r.reclamo_ano = t.reclamo_ano
          AND r.reclamo_mes_nro = t.reclamo_mes_nro
          AND r.reclamo_mes_nombre = t.reclamo_mes_nombre
          AND r.reclamo_prestadora = t.reclamo_prestadora
          AND r.reclamo_provincia = t.reclamo_provincia
          AND r.reclamo_grupo = t.reclamo_grupo
          AND r.reclamo_via_ingreso = t.reclamo_via_ingreso
          AND r.reclamo_resolucion = t.reclamo_resolucion
          AND r.reclamo_cantidad = t.reclamo_cantidad
    );

    DROP TABLE #ReclamosTemp;
END;
GO

exec Inserciones.sp_ImportarJSON 'C:\Importar\reclamos_prestadoras_2022.json'
go

select * from Inserciones.Reclamos
go









