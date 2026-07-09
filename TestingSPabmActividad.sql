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

-- Testing de los SPs de ABM asociados a las tablas Actividad

SET NOCOUNT ON;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

-------------------------------------------------------------------------------------
---- Chequeo de datos cargados inicialmente

SELECT * FROM PnTablas.Parque;
GO
SELECT * FROM PnTablas.TipoActividad;
GO
SELECT * FROM PnTablas.Actividad;
GO

-------------------------------------------------------------------------------------
---- TESTING TipoActividad 

--RESULTADOS ESPERADOS: Inserción Fallida

-- Falla por parámetros nulos
EXECUTE PnSPabm.altaTipoActividad @descripcion = NULL, @costo = NULL;
-- Falla por costo negativo (violación de CHECK constraint)
EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Caminata Grupal sin Guia', @costo = -500;
-- Falla por descripción nula o costo cero
EXECUTE PnSPabm.altaTipoActividad @descripcion = NULL, @costo = 0;
-- Falla por registro duplicado
EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Caminata Grupal sin Guia', @costo = 1000;
GO

SELECT * FROM PnTablas.TipoActividad;
GO

--RESULTADOS ESPERADOS: Modificación (Descripción) Fallida

-- Falla por parámetros nulos, ID negativo o idéntica descripción
EXECUTE PnSPabm.modificarDescripcionTipoActividad @tipo = NULL, @descripcionNEW = NULL;
EXECUTE PnSPabm.modificarDescripcionTipoActividad @tipo = -3, @descripcionNEW = 'Caminata Guiada';
EXECUTE PnSPabm.modificarDescripcionTipoActividad @tipo = 3, @descripcionNEW = NULL;
EXECUTE PnSPabm.modificarDescripcionTipoActividad @tipo = 31, @descripcionNEW = 'Caminata Grupal no Guiada';
EXECUTE PnSPabm.modificarDescripcionTipoActividad @tipo = 3, @descripcionNEW = 'Caminata Guiada';
GO

SELECT * FROM PnTablas.TipoActividad;
GO

--RESULTADO ESPERADO: Modificación (Descripción) Exitosa

EXECUTE PnSPabm.modificarDescripcionTipoActividad @tipo = 3, @descripcionNEW = 'Caminata Grupal no Guiada';
GO

SELECT * FROM PnTablas.TipoActividad;
GO

--RESULTADOS ESPERADOS: Modificación (Costo) Fallida

-- Falla por parámetros nulos, ID negativo o costo fuera de rango
EXECUTE PnSPabm.modificarCostoTipoActividad @tipo = NULL, @costoNEW = NULL;
EXECUTE PnSPabm.modificarCostoTipoActividad @tipo = 1, @costoNEW = -3000;
EXECUTE PnSPabm.modificarCostoTipoActividad @tipo = -2, @costoNEW = 50000.50;
EXECUTE PnSPabm.modificarCostoTipoActividad @tipo = 10, @costoNEW = 50000.50;
GO

SELECT * FROM PnTablas.TipoActividad;
GO

--RESULTADO ESPERADO: Modificación (Costo) Exitosa

EXECUTE PnSPabm.modificarCostoTipoActividad @tipo = 1, @costoNEW = 3000;
GO

SELECT * FROM PnTablas.TipoActividad;
GO

--RESULTADOS ESPERADOS: Baja Fallida

-- Falla por parámetro nulo, ID inexistente o integridad referencial
EXECUTE PnSPabm.bajaTipoActividad @tipo = NULL;
EXECUTE PnSPabm.bajaTipoActividad @tipo = -1;
EXECUTE PnSPabm.bajaTipoActividad @tipo = 1;
EXECUTE PnSPabm.bajaTipoActividad @tipo = 24;
GO

SELECT * FROM PnTablas.TipoActividad;
GO

--RESULTADO ESPERADO: Baja Exitosa

EXECUTE PnSPabm.bajaTipoActividad @tipo = 3;
GO

SELECT * FROM PnTablas.TipoActividad;
GO

-------------------------------------------------------------------------------------
---- TESTING Actividad

--RESULTADOS ESPERADOS: Inserción Fallida

-- Falla por parámetros nulos o valores inválidos (duración 0, cupo negativo)
EXECUTE PnSPabm.altaActividad @nombre = NULL, @duracion = NULL, @cupo = NULL, @parque = NULL, @tipo = NULL;
EXECUTE PnSPabm.altaActividad @nombre = NULL, @duracion = 0, @cupo = -10, @parque = 1, @tipo = 1;
-- Falla por duplicidad
EXECUTE PnSPabm.altaActividad @nombre = 'Pesca en Rio Salado', @duracion = 220, @cupo = 25, @parque = 1, @tipo = 1;
GO

