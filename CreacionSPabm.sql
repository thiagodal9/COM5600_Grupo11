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

--Creo el esquema para los SP
--create schema PnSPabm
--go


/*
================================================================
abm HorarioActividad
================================================================
*/
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
	if not exists (select fechaActividad, idActividad from PnTablas.HorarioActividad 
	where fechaActividad = @fechaActividadActual and idActividad = @idActividadActual)
	begin
		print 'No existe la actividad en el dia que se quiere borrar'
	end
	else
	begin
		update PnTablas.HorarioActividad 
		set fechaActividad = @fechaActividadNueva,
		    idActividad = @idActividadNueva,
			horaInicio = @horaInicioNueva
		where fechaActividad = @fechaActividadActual and idActividad = @idActividadActual
	end
end
go

/*
================================================================
abm Venta
================================================================
*/

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
go

--Baja
create procedure PnSPabm.bajaVenta
@idVenta int
as
begin
	if not exists (select idVenta from PnTablas.Venta where idVenta = @idVenta)
	begin
		print 'La venta que quiere eliminar no existe'	
	end
	else
	begin
		delete from PnTablas.Venta 
		where idVenta = @idVenta
	end
end
go


--Modificacion
create procedure PnSPabm.modificacionVenta
@idVenta int,
@idActividadNuevo int,
@idTipoActividadNuevo int,
@fechaActividadNuevo date,
@idParqueNuevo int,
@fechaVentaNuevo date,
@totalVentaNuevo decimal(10,2)
as
begin
	if not exists (select idVenta from PnTablas.Venta where idVenta = @idVenta)
	begin
		print 'La Venta que se quiere modificar no existe'
	end
	else
	begin
		update PnTablas.Venta
		set idActividad = @idActividadNuevo,
			idTipoActividad = @idTipoActividadNuevo,
			fechaActividad = @fechaActividadNuevo,
			idParque = @idParqueNuevo,
			fechaVenta = @fechaVentaNuevo,
			totalVenta = @totalVentaNuevo
		where idVenta = @idVenta
	end
end
go

/*
================================================================
abm Entrada
================================================================
*/

--Alta
create procedure PnSPabm.altaEntrada
@idVenta int,
@precio decimal(10,2),
@descripcion varchar,
@cantidad int
as 
begin
	if not exists  (select idVenta from PnTablas.Venta where idVenta = @idVenta)
	begin
		print 'La venta de la entrada no esta registrada'
	end
	else
	begin
		insert into PnTablas.Entrada(idVenta, precio, descripcion, cantidad) values
		(@idVenta, @precio, @descripcion, @cantidad)
		print 'Entrada registrada con exito'
	end
end
go

--Baja
create procedure PnSPabm.bajaEntrada
@idEntrada int
as
begin
	if not exists (select idEntrada from PnTablas.Entrada where idEntrada = @idEntrada)
	begin
		print 'No hay una entrada registrada con es id'
	end
	else
	begin
		delete from PnTablas.Entrada
		where idEntrada = @idEntrada
		print 'Entrada eliminada exitosamente'
	end
end
go

--Modificacion
create procedure PnSPabm.modificacionEntrada
@idEntrada int,
@idVentaNueva int,
@precioNueva decimal(10,2),
@descripcionNueva varchar,
@cantidadNueva int
as
begin
	if not exists (select idEntrada from PnTablas.Entrada where idEntrada = @idEntrada)
	begin
		print 'No existe una entrada con ese id'
	end
	else if not exists (select idVenta from PnTablas.Venta where idVenta = @idVentaNueva)
	begin
		print 'No hay una venta registrada con ese id'
	end
	else
	begin
		update PnTablas.Entrada
		set idVenta = @idVentaNueva,
			precio = @precioNueva,
			descripcion = @descripcionNueva,
			cantidad = @cantidadNueva
	end
end
go
























































