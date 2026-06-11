/*
03/06/2026 - Corregido 11/06/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL


*/

create database ParquesNacionales
go

use ParquesNacionales
go


/*======================================================================*/

-- Tabla Persona
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'Persona')
begin
create table PnTablas.Persona(
    idPersona int identity(1,1) primary key,
    dni int not null,
    nombre char(20) not null,
    apellido char(20) not null,
    telefono char(11),

    constraint UQ_Persona_dni unique(dni),
    constraint CK_Persona_dni check(dni > 0),
    constraint CK_telefono check(telefono like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
)
end
go

/*======================================================================*/

-- Tabla Provincia
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'Provincia')
begin
create table PnTablas.Provincia(
    idProvincia int identity(1,1) primary key,
    nombre char(30) not null
)
end
go

/*======================================================================*/

-- Tabla TipoParque
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'TipoParque')
begin
create table PnTablas.TipoParque(
    idTipoParque int identity(1,1) primary key,
    descripcion  varchar(50) not null
)
end
go

/*======================================================================*/

-- Tabla Parque
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'Parque')
begin
create table PnTablas.Parque(
    idParque int identity(1,1) primary key,
    idTipoParque int references PnTablas.TipoParque(idTipoParque),
    idProv int references PnTablas.Provincia(idProvincia),
    nombre char(50) not null,
    superficieM2 decimal(10,2) check(superficieM2 > 0)
)
end
go

/*======================================================================*/

-- Tabla HorarioParque
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'HorarioParque')
begin
create table PnTablas.HorarioParque(
    idHorario int identity(1,1) primary key,
    idParque int references PnTablas.Parque(idParque),
    horaApertura time,
    horaCierre time,
    temporada char(10),
    dia date
)
end
go

/*======================================================================*/

-- Tabla GuardaParque
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'GuardaParque')
begin
create table PnTablas.GuardaParque(
    idPersona int,
    idParque int,
    fechaInicio date,
    estado char(10),

    constraint CK_GuardaParque_estado check(estado = 'Activo' or estado = 'Inactivo'),
    constraint PK_GuardaParque primary key(idPersona, idParque, fechaInicio),
    constraint FK_GuardaParque_Persona foreign key(idPersona) references PnTablas.Persona(idPersona),
    constraint FK_GuardaParque_Parque foreign key(idParque) references PnTablas.Parque(idParque)
)
end
go

/*======================================================================*/

-- Tabla Historial
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'Historial')
begin
create table PnTablas.Historial(
    idPersona int,
    idParque int,
    fechaInicio date,
    fechaEgreso date,
    razonEgreso varchar(200),

    constraint PK_Historial primary key(idPersona, idParque, fechaInicio),
    constraint FK_Historial_GuardaParque foreign key(idPersona, idParque, fechaInicio) 
        references PnTablas.GuardaParque(idPersona, idParque, fechaInicio)
)
end
go

/*======================================================================*/

-- Tabla Guia
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'Guia')
begin
create table PnTablas.Guia(
    idPersona int,
    titulo varchar(100),
    vencimientoHabilitacion date,
    numeroHabilitacion int,

    constraint PK_Guia primary key(idPersona),
    constraint FK_Guia_Persona foreign key(idPersona) references PnTablas.Persona(idPersona)
)
end
go

/*======================================================================*/

-- Tabla Especialidad
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'Especialidad')
begin
create table PnTablas.Especialidad(
    idEspecialidad int identity(1,1) primary key,
    descripcion varchar(100) not null
)
end
go

/*======================================================================*/

-- Tabla GuiaEspecialidad
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'GuiaEspecialidad')
begin
create table PnTablas.GuiaEspecialidad(
    idPersona int,
    idEspecialidad int,

    constraint PK_GuiaEspecialidad primary key(idPersona, idEspecialidad),
    constraint FK_GuiaEspecialidad_Guia foreign key(idPersona) references PnTablas.Guia(idPersona),
    constraint FK_GuiaEspecialidad_Especialidad foreign key(idEspecialidad) references PnTablas.Especialidad(idEspecialidad)
)
end
go

/*======================================================================*/

-- Tabla TipoActividad
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'TipoActividad')
begin
create table PnTablas.TipoActividad(
    idTipoActividad int identity(1,1) primary key,
    descripcion varchar(100)  not null,
    costo decimal(10,2) check(costo >= 0)
)
end
go

