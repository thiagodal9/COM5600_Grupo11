/*
08/07/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

Testing de los SPs de ABM asociados a las tablas Persona, Guardaparque,
Guia y Especialidad.

Este script no depende de Dataset_testing.sql para Persona (esa tabla no
tiene seed data propia todavia), asi que carga sus propios registros base
antes de empezar a testear alta/baja/modificacion.
*/

SET NOCOUNT ON;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--'
END;
GO

-------------------------------------------------------------------------------------
---- Carga inicial de Personas (no hay seed en Dataset_testing.sql para esta tabla)

EXECUTE PnSPabm.altaPersona @dni = 30111222, @nombre = 'Juan',   @apellido = 'Perez',  @telefono = '11-4000-0001', @rol = 'Guardaparque';
EXECUTE PnSPabm.altaPersona @dni = 30222333, @nombre = 'Maria',  @apellido = 'Gomez',  @telefono = '11-4000-0002', @rol = 'Guia';
EXECUTE PnSPabm.altaPersona @dni = 30333444, @nombre = 'Carlos', @apellido = 'Diaz',   @telefono = '11-4000-0003', @rol = 'Guardaparque';
EXECUTE PnSPabm.altaPersona @dni = 30444555, @nombre = 'Ana',    @apellido = 'Lopez',  @telefono = '11-4000-0004', @rol = 'Guia';
EXECUTE PnSPabm.altaPersona @dni = 30555666, @nombre = 'Pedro',  @apellido = 'Ruiz',   @telefono = '11-4000-0005', @rol = 'Guardaparque';
GO

-- Verificacion de carga inicial (via consultarPersona, que descifra DNI/Telefono)
EXECUTE PnSPabm.consultarPersona;
GO

-------------------------------------------------------------------------------------
---- TESTING Persona

--RESULTADOS ESPERADOS: Insercion Fallida

-- Falla por todos los parametros nulos
EXECUTE PnSPabm.altaPersona @dni = NULL, @nombre = NULL, @apellido = NULL, @telefono = NULL, @rol = NULL;
-- Falla por DNI fuera de rango (negativo)
EXECUTE PnSPabm.altaPersona @dni = -5, @nombre = 'Test', @apellido = 'Test', @telefono = '11-0000-0000', @rol = 'Guia';
-- Falla por DNI fuera de rango (mayor a 99999999)
EXECUTE PnSPabm.altaPersona @dni = 999999999, @nombre = 'Test', @apellido = 'Test', @telefono = '11-0000-0000', @rol = 'Guia';
-- Falla por rol invalido
EXECUTE PnSPabm.altaPersona @dni = 30777888, @nombre = 'Lucia', @apellido = 'Fernandez', @telefono = '11-4000-0006', @rol = 'Administrador';
-- Falla por DNI duplicado (30111222 ya pertenece a Juan Perez)
EXECUTE PnSPabm.altaPersona @dni = 30111222, @nombre = 'Otro', @apellido = 'Duplicado', @telefono = '11-9999-9999', @rol = 'Guia';
GO

EXECUTE PnSPabm.consultarPersona;
GO

-------------------------------------------------------------------------------------
--RESULTADOS ESPERADOS: Modificacion Fallida

-- Falla por ID nulo/invalido
EXECUTE PnSPabm.modificacionPersona @IDPersona = NULL, @nombreNuevo = 'X';
EXECUTE PnSPabm.modificacionPersona @IDPersona = -1, @nombreNuevo = 'X';
-- Falla por ID inexistente
EXECUTE PnSPabm.modificacionPersona @IDPersona = 999, @nombreNuevo = 'X';
-- Falla por rol invalido
EXECUTE PnSPabm.modificacionPersona @IDPersona = 1, @rolNuevo = 'Jefe';
-- Falla por DNI nuevo en uso por otra persona (30222333 es de Maria Gomez)
EXECUTE PnSPabm.modificacionPersona @IDPersona = 1, @dniNuevo = 30222333;
-- Falla por DNI nuevo fuera de rango
EXECUTE PnSPabm.modificacionPersona @IDPersona = 1, @dniNuevo = 999999999;
GO

EXECUTE PnSPabm.consultarPersona;
GO

--RESULTADO ESPERADO: Modificacion Exitosa

-- Actualiza nombre, telefono y DNI de la Persona 1 (Juan Perez)
EXECUTE PnSPabm.modificacionPersona @IDPersona = 1, @nombreNuevo = 'Juan Ignacio', @telefonoNuevo = '11-4000-9999', @dniNuevo = 30111223;
GO

EXECUTE PnSPabm.consultarPersona @IDPersona = 1;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING Guardaparque (alta)
---- La asignacion a un parque y las bajas/reasignaciones se prueban en
---- TestingSPtransPersona.sql, ya que dependen de SPs transaccionales.

