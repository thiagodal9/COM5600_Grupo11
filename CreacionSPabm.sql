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
		throw 50001, 'El idVenta es inválido.',1;

	begin transaction
	begin try
		insert into PnTablas.Entrada(idVenta, precio, descripcion, cantidad) values
		(@idVenta, @precio, @descripcion, @cantidad);
		commit transaction;
		print 'Entrada registrada con exito';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Baja
create procedure PnSPabm.bajaEntrada
@idEntrada int
as
begin
	if not exists (select idEntrada from PnTablas.Entrada where idEntrada = @idEntrada)
		throw 50001, 'El idEntrada es inválido.',1;

	begin transaction
	begin try
		delete from PnTablas.Entrada
		where idEntrada = @idEntrada;
		commit transaction;
		print 'Entrada eliminada exitosamente.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
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
		throw 5001, 'El idEntrada es inválido.',1;
	
	else if not exists (select idVenta from PnTablas.Venta where idVenta = @idVentaNueva)
		throw 50002, 'El idVenta es inválido.', 1;
	
	begin transaction
	begin try
		update PnTablas.Entrada
		set idVenta = @idVentaNueva,
			precio = @precioNueva,
			descripcion = @descripcionNueva,
			cantidad = @cantidadNueva
		where idEntrada = @idEntrada;
		commit transaction;
		print 'La modificación de la entrada se realizó exitosamente.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

/*
================================================================
abm Empresa
================================================================
*/

--Alta
create procedure PnSPabm.altaEmpresa
@nombre varchar(100),
@descripcion varchar(255)
as 
begin
	if ltrim(rtrim(isnull(@nombre, ''))) = ''
		throw 50001, 'El nombre de la empresa no puede estar vacío.',1;

	begin transaction
	begin try
		insert into PnTablas.Empresa(nombre, descripcion) values
		(@nombre, @descripcion);
		commit transaction;
		print 'La Empresa se ha registrado exitosamente.';
	end try
	begin catch
		if @@TRANCOUNT > 0
			rollback transaction;
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Baja
create procedure PnSPabm.bajaEmpresa
@idEmpresa int
as
begin
	if not exists (select idEmpresa from PnTablas.Empresa where idEmpresa = @idEmpresa)
		throw 50001, 'El idEmpresa es inválido.',1;

	begin transaction
	begin try
		delete from PnTablas.Empresa
		where idEmpresa = @idEmpresa;
		commit transaction;
		print 'La Empresa eliminada exitosamente.';
	end try
	begin catch
		if @@TRANCOUNT > 0
			rollback transaction;
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Modificacion
create procedure PnSPabm.modificacionEmpresa
@idEmpresa int,
@nombreNuevo varchar(100),
@descripcionNueva varchar(255)
as
begin
	if not exists (select idEmpresa from PnTablas.Empresa where idEmpresa = @idEmpresa)
		throw 50001, 'El idEmpresa es inválido.',1;
	
	else if ltrim(rtrim(isnull(@nombreNuevo, ''))) = ''
		throw 50002, 'El nombre de la empresa no puede estar vacío.', 1;
	
	begin transaction
	begin try
		update PnTablas.Empresa
		set nombre = @nombreNuevo,
			descripcion = @descripcionNueva
		where idEmpresa = @idEmpresa;
		commit transaction;
		print 'La modificación de la Empresa se realizó exitosamente.';
	end try
	begin catch
		if @@TRANCOUNT > 0
			rollback transaction;
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

/*
================================================================
abm Concesion
================================================================
*/

