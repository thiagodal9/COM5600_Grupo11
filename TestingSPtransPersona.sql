/*
-/-/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

Testing de los SPs transaccionales asociados a Persona: asignacion,
reasignacion y desasignacion de Guardaparques, asignacion/desasignacion
de Guias a turnos de actividad, historial y baja total de una Persona.

antes de correr este script:
  1) Dataset_testing.sql (provee los Parques 1-10 y la Actividad 1 con sus
  turnos en PnTablas.HorarioActividad).
  2) TestingSPabmPersona.sql (provee las Personas 1-5, donde 1/3/5 son
  Guardaparque y 2/4 son Guia).
*/

SET NOCOUNT ON;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--'
END;
GO

-------------------------------------------------------------------------------------
---- Chequeo de datos cargados previamente (TestingSPabmPersona.sql + Dataset_testing.sql)

SELECT * FROM PnTablas.GuardaParque;
GO
SELECT * FROM PnTablas.Guia;
GO
SELECT IDActividad, NombreActividad FROM PnTablas.Actividad WHERE IDActividad = 1;
GO
SELECT * FROM PnTablas.HorarioActividad WHERE Actividad = 1;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING asignarGuardaparque

--RESULTADOS ESPERADOS: Asignacion Fallida

-- Falla por parque inexistente
EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 1, @Parque = 999;
-- Falla por guardaparque inexistente (Persona 2 es Guia, no esta en GuardaParque)
EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 2, @Parque = 1;
GO

SELECT * FROM PnTablas.GuardaParque;
GO

--RESULTADO ESPERADO: Asignacion Exitosa

-- Asigna al Guardaparque 1 (Juan Perez) al Parque 1
EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 1, @Parque = 1;
-- Asigna al Guardaparque 3 (Carlos Diaz) al Parque 2
EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 3, @Parque = 2;
GO

SELECT * FROM PnTablas.GuardaParque;
GO

--RESULTADOS ESPERADOS: Asignacion Fallida (ya activo)

-- Falla porque el Guardaparque 1 ya esta activo en un parque
EXECUTE PnSPtrans.asignarGuardaparque @IDPersona = 1, @Parque = 3;
GO

SELECT * FROM PnTablas.GuardaParque;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING reasignarGuardaparque

--RESULTADOS ESPERADOS: Reasignacion Fallida

-- Falla por parque inexistente
EXECUTE PnSPtrans.reasignarGuardaparque @IDPersona = 1, @Parque = 999, @razon = 'Reasignacion de prueba';
-- Falla por guardaparque inexistente
EXECUTE PnSPtrans.reasignarGuardaparque @IDPersona = 999, @Parque = 2, @razon = 'Reasignacion de prueba';
-- Falla porque el Guardaparque 1 ya esta en el Parque 1 (mismo parque)
EXECUTE PnSPtrans.reasignarGuardaparque @IDPersona = 1, @Parque = 1, @razon = 'Reasignacion de prueba';
GO

SELECT * FROM PnTablas.GuardaParque;
GO

--RESULTADO ESPERADO: Reasignacion Exitosa
--Se espera que quede un registro de historial (Guardaparque 1, Parque 1)

EXECUTE PnSPtrans.reasignarGuardaparque @IDPersona = 1, @Parque = 4, @razon = 'Rotacion de personal';
GO

SELECT * FROM PnTablas.GuardaParque;
GO

-- Verificacion del historial generado (via consultarHistorial, que descifra RazonEgreso)
EXECUTE PnSPtrans.consultarHistorial @Guardaparque = 1;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING desasignarGuardaparque

--RESULTADOS ESPERADOS: Desasignacion Fallida

-- Falla por parque inexistente
EXECUTE PnSPtrans.desasignarGuardaparque @IDPersona = 1, @Parque = 999, @razon = 'Fin de asignacion';
-- Falla porque el Guardaparque 1 no esta asignado al Parque 1 (ahora esta en el 4)
EXECUTE PnSPtrans.desasignarGuardaparque @IDPersona = 1, @Parque = 1, @razon = 'Fin de asignacion';
GO

SELECT * FROM PnTablas.GuardaParque;
GO

--RESULTADO ESPERADO: Desasignacion Exitosa
--Se espera un segundo registro de historial (Guardaparque 1, Parque 4)

EXECUTE PnSPtrans.desasignarGuardaparque @IDPersona = 1, @Parque = 4, @razon = 'Fin de temporada';
GO

SELECT * FROM PnTablas.GuardaParque;
GO

EXECUTE PnSPtrans.consultarHistorial @Guardaparque = 1;
GO

--RESULTADOS ESPERADOS: Desasignacion Fallida (ya inactivo)

EXECUTE PnSPtrans.desasignarGuardaparque @IDPersona = 1, @Parque = 4, @razon = 'Fin de temporada';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING asignarGuia / desasignarGuia

--RESULTADOS ESPERADOS: Asignacion Fallida