--RESULTADOS ESPERADOS: Insercion Fallida

-- Falla por ID nulo
EXECUTE PnSPabm.altaGuardaParque @IDPersona = NULL;
-- Falla por ID inexistente
EXECUTE PnSPabm.altaGuardaParque @IDPersona = 999;
-- Falla porque la Persona 2 (Maria Gomez) tiene Rol = 'Guia', no 'Guardaparque'
EXECUTE PnSPabm.altaGuardaParque @IDPersona = 2;
GO

SELECT * FROM PnTablas.GuardaParque;
GO

--RESULTADO ESPERADO: Insercion Exitosa

-- Personas 1, 3 y 5 tienen Rol = 'Guardaparque'
EXECUTE PnSPabm.altaGuardaParque @IDPersona = 1;
EXECUTE PnSPabm.altaGuardaParque @IDPersona = 3;
EXECUTE PnSPabm.altaGuardaParque @IDPersona = 5;
GO

SELECT * FROM PnTablas.GuardaParque;
GO

--RESULTADOS ESPERADOS: Insercion Fallida (duplicidad)

-- Falla porque la Persona 1 ya es Guardaparque
EXECUTE PnSPabm.altaGuardaParque @IDPersona = 1;
GO

SELECT * FROM PnTablas.GuardaParque;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING Guia

--RESULTADOS ESPERADOS: Insercion Fallida

-- Falla por parametros nulos / numero de habilitacion invalido
EXECUTE PnSPabm.altaGuia @idPersona = NULL, @titulo = NULL, @vencimientoHabilitacion = NULL, @numeroHabilitacion = NULL;
EXECUTE PnSPabm.altaGuia @idPersona = 2, @titulo = 'Guia de Montania', @vencimientoHabilitacion = '2030-01-01', @numeroHabilitacion = -5;
-- Falla por habilitacion ya vencida
EXECUTE PnSPabm.altaGuia @idPersona = 2, @titulo = 'Guia de Montania', @vencimientoHabilitacion = '2020-01-01', @numeroHabilitacion = 1001;
-- Falla por persona inexistente
EXECUTE PnSPabm.altaGuia @idPersona = 999, @titulo = 'Guia de Montania', @vencimientoHabilitacion = '2030-01-01', @numeroHabilitacion = 1001;
-- Falla porque la Persona 1 (Juan Perez) tiene Rol = 'Guardaparque', no 'Guia'
EXECUTE PnSPabm.altaGuia @idPersona = 1, @titulo = 'Guia de Montania', @vencimientoHabilitacion = '2030-01-01', @numeroHabilitacion = 1001;
GO

SELECT * FROM PnTablas.Guia;
GO

--RESULTADO ESPERADO: Insercion Exitosa

-- Personas 2 y 4 tienen Rol = 'Guia'
EXECUTE PnSPabm.altaGuia @idPersona = 2, @titulo = 'Guia de Montania', @vencimientoHabilitacion = '2030-06-30', @numeroHabilitacion = 1001;
EXECUTE PnSPabm.altaGuia @idPersona = 4, @titulo = 'Guia de Aventura', @vencimientoHabilitacion = '2030-12-31', @numeroHabilitacion = 1002;
GO

SELECT * FROM PnTablas.Guia;
GO

--RESULTADOS ESPERADOS: Insercion Fallida (duplicidad)

-- Falla porque la Persona 2 ya es Guia
EXECUTE PnSPabm.altaGuia @idPersona = 2, @titulo = 'Otro Titulo', @vencimientoHabilitacion = '2030-01-01', @numeroHabilitacion = 1003;
GO

SELECT * FROM PnTablas.Guia;
GO

-------------------------------------------------------------------------------------
--RESULTADOS ESPERADOS: Modificacion (Guia) Fallida

-- Falla por numero de habilitacion invalido
EXECUTE PnSPabm.modificacionGuia @idPersona = 2, @numeroHabilitacionNuevo = -1;
-- Falla por nueva fecha de vencimiento ya vencida
EXECUTE PnSPabm.modificacionGuia @idPersona = 2, @vencimientoHabilitacionNuevo = '2020-01-01';
-- Falla por guia inexistente
EXECUTE PnSPabm.modificacionGuia @idPersona = 999, @tituloNuevo = 'X';
GO

SELECT * FROM PnTablas.Guia;
GO

--RESULTADO ESPERADO: Modificacion (Guia) Exitosa

EXECUTE PnSPabm.modificacionGuia @idPersona = 2, @tituloNuevo = 'Guia de Alta Montania', @vencimientoHabilitacionNuevo = '2031-01-01';
GO

SELECT * FROM PnTablas.Guia;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING Especialidad

--RESULTADOS ESPERADOS: Insercion Fallida

