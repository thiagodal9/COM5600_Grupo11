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

/*
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Cargado Inicial con Inserciones exitosas

--TipoActividad
EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Taller', @costo = 100;
EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Caminata Guiada', @costo = 1000.50;
EXECUTE PnSPabm.altaTipoActividad @descripcion = 'Caminata Grupal sin Guia', @costo = 500;
GO

SELECT *
FROM PnTablas.TipoActividad;
GO

SELECT *
FROM PnTablas.Parque

--Actividad
--PnSPabm.altaActividad (@nombre varchar(30), @duracion INT, @cupo INT, @parque INT, @tipo INT)
EXECUTE PnSPabm.nuevoActividadParque 
@nombre = 'Pesca en Rio Salado', 
@duracion = 360, 
@cupo = 10, 
@parque = 1, 
@tipo = 1;
EXECUTE PnSPabm.nuevoActividadParque 
@nombre = 'Caminata por Bosque Salado', 
@duracion = 240, 
@cupo = 25, 
@parque = 1, 
@tipo = 2;
EXECUTE PnSPabm.nuevoActividadParque 
@nombre = 'Caminata por Bosque Pochoclo', 
@duracion = 240, 
@cupo = 25, 
@parque = 2, 
@tipo = 2;
GO

SELECT *
FROM PnTablas.ActividadParque;
GO

----Testing
-------------------------------------------------------------------------------------
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

SELECT *
FROM PnTablas.TipoActividad;
GO

--Modificacion (Costo) Exitosa
EXECUTE PnSPabm.modificarCostoTipoActividad @tipo = 1, @costoNEW = 3000;

SELECT *
FROM PnTablas.TipoActividad;
GO

--Baja Fallida
EXECUTE PnSPabm.bajaTipoActividad @tipo = NULL
EXECUTE PnSPabm.bajaTipoActividad @tipo = -1
EXECUTE PnSPabm.bajaTipoActividad @tipo = 1
EXECUTE PnSPabm.bajaTipoActividad @tipo = 24
GO

SELECT *
FROM PnTablas.TipoActividad;
GO

--Baja Exitosa
EXECUTE PnSPabm.bajaTipoActividad @tipo = 3
GO

SELECT *
FROM PnTablas.TipoActividad;
GO

-------------------------------------------------------------------------------------
--Actividad
--PnSPabm.altaActividad (@nombre varchar(30), @duracion INT, @cupo INT, @parque INT, @tipo INT)
--Insercion Fallida
EXECUTE PnSPabm.nuevoActividadParque 
@nombre = NULL, 
@duracion = NULL, 
@cupo = NULL, 
@parque = NULL, 
@tipo = NULL;
EXECUTE PnSPabm.nuevoActividadParque 
@nombre = NULL, 
@duracion = 0, 
@cupo = -10, 
@parque = 1, 
@tipo = 1;
EXECUTE PnSPabm.nuevoActividadParque 
@nombre = 'Pesca en Rio Salado', 
@duracion = 220, 
@cupo = 25, 
@parque = 1, 
@tipo = 1;
GO

SELECT *
FROM PnTablas.Actividad;
GO

--Modificacion (Nombre) Fallida
EXECUTE PnSPabm.cambiarNombreActividadParque @actividad = NULL, @nombreNEW = NULL;
EXECUTE PnSPabm.cambiarNombreActividadParque @actividad = -2, @nombreNEW = 'Trecking por Bosque Salado';
EXECUTE PnSPabm.cambiarNombreActividadParque @actividad = 1, @nombreNEW = 'Caminata por Bosque Salado';
EXECUTE PnSPabm.cambiarNombreActividadParque @actividad = 45, @nombreNEW = 'Trecking por Bosque Salado';
GO

SELECT *
FROM PnTablas.ActividadParque;
GO

--Modificacion (Nombre) Exitosa
EXECUTE PnSPabm.cambiarNombreActividadParque @actividad = 2, @nombreNEW = 'Trecking por Bosque Salado';
GO

SELECT *
FROM PnTablas.ActividadParque;
GO

--Modificacion (Duracion) Fallida
EXECUTE PnSPabm.modificarDuracionActividadParque @actividad = NULL, @duracionNEW = -2;
EXECUTE PnSPabm.modificarDuracionActividadParque @actividad = 1, @duracionNEW = NULL;
EXECUTE PnSPabm.modificarDuracionActividadParque @actividad = 1, @duracionNEW = 0;
GO

SELECT *
FROM PnTablas.ActividadParque;
GO

--Modificacion (Duracion) Exitosa
EXECUTE PnSPabm.modificarDuracionActividadParque @actividad = 1, @duracionNEW = 30;
GO

SELECT *
FROM PnTablas.ActividadParque;
GO

--Modificacion (Cupo) Fallida
EXECUTE PnSPabm.modificarCupoActividadParque @actividad = NULL, @cupoNEW = -2;
EXECUTE PnSPabm.modificarCupoActividadParque @actividad = 1, @cupoNEW = NULL;
EXECUTE PnSPabm.modificarCupoActividadParque @actividad = 1, @cupoNEW = 0;
GO

SELECT *
FROM PnTablas.ActividadParque;
GO

--Modificacion (Cupo) Exitosa
EXECUTE PnSPabm.modificarCupoActividadParque @actividad = 1, @cupoNEW = 30;
GO

SELECT *
FROM PnTablas.ActividadParque;
GO

--Baja Fallida
EXECUTE PnSPabm.bajaActividadParque @actividad = NULL;
EXECUTE PnSPabm.bajaActividadParque @actividad = -1;
EXECUTE PnSPabm.bajaActividadParque @actividad = 0;
EXECUTE PnSPabm.bajaActividadParque @actividad = 45;
EXECUTE PnSPabm.bajaActividadParque @actividad = 1;
GO

SELECT *
FROM PnTablas.ActividadParque;
GO

--Baja Exitosa
EXECUTE PnSPabm.bajaActividadParque @actividad = 3;
GO

SELECT *
FROM PnTablas.ActividadParque;
GO
*/