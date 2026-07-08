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

--Testing de los SPs de ABM asociados a las tablas Actividad

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Chequeo de datos cargados

SELECT *
FROM PnTablas.Parque
GO

SELECT *
FROM PnTablas.TipoActividad;
GO

SELECT *
FROM PnTablas.Actividad;
GO

--falta testing horarioActividad

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----TESTING (las inserciones se dan por probadas al llenar las tablas con datos iniciales para testing)

----TipoActividad
--Insercion Fallida
EXECUTE PnSPabm.altaTipoActividad @descripcion = NULL, @costo = NULL;
EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Caminata Grupal sin Guia', @costo = -500;
EXECUTE PnSPabm.altaTipoActividad @descripcion = NULL, @costo = 0;
EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Caminata Grupal sin Guia', @costo = 1000;
GO

SELECT *
FROM PnTablas.TipoActividad;
GO

--Modificacion (Descripcion) Fallida
EXECUTE PnSPabm.modificarDescripcionTipoActividad @tipo = NULL, @descripcionNEW = NULL;
EXECUTE PnSPabm.modificarDescripcionTipoActividad @tipo = -3, @descripcionNEW = 'Caminata Guiada';
EXECUTE PnSPabm.modificarDescripcionTipoActividad @tipo = 3, @descripcionNEW = NULL;
EXECUTE PnSPabm.modificarDescripcionTipoActividad @tipo = 31, @descripcionNEW = 'Caminata Grupal no Guiada';
EXECUTE PnSPabm.modificarDescripcionTipoActividad @tipo = 3, @descripcionNEW = 'Caminata Guiada';

SELECT *
FROM PnTablas.TipoActividad;
GO

--Modificacion (Descripcion) Exitosa
EXECUTE PnSPabm.modificarDescripcionTipoActividad @tipo = 3, @descripcionNEW = 'Caminata Grupal no Guiada';

SELECT *
FROM PnTablas.TipoActividad;
GO

--Modificacion (Costo) Fallida
EXECUTE PnSPabm.modificarCostoTipoActividad @tipo = NULL, @costoNEW = NULL
EXECUTE PnSPabm.modificarCostoTipoActividad @tipo = 1, @costoNEW = -3000;
EXECUTE PnSPabm.modificarCostoTipoActividad @tipo = -2, @costoNEW = 50000.50;
EXECUTE PnSPabm.modificarCostoTipoActividad @tipo = 10, @costoNEW = 50000.50;
GO

SELECT * FROM PnTablas.TipoActividad;
GO

--Modificacion (Costo) Exitosa
EXECUTE PnSPabm.modificarCostoTipoActividad @tipo = 1, @costoNEW = 3000;

SELECT * FROM PnTablas.TipoActividad;
GO

--Baja Fallida
EXECUTE PnSPabm.bajaTipoActividad @tipo = NULL
EXECUTE PnSPabm.bajaTipoActividad @tipo = -1
EXECUTE PnSPabm.bajaTipoActividad @tipo = 1
EXECUTE PnSPabm.bajaTipoActividad @tipo = 24
GO

SELECT * FROM PnTablas.TipoActividad;
GO

--Baja Exitosa
EXECUTE PnSPabm.bajaTipoActividad @tipo = 3
GO

SELECT * FROM PnTablas.TipoActividad;
GO

-------------------------------------------------------------------------------------
----Actividad
--Insercion Fallida
EXECUTE PnSPabm.altaActividad 
@nombre = NULL, 
@duracion = NULL, 
@cupo = NULL, 
@parque = NULL, 
@tipo = NULL;
EXECUTE PnSPabm.altaActividad 
@nombre = NULL, 
@duracion = 0, 
@cupo = -10, 
@parque = 1, 
@tipo = 1;
EXECUTE PnSPabm.altaActividad 
@nombre = 'Pesca en Rio Salado', 
@duracion = 220, 
@cupo = 25, 
@parque = 1, 
@tipo = 1;
GO

SELECT * FROM PnTablas.Actividad;
GO

--Modificacion (Nombre) Fallida
EXECUTE PnSPabm.modificarNombreActividad @actividad = NULL, @nombreNEW = NULL;
EXECUTE PnSPabm.modificarNombreActividad @actividad = -2, @nombreNEW = 'Trecking por Bosque Salado';
EXECUTE PnSPabm.modificarNombreActividad @actividad = 1, @nombreNEW = 'Caminata por bosque salado';
EXECUTE PnSPabm.modificarNombreActividad @actividad = 45, @nombreNEW = 'Trecking por Bosque Salado';
GO

SELECT * FROM PnTablas.Actividad;
GO

--Modificacion (Nombre) Exitosa
EXECUTE PnSPabm.modificarNombreActividad @actividad = 2, @nombreNEW = 'Trecking por Bosque Salado';
GO

SELECT * FROM PnTablas.Actividad;
GO

--Modificacion (Duracion) Fallida
EXECUTE PnSPabm.modificarDuracionActividad @actividad = NULL, @duracionNEW = -2;
EXECUTE PnSPabm.modificarDuracionActividad @actividad = 1, @duracionNEW = NULL;
EXECUTE PnSPabm.modificarDuracionActividad @actividad = 1, @duracionNEW = 0;
GO

SELECT * FROM PnTablas.Actividad;
GO

--Modificacion (Duracion) Exitosa
EXECUTE PnSPabm.modificarDuracionActividad @actividad = 1, @duracionNEW = 30;
GO

SELECT * FROM PnTablas.Actividad;
GO

--Modificacion (Cupo) Fallida
EXECUTE PnSPabm.modificarCupoActividad @actividad = NULL, @cupoNEW = -2;
EXECUTE PnSPabm.modificarCupoActividad @actividad = 1, @cupoNEW = NULL;
EXECUTE PnSPabm.modificarCupoActividad @actividad = 1, @cupoNEW = 0;
GO

