/*
11/06/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

Testing de los SP de ABM: Persona, GuardaParque, Historial, Guia, Especialidad, GuiaEspecialidad
*/

use ParquesNacionales
go

-- ============================================================
-- Testing Persona
-- ============================================================

--Alta
exec PnSPabm.altaPersona @dni = 12345678, @nombre = 'Juan', @apellido = 'Perez', @telefono = '01134567890';
exec PnSPabm.altaPersona @dni = 87654321, @nombre = 'Ana',  @apellido = 'Lopez', @telefono = null;
select * from PnTablas.Persona;
go

--Alta duplicado
exec PnSPabm.altaPersona @dni = 12345678, @nombre = 'Carlos', @apellido = 'Gomez';
go

--Modificacion
exec PnSPabm.modificacionPersona @idPersona = 1, @apellidoNuevo = 'Garcia';
select * from PnTablas.Persona;
go

--modificacion con dni duplicado
exec PnSPabm.modificacionPersona @idPersona = 1, @dniNuevo = 87654321;
go

--Baja OK
exec PnSPabm.bajaPersona @idPersona = 2;
select * from PnTablas.Persona;
go

--Alta de nueva persona para los tests de guardaparque (necesita un parque primero)
exec PnSPabm.altaPersona @dni = 11111111, @nombre = 'Carlos',  @apellido = 'Diaz',   @telefono = '01112345678';
exec PnSPabm.altaPersona @dni = 22222222, @nombre = 'Marta',   @apellido = 'Ruiz',   @telefono = null;
exec PnSPabm.altaPersona @dni = 33333333, @nombre = 'Roberto', @apellido = 'Santos', @telefono = null;
select * from PnTablas.Persona;
go

-- ============================================================
-- Testing GuardaParque
-- (requiere que existan Parques con idParque 1 y 2)
-- ============================================================

--Alta OK
exec PnSPabm.altaGuardaParque @idPersona = 1, @idParque = 1, @fechaInicio = '2024-01-01';
exec PnSPabm.altaGuardaParque @idPersona = 3, @idParque = 1, @fechaInicio = '2024-03-01';
select * from PnTablas.GuardaParque;
go

--alta duplicado activo en mismo parque
exec PnSPabm.altaGuardaParque @idPersona = 1, @idParque = 1;
go
--alta en parque inexistente
exec PnSPabm.altaGuardaParque @idPersona = 1, @idParque = 999;
go

--Baja ok
exec PnSPabm.bajaGuardaParque
    @idPersona = 3,
    @idParque = 1,
    @fechaInicio = '2024-03-01',
    @fechaEgreso = '2024-12-31',
    @razonEgreso = 'Fin de contrato';

select * from PnTablas.GuardaParque;
select * from PnTablas.Historial;
go

--Baja ya inactivo
exec PnSPabm.bajaGuardaParque
    @idPersona = 3,
    @idParque = 1,
    @fechaInicio = '2024-03-01',
    @fechaEgreso = '2025-01-01';
go

--Baja con fecha egreso anterior a inicio
exec PnSPabm.bajaGuardaParque
    @idPersona = 1,
    @idParque = 1,
    @fechaInicio = '2024-01-01',
    @fechaEgreso = '2023-06-01';
go

--Reasignacion ok
exec PnSPabm.reasignarGuardaParque
    @idPersona = 1,
    @idParqueActual = 1,
    @fechaInicio = '2024-01-01',
    @idParqueNuevo = 2,
    @razonEgreso = 'Reasignacion por necesidad operativa';

select * from PnTablas.GuardaParque;
select * from PnTablas.Historial;
go

--Reasignacion a parque inexistente
exec PnSPabm.reasignarGuardaParque
    @idPersona      = 1,
    @idParqueActual = 2,
    @fechaInicio    = '2024-01-01',
    @idParqueNuevo  = 999;
go

-- ============================================================
-- Testing Especialidad
-- ============================================================

--alta OK
exec PnSPabm.altaEspecialidad @descripcion = 'Flora nativa';
exec PnSPabm.altaEspecialidad @descripcion = 'Fauna autoctona';
exec PnSPabm.altaEspecialidad @descripcion = 'Senderismo';
select * from PnTablas.Especialidad;
go

--alta duplicada
exec PnSPabm.altaEspecialidad @descripcion = 'Senderismo';
go

--Modificacion OK
exec PnSPabm.modificacionEspecialidad @idEspecialidad = 3, @descripcionNueva = 'Trekking y senderismo';
select * from PnTablas.Especialidad;
go

--Baja OK (sin guias asignados)
exec PnSPabm.bajaEspecialidad @idEspecialidad = 2;
select * from PnTablas.Especialidad;
go

-- ============================================================
-- Testing Guia
-- ============================================================

--Alta OK
exec PnSPabm.altaGuia
    @idPersona = 1,
    @titulo = 'Licenciado en Ecoturismo',
    @vencimientoHabilitacion = '2027-12-31',
    @numeroHabilitacion = 10001;

exec PnSPabm.altaGuia
    @idPersona = 3,
    @titulo = null,
    @vencimientoHabilitacion = '2026-08-01',
    @numeroHabilitacion = 10002;

select * from PnTablas.Guia;
go

--Alta en persona inexistente
exec PnSPabm.altaGuia
    @idPersona = 999,
    @titulo = 'Guia',
    @vencimientoHabilitacion = '2027-01-01',
    @numeroHabilitacion = 99999;
go

--Alta con habilitacion vencida
exec PnSPabm.altaGuia
    @idPersona = 4,
    @titulo = 'Guia',
    @vencimientoHabilitacion = '2020-01-01',
    @numeroHabilitacion = 10003;
go

--Alta duplicado
exec PnSPabm.altaGuia
    @idPersona = 1,
    @titulo = 'Otro titulo',
    @vencimientoHabilitacion = '2028-01-01',
    @numeroHabilitacion = 10004;
go

--Modificacion OK, renovar habilitacion
exec PnSPabm.modificacionGuia
    @idPersona = 3,
    @vencimientoHabilitacionNuevo = '2028-06-30';
select * from PnTablas.Guia;
go

-- ============================================================
-- Testing GuiaEspecialidad
-- ============================================================

--Alta OK
exec PnSPabm.altaGuiaEspecialidad @idPersona = 1, @idEspecialidad = 1;
exec PnSPabm.altaGuiaEspecialidad @idPersona = 1, @idEspecialidad = 3;
exec PnSPabm.altaGuiaEspecialidad @idPersona = 3, @idEspecialidad = 1;
select * from PnTablas.GuiaEspecialidad;
go

--Alta duplicada
exec PnSPabm.altaGuiaEspecialidad @idPersona = 1, @idEspecialidad = 1;
go

--Baja OK
exec PnSPabm.bajaGuiaEspecialidad @idPersona = 1, @idEspecialidad = 3;
select * from PnTablas.GuiaEspecialidad;
go

--Baja especialidad con guias asignados
exec PnSPabm.bajaEspecialidad @idEspecialidad = 1;
go

--Baja guia con especialidades (verifica que bajaGuia las elimina en cascada)
exec PnSPabm.bajaGuia @idPersona = 3;
select * from PnTablas.Guia;
select * from PnTablas.GuiaEspecialidad;
go