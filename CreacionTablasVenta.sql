/*
03/06/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

En este script se realiza la creacion de las tablas de ventas
*/

/*
Tablas Principales: PagoVenta, PagoPoseeEntrada, VentaTieneHorarioParque
Tablas intermedias: #ventaEntrada, #ventaActividad
*/

use ParquesNacionales
go

--Creación de tablas

--Tabla PagoVenta
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'PagoVenta')
begin
create table PnTablas.PagoVenta(
idPagoVenta int identity(1,1) primary key,
importe decimal(10,2),
fechaPago date,
item char(30),
metodo char(30),
venta int
)
end
go

--Tabla #ventaEntradas
IF OBJECT_ID('tempdb..#ventaEntradas') IS NULL
BEGIN
    CREATE TABLE #ventaEntradas
    (
        IDvEntrada INT IDENTITY(1, 1) PRIMARY KEY,
        Entrada INT,
        Cantidad INT,
        FOREIGN KEY(Entrada) REFERENCES PnTablas.Entrada(IDEntrada)
    )
END;
GO

--Tabla #ventaActividades
IF OBJECT_ID('tempdb..#ventaActividades') IS NULL
BEGIN
    CREATE TABLE #ventaActividades
    (
        IdvActividad INT IDENTITY(1, 1) PRIMARY KEY,
        Actividad INT,
        FechaActividad DATE,
        Cantidad INT,
        FOREIGN KEY(Actividad, FechaActividad)
            REFERENCES PnTablas.HorarioActividad(IDActividad, FechaActividad)
    )
END;
GO

--Tabla PagoPoseeEntrada
IF NOT EXISTS (
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'PnTablas'
      AND TABLE_NAME = 'PagoPoseeEntrada'
)
BEGIN
    CREATE TABLE PnTablas.PagoPoseeEntrada
    (
        idPagoVenta INT,
        idEntrada INT,
        FechaAcceso DATE,
        Cantidad INT,
        FOREIGN KEY(idPagoVenta)
            REFERENCES PnTablas.PagoVenta(IDPagoVenta),
        FOREIGN KEY(idEntrada)
            REFERENCES PnTablas.Entrada(IDEntrada)
        PRIMARY KEY(idPagoVenta, idEntrada)
    )
END;
GO

--Tabla PagoVentaTieneHorarioActividad
IF NOT EXISTS (
    SELECT *
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'PnTablas'
      AND TABLE_NAME = 'PagoVentaTieneHorarioActividad'
)
BEGIN
    CREATE TABLE PnTablas.PagoVentaTieneHorarioActividad
    (
        Venta INT,
        Actividad INT,
        FechaActividad DATE,
        Cantidad INT,
        FOREIGN KEY(Venta)
            REFERENCES PnTablas.Venta(IDVenta),
        FOREIGN KEY(Actividad, FechaActividad)
            REFERENCES PnTablas.HorarioActividad(IDActividad, FechaActividad),
        PRIMARY KEY(Venta, Actividad, FechaActividad)
    )
END;
GO













































