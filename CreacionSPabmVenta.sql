/*
08/06/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

En este script se realiza la creacion de Stored Procedures para los ABM de Venta
*/

/*
Tablas Principales: PagoVenta, PagoPoseeEntrada, VentaTieneHorarioParque
Tablas intermedias: #ventaEntrada, #ventaActividad
*/

use ParquesNacionales
go



/*
================================================================
abm PagoVenta
================================================================
*/

--Alta
create procedure PnSPabm.altaPagoVenta
@idPagoVenta int,
@importe decimal(10,2),
@fechaPago date,
@item char(30),
@metodo char(30),
@venta int
as
begin
	begin transaction
	begin try
		insert into PnTablas.PagoVenta(idPAgoVenta, importe, fechaPago, item, metodo, venta) values
		(@idPAgoVenta, @importe, @fechaPago, @item, @metodo, @venta)
		commit transaction;
		print 'El pago de la venta se ha registrado exitosamente.';
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
@idPagoVenta int
as
begin
	if not exists (select idPagoVenta from PnTablas.PagoVenta where idPagoVenta = @idPagoVenta)
		throw 50001, 'El idPagoVenta es inválido.',1; 	
	begin transaction
	begin try
		delete from PnTablas.PagoVenta 
		where idPagoVenta = @idPagoVenta;
		commit transaction
		print 'El registro del pago de la venta se ha eliminado exitósamente.';
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
@idPagoVenta int,
@importeNuevo decimal(10,2),
@fechaPagoNuevo date,
@itemNuevo char(30),
@metodoNuevo char(30),
@ventaNuevo int
as
begin
	if not exists (select idPagoVenta from PnTablas.PagoVenta where idPagoVenta = @idPagoVenta)
		throw 50001, 'El idPagoVenta es inválido.',1; 

	begin transaction
	begin try
		update PnTablas.PagoVenta
		set importe = @importeNuevo,
			fechaPago = @fechaPagoNuevo,
			item = @itemNuevo,
			metodo = @metodoNuevo,
			venta = @VentaNuevo
		where idPagoVenta = @idPagoVenta;
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
abm #ventaEntrada
================================================================
*/

--Alta
create procedure PnSPabm.altaVentaEntrada
@Entrada INT,
@Cantidad INT
as
begin
	begin transaction
	begin try
		insert #ventaEntrada(Entrada, Cantidad) values
		(@Entrada, @Cantidad)
		commit transaction;
		print 'La venta de la entrada se ha registrado exitosamente.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Baja
