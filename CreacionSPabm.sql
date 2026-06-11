/*
11/06/2026
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


/*============================= Persona ==============================*/

--Alta
create procedure PnSPabm.altaPersona
    @dni int,
    @nombre char(20),
    @apellido char(20),
    @telefono char(11) = null
as
begin
    if exists (select 1 from PnTablas.Persona where dni = @dni)
        throw 50001, 'Ya existe persona con ese DNI.', 1;

    begin transaction
    begin try
        insert into PnTablas.Persona(dni, nombre, apellido, telefono)
        values (@dni, @nombre, @apellido, @telefono);
        commit transaction;
        print 'Persona registrada exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
            rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go

--Baja
create procedure PnSPabm.bajaPersona
    @idPersona int
as
begin
    if not exists (select 1 from PnTablas.Persona where idPersona = @idPersona)
        throw 50001, 'El idPersona es invalido.', 1;

    --Este SP solo borra si no hay dependencias.
    if exists (select 1 from PnTablas.GuardaParque where idPersona = @idPersona and estado = 'Activo')
        throw 50002, 'La persona tiene asignaciones de guardaparque activas, debe darlas de baja primero.', 1;

    begin transaction
    begin try
        delete from PnTablas.Persona where idPersona = @idPersona;
        commit transaction;
        print 'Persona eliminada exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
            rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go

--Modificacion
create procedure PnSPabm.modificacionPersona
    @idPersona int,
    @dniNuevo int = null,
    @nombreNuevo char(20) = null,
    @apellidoNuevo char(20) = null,
    @telefonoNuevo char(11) = null
as
begin
    if not exists (select 1 from PnTablas.Persona where idPersona = @idPersona)
        throw 50001, 'El idPersona es invalido.', 1;

    if @dniNuevo is not null and exists (
        select 1 from PnTablas.Persona where dni = @dniNuevo and idPersona != @idPersona
    )
        throw 50002, 'El dni nuevo ya lo tiene otra persona.', 1;

    begin transaction
    begin try
        update PnTablas.Persona
        set
            dni = isnull(@dniNuevo, dni),
            nombre = isnull(@nombreNuevo, nombre),
            apellido = isnull(@apellidoNuevo, apellido),
            telefono = isnull(@telefonoNuevo, telefono)
        where idPersona = @idPersona;
        commit transaction;
        print 'Persona modificada exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
            rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go

/*=========================== Guardaparque ============================*/

--Alta
create procedure PnSPabm.altaGuardaParque
    @idPersona int,
    @idParque int,
    @fechaInicio date = null
as
begin
    if not exists (select 1 from PnTablas.Persona where idPersona = @idPersona)
        throw 50001, 'El idPersona es invalido.', 1;

    if not exists (select 1 from PnTablas.Parque where idParque = @idParque)
        throw 50002, 'El idParque es invalido.', 1;

    -- No puede haber dos asignaciones activas para la misma persona en el mismo parque
    if exists (
        select 1 from PnTablas.GuardaParque
        where idPersona = @idPersona and idParque = @idParque and estado = 'Activo'
    )
        throw 50003, 'Esa persona ya es guardaparque activo en ese parque.', 1;

    set @fechaInicio = isnull(@fechaInicio, cast(getdate() as date));

    begin transaction
    begin try
        insert into PnTablas.GuardaParque(idPersona, idParque, fechaInicio, estado)
        values (@idPersona, @idParque, @fechaInicio, 'Activo');
        commit transaction;
        print 'GuardaParque registrado exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
            rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go

--Baja
create procedure PnSPabm.bajaGuardaParque
    @idPersona int,
    @idParque int,
    @fechaInicio date,
    @fechaEgreso date = null,
    @razonEgreso varchar(200) = null
as
begin
    if not exists (
        select 1 from PnTablas.GuardaParque
        where idPersona = @idPersona and idParque = @idParque and fechaInicio = @fechaInicio
    )
        throw 50001, 'No existe esa asignacion de GuardaParque.', 1;

    if exists (
        select 1 from PnTablas.GuardaParque
        where idPersona = @idPersona and idParque = @idParque and fechaInicio = @fechaInicio and estado = 'Inactivo'
    )
        throw 50002, 'Esa asignacion ya esta inactiva.', 1;

    set @fechaEgreso = isnull(@fechaEgreso, cast(getdate() as date));

    if @fechaEgreso < @fechaInicio
        throw 50003, 'La fecha de egreso no puede ser anterior a la fecha de inicio.', 1;

    begin transaction
    begin try
        --pasa a inactivo y se registra en historial
        update PnTablas.GuardaParque
        set estado = 'Inactivo'
        where idPersona = @idPersona and idParque = @idParque and fechaInicio = @fechaInicio;

        if not exists (
            select 1 from PnTablas.Historial
            where idPersona = @idPersona and idParque = @idParque and fechaInicio = @fechaInicio
        )
            insert into PnTablas.Historial(idPersona, idParque, fechaInicio, fechaEgreso, razonEgreso)
            values (@idPersona, @idParque, @fechaInicio, @fechaEgreso, @razonEgreso);
        else
            update PnTablas.Historial
            set fechaEgreso = @fechaEgreso, razonEgreso = @razonEgreso
            where idPersona = @idPersona and idParque = @idParque and fechaInicio = @fechaInicio;

        commit transaction;
        print 'Guardaparque dado de baja, historial actualizado exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
            rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go

