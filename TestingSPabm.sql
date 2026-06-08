USE ParquesNacionales;
GO

-------------------------------------------------------------------------------------

--Insercion
EXECUTE PnSPabm.nuevoTipoParque @tipo = 'Reserva';
EXECUTE PnSPabm.nuevoTipoParque @tipo = 'Reserva Aviaria';

SELECT *
FROM PnTablas.TipoParque;
GO

--Insercion Duplicado
EXECUTE PnSPabm.nuevoTipoParque @tipo = 'Reserva';

SELECT *
FROM PnTablas.TipoParque;
GO

--Modificacion
EXECUTE PnSPabm.cambiarTipoParque @tipoOLD = 'Reserva', @tipoNEW = 'Reserva Animal';

SELECT *
FROM PnTablas.TipoParque;
GO

--Borrado
EXECUTE PnSPabm.borrarTipoParque @tipo = 'Reserva Aviaria';

SELECT *
FROM PnTablas.TipoParque;
GO
-------------------------------------------------------------------------------------

--Insercion
EXECUTE PnSPabm.nuevoProvincia @nombre = 'rio negro';
EXECUTE PnSPabm.nuevoProvincia @nombre = 'Santa Cruz';

SELECT *
FROM PnTablas.Provincia;
GO

--Insercion Duplicado
EXECUTE PnSPabm.nuevoProvincia @nombre = 'Rio Negro';

SELECT *
FROM PnTablas.Provincia
GO;

--Modificacion
EXECUTE PnSPabm.cambiarProvincia @nombreOLD = 'rio negro', @nombreNEW = 'Rio Negro';

SELECT *
FROM PnTablas.Provincia;
GO

--Borrado
EXECUTE PnSPabm.borrarProvincia @nombre = 'Santa Cruz';

SELECT *
FROM PnTablas.Provincia;
GO

-------------------------------------------------------------------------------------

--Insercion
EXECUTE PnSPabm.nuevoParque @nombre = 'Parque Iguazu', @ubicacion = 'Rio Negro', @Superficie = 2000, @tipo = 'Reserva Animal';
EXECUTE PnSPabm.nuevoParque @nombre = 'Parque Pochoclo', @ubicacion = 'Rio Negro', @Superficie = 1500, @tipo = 'Reserva Animal';

SELECT *
FROM PnTablas.Parque
GO

--Insercion (todos los campos mal)
EXECUTE PnSPabm.nuevoParque @nombre = 'Parque Iguazu', @ubicacion = 'Buenos Aires', @Superficie = -2000, @tipo = 'Monumento';

SELECT *
FROM PnTablas.Parque
GO

--Insercion (algunos campos mal - nombre, superficie)
EXECUTE PnSPabm.nuevoParque @nombre = 'Parque Iguazu', @ubicacion = 'Rio Negro', @Superficie = -2000, @tipo = 'Reserva Animal';

SELECT *
FROM PnTablas.Parque
GO

--Modificacion (Superficie)
EXECUTE PnSPabm.cambiarSuperficieParque @nombre = 'Parque Pochoclo', @SuperficieNEW = 2000

SELECT *
FROM PnTablas.Parque;
GO

--Modificacion (Nombre)
EXECUTE PnSPabm.cambiarNombreParque @nombreOLD = 'Parque Pochoclo', @nombreNEW = 'Parque Pochoclero'

SELECT *
FROM PnTablas.Parque;
GO

--Borrado
EXECUTE PnSPabm.borrarParque @nombre = 'Parque Pochoclero'

SELECT *
FROM PnTablas.Parque
GO

-------------------------------------------------------------------------------------
--Tabla trivial
EXECUTE PnSPabm.llenarTablaDia

SELECT *
FROM PnTablas.Dia
-------------------------------------------------------------------------------------

--Insercion
EXECUTE PnSPabm.nuevoHorario @parque = 'Parque Iguazu', @dia = 'Lunes', @hapertura = '10:30', @hcierre = '17:00', @temporada = 'Invierno';
EXECUTE PnSPabm.nuevoHorario @parque = 'Parque Iguazu', @dia = 'Martes', @hapertura = '09:00', @hcierre = '15:00', @temporada = 'Verano';

SELECT *
FROM PnTablas.HorarioParque;

SELECT *
FROM PnTablas.Abre;
GO

--Insercion (parque no existe)
EXECUTE PnSPabm.nuevoHorario @parque = 'Parque Patata', @dia = 'Lunes', @hapertura = '10:30', @hcierre = '17:00', @temporada = 'Invierno';

SELECT *
FROM PnTablas.HorarioParque;

SELECT *
FROM PnTablas.Abre;
GO

--Insercion (Horario ya presente)
EXECUTE PnSPabm.nuevoHorario @parque = 'Parque Iguazu', @dia = 'Lunes', @hapertura = '10:30', @hcierre = '17:00', @temporada = 'Invierno';

SELECT *
FROM PnTablas.HorarioParque;

SELECT *
FROM PnTablas.Abre;
GO

--Modificacion
EXECUTE PnSPabm.cambiarHorario
@parque = 'Parque Iguazu', @dia = 'Martes', @temporada = 'Verano',
@haperturaOLD = '09:00', @hcierreOLD = '15:00',
@haperturaNEW = '10:00', @hcierreNEW = '12:00';

SELECT *
FROM PnTablas.HorarioParque;
GO

--Borrado
EXECUTE PnSPabm.borrarHorario @parque = 'Parque Iguazu', @dia = 'Martes', @hapertura = '10:00', @hcierre = '12:00', @temporada = 'Verano';

