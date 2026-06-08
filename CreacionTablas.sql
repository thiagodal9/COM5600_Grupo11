/*
03/06/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

En este script se realiza la creacion de la base de datos, del SCHEMA que contendra las tablas y de las tablas de acuerdo al DER entregado
*/


--Creación de la base de datos
create database ParquesNacionales
go

use ParquesNacionales
go

--Creo el esquema donde voy a crear las tablas
--create schema PnTablas
--go

--Creación de tablas

--Tabla Persona
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Persona')
begin
create table PnTablas.Persona(
idPersona int identity(1,1) primary key,
dni int check(dni > 0),
nombre char(20),
apellido char(20),
telefono char(11),
constraint CK_telefono check(
	telefono like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
	)
)
end
go

--Tabla Provincia
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Provincia')
begin
create table PnTablas.Provincia(
idProvincia int identity(1,1) primary key,
nombre char(30)
)
end
go

--Tabla TipoParque
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TipoParque')
begin
create table PnTablas.TipoParque(
idTipoParque int identity(1,1) primary key,
descripcion varchar
)
end
go


--Tabla Parque
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Parque')
begin
create table PnTablas.Parque(
idParque int identity(1,1) primary key,
idTipoParque int references PnTablas.TipoParque (idTipoParque),
idProv int references PnTablas.Provincia (idProvincia),
nombre char (50),
superficieM2 decimal(10,2),
)
end
go


--Tabla HorarioParque
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'HorarioParque')
begin
create table PnTablas.HorarioParque(
idHorario int identity(1,1) primary key,
idParque int references PnTablas.Parque(idParque),
horaApertura time,
horaCierre time,
temporada char(10),
ubicacion char(30),
dia date,
)
end
go

--Tabla GuardaParque
/*
Se eliminó el campo idGuardaParque, la primary key pasa a ser directamente (idPersona, idParque, fechaInicio)
Se añadió a la primary key fechaInicio, para que una persona pueda ser guardaParque en un mismo parque en diferentes momentos
Fecha del cambio 07/06/2026
*/
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'GuardaParque')
begin
create table PnTablas.GuardaParque(
idPersona int,
idParque int,
estado char(8),
fechaInicio date,
constraint CK_estado check(
	estado like 'Activo' or
	estado like 'Inactvo'
),
constraint PK_GuardaParque primary key(idPersona, idParque, fechaInicio),
constraint FK_GuardaParque_Persona foreign key(idPersona) references PnTablas.Persona(idPersona),
constraint FK_GuardaParque_Parque foreign key(idParque) references PnTablas.Parque(idParque),
)
end
go

--Tabla Historial
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Historial')
begin
create table PnTablas.Historial(
idPersona int,
idParque int,
fechaInicio date,
razonEgreso varchar,
fechaEgreso date,
constraint PK_Historial primary key(fechaInicio, idPersona),
constraint FK_Historial_GuardaParque foreign key(idPersona, idParque, fechaInicio) references PnTablas.GuardaParque(idPersona, idParque, fechaInicio)
)
end
go

--Tabla Guia
/*
Se eliminó el campo idGuia, la primary key paso a ser directamente (idPersona)
Fecha del cambio 07/06/2026
*/
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Guia')
begin
create table PnTablas.Guia(
idPersona int,
titulo varchar,
vencimientoHabilitacion date,
numeroHabilitacion int,
constraint PK_Guia primary key(idPersona),
constraint FK_Guia_Persona foreign key(idPersona) references PnTablas.Persona(idPersona)
)
end
go

--Tabla Especialidad
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Especialidad')
begin
create table PnTablas.Especialidad(
idEspecialidad int identity(1,1) primary key,
descripcion varchar,
)
end
go

--Tabla GuiaEspecialidad
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'GuiaEspecialidad')
begin
create table PnTablas.GuiaEspecialidad(
idPersona int,
idEspecialidad int,
constraint PK_GuiaEspecialidad primary key(idPersona, idEspecialidad),
constraint FK_GuiaEspecialidad_Persona foreign key(idPersona) references PnTablas.Persona(idPersona),
constraint FK_GuiaEspecialidad_Especialidad foreign key(idEspecialidad) references PnTablas.Especialidad(idEspecialidad)
)
end
go


--Tabla TipoActividad
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'TipoActividad')
begin
create table PnTablas.TipoActividad(
idTipoActividad int identity(1,1) primary key,
descripcion varchar,
costo decimal(10,2)
)
end
go

--Tabla Actividad
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Actividad')
begin
create table PnTablas.Actividad(
idActividad int identity(1,1) primary key,
idParque int,
idPersona int,
idTipoActividad int,
nombre char(50),
duracionMinutos int,
cupoMax int,
constraint FK_Actividad_Parque foreign key(idParque) references PnTablas.Parque(idParque),
constraint FK_Actividad_Guia foreign key (idPersona) references PnTablas.Guia(idPersona),
constraint FK_Actividad_TipoActividad foreign key(idTipoActividad) references PnTablas.TipoActividad(idTipoActividad)
)
end
go


--Tabla HorarioActividad
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'HorarioActividad')
begin
create table PnTablas.HorarioActividad(
fechaActividad date primary key,
idActividad int,
horaInicion time,
constraint FK_HorarioActividad_Actividad foreign key(idActividad) references PnTablas.Actividad(idActividad),
)
end
go

--Tabla Venta
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Venta')
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

--Tabla PagoVenta
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'PagoVenta')
begin
create table PnTablas.PagoVenta(
idPagoVenta int identity(1,1) primary key,
idVenta int,
importe decimal(10,2),
fechaPago date,
descripcion varchar,
metodo char(30),
constraint FK_PagoVenta_Venta foreign key(idVenta) references PnTablas.Venta(idVenta)
)
end
go


--Tabla Entrada
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Entrada')
begin
create table PnTablas.Entrada(
idEntrada int identity(1,1) primary key,
idVenta int,
precio decimal(10,2),
descripcion varchar,
cantidad int,
constraint FK_Entrada_Venta foreign key(idVenta) references PnTablas.Venta(idVenta)
)
end


--Tabla Empresa
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Empresa')
begin
create table PnTablas.Empresa(
idEmpresa int identity(1,1) primary key,
nombre char(50),
descripcion varchar,
)
end


--Tabla Concesion
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Concesion')
begin
create table PnTablas.Concesion(
idConcesion int identity(1,1) primary key,
idParque int,
idEmpresa int,
rubro char(30),
fechaInicioConcesion date,
fechaFinConcesion date,
costoAlquiler decimal(10,2),
constraint FK_Concesion_Parque foreign key(idParque) references PnTablas.Parque(idParque),
constraint FK_Concesion_Empresa foreign key(idEmpresa) references PnTablas.Empresa(idEmpresa)
)
end

--Tabla HistorialPago
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'HistorialPago')
begin
create table PnTablas.HistorialPago(
idPagoConcesion int identity(1,1) primary key,
idConcesion int,
fechaPagoConcesion date,
importe decimal(10,2),
estado char(7),
constraint CK_estadoPago check(
	estado like 'Pago' or
	estado like 'No pago'
),
constraint FK_PagoConcesion_Concesion foreign key(idConcesion) references PnTablas.Concesion(idConcesion)
)
end



