--Alta
create procedure PnSPabm.altaConcesion
@idEmpresa int,
@idParque int,
@actividad varchar(100),
@fechaInicio date,
@fechaFin date,
@precioAlquiler decimal(18,2)
as 
begin
	declare @msjError nvarchar(max) = '';

	if not exists (select idEmpresa from PnTablas.Empresa where idEmpresa = @idEmpresa)
		set @msjError += 'La empresa especificada no existe. ';
	if @fechaFin <= @fechaInicio 
		set @msjError += 'La Fecha de Fin debe ser posterior a la Fecha de Inicio. ';
	if @precioAlquiler < 0 
		set @msjError += 'El precio de alquiler no puede ser negativo. ';

	if @msjError <> ''
		throw 50001, @msjError, 1;

	begin transaction
	begin try
		insert into PnTablas.Concesion(idEmpresa, idParque, actividad, fechaInicio, fechaFin, precioAlquiler) values
		(@idEmpresa, @idParque, @actividad, @fechaInicio, @fechaFin, @precioAlquiler);
		commit transaction;
		print 'La Concesion se ha registrado exitosamente.';
	end try
	begin catch
		if @@TRANCOUNT > 0
			rollback transaction;
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Baja
create procedure PnSPabm.bajaConcesion
@idConcesion int
as
begin
	if not exists (select idConcesion from PnTablas.Concesion where idConcesion = @idConcesion)
		throw 50001, 'El idConcesion es inválido.',1;

	begin transaction
	begin try
		delete from PnTablas.Concesion
		where idConcesion = @idConcesion;
		commit transaction;
		print 'La Concesion ha sido eliminada exitosamente.';
	end try
	begin catch
		if @@TRANCOUNT > 0
			rollback transaction;
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Modificacion
create procedure PnSPabm.modificacionConcesion
@idConcesion int,
@idEmpresaNueva int,
@idParqueNuevo int,
@actividadNueva varchar(100),
@fechaInicioNueva date,
@fechaFinNueva date,
@precioAlquilerNuevo decimal(18,2)
as
begin
	declare @msjError nvarchar(max) = '';

	if not exists (select idConcesion from PnTablas.Concesion where idConcesion = @idConcesion)
		set @msjError += 'El idConcesion es inválido. ';
	if not exists (select idEmpresa from PnTablas.Empresa where idEmpresa = @idEmpresaNueva)
		set @msjError += 'La empresa especificada no existe. ';
	if @fechaFinNueva <= @fechaInicioNueva 
		set @msjError += 'La Fecha de Fin debe ser posterior a la Fecha de Inicio. ';
	if @precioAlquilerNuevo < 0 
		set @msjError += 'El precio de alquiler no puede ser negativo. ';

	if @msjError <> ''
		throw 50001, @msjError, 1;
	
	begin transaction
	begin try
		update PnTablas.Concesion
		set idEmpresa = @idEmpresaNueva,
			idParque = @idParqueNuevo,
			actividad = @actividadNueva,
			fechaInicio = @fechaInicioNueva,
			fechaFin = @fechaFinNueva,
			precioAlquiler = @precioAlquilerNuevo
		where idConcesion = @idConcesion;
		commit transaction;
		print 'La modificación de la Concesion se realizó exitosamente.';
	end try
	begin catch
		if @@TRANCOUNT > 0
			rollback transaction;
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

/*
================================================================
abm PagoConcesion
================================================================
*/

--Alta
create procedure PnSPabm.altaPagoConcesion
@idConcesion int,
@fecha date,
@metodo varchar(50),
@importe decimal(18,2),
@descripcion varchar(255)
as 
begin
	declare @msjError nvarchar(max) = '';
	declare @fechaFinConcesion date;

	if not exists (select idConcesion from PnTablas.Concesion where idConcesion = @idConcesion)
	begin
		set @msjError += 'La concesión indicada no existe. ';
	end
	else
	begin
		select @fechaFinConcesion = fechaFin from PnTablas.Concesion where idConcesion = @idConcesion;
		if @fechaFinConcesion < @fecha
			set @msjError += 'No se pueden registrar pagos para una concesión vencida. ';
	end

	if @importe <= 0 
		set @msjError += 'El importe del pago debe ser mayor a cero. ';

	if @msjError <> ''
		throw 50001, @msjError, 1;

	begin transaction
	begin try
		insert into PnTablas.PagoConcesion(idConcesion, fecha, metodo, importe, descripcion) values
		(@idConcesion, @fecha, @metodo, @importe, @descripcion);
		commit transaction;
		print 'El Pago de la Concesion se ha registrado exitosamente.';
	end try
	begin catch
		if @@TRANCOUNT > 0
			rollback transaction;
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Baja
create procedure PnSPabm.bajaPagoConcesion
@idPagoConcesion int
as
begin
	if not exists (select idPagoConcesion from PnTablas.PagoConcesion where idPagoConcesion = @idPagoConcesion)
		throw 50001, 'El idPagoConcesion es inválido.',1;

	begin transaction
	begin try
		delete from PnTablas.PagoConcesion
		where idPagoConcesion = @idPagoConcesion;
		commit transaction;
		print 'El Pago de Concesion eliminado exitosamente.';
	end try
	begin catch
		if @@TRANCOUNT > 0
			rollback transaction;
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Modificacion
create procedure PnSPabm.modificacionPagoConcesion
@idPagoConcesion int,
@idConcesionNueva int,
@fechaNueva date,
@metodoNuevo varchar(50),
@importeNuevo decimal(18,2),
@descripcionNueva varchar(255)
as
begin
	declare @msjError nvarchar(max) = '';

	if not exists (select idPagoConcesion from PnTablas.PagoConcesion where idPagoConcesion = @idPagoConcesion)
		set @msjError += 'El idPagoConcesion es inválido. ';
	if not exists (select idConcesion from PnTablas.Concesion where idConcesion = @idConcesionNueva)
		set @msjError += 'La nueva concesión indicada no existe. ';
	if @importeNuevo <= 0 
		set @msjError += 'El importe del pago debe ser mayor a cero. ';

	if @msjError <> ''
		throw 50001, @msjError, 1;
	
	begin transaction
	begin try
		update PnTablas.PagoConcesion
		set idConcesion = @idConcesionNueva,
			fecha = @fechaNueva,
			metodo = @metodoNuevo,
			importe = @importeNuevo,
			descripcion = @descripcionNueva
		where idPagoConcesion = @idPagoConcesion;
		commit transaction;
		print 'La modificación del Pago de Concesion se realizó exitosamente.';
	end try
	begin catch
		if @@TRANCOUNT > 0
			rollback transaction;
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go






















