create procedure PnSPabm.bajaVentaEntrada
@IDvEntrada int
as
begin
	if not exists (select IDvEntrada from #ventaEntrada where IDvEntrada = @IDvEntrada)
		throw 50001, 'El IDvEntrada es inválido.',1; 	
	begin transaction
	begin try
		delete from #ventaEntrada
		where IDvEntrada = @IDvEntrada;
		commit transaction
		print 'La venta de la entrada se ha eliminado exitósamente.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Modificacion
create procedure PnSPabm.modificacionVentaEntrada
@IDvEntrada INT,
@EntradaNuevo INT,
@CantidadNuevo INT
as
begin
	if not exists (select IDvEntrada from #ventaEntrada where IDvEntrada = @IDvEntrada)
		throw 50001, 'El IDvEntrada es inválido.',1; 
	if not exists (select idEntrada from PnTablas.Entrada where idEntrada = @idEntrada)
		throw 50001, 'El idEntrada es inválido.',1; 

	begin transaction
	begin try
		update #ventaEntrada
		set Entrada = @EntradaNuevo,
		Cantidad = @CantidadNuevo
		where IDvEntrada = @IDvEntrada;
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
abm #ventaActividad
================================================================
*/

--Alta
create procedure PnSPabm.altaVentaActividad
@Actividad INT,
@FechaActividad DATE,
@Cantidad INT
as
begin
	begin transaction
	begin try
		insert #ventaActividad(Actividad, FechaActividad, Cantidad) values
		(@Actividad, @FechaActividad, @Cantidad)
		commit transaction;
		print 'La venta de la actividad se ha registrado exitosamente.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Baja
create procedure PnSPabm.bajaVentaActividad
@IdvActividad int
as
begin
	if not exists (select IdvActividad from #ventaActividad where IdvActividad = @IdvActividad)
		throw 50001, 'El IdvActividad es inválido.',1; 	
	begin transaction
	begin try
		delete from #ventaActividad
		where IdvActividad = @IdvActividad;
		commit transaction
		print 'La venta de la actividad se ha eliminado exitósamente.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Modificacion
create procedure PnSPabm.modificacionVentaActividad
@IdvActividad INT,
@EntradaNuevo INT,
@CantidadNuevo INT
as
begin
	if not exists (select IDvEntrada from #ventaEntrada where IDvEntrada = @IDvEntrada)
		throw 50001, 'El IDvEntrada es inválido.',1; 
	if not exists (select idEntrada from PnTablas.Entrada where idEntrada = @idEntrada)
		throw 50001, 'El idEntrada es inválido.',1; 

	begin transaction
	begin try
		update #ventaEntrada
		set Entrada = @EntradaNuevo,
		Cantidad = @CantidadNuevo
		where IDvEntrada = @IDvEntrada;
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
abm PagoPoseeEntrada
================================================================
*/

--Alta
create procedure PnSPabm.altaPagoPoseeEntrada
@PagoVenta INT,
@Entrada INT,
@FechaAcceso DATE,
@Cantidad INT
as
begin
if not exists (select idEntrada from PnTablas.Entrada where idEntrada = @Entrada)
	throw 50001, 'El idEntrada es inválido', 1;

if not exists (select idPago from PnTablas.PagoVenta where idPagoVenta = @PagoVenta)
	throw 50001, 'El idEntrada es inválido', 1;


	begin transaction
	begin try
		insert into PnTablas.PagoPoseeEntrada(Pago, Entrada, FechaAcceso, Cantidad) values
		(@Pago, @Entrada, @FechaAcceso, @Cantidad)
		commit transaction;
		print 'El registro se ha creado exitosamente.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Baja
create procedure PnSPabm.bajaPagoPoseeEntrada
@idPagoVenta int,
@idEntrada int
as
begin
	if not exists (select idPagoVenta from PnTablas.PagoVenta where idPagoVenta = @idPagoVenta)
		throw 50001, 'El idPagoVenta es inválido.',1; 	
	if not exists (select idEntrada from PnTablas.Entrada where idEntrada = @idEntrada)
		throw 50001, 'El idEntrada es inválido.',1; 	

	begin transaction
	begin try
		delete from PnTablas.PagoPoseeEntrada
		where idPagoVenta = @idPagoVenta AND
		idEntrada = @idEntrada;
		commit transaction
		print 'El registro se ha eliminado exitósamente.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Modificacion
create procedure PnSPabm.modificacionPagoPoseeEntrada
@idPagoVenta int,
@idEntrada int,
@FechaAccesoNuevo date,
@CantidadNuevo int
as
begin
	if not exists (select idPagoVenta from PnTablas.PagoVenta where idPagoVenta = @idPagoVenta)
		throw 50001, 'El idPagoVenta es inválido.',1; 
	if not exists (select idEntrada from PnTablas.Entrada where idEntrada = @idEntrada)
		throw 50001, 'El idEntrada es inválido.',1; 

	begin transaction
	begin try
		update PnTablas.PagoPoseeEntrada
		set FechaAcceso = @FechaAccesoNuevo,
		Cantidad = @CantidadNuevo
		where idPagoVenta = @idPagoVenta AND idEntrada = @idEntrada;
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
abm PagoVentaTieneHorarioActividad
================================================================
*/

--Alta
create procedure PnSPabm.altaPagoVentaTieneHorarioActividad
@idPagoVenta INT,
@idActividad INT,
@FechaActividad DATE,
@Cantidad INT,
as
begin
if not exists (select idPagoVenta from PnTablas.PagoVenta where idPagoVenta = @idPagoVenta)
	throw 50001, 'El idPagoVenta es inválido', 1;

if not exists (select idActividad from PnTablas.Actividad where idActividad = @idActividad)
	throw 50001, 'El idActividad es inválido', 1;

if not exists (select FechaActividad from PnTablas.HorarioActividad where FechaActividad = @FechaActividad)
	throw 50001, 'La FechaActividad es inválido', 1;


	begin transaction
	begin try
		insert into PnTablas.PagoVentaTieneHorarioActividad(idPagoVenta, idActividad, FechaActividad, Cantidad) values
		(@idPagoVenta, @idActividad, @FechaActividad, @Cantidad)
		commit transaction;
		print 'El registro se ha creado exitosamente.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go


--Baja
create procedure PnSPabm.bajaPagoVentaTieneHorarioActividad
@idPagoVenta INT,
@idActividad INT,
@FechaActividad DATE
as
begin
	if not exists (select idPagoVenta from PnTablas.PagoVenta where idPagoVenta = @idPagoVenta)
		throw 50001, 'El idPagoVenta es inválido.',1; 	
	if not exists (select idEntrada from PnTablas.Entrada where idEntrada = @idEntrada)
		throw 50001, 'El idEntrada es inválido.',1; 
	if not exists (select FechaActividad from PnTablas.HorarioActividad where FechaActividad = @FechaActividad)
		throw 50001, 'La fecha de la actividad es inválido.',1; 	


	begin transaction
	begin try
		delete from PnTablas.PagoVentaTieneHorarioActividad
		where idPagoVenta = @idPagoVenta AND idEntrada = @idEntrada AND FechaActividad = @FechaActividad;
		commit transaction
		print 'El registro se ha eliminado exitósamente.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Modificacion
create procedure PnSPabm.modificacionPagoVentaTieneHorarioActividad
@idPagoVenta INT,
@idActividad INT,
@FechaActividad DATE,
@CantidadNuevo int
as
begin
	if not exists (select idPagoVenta from PnTablas.PagoVenta where idPagoVenta = @idPagoVenta)
		throw 50001, 'El idPagoVenta es inválido.',1; 	
	if not exists (select idEntrada from PnTablas.Entrada where idEntrada = @idEntrada)
		throw 50001, 'El idEntrada es inválido.',1; 
	if not exists (select FechaActividad from PnTablas.HorarioActividad where FechaActividad = @FechaActividad)
		throw 50001, 'La fecha de la actividad es inválido.',1; 

	begin transaction
	begin try
		update PnTablas.PagoVentaTieneHorarioActividad
		set FechaAcceso = @FechaAccesoNuevo,
		Cantidad = @CantidadNuevo
		where idPagoVenta = @idPagoVenta AND idEntrada = @idEntrada;
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



