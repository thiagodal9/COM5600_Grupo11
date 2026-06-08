/*
03/06/2026
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

--Creo el esquema donde voy a guardar los parques
--create schema Parques
--go

--Creación de tablas

--Tabla Persona
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'Persona')
begin
create table Parques.Persona(
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
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'Provincia')
begin
create table Parques.Provincia(
idProvincia int identity(1,1) primary key,
nombre char(30)
)
end
go

--Tabla TipoParque
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'TipoParque')
begin
create table Parques.TipoParque(
idTipoParque int identity(1,1) primary key,
descripcion varchar
)
end
go


--Tabla Parque
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'Parque')
begin
create table Parques.Parque(
idParque int identity(1,1) primary key,
idTipoParque int,
idProv int,
nombre char (50),
superficieM2 decimal(10,2),
constraint FK_Parque_TipoParque(idTipoParque) references Parques.TipoParque(idTipoParque),
constraint FK_Parque_Provincia(idProvincia) references Parques.Provincia(idProvincia)
)
end
go


--Tabla HorarioParque
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'HorarioParque')
begin
create table Parques.HorarioParque(
idHorario int identity(1,1) primary key,
idParque int,
horaApertura time,
horaCierre time,
temporada char(10),
ubicacion char(30),
dia date,
constraint FK_HorarioParque_Parque(idParque) references Parques.Parque(idParque),
)
end
go

--Tabla GuardaParque
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'GuardaParque')
begin
create table Parques.GuardaParque(
idGuardaParque int identity(1,1)
idPersona int,
idParque int,
estado bool,
fechaInicio date,
constraint PK_GuardaParque(idGuardaParque, idPersona, idParque),
constraint FK_GuardaParque_Persona (idPersona) references Parques.Persona(idPersona),
constraint FK_GuardaParque_Parque (idParque) references Parques.Parque(idParque),
)
end
go

--Tabla Historial
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'Historial')
begin
create table Parques.Historial(
fechaIngreso date,
idGuardaParque int,
razonEgreso varchar,
fechaEgreso date,
constraint PK_Historial(fechaIngreso, idGuardaParque),
constraint FK_Historial_GuardaParque (idGuardaParque) references Parques.GuardaParque(idGuardaParque)
)
end
go

--Tabla Guia
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'Guia')
begin
create table Parques.Guia(
idGuia int identity(1,1),
idPersona int,
titulo varchar,
vencimiento Habilitacion date,
numeroHabilitacion int,
constraint PK_Guia(idGuia, idPersona),
constraint FK_Guia_Persona (idPersona) references Parques.Persona(idPersona)
)
end
go

--Tabla Especialidad
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'Especialidad')
begin
create table Parques.Especialidad(
idEspecialidad int identity(1,1) primary key,
descripcion varchar,
)
end
go

--Tabla GuiaEspecialidad
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'GuiaEspecialidad')
begin
create table Parques.GuiaEspecialidad(
idGuia int,
idPersona int,
idEspecialidad int,
constraint PK_GuiaEspecialidad(idGuia, idPersona, idEspecialidad),
constraint FK_GuiaEspecialidad_Guia (idGuia) references Parques.Guia(idGuia),
constraint FK_GuiaEspecialidad_Persona (idPersona) references Parques.Persona(idPersona),
constraint FK_GuiaEspecialidad_Especialidad(idEspecialidad) references Parques.Especialidad(idEspecialidad)
)
end
go


--Tabla TipoActividad
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'TipoActividad')
begin
create table Parques.TipoActividad(
idTipoActividad int identity(1,1) primary key,
descripcion varchar,
costo decimal(10,2)
)
end
go

--Tabla Actividad
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'Actividad')
begin
create table Parques.Actividad(
idActividad int identity(1,1) primary key,
idParque int,
idGuia int,
idTipoActividad int,
nombre char(50),
duracionMinutos int,
cupoMax int,
constraint FK_Actividad_Parque (idParque) references Parques.Parque(idParque),
constraint FK_Actividad_Guia (idGuia) references Parques.Guia(idGuia),
constraint FK_Actividad_TipoActividad (idTipoActividad) references Parques.TipoActividad(idTipoActividad)
)
end
go


--Tabla HorarioActividad
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'HorarioActividad')
begin
create table Parques.HorarioActividad(
fechaActividad date primary key,
idActividad int,
horaInicion time,
constraint FK_HorarioActividad_Actividad (idActividad) references Parques.Actividad(idActividad),
)
end
go

--Tabla Venta
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'Venta')
begin
create table Parques.Venta(
idVenta int identity(1,1) primary key,
idActividad int,
idTipoActividad int,
fechaActividad date,
idParque int,
fechaVenta date,
totalVenta decimal(10,2),
constraint FK_Venta_Actividad (idActividad) references Parques.Actividad(idActividad),
constraint FK_Venta_TipoActividad (idTipoActividad) references Parques.TipoActividad(idTipoActividad),
constraint FK_Venta_FechaActividad (fechaActividad) references Parques.HorarioActividad(fechaActividad),
constraint FK_Venta_Parque (idParque) references Parques.Parque(idParque)
)
end
go

--Tabla PagoVenta
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'PagoVenta')
begin
create table Parques.PagoVenta(
idPagoVenta int identity(1,1) primary key,
idVenta int,
importe decimal(10,2),
fechaPago date,
descripcion varchar,
metodo char(30),
constraint FK_PagoVenta_Venta (idVenta) references Parques.Venta(idVenta)
)
end
go


--Tabla Entrada
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'Entrada')
begin
create table Parques.Entrada(
idEntrada int identity(1,1) primary key,
idVenta int,
precio decimal(10,2),
descripcion varchar,
cantidad int,
constraint FK_Entrada_Venta (idVenta) references Parques.Venta(idVenta)
)
end


--Tabla Empresa
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'Empresa')
begin
create table Parques.Empresa(
idEmpresa int identity(1,1) primary key,
nombre char(50),
descripcion varchar,
)
end


--Tabla Concesion
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'Concesion')
begin
create table Parques.Concesion(
idConcesion int identity(1,1) primary key,
idParque int,
idEmpresa int,
rubro char(30),
fechaInicioConcesion date,
fechaFinConcesion date,
costoAlquiler decimal(10,2),
constraint FK_Concesion_Parque (idParque) references Parques.Parque(idParque),
constraint FK_Concesion_Empresa (idEmpresa) references Parques.Empresa(idEmpresa)
)
end

--Tabla HistorialPago
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'Parques' AND TABLE_NAME = 'HistorialPago')
begin
create table Parques.HistorialPago(
idPagoConcesion int identity(1,1) primary key,
idConcesion int,
fechaPagoConcesion date,
importe decimal(10,2),
estado bool,
constraint FK_PagoConcesion_Concesion (idConsecion) references Parques.Consecion(idConsecion)
)
end



























