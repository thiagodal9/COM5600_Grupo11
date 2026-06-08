/*
08/06/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

En este script se realiza la creacion de Stored Procedures para los ABM
*/

use ParquesNacionales
go

/*
Crear Para Venta, Entrada, HorarioActividad
HorarioActividad Listo
*/
--Creo el esquema para los SP
--create schema PnSPabm
--go

--Alta
create procedure PnSPabm.altaHorarioActividad
@fechaActividad date,
@idActividad int,
@horaInicio time
as
begin
	--Si no existe el idActvidad, no se debe realizar la insercion
	if not exists (select idActividad from PnTablas.Actividad where idActividad = @idActividad)
	begin
		print 'El idActividad es invalido'
	end
	else
	begin
		insert into PnTablas.HorarioActividad(fechaActividad, idActividad, horaInicio) values (@fechaActividad, @idActividad, @horaInicio)
	end
end
go

--Baja
create procedure PnSPabm.bajaHorarioActividad
@fechaActividad date,
@idActividad int
as
begin
	if exists (select fechaActividad, idActividad from PnTablas.HorarioActividad 
	where fechaActividad = @fechaActividad and idActividad = @idActividad)
	begin
		delete PnTablas.HorarioActividad 
		where fechaActividad = @fechaActividad and idActividad = @idActividad
	end
	else
	begin
		print 'No existe la actividad en el dia que se quiere borrar'
	end
end
go

--Modificacion
create procedure PnSPabm.modificacionHorarioActividad
@fechaActividadActual date,
@idActividadActual int,
@fechaActividadNueva date,
@idActividadNueva int,
@horaInicioNueva time
as
begin
	if exists (select fechaActividad, idActividad from PnTablas.HorarioActividad 
	where fechaActividad = @fechaActividadActual and idActividad = @idActividadActual)
	begin
		update PnTablas.HorarioActividad 
		set fechaActividad = @fechaActividadNueva,
		    idActividad = @idActividadNueva,
			horaInicio = @horaInicioNueva
		where fechaActividad = @fechaActividadActual and idActividad = @idActividadActual
	end
	else
	begin
		print 'No existe la actividad en el dia que se quiere borrar'
	end
end
go


--SP de Ventas

--Alta
create procedure PnSPabm.altaVenta
@idActividad int,
@idTipoActividad int,
@fechaActividad date,
@idParque int,
@fechaVenta date,
@totalVenta decimal(10,2)
as
begin
	if not exists (select idActividad from PnTablas.Actividad where idActividad = @idActividad and idParque = @idParque)
	begin
		print 'Esa actividad no se realiza en ese parque'
	end
	else if not exists (select idActividad from PnTablas.HorarioActividad where idActividad = @idActividad and fechaActividad = @fechaActividad)
	begin
		print 'Esa actividad no se realiza en esa fecha'
	end
	else if (select costo from PnTablas.TipoActividad where idTipoActividad = @idTipoActividad) != @totalVenta
	begin
		print 'Ese tipo de actividad no tiene ese valor de venta'
	end
	else
	begin
		insert into PnTablas.Venta(idActividad, idTipoActividad, fechaActividad, idParque, fechaVenta, totalVenta) values
		(@idActividad, @idTipoActividad, @fechaActividad, @idParque, @fechaVenta, @totalVenta)
	end
end
