-- Falla por descripcion nula
EXECUTE PnSPabm.altaEspecialidad @descripcion = NULL;
GO

-- Carga base para poder testear duplicidad, asignacion y baja
EXECUTE PnSPabm.altaEspecialidad @descripcion = 'Fauna Autoctona';
EXECUTE PnSPabm.altaEspecialidad @descripcion = 'Flora Nativa';
GO

SELECT * FROM PnTablas.Especialidad;
GO

--RESULTADOS ESPERADOS: Insercion Fallida (duplicidad)

EXECUTE PnSPabm.altaEspecialidad @descripcion = 'Fauna Autoctona';
GO

SELECT * FROM PnTablas.Especialidad;
GO

--RESULTADOS ESPERADOS: Modificacion Fallida

EXECUTE PnSPabm.modificacionEspecialidad @idEspecialidad = NULL, @descripcionNueva = 'X';
EXECUTE PnSPabm.modificacionEspecialidad @idEspecialidad = 999, @descripcionNueva = 'X';
-- Falla por nombre ya usado por otra especialidad
EXECUTE PnSPabm.modificacionEspecialidad @idEspecialidad = 1, @descripcionNueva = 'Flora Nativa';
GO

SELECT * FROM PnTablas.Especialidad;
GO

--RESULTADO ESPERADO: Modificacion Exitosa

EXECUTE PnSPabm.modificacionEspecialidad @idEspecialidad = 1, @descripcionNueva = 'Fauna y Ecosistemas';
GO

SELECT * FROM PnTablas.Especialidad;
GO

-------------------------------------------------------------------------------------
---- TESTING asignarEspecialidad / desasignarEspecialidad / reasignarEspecialidad

--RESULTADOS ESPERADOS: Asignacion Fallida

EXECUTE PnSPabm.asignarEspecialidad @guia = NULL, @especialidad = NULL;
-- Falla por guia inexistente
EXECUTE PnSPabm.asignarEspecialidad @guia = 999, @especialidad = 1;
-- Falla por especialidad inexistente
EXECUTE PnSPabm.asignarEspecialidad @guia = 2, @especialidad = 999;
GO

SELECT * FROM PnTablas.TieneEspecialidad;
GO

--RESULTADO ESPERADO: Asignacion Exitosa

EXECUTE PnSPabm.asignarEspecialidad @guia = 2, @especialidad = 1;
EXECUTE PnSPabm.asignarEspecialidad @guia = 4, @especialidad = 2;
GO

SELECT * FROM PnTablas.TieneEspecialidad;
GO

--RESULTADOS ESPERADOS: Asignacion Fallida (duplicidad)

EXECUTE PnSPabm.asignarEspecialidad @guia = 2, @especialidad = 1;
GO

SELECT * FROM PnTablas.TieneEspecialidad;
GO

--RESULTADOS ESPERADOS: Baja Especialidad Fallida (referencia activa)

-- Falla porque hay guias con esa especialidad asignada
EXECUTE PnSPabm.bajaEspecialidad @idEspecialidad = 1;
GO

SELECT * FROM PnTablas.Especialidad;
GO

--RESULTADO ESPERADO: Reasignacion Exitosa

-- Cambia al guia 4 de la especialidad 2 a la especialidad 1
EXECUTE PnSPabm.reasignarEspecialidad @guia = 4, @especialidadOLD = 2, @especialidadNEW = 1;
GO

SELECT * FROM PnTablas.TieneEspecialidad;
GO

--RESULTADOS ESPERADOS: Reasignacion Fallida

-- Falla porque ya no existe la asociacion guia=4/especialidad=2 (se acaba de mover)
EXECUTE PnSPabm.reasignarEspecialidad @guia = 4, @especialidadOLD = 2, @especialidadNEW = 1;
GO

--RESULTADO ESPERADO: Desasignacion Exitosa (especialidad puntual)

EXECUTE PnSPabm.desasignarEspecialidad @guia = 4, @especialidad = 1;
GO

SELECT * FROM PnTablas.TieneEspecialidad;
GO

--RESULTADO ESPERADO: Baja Especialidad Exitosa
--(ahora la especialidad 2 quedo sin guias asociados)

EXECUTE PnSPabm.bajaEspecialidad @idEspecialidad = 2;
GO

SELECT * FROM PnTablas.Especialidad;
GO

--RESULTADO ESPERADO: Desasignacion (todas) Exitosa

EXECUTE PnSPabm.desasignarEspecialidades @guia = 2;
GO

SELECT * FROM PnTablas.TieneEspecialidad;
GO

--RESULTADOS ESPERADOS: Desasignacion (todas) Fallida
--(el guia 2 ya no tiene especialidades asignadas)

EXECUTE PnSPabm.desasignarEspecialidades @guia = 2;
GO