SELECT * FROM PnTablas.Actividad;
GO

--Modificacion (Cupo) Exitosa
EXECUTE PnSPabm.modificarCupoActividad @actividad = 1, @cupoNEW = 30;
GO

SELECT * FROM PnTablas.Actividad;
GO

--Baja Fallida
EXECUTE PnSPabm.bajaActividad @actividad = NULL;
EXECUTE PnSPabm.bajaActividad @actividad = -1;
EXECUTE PnSPabm.bajaActividad @actividad = 0;
EXECUTE PnSPabm.bajaActividad @actividad = 45;
EXECUTE PnSPabm.bajaActividad @actividad = 1;
GO

SELECT * FROM PnTablas.Actividad;
GO

--Baja Exitosa
EXECUTE PnSPabm.bajaActividad @actividad = 3;
GO

SELECT * FROM PnTablas.Actividad;
GO

-------------------------------------------------------------------------------------
----HorarioActividad
--Insercion Fallida
EXECUTE PnSPabm.altaHActividad @actividad = NULL, @fechaAct = NULL, @hInicio = NULL;
EXECUTE PnSPabm.altaHActividad @actividad = -2, @fechaAct = '2026-12-29', @hInicio = '18:00';
EXECUTE PnSPabm.altaHActividad @actividad = 50, @fechaAct = '2026-12-29', @hInicio = '18:00';
EXECUTE PnSPabm.altaHActividad @actividad = 2, @fechaAct = '2026-12-26', @hInicio = '17:00';
GO

SELECT *
FROM PnTablas.HorarioActividad;
GO

--Modificacion(fecha) Fallida
EXECUTE PnSPabm.modificacionFechaActividad @actividad = NULL, @fechaAct = NULL, @hInicio = NULL, @fechaNew = NULL;
EXECUTE PnSPabm.modificacionFechaActividad @actividad = -2, @fechaAct = '2026-12-26', @hInicio = '17:00', @fechaNew = '2026-12-30';
EXECUTE PnSPabm.modificacionFechaActividad @actividad = 50, @fechaAct = '2026-12-26', @hInicio = '17:00', @fechaNew = '2026-12-30';
EXECUTE PnSPabm.modificacionFechaActividad @actividad = 2, @fechaAct = '2026-12-26', @hInicio = '18:00', @fechaNew = '2026-12-29';
EXECUTE PnSPabm.modificacionFechaActividad @actividad = 2, @fechaAct = '2026-12-26', @hInicio = '18:00', @fechaNew = '2026-03-29';

SELECT *
FROM PnTablas.HorarioActividad;
GO

--Modificacion(fecha) Exitosa
EXECUTE PnSPabm.modificacionFechaActividad @actividad = 2, @fechaAct = '2026-12-26', @hInicio = '18:00', @fechaNew = '2026-12-27';

SELECT * FROM PnTablas.HorarioActividad;
GO

--Modificacion(hora) Fallida
EXECUTE PnSPabm.modificacionHoraActividad @actividad = NULL, @fechaAct = NULL, @hInicio = NULL, @hInicioNEW = NULL
EXECUTE PnSPabm.modificacionHoraActividad @actividad = -2, @fechaAct = NULL, @hInicio = NULL, @hInicioNEW = NULL
EXECUTE PnSPabm.modificacionHoraActividad @actividad = 50, @fechaAct = '2026-10-29', @hInicio = '17:00', @hInicioNEW = '20:00'
EXECUTE PnSPabm.modificacionHoraActividad @actividad = 2, @fechaAct = '2026-04-29', @hInicio = '17:00', @hInicioNEW = '20:00'
EXECUTE PnSPabm.modificacionHoraActividad @actividad = 2, @fechaAct = '2026-12-29', @hInicio = '17:00', @hInicioNEW = '18:00'

SELECT * FROM PnTablas.HorarioActividad;
GO

--Modificacion(hora) Exitosa
EXECUTE PnSPabm.modificacionHoraActividad @actividad = 2, @fechaAct = '2026-12-29', @hInicio = '17:00', @hInicioNEW = '20:00';
GO

SELECT * FROM PnTablas.HorarioActividad;
GO

--Baja(One) Fallida
EXECUTE PnSPabm.bajaHActividadOne @actividad = NULL, @fecha = NULL, @hInicio = NULL;
EXECUTE PnSPabm.bajaHActividadOne @actividad = -2, @fecha = NULL, @hInicio = NULL;
EXECUTE PnSPabm.bajaHActividadOne @actividad = 50, @fecha = '2026-12-29', @hInicio = '20:00';
EXECUTE PnSPabm.bajaHActividadOne @actividad = 2, @fecha = '2026-12-29', @hInicio = '18:00';
GO

SELECT * FROM PnTablas.HorarioActividad;
GO

--Baja(One) Exitosa
EXECUTE PnSPabm.bajaHActividadOne @actividad = 2, @fecha = '2026-12-29', @hInicio = '20:00';
GO

SELECT * FROM PnTablas.HorarioActividad;
GO

--Baja(All) Fallida
EXECUTE PnSPabm.bajaHActividadAll;
GO

SELECT * FROM PnTablas.HorarioActividad;
GO

--Baja(All) Exitosa
--Elimino primero el registro en conflicto
EXECUTE PnSPabm.bajaTHActividadOne
@pago = 3,
@actividad = 1,
@fechaActividad = '2025-12-29',
@horaInicio = '17:00';
GO

EXECUTE PnSPabm.bajaHActividadAll;
GO

SELECT * FROM PnTablas.HorarioActividad;
GO