--Reasignacion
create procedure PnSPabm.reasignarGuardaParque
    @idPersona int,
    @idParqueActual int,
    @fechaInicio date,
    @idParqueNuevo int,
    @razonEgreso varchar(200) = null,
    @fechaReasignacion date = null
as
begin
    if not exists (
        select 1 from PnTablas.GuardaParque
        where idPersona = @idPersona and idParque = @idParqueActual and fechaInicio = @fechaInicio and estado = 'Activo'
    )
        throw 50001, 'No existe asignacion activa para esa persona en el parque con esa fecha de inicio.', 1;

    if not exists (select 1 from PnTablas.Parque where idParque = @idParqueNuevo)
        throw 50002, 'El idParque nuevo es invalido.', 1;

    set @fechaReasignacion = isnull(@fechaReasignacion, cast(getdate() as date));

    begin transaction
    begin try
        --da de baja en actual y alta en nuevo
        exec PnSPabm.bajaGuardaParque
            @idPersona = @idPersona,
            @idParque = @idParqueActual,
            @fechaInicio = @fechaInicio,
            @fechaEgreso = @fechaReasignacion,
            @razonEgreso = isnull(@razonEgreso, 'Reasignacion');

        exec PnSPabm.altaGuardaParque
            @idPersona = @idPersona,
            @idParque = @idParqueNuevo,
            @fechaInicio = @fechaReasignacion;

        commit transaction;
        print 'Reasignacion de Guardaparque realizada exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
            rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go

/*=============================== Guia ================================*/

--Alta
create procedure PnSPabm.altaGuia
    @idPersona int,
    @titulo varchar(100) = null,
    @vencimientoHabilitacion date,
    @numeroHabilitacion int
as
begin
    if not exists (select 1 from PnTablas.Persona where idPersona = @idPersona)
        throw 50001, 'El idPersona es invalido, registre primero a la persona.', 1;

    if exists (select 1 from PnTablas.Guia where idPersona = @idPersona)
        throw 50002, 'Esa persona ya esta registrada como guia.', 1;

    if @vencimientoHabilitacion < cast(getdate() as date)
        throw 50003, 'La habilitacion ya esta vencida.', 1;

    begin transaction
    begin try
        insert into PnTablas.Guia(idPersona, titulo, vencimientoHabilitacion, numeroHabilitacion)
        values (@idPersona, @titulo, @vencimientoHabilitacion, @numeroHabilitacion);
        commit transaction;
        print 'Guia registrado exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
            rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go

--Baja
create procedure PnSPabm.bajaGuia
    @idPersona int
as
begin
    if not exists (select 1 from PnTablas.Guia where idPersona = @idPersona)
        throw 50001, 'El idPersona no es de ningun guia registrado.', 1;

    if exists (select 1 from PnTablas.Actividad where idPersona = @idPersona)
        throw 50002, 'El guia tiene actividades asignadas. Reasigne o elimine las actividades antes de eliminar.', 1;

    begin transaction
    begin try
        --elimino especialidades asociadas primero
        delete from PnTablas.GuiaEspecialidad where idPersona = @idPersona;
        delete from PnTablas.Guia where idPersona = @idPersona;
        commit transaction;
        print 'Guia eliminado exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
            rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go

--Modificacion
create procedure PnSPabm.modificacionGuia
    @idPersona                   int,
    @tituloNuevo                 varchar(100) = null,
    @vencimientoHabilitacionNuevo date        = null,
    @numeroHabilitacionNuevo     int          = null
as
begin
    if not exists (select 1 from PnTablas.Guia where idPersona = @idPersona)
        throw 50001, 'El idPersona no corresponde a ningun guia registrado.', 1;

    begin transaction
    begin try
        update PnTablas.Guia
        set
            titulo = isnull(@tituloNuevo, titulo),
            vencimientoHabilitacion = isnull(@vencimientoHabilitacionNuevo, vencimientoHabilitacion),
            numeroHabilitacion = isnull(@numeroHabilitacionNuevo, numeroHabilitacion)
        where idPersona = @idPersona;
        commit transaction;
        print 'Guia modificado exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
            rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go

/*=========================== Especialidad ============================*/

--Alta
create procedure PnSPabm.altaEspecialidad
    @descripcion varchar(100)
as
begin
    if exists (select 1 from PnTablas.Especialidad where descripcion = @descripcion)
        throw 50001, 'Ya existe una especialidad con esa descripcion.', 1;

    begin transaction
    begin try
        insert into PnTablas.Especialidad(descripcion) values (@descripcion);
        commit transaction;
        print 'Especialidad registrada exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
            rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go

--Baja
create procedure PnSPabm.bajaEspecialidad
    @idEspecialidad int
as
begin
    if not exists (select 1 from PnTablas.Especialidad where idEspecialidad = @idEspecialidad)
        throw 50001, 'El idEspecialidad es invalido.', 1;

    if exists (select 1 from PnTablas.GuiaEspecialidad where idEspecialidad = @idEspecialidad)
        throw 50002, 'Hay guias con esa especialidad asignada. Quite la asignacion primero.', 1;

    begin transaction
    begin try
        delete from PnTablas.Especialidad where idEspecialidad = @idEspecialidad;
        commit transaction;
        print 'Especialidad eliminada exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
            rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go

--Modificacion
create procedure PnSPabm.modificacionEspecialidad
    @idEspecialidad    int,
    @descripcionNueva  varchar(100)
as
begin
    if not exists (select 1 from PnTablas.Especialidad where idEspecialidad = @idEspecialidad)
        throw 50001, 'El idEspecialidad es invalido.', 1;

    if exists (select 1 from PnTablas.Especialidad where descripcion = @descripcionNueva and idEspecialidad != @idEspecialidad)
        throw 50002, 'Ya existe otra especialidad con esa descripcion.', 1;

    begin transaction
    begin try
        update PnTablas.Especialidad
        set descripcion = @descripcionNueva
        where idEspecialidad = @idEspecialidad;
        commit transaction;
        print 'Especialidad modificada exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
            rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go

/*========================= Guia Especialidad ==========================*/

--Alta
create procedure PnSPabm.altaGuiaEspecialidad
    @idPersona      int,
    @idEspecialidad int
as
begin
    if not exists (select 1 from PnTablas.Guia where idPersona = @idPersona)
        throw 50001, 'El idPersona no pertenece a ningun guia registrado.', 1;

    if not exists (select 1 from PnTablas.Especialidad where idEspecialidad = @idEspecialidad)
        throw 50002, 'El idEspecialidad es invalido.', 1;

    if exists (
        select 1 from PnTablas.GuiaEspecialidad
        where idPersona = @idPersona and idEspecialidad = @idEspecialidad
    )
        throw 50003, 'El guia ya tiene esa especialidad asignada.', 1;

    begin transaction
    begin try
        --asigna especialidad a guia
        insert into PnTablas.GuiaEspecialidad(idPersona, idEspecialidad)
        values (@idPersona, @idEspecialidad);
        commit transaction;
        print 'Especialidad asignada al guia exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
            rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go

--Baja
create procedure PnSPabm.bajaGuiaEspecialidad
    @idPersona      int,
    @idEspecialidad int
as
begin
    if not exists (
        select 1 from PnTablas.GuiaEspecialidad
        where idPersona = @idPersona and idEspecialidad = @idEspecialidad
    )
        throw 50001, 'Esa asignacion de especialidad no existe.', 1;

    begin transaction
    begin try
        --quita especialidad a guia
        delete from PnTablas.GuiaEspecialidad
        where idPersona = @idPersona and idEspecialidad = @idEspecialidad;
        commit transaction;
        print 'Especialidad quitada al guia exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
            rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go

--Modificacion (equivale a una baja y un alta)
create procedure PnSPabm.modificacionGuiaEspecialidad
    @idPersona int,
    @idEspecialidadActual int,
    @idEspecialidadNueva int
as
begin
    if not exists (
        select 1 from PnTablas.GuiaEspecialidad
        where idPersona = @idPersona and idEspecialidad = @idEspecialidadActual
    )
        throw 50001, 'Esa asignacion de especialidad no existe.', 1;

    if not exists (select 1 from PnTablas.Especialidad where idEspecialidad = @idEspecialidadNueva)
        throw 50002, 'El idEspecialidad nuevo es invalido.', 1;

    if exists (
        select 1 from PnTablas.GuiaEspecialidad
        where idPersona = @idPersona and idEspecialidad = @idEspecialidadNueva
    )
        throw 50003, 'El guia ya tiene la especialidad nueva asignada.', 1;

    begin transaction
    begin try
        update PnTablas.GuiaEspecialidad
        set idEspecialidad = @idEspecialidadNueva
        where idPersona = @idPersona and idEspecialidad = @idEspecialidadActual;
        commit transaction;
        print 'Especialidad del guia modificada exitosamente.';
    end try
    begin catch
        if @@TRANCOUNT > 0 
        	rollback transaction;

        declare @msj nvarchar(200) = error_message();
        declare @num int = error_number();
        print concat('ERROR (', @num, '): ', @msj);
        throw;
    end catch
end
go





















