SELECT * FROM PnTablas.Actividad;
GO

--RESULTADOS ESPERADOS: Modificación (Nombre) Fallida

-- Falla por parámetros nulos, ID inexistente o nombre duplicado
EXECUTE PnSPabm.modificarNombreActividad @actividad = NULL, @nombreNEW = NULL;
EXECUTE PnSPabm.modificarNombreActividad @actividad = -2, @nombreNEW = 'Trecking por Bosque Salado';
EXECUTE PnSPabm.modificarNombreActividad @actividad = 1, @nombreNEW = 'Caminata por bosque salado';
EXECUTE PnSPabm.modificarNombreActividad @actividad = 45, @nombreNEW = 'Trecking por Bosque Salado';
GO

SELECT * FROM PnTablas.Actividad;
GO

--RESULTADO ESPERADO: Modificación (Nombre) Exitosa

EXECUTE PnSPabm.modificarNombreActividad @actividad = 2, @nombreNEW = 'Trecking por Bosque Salado';
GO

SELECT * FROM PnTablas.Actividad;
GO

--RESULTADOS ESPERADOS: Modificación (Duración) Fallida

-- Falla por valores nulos, negativos o cero
EXECUTE PnSPabm.modificarDuracionActividad @actividad = NULL, @duracionNEW = -2;
EXECUTE PnSPabm.modificarDuracionActividad @actividad = 1, @duracionNEW = NULL;
EXECUTE PnSPabm.modificarDuracionActividad @actividad = 1, @duracionNEW = 0;
GO

SELECT * FROM PnTablas.Actividad;
GO

---RESULTADO ESPERADO: Modificación (Duración) Exitosa

EXECUTE PnSPabm.modificarDuracionActividad @actividad = 1, @duracionNEW = 30;
GO

SELECT * FROM PnTablas.Actividad;
GO

--RESULTADOS ESPERADOS: Modificación (Cupo) Fallida

-- Falla por valores nulos, negativos o cero
EXECUTE PnSPabm.modificarCupoActividad @actividad = NULL, @cupoNEW = -2;
EXECUTE PnSPabm.modificarCupoActividad @actividad = 1, @cupoNEW = NULL;
EXECUTE PnSPabm.modificarCupoActividad @actividad = 1, @cupoNEW = 0;
GO

SELECT * FROM PnTablas.Actividad;
GO

--RESULTADO ESPERADO: Modificación (Cupo) Exitosa

EXECUTE PnSPabm.modificarCupoActividad @actividad = 1, @cupoNEW = 30;
GO

SELECT * FROM PnTablas.Actividad;
GO

--RESULTADOS ESPERADOS: Baja Fallida

-- Falla por ID nulo, negativo, cero, inexistente o por integridad referencial
EXECUTE PnSPabm.bajaActividad @actividad = NULL;
EXECUTE PnSPabm.bajaActividad @actividad = -1;
EXECUTE PnSPabm.bajaActividad @actividad = 0;
EXECUTE PnSPabm.bajaActividad @actividad = 45;
EXECUTE PnSPabm.bajaActividad @actividad = 1;
GO

SELECT * FROM PnTablas.Actividad;
GO

--RESULTADO ESPERADO: Baja Exitosa

EXECUTE PnSPabm.bajaActividad @actividad = 3;
GO

SELECT * FROM PnTablas.Actividad;
GO

-------------------------------------------------------------------------------------
---- TESTING HorarioActividad

--RESULTADOS ESPERADOS: Inserción Fallida

-- Falla por parámetros nulos, ID de actividad inexistente o fechas inválidas/solapadas
EXECUTE PnSPabm.altaHActividad @actividad = NULL, @fechaAct = NULL, @hInicio = NULL;
EXECUTE PnSPabm.altaHActividad @actividad = -2, @fechaAct = '2026-12-29', @hInicio = '18:00';
EXECUTE PnSPabm.altaHActividad @actividad = 50, @fechaAct = '2026-12-29', @hInicio = '18:00';
EXECUTE PnSPabm.altaHActividad @actividad = 2, @fechaAct = '2026-12-26', @hInicio = '17:00';
GO

SELECT * FROM PnTablas.HorarioActividad;
GO

--RESULTADOS ESPERADOS: Modificación (Fecha) Fallida