SELECT *
FROM PnTablas.HorarioParque;

SELECT *
FROM PnTablas.Abre;
GO

-------------------------------------------------------------------------------------

--Insercion
EXECUTE PnSPabm.nuevoTelefonoParque @numero = '4567-0345', @parque = 'Parque Iguazu';
EXECUTE PnSPabm.nuevoTelefonoParque @numero = '4567-0352', @parque = 'Parque Iguazu';

SELECT *
FROM PnTablas.TelefonoParque;
GO

--Insercion (numero ya existente)
EXECUTE PnSPabm.nuevoTelefonoParque @numero = '4567-0345', @parque = 'Parque Iguazu';

SELECT *
FROM PnTablas.TelefonoParque;
GO

----Insercion (Parque no existente)
EXECUTE PnSPabm.nuevoTelefonoParque @numero = '4567-0345', @parque = 'Parque Pochoclo';

SELECT *
FROM PnTablas.TelefonoParque;
GO

--Modificacion
EXECUTE PnSPabm.cambiarTelefonoParque @numeroOLD = '4567-0352', @numeroNEW = '11 4567-0352', @parque = 'Parque Iguazu';

SELECT *
FROM PnTablas.TelefonoParque;
GO

--Borrado
EXECUTE PnSPabm.borrarTelefonoParque @numero = '4567-0345', @parque = 'Parque Iguazu';

SELECT *
FROM PnTablas.TelefonoParque;
GO

-------------------------------------------------------------------------------------

--Insercion
EXECUTE PnSPabm.nuevoTipoActividad @descripcion = 'Caminata Guiada', @costo = 1000.50;
EXECUTE PnSPabm.nuevoTipoActividad @descripcion = 'Caminata Grupal sin Guia', @costo = 500;

SELECT *
FROM PnTablas.TipoActividad

--Insercion (duplicado)
EXECUTE PnSPabm.nuevoTipoActividad @descripcion = 'Caminata Guiada', @costo = 300.50;

SELECT *
FROM PnTablas.TipoActividad;
GO

--Modificacion (Descripcion)
EXECUTE PnSPabm.cambiarDescripcionTipoActividad @descripcionOLD = 'Caminata Grupal sin Guia', @descripcionNEW = 'Caminata Grupal con Guia';

SELECT *
FROM PnTablas.TipoActividad;
GO

--Modificacion (Costo)
EXECUTE PnSPabm.cambiarCostoTipoActividad @descripcion = 'Caminata Grupal con Guia', @costoNEW = 50000.50;

SELECT *
FROM PnTablas.TipoActividad;
GO

--Borrado
EXECUTE PnSPabm.borrarTipoActividad @descripcion = 'Caminata Grupal con Guia';

SELECT *
FROM PnTablas.TipoActividad;
GO

-------------------------------------------------------------------------------------

--Insercion
EXECUTE PnSPabm.nuevoActividadParque 
@nombre = 'Pesca en Rio Salado', 
@duracion = 360, 
@cupo = 10, @parque = 'Parque Iguazu', 
@tipo = 'Taller guiado', @guia = 'Perez Anibal';

EXECUTE PnSPabm.nuevoActividadParque 
@nombre = 'Caminata por Bosque Salado', 
@duracion = 240, 
@cupo = 25, @parque = 'Parque Iguazu', 
@tipo = 'Caminata Grupal con Guia', @guia = 'Dario Juarez';

SELECT *
FROM PnTablas.ActividadParque;
GO

--Insercion (todos los campos mal)
EXECUTE PnSPabm.nuevoActividadParque 
@nombre = 'Pesca en Rio Salado', 
@duracion = -360, 
@cupo = 0, @parque = 'Parque Pochoclo', 
@tipo = 'Taller Supervisado', @guia = 'Juan Rodriguez';

SELECT *
FROM PnTablas.ActividadParque;
GO

--Insercion (algunos campos mal: duracion, tipo)
EXECUTE PnSPabm.nuevoActividadParque 
@nombre = 'Pesca en Lago Azucarado', 
@duracion = -360, 
@cupo = 5, @parque = 'Parque Iguazu', 
@tipo = 'Taller Supervisado', @guia = 'Dario Juarez';

SELECT *
FROM PnTablas.ActividadParque;
GO

--Modificacion (nombre)
EXECUTE PnSPabm.cambiarNombreActividadParque @nombreOLD = 'Caminata por Bosque Salado', @nombreNEW = 'Trecking por Bosque Salado';

SELECT *
FROM PnTablas.ActividadParque;
GO

--Modificacion(duracion)
EXECUTE PnSPabm.cambiarDuracionActividadParque @nombre = 'Caminata por Bosque Salado', @duracionNEW = 60;

SELECT *
FROM PnTablas.ActividadParque;
GO

--Modificacion(cupo)
EXECUTE PnSPabm.cambiarCupoActividadParque @nombre = 'Caminata por Bosque Salado', @cupoNEW = 45;

SELECT *
FROM PnTablas.ActividadParque;
GO

--Modificacion(guia)
EXECUTE PnSPabm.cambiarGuiaActividadParque @nombre = 'Caminata por Bosque Salado', @guia = 'Cristiano Hernaldo';

SELECT *
FROM PnTablas.ActividadParque;
GO

--Borrado
PnSPabm.borrarActividadParque @nombre = 'Caminata por Bosque Salado';

SELECT *
FROM PnTablas.ActividadParque;
GO