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
create schema PnSPabm
go


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
		throw 50001, 'El idActividad es inválido.', 1;

	begin transaction
	begin try
		insert into PnTablas.HorarioActividad(fechaActividad, idActividad, horaInicio) values (@fechaActividad, @idActividad, @horaInicio)
		commit transaction;
		print 'El horario de la actividad se ha registradoa exitosamente.';
	end try
	begin catch
		if @@TRANCOUNT > 0
			rollback transaction;

		declare @msj nvarchar(100) = ERROR_MESSAGE();
		declare @numError int = ERROR_NUMBER();
		print concat('ERROR (', @numError,'):', @msj);
		throw
	end catch
end
go

--Baja
create procedure PnSPabm.bajaHorarioActividad
@fechaActividad date,
@idActividad int
as
begin
	if not exists (select fechaActividad, idActividad from PnTablas.HorarioActividad 
	where fechaActividad = @fechaActividad and idActividad = @idActividad)
		throw 50001, 'La actividad no se realiza en el dia indicado',1;
	
	begin transaction;
	begin try
		delete PnTablas.HorarioActividad 
		where fechaActividad = @fechaActividad and idActividad = @idActividad;
		commit transaction;
		print 'El horario de la actividad se ha eliminado exitosamente.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError, ')', @msj);
	end catch
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
		throw 50001, 'La actividad no se realiza en el dia indicado',1;
	begin transaction
	begin try
		update PnTablas.HorarioActividad 
		set fechaActividad = @fechaActividadNueva,
		    idActividad = @idActividadNueva,
			horaInicio = @horaInicioNueva
		where fechaActividad = @fechaActividadActual and idActividad = @idActividadActual
		commit transaction
		print 'La modificación se ha realizado con éxito.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')', @msj);
	end catch
end
go

/*
================================================================
abm Venta
================================================================
*/

--Alta
create procedure PnSPabm.altaPagoVenta
@idPagoVenta int,
@idTipoActividad int,
@fechaActividad date,
@idParque int,
@fechaVenta date,
@totalVenta decimal(10,2)
as
begin
	if not exists (select idActividad from PnTablas.Actividad where idActividad = @idActividad and idParque = @idParque)
		throw 50001, 'Esa actividad no se realiza en ese parque',1;
	else if not exists (select idActividad from PnTablas.HorarioActividad where idActividad = @idActividad and fechaActividad = @fechaActividad)
		throw 50002, 'Esa actividad no se realiza en esa fecha',1;
	else if (select costo from PnTablas.TipoActividad where idTipoActividad = @idTipoActividad) != @totalVenta
		throw 50003, 'Ese tipo de actividad no tiene ese valor de venta',1;
	begin transaction
	begin try
		insert into PnTablas.Venta(idActividad, idTipoActividad, fechaActividad, idParque, fechaVenta, totalVenta) values
		(@idActividad, @idTipoActividad, @fechaActividad, @idParque, @fechaVenta, @totalVenta)
		commit transaction;
		print 'La Venta se ha registrado exitosamente.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Baja
create procedure PnSPabm.bajaVenta
@idVenta int
as
begin
	if not exists (select idVenta from PnTablas.Venta where idVenta = @idVenta)
		throw 50001, 'El idVenta es inválido.',1; 	
	begin transaction
	begin try
		delete from PnTablas.Venta 
		where idVenta = @idVenta;
		commit transaction
		print 'El registro de la venta se ha eliminado exitósamente.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
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
		throw 50001, 'El idVenta es inválido.',1; 

	begin transaction
	begin try
		update PnTablas.Venta
		set idActividad = @idActividadNuevo,
			idTipoActividad = @idTipoActividadNuevo,
			fechaActividad = @fechaActividadNuevo,
			idParque = @idParqueNuevo,
			fechaVenta = @fechaVentaNuevo,
			totalVenta = @totalVentaNuevo
		where idVenta = @idVenta;
		commit transaction
		print 'La modificación se realizó con éxito.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go




























