-- Falla por parámetros nulos, IDs inexistentes o fechas conflictivas
EXECUTE PnSPabm.modificacionFechaActividad @actividad = NULL, @fechaAct = NULL, @hInicio = NULL, @fechaNew = NULL;
EXECUTE PnSPabm.modificacionFechaActividad @actividad = -2, @fechaAct = '2026-12-26', @hInicio = '17:00', @fechaNew = '2026-12-30';
EXECUTE PnSPabm.modificacionFechaActividad @actividad = 50, @fechaAct = '2026-12-26', @hInicio = '17:00', @fechaNew = '2026-12-30';
EXECUTE PnSPabm.modificacionFechaActividad @actividad = 2, @fechaAct = '2026-12-26', @hInicio = '18:00', @fechaNew = '2026-12-29';
EXECUTE PnSPabm.modificacionFechaActividad @actividad = 2, @fechaAct = '2026-12-26', @hInicio = '18:00', @fechaNew = '2026-03-29';
GO

SELECT * FROM PnTablas.HorarioActividad;
GO

--RESULTADO ESPERADO: Modificación (Fecha) Exitosa

EXECUTE PnSPabm.modificacionFechaActividad @actividad = 2, @fechaAct = '2026-12-26', @hInicio = '18:00', @fechaNew = '2026-12-27';
GO

SELECT * FROM PnTablas.HorarioActividad;
GO

--RESULTADOS ESPERADOS: Modificación (Hora) Fallida

-- Falla por parámetros nulos, registros inexistentes o solapamiento horario
EXECUTE PnSPabm.modificacionHoraActividad @actividad = NULL, @fechaAct = NULL, @hInicio = NULL, @hInicioNEW = NULL;
EXECUTE PnSPabm.modificacionHoraActividad @actividad = -2, @fechaAct = NULL, @hInicio = NULL, @hInicioNEW = NULL;
EXECUTE PnSPabm.modificacionHoraActividad @actividad = 50, @fechaAct = '2026-10-29', @hInicio = '17:00', @hInicioNEW = '20:00';
EXECUTE PnSPabm.modificacionHoraActividad @actividad = 2, @fechaAct = '2026-04-29', @hInicio = '17:00', @hInicioNEW = '20:00';
EXECUTE PnSPabm.modificacionHoraActividad @actividad = 2, @fechaAct = '2026-12-29', @hInicio = '17:00', @hInicioNEW = '18:00';
GO

SELECT * FROM PnTablas.HorarioActividad;
GO

--RESULTADO ESPERADO: Modificación (Hora) Exitosa

EXECUTE PnSPabm.modificacionHoraActividad @actividad = 2, @fechaAct = '2026-12-29', @hInicio = '17:00', @hInicioNEW = '20:00';
GO

SELECT * FROM PnTablas.HorarioActividad;
GO

--RESULTADOS ESPERADOS: Baja (One) Fallida

-- Falla por parámetros nulos o combinación de PK inexistente
EXECUTE PnSPabm.bajaHActividadOne @actividad = NULL, @fecha = NULL, @hInicio = NULL;
EXECUTE PnSPabm.bajaHActividadOne @actividad = -2, @fecha = NULL, @hInicio = NULL;
EXECUTE PnSPabm.bajaHActividadOne @actividad = 50, @fecha = '2026-12-29', @hInicio = '20:00';
EXECUTE PnSPabm.bajaHActividadOne @actividad = 2, @fecha = '2026-12-29', @hInicio = '18:00';
GO

SELECT * FROM PnTablas.HorarioActividad;
GO

--RESULTADO ESPERADO: Baja (One) Exitosa

EXECUTE PnSPabm.bajaHActividadOne @actividad = 2, @fecha = '2026-12-29', @hInicio = '20:00';
GO

SELECT * FROM PnTablas.HorarioActividad;
GO

--RESULTADOS ESPERADOS: Baja (All) Fallida

-- Falla por conflicto de integridad referencial
EXECUTE PnSPabm.bajaHActividadAll;
GO

SELECT * FROM PnTablas.HorarioActividad;
GO

--RESULTADO ESPERADO: Baja (All) Exitosa

-- Elimino primero el registro en conflicto
EXECUTE PnSPabm.bajaTHActividadOne @pago = 3, @actividad = 1, @fechaActividad = '2025-12-29', @horaInicio = '17:00';
GO

EXECUTE PnSPabm.bajaHActividadAll;
GO

SELECT * FROM PnTablas.HorarioActividad;
GO