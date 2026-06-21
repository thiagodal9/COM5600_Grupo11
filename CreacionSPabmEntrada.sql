/*
08/06/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

En este script se realiza la creacion de Stored Procedures para los ABM de Entrada
*/

/*
----Tablas Principales: TipoEntrada, Entrada
*/

use ParquesNacionales
go


/*
================================================================
abm TipoEntrada
================================================================
*/

--Alta
create procedure PnSPabm.altaTipoEntrada
@IDTipoEntrada int,
@DescripcionTipoEntrada char(20)
as 
begin
	
	begin transaction
	begin try
		insert into PnTablas.TipoEntrada(DescripcionTipoEntrada) values
		(@DescripcionTipoEntrada);
		commit transaction;
		print 'Tipo de entrada registrado con exito';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Baja
create procedure PnSPabm.bajaTipoEntrada
@idTipoEntrada int
as
begin
	if not exists (select idTipoEntrada from PnTablas.TipoEntrada where idTipoEntrada = @idTipoEntrada)
		throw 50001, 'El idTipoEntrada es inválido.',1;

	begin transaction
	begin try
		delete from PnTablas.TipoEntrada
		where idTipoEntrada = @idTipoEntrada;
		commit transaction;
		print 'Tipo de Entrada eliminada exitosamente.';
	end try
	begin catch
		declare @msj nvarchar(100) = error_message();
		declare @numError int = error_number();
		print concat('ERROR (', @numError,')',@msj);
	end catch
end
go

--Modificacion
create procedure PnSPabm.modificacionTipoEntrada
@idTipoEntrada int,
@descripcionNueva varchar
as
begin
	if not exists (select idTipoEntrada from PnTablas.TipoEntrada where idTipoEntrada = @idTipoEntrada)
		throw 5001, 'El idTipoEntrada es inválido.',1;
		
	begin transaction
	begin try
		update PnTablas.TipoEntrada
		set descripcion = @descripcionNueva
		where idTipoEntrada = @idTipoEntrada;
		commit transaction;
		print 'La modificación del tipo de entrada se realizó exitosamente.';
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
@idTipoEntrada int,
@precio decimal(10,2),
@parque int
as 
begin
	if not exists  (select idTipoEntrada from PnTablas.TipoEntrada where idTipoEntrada = @idTipoEntrada)
		throw 50001, 'El idTipoEntrada es inválido.',1;

	if not exists  (select idParque from PnTablas.Parque where idParque = @parque)
		throw 50001, 'El Parque es inválido.',1;

	begin transaction
	begin try
		insert into PnTablas.Entrada(idTipoEntrada, precio, parque) values
		(@idTipoEntrada, @precio, @parque);
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
@idTipoEntradaNuevo int,
@precioNueva decimal(10,2),
@descripcionNueva varchar,
@parqueNuevo int
as
begin
	if not exists (select idEntrada from PnTablas.Entrada where idEntrada = @idEntrada)
		throw 5001, 'El idEntrada es inválido.',1;
	
	else if not exists (select idTipoEntrada from PnTablas.TipoEntrada where idTipoEntrada = @idTipoEntrada)
		throw 50002, 'El idVenta es inválido.', 1;

	else if not exists (select idParque from PnTablas.Parque where idParque = @idParque)
		throw 50002, 'El idParque es inválido.', 1;
	
	begin transaction
	begin try
		update PnTablas.Entrada
		set idTipoEntrada = @idTipoEntradaNuevo,
			precio = @precioNueva,
			descripcion = @descripcionNueva,
			Parque = @ParqueNueva
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




