-- Falla por parametros nulos
EXECUTE PnSPtrans.asignarGuia @guia = NULL, @actividad = NULL, @fecha = NULL, @hora = NULL;
-- Falla por actividad inexistente
EXECUTE PnSPtrans.asignarGuia @guia = 2, @actividad = 999, @fecha = '2026-12-07', @hora = '10:00';
-- Falla por guia inexistente (Persona 1 es Guardaparque, no esta en Guia)
EXECUTE PnSPtrans.asignarGuia @guia = 1, @actividad = 1, @fecha = '2026-12-07', @hora = '10:00';
-- Falla porque no existe ese turno para la actividad
EXECUTE PnSPtrans.asignarGuia @guia = 2, @actividad = 1, @fecha = '2026-01-01', @hora = '08:00';
GO

SELECT * FROM PnTablas.HorarioActividad WHERE Actividad = 1;
GO

--RESULTADO ESPERADO: Asignacion Exitosa

EXECUTE PnSPtrans.asignarGuia @guia = 2, @actividad = 1, @fecha = '2026-12-07', @hora = '10:00';
GO

SELECT * FROM PnTablas.HorarioActividad WHERE Actividad = 1;
GO

--RESULTADOS ESPERADOS: Asignacion Fallida (ya asignado)

-- Falla porque ese turno ya tiene guia asignado
EXECUTE PnSPtrans.asignarGuia @guia = 4, @actividad = 1, @fecha = '2026-12-07', @hora = '10:00';
-- Falla porque el mismo guia ya esta asignado a ese turno
EXECUTE PnSPtrans.asignarGuia @guia = 2, @actividad = 1, @fecha = '2026-12-07', @hora = '10:00';
GO

SELECT * FROM PnTablas.HorarioActividad WHERE Actividad = 1;
GO

--RESULTADOS ESPERADOS: Desasignacion Fallida

-- Falla porque ese turno especifico no tiene guia asignado
EXECUTE PnSPtrans.desasignarGuia @guia = 2, @actividad = 1, @fecha = '2026-12-07', @hora = '12:00';
GO

--RESULTADO ESPERADO: Desasignacion Exitosa

EXECUTE PnSPtrans.desasignarGuia @guia = 2, @actividad = 1, @fecha = '2026-12-07', @hora = '10:00';
GO

SELECT * FROM PnTablas.HorarioActividad WHERE Actividad = 1;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
---- TESTING bajaPersona (baja integral: Persona + rol Guardaparque/Guia + historial)

--RESULTADOS ESPERADOS: Baja Fallida (guardaparque activo)

-- Falla porque el Guardaparque 3 (Carlos Diaz) sigue activo en el Parque 2
EXECUTE PnSPtrans.bajaPersona @IDPersona = 3, @razon = 'Renuncia';
GO

SELECT * FROM PnTablas.Persona WHERE IDPersona = 3;
GO

--RESULTADO ESPERADO: Baja Exitosa (tras desasignar primero)

EXECUTE PnSPtrans.desasignarGuardaparque @IDPersona = 3, @Parque = 2, @razon = 'Renuncia';
GO
EXECUTE PnSPtrans.bajaPersona @IDPersona = 3, @razon = 'Renuncia';
GO

-- Se espera que la Persona 3 y su fila en Guardaparque ya no existan,
-- pero que el historial de sus asignaciones se conserve.
SELECT * FROM PnTablas.Persona WHERE IDPersona = 3;
SELECT * FROM PnTablas.GuardaParque WHERE IDGuardaParque = 3;
GO
EXECUTE PnSPtrans.consultarHistorial @Guardaparque = 3;
GO

-------------------------------------------------------------------------------------
--RESULTADOS ESPERADOS: Baja Fallida (guia con turno asignado)

-- Asigna primero al Guia 4 a un turno para poder probar el bloqueo
EXECUTE PnSPtrans.asignarGuia @guia = 4, @actividad = 1, @fecha = '2026-12-07', @hora = '12:00';
GO

-- Falla porque el Guia 4 (Ana Lopez) tiene un turno de actividad asignado
EXECUTE PnSPtrans.bajaPersona @IDPersona = 4, @razon = 'Renuncia';
GO

SELECT * FROM PnTablas.Persona WHERE IDPersona = 4;
GO

--RESULTADO ESPERADO: Baja Exitosa (tras desasignar primero)

EXECUTE PnSPtrans.desasignarGuia @guia = 4, @actividad = 1, @fecha = '2026-12-07', @hora = '12:00';
GO
EXECUTE PnSPtrans.bajaPersona @IDPersona = 4, @razon = 'Renuncia';
GO

SELECT * FROM PnTablas.Persona WHERE IDPersona = 4;
SELECT * FROM PnTablas.Guia WHERE IDGuia = 4;
GO

-------------------------------------------------------------------------------------
--RESULTADO ESPERADO: Baja Exitosa (persona sin ningun rol activo asignado)

-- Persona 5 (Pedro Ruiz) es Guardaparque pero nunca fue asignado a un parque
EXECUTE PnSPtrans.bajaPersona @IDPersona = 5, @razon = 'No se presento';
GO

SELECT * FROM PnTablas.Persona WHERE IDPersona = 5;
SELECT * FROM PnTablas.GuardaParque WHERE IDGuardaParque = 5;
GO

--RESULTADOS ESPERADOS: Baja Fallida (persona inexistente, ya fue eliminada)

EXECUTE PnSPtrans.bajaPersona @IDPersona = 5, @razon = 'No se presento';
GO
