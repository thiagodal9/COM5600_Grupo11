/*
03/06/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

En este script se realiza la creacion de las tablas de Entrada
*/

/*
Tablas Principales: Entrada, TipoEntrada
*/

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

--Creación de tablas

--Tabla TipoEntrada
IF NOT EXISTS (
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'PnTablas'
      AND TABLE_NAME = 'TipoEntrada'
)
BEGIN
    CREATE TABLE PnTablas.TipoEntrada
    (
        IDTipoEntrada INT IDENTITY(1, 1) PRIMARY KEY,
        DescripcionTipoEntrada CHAR(20)
    )
END;
GO


--Tabla Entrada
IF NOT EXISTS (
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'PnTablas'
      AND TABLE_NAME = 'Entrada'
)
BEGIN
    CREATE TABLE PnTablas.Entrada
    (
        IDEntrada INT IDENTITY(1,1) PRIMARY KEY,
        Precio DECIMAL(10,2),
        TipoEntrada INT,
        Parque INT,
        FOREIGN KEY(TipoEntrada)
            REFERENCES PnTablas.TipoEntrada(IDTipoEntrada),
        FOREIGN KEY(Parque)
            REFERENCES PnTablas.Parque(IDParque)
    )
END;
GO