/*======================================================================*/

-- Tabla Actividad
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'Actividad')
begin
create table PnTablas.Actividad(
    idActividad int identity(1,1) primary key,
    idParque int,
    idPersona int,
    idTipoActividad int,
    nombre char(50),
    duracionMinutos int check(duracionMinutos > 0),
    cupoMax int check(cupoMax > 0),

    constraint FK_Actividad_Parque foreign key(idParque) references PnTablas.Parque(idParque),
    constraint FK_Actividad_Guia foreign key(idPersona) references PnTablas.Guia(idPersona),
    constraint FK_Actividad_TipoActividad foreign key(idTipoActividad) references PnTablas.TipoActividad(idTipoActividad)
)
end
go

/*======================================================================*/

-- Tabla HorarioActividad
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'HorarioActividad')
begin
create table PnTablas.HorarioActividad(
    fechaActividad date not null,
    idActividad int not null,
    horaInicio time,

    constraint PK_HorarioActividad primary key(fechaActividad, idActividad),
    constraint FK_HorarioActividad_Actividad foreign key(idActividad) references PnTablas.Actividad(idActividad)
)
end
go

/*======================================================================*/

-- Tabla Venta
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'Venta')
begin
create table PnTablas.Venta(
    idVenta int identity(1,1) primary key,
    idActividad int,
    idTipoActividad int,
    fechaActividad date,
    idParque int,
    fechaVenta date,
    totalVenta decimal(10,2),

    constraint FK_Venta_Actividad foreign key(idActividad) references PnTablas.Actividad(idActividad),
    constraint FK_Venta_TipoActividad foreign key(idTipoActividad) references PnTablas.TipoActividad(idTipoActividad),
    constraint FK_Venta_FechaActividad foreign key(fechaActividad) references PnTablas.HorarioActividad(fechaActividad),
    constraint FK_Venta_Parque foreign key(idParque) references PnTablas.Parque(idParque)
)
end
go

/*======================================================================*/

-- Tabla PagoVenta
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'PagoVenta')
begin
create table PnTablas.PagoVenta(
    idPagoVenta int identity(1,1) primary key,
    idVenta int,
    importe decimal(10,2),
    fechaPago date,
    descripcion varchar(200),
    metodo char(30),

    constraint FK_PagoVenta_Venta foreign key(idVenta) references PnTablas.Venta(idVenta)
)
end
go

/*======================================================================*/

-- Tabla Entrada
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'Entrada')
begin
create table PnTablas.Entrada(
    idEntrada int identity(1,1) primary key,
    idVenta int,
    precio decimal(10,2),
    descripcion varchar(200),
    cantidad int check(cantidad > 0),

    constraint FK_Entrada_Venta foreign key(idVenta) references PnTablas.Venta(idVenta)
)
end
go

/*======================================================================*/

-- Tabla Empresa
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'Empresa')
begin
create table PnTablas.Empresa(
    idEmpresa int identity(1,1) primary key,
    nombre char(50) not null,
    descripcion varchar(200)
)
end
go

/*======================================================================*/

-- Tabla Concesion
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'Concesion')
begin
create table PnTablas.Concesion(
    idConcesion int identity(1,1) primary key,
    idParque int,
    idEmpresa int,
    rubro char(30),
    fechaInicioConcesion date,
    fechaFinConcesion date,
    costoAlquiler decimal(10,2) check(costoAlquiler >= 0),

    constraint FK_Concesion_Parque  foreign key(idParque)  references PnTablas.Parque(idParque),
    constraint FK_Concesion_Empresa foreign key(idEmpresa) references PnTablas.Empresa(idEmpresa)
)
end
go

/*======================================================================*/

-- Tabla HistorialPago
if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = 'PnTablas' and TABLE_NAME = 'HistorialPago')
begin
create table PnTablas.HistorialPago(
    idPagoConcesion int identity(1,1) primary key,
    idConcesion int,
    fechaPagoConcesion date,
    importe decimal(10,2),
    estado char(10),
    
    constraint CK_estadoPago check(estado = 'Pago' or estado = 'No pago'),
    constraint FK_PagoConcesion_Concesion foreign key(idConcesion) references PnTablas.Concesion(idConcesion)
)
end
go