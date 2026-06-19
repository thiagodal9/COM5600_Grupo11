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

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

PRINT '--Creando SPabm para tablas Persona...--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

--altaPersona
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaPersona'))
    DROP PROCEDURE PnSPabm.altaPersona
GO;
create procedure PnSPabm.altaPersona
@dni int,
@nombre varchar(20),
@apellido varchar(20),
@telefono char(12),
@rol varchar(10)
as
begin
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidezDatos
    IF ( (@dni <= 0) OR (99999999 < @dni) )
    BEGIN
        SET @errorCount = @errorCount + 1
	    SET @errorLine = @errorLine + CHAR(13) + '- Numero de DNI invalido.'
    END

    IF ( (@rol NOT LIKE 'Guardaparque') OR (@rol NOT LIKE 'Guia') )
    BEGIN
        SET @errorCount = @errorCount + 1
	    SET @errorLine = @errorLine + CHAR(13) + '- Rol invalido.'
    END

    --controlDuplicidad
    if ( (@errorCount = 0) AND exists(select 1 from PnTablas.Persona where dni = @dni) )
    BEGIN
	    SET @errorCount = @errorCount + 1
	    SET @errorLine = @errorLine + CHAR(13) + '- Persona ya presente.'
    END

    IF(@errorCount = 0)
    BEGIN
        insert into PnTablas.Persona(dni, NombrePersona, apellido, telefono, rol)
        values (@dni, @nombre, @apellido, @telefono, @rol);
    END
    ELSE
        PRINT @errorLine
end;
GO
PRINT '--Creado SP: altaPersona--';
GO

--modificacionPersona
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionPersona'))
    DROP PROCEDURE PnSPabm.modificacionPersona
GO;
create procedure PnSPabm.modificacionPersona
@IDPersona int,
@dniNuevo int = NULL,
@nombreNuevo varchar(20) = NULL,
@apellidoNuevo varchar(20) = NULL,
@telefonoNuevo varchar(12) = NULL,
@rolNuevo varchar(10) = NULL
as
begin
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidezDatos
    if ( (@rolNuevo IS NOT NULL) AND ( (@dniNuevo <= 0) OR (99999999 < @dniNuevo) ) )
    BEGIN
        SET @errorCount = @errorCount + 1
	    SET @errorLine = @errorLine + CHAR(13) + '- Numero de DNI invalido.'
    END

    if ( (@rolNuevo IS NOT NULL) AND ( (@rolNuevo NOT LIKE 'Guardaparque') OR (@rolNuevo NOT LIKE 'Guia') ) )
    BEGIN
        SET @errorCount = @errorCount + 1
	    SET @errorLine = @errorLine + CHAR(13) + '- Rol invalido.'
    END

    --controlExistencia
    if ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Persona WHERE IDPersona = @IDPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- La persona no existe.'
    END

    --controlDuplicidad
    if ( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Persona WHERE DNI = @dniNuevo) )
    BEGIN
        SET @errorCount = @errorCount + 1
	    SET @errorLine = @errorLine + CHAR(13) + '- Numero de DNI en uso por otra persona.'
    END

    --controlReferencias
    if (@errorCount = 0)
    BEGIN
        IF( (@rolNuevo IS NOT NULL) AND
        (( (@rolNuevo LIKE 'Guia') AND EXISTS(SELECT 1 FROM PnTablas.Guardaparque WHERE IDGuardaParque = @IDPersona) )
        OR
        ( (@rolNuevo LIKE 'Guardaparque') AND EXISTS(SELECT 1 FROM PnTablas.Guia WHERE IDGuia = @IDPersona) )))
        BEGIN
            SET @errorCount = @errorCount + 1
	        SET @errorLine = @errorLine + CHAR(13) + '- Persona activa en un rol diferente. Primero elimine el rol.'
        END
    END

    IF(@errorCount = 0)
    BEGIN
        update PnTablas.Persona
        set
        dni = isnull(@dniNuevo, dni),
        NombrePersona = isnull(@nombreNuevo, NombrePersona),
        apellido = isnull(@apellidoNuevo, apellido),
        telefono = isnull(@telefonoNuevo, telefono),
        rol = isnull(@rolNuevo, rol)
        where idPersona = @IDPersona;
    END
    ELSE
        PRINT @errorLine
end;
go
PRINT '--Creado SP: modificacionPersona--';
GO

--Baja
--Este SP solo borra si no hay dependencias.
--De haberlas, primero se pide quitar las dependencias con los SP correspondientes.
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaPersona'))
    DROP PROCEDURE PnSPabm.bajaPersona
GO;
create procedure PnSPabm.bajaPersona
@IDPersona int,
@razon varchar(40)
as
begin
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlExistencia
    if ( NOT EXISTS(SELECT 1 FROM PnTablas.Persona WHERE IDPersona = @IDPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- La persona no existe.'
    END

    --controlReferencias
    IF (@errorCount = 0)
    BEGIN
        IF ( EXISTS(select 1 from PnTablas.GuardaParque where IDGuardaParque = @idPersona and estado = 'Activo') )
        BEGIN
            SET @errorCount = @errorCount + 1
	        SET @errorLine = @errorLine + CHAR(13) + '- La persona tiene asignaciones de guardaparque activas, debe darlas de baja primero.'
        END

        IF ( EXISTS(select 1 from PnTablas.Actividad where Guia = @idPersona) )
        BEGIN
            SET @errorCount = @errorCount + 1
	        SET @errorLine = @errorLine + CHAR(13) + '- La persona tiene asignaciones de guia activas, debe darlas de baja primero.'
        END
    END
    
    IF(@errorCount = 0)
    BEGIN
        --sp bajarGuia

        EXECUTE bajaGuardaparque @IDPersona = @IDPersona, @razon = @razon

        delete from PnTablas.Persona 
        where idPersona = @idPersona
    END
    ELSE
        PRINT @errorLine
end;
go
PRINT '--Creado SP: bajaPersona--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

--altaGuardaParque
--Solo registra al guardaparques, no asigna. Ingresa como inactivo.
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaGuardaParque'))
    DROP PROCEDURE PnSPabm.altaGuardaParque
GO;
create procedure PnSPabm.altaGuardaParque
@IDPersona INT
as
begin
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlExistencia
    if ( NOT EXISTS(SELECT 1 FROM PnTablas.Persona WHERE IDPersona = @IDPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- La persona no existe.'
    END

    --controlReferencias
    if ( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Persona WHERE IDPersona = @IDPersona AND Rol NOT LIKE 'Guardaparque') )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- La persona tiene un rol diferente asignado.'
    END

    --controlDuplicidad
    if ( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Guardaparque WHERE IDGuardaparque = @IDPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Guardaparque ya presente.'
    END

    IF(@errorCount = 0)
    BEGIN
        insert into PnTablas.Guardaparque(IDGuardaParque, Estado)
        values (@IDPersona, 'Inactivo');
    END
    ELSE
        PRINT @errorLine
end;
go
PRINT '--Creado SP: altaGuardaParque--';
GO

--asignarGuardaparque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.asignarGuardaparque'))
    DROP PROCEDURE PnSPabm.asignarGuardaparque
GO;
CREATE PROCEDURE PnSPtrans.asignarGuardaparque (@IDPersona INT, @Parque varchar(30))
AS
BEGIN
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlExistencia
    IF( NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @Parque) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
    END

    IF( NOT EXISTS(SELECT 1 FROM PnTablas.Guardaparque WHERE IDGuardaparque = @IDPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Guardaparque inexistente.'
    END

    IF(@errorCount <> 0)
        PRINT @errorLine
    ELSE
    BEGIN
        BEGIN TRANSACTION
        BEGIN TRY
            IF( EXISTS(SELECT 1 FROM PnTablas.Guardaparque WHERE IDGuardaparque = @IDPersona AND Estado = 'Activo') )
                THROW 50000, '-Guardaparque ya activo en un parque.', 1
        
            UPDATE PnTablas.Guardaparque
            SET Estado = 'Activo', Parque = @Parque, FechaInicio = GETDATE()
            WHERE IDGuardaparque = @IDPersona

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
            DECLARE @Num INT           = ERROR_NUMBER();
            PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        END CATCH
    END
END;
GO
PRINT '--Creado SP: asignarGuardaparque--';
GO

--reasignarGuardaparque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.reasignarGuardaparque'))
    DROP PROCEDURE PnSPabm.reasignarGuardaparque
GO;
CREATE PROCEDURE PnSPtrans.reasignarGuardaparque (@IDPersona INT, @Parque INT, @razon varchar(40))
AS
BEGIN
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)
    DECLARE @fechaIni DATE
    DECLARE @fechaFin DATE

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlExistencia
    IF( NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @Parque) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
    END

    IF( NOT EXISTS(SELECT 1 FROM PnTablas.Guardaparque WHERE IDGuardaparque = @IDPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Guardaparque inexistente.'
    END

    IF(@errorCount <> 0)
        PRINT @errorLine
    ELSE
    BEGIN
        BEGIN TRANSACTION
        BEGIN TRY
            IF( EXISTS(SELECT 1 FROM PnTablas.Guardaparque WHERE IDGuardaparque = @IDPersona AND Parque = @Parque) )
                THROW 50000, '-Guardaparque ya activo en este parque.', 1
        
            SET @fechaIni = (SELECT FechaInicio FROM PnTablas.GuardaParque WHERE IDGuardaParque = @IDPersona)
            SET @fechaFin = GETDATE()

            EXECUTE PnSPabm.altaHistorial 
            @Guardaparque = @IDPersona, 
            @parque = @Parque, 
            @fechaIni = @fechaIni,
            @fechaFin = @fechaFin,
            @razon = @razon

            UPDATE PnTablas.Guardaparque
            SET Parque = @Parque, FechaInicio = GETDATE()
            WHERE IDGuardaparque = @IDPersona

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
            DECLARE @Num INT           = ERROR_NUMBER();
            PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        END CATCH
    END
END;
GO
PRINT '--Creado SP: reasignarGuardaparque--';
GO

--desasignarGuardaparque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.desasignarGuardaparque'))
    DROP PROCEDURE PnSPabm.desasignarGuardaparque
GO;
CREATE PROCEDURE PnSPtrans.desasignarGuardaparque (@IDPersona INT, @Parque INT, @razon varchar(40))
AS
BEGIN
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)
    DECLARE @fechaIni DATE
    DECLARE @fechaFin DATE

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlExistencia
    IF( NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @Parque) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
    END

    IF( NOT EXISTS(SELECT 1 FROM PnTablas.Guardaparque WHERE IDGuardaparque = @IDPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Guardaparque inexistente.'
    END

    IF(@errorCount <> 0)
        PRINT @errorLine
    ELSE
    BEGIN
        BEGIN TRANSACTION
        BEGIN TRY
            IF( EXISTS(SELECT 1 FROM PnTablas.Guardaparque WHERE IDGuardaparque = @IDPersona AND Estado = 'Activo') )
                THROW 50001, '-Guardaparque no activo.', 1

            IF( EXISTS(SELECT 1 FROM PnTablas.Guardaparque WHERE IDGuardaparque = @IDPersona AND Parque = @Parque) )
                THROW 50002, '-Guardaparque no asignado a ese parque.', 1
        
            SET @fechaIni = (SELECT FechaInicio FROM PnTablas.GuardaParque WHERE IDGuardaParque = @IDPersona)
            SET @fechaFin = GETDATE()

            EXECUTE PnSPabm.altaHistorial 
            @Guardaparque = @IDPersona, 
            @parque = @Parque, 
            @fechaIni = @fechaIni,
            @fechaFin = @fechaFin,
            @razon = @razon

            UPDATE PnTablas.Guardaparque
            SET Estado = 'Inactivo', Parque = NULL
            WHERE IDGuardaparque = @IDPersona

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
            DECLARE @Num INT           = ERROR_NUMBER();
            PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        END CATCH
    END
END;
GO
PRINT '--Creado SP: desasignarGuardaparque--';
GO

--bajaGuardaparque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaGuardaparque'))
    DROP PROCEDURE PnSPabm.bajaGuardaparque
GO;
CREATE PROCEDURE PnSPtrans.bajaGuardaparque (@IDPersona INT, @razon varchar(40))
AS
BEGIN
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlExistencia
    IF( NOT EXISTS(SELECT 1 FROM PnTablas.Guardaparque WHERE IDGuardaparque = @IDPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: Guardaparque inexistente.'
    END

    --controlReferencias
    IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Guardaparque WHERE IDGuardaparque = @IDPersona AND Estado = 'Activo') )
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: Guardaparque activo. Debe ser primero desasignado.'
    END

    IF(@errorCount = 0)
    BEGIN
        BEGIN TRANSACTION
        BEGIN TRY
            EXECUTE PnSPabm.bajaHistorial @Guardaparque = @IDPersona

            DELETE FROM PnTablas.Guardaparque
            WHERE IDGuardaparque = @IDPersona
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
            DECLARE @Num INT           = ERROR_NUMBER();
            PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        END CATCH
    END
END;
GO
PRINT '--Creado SP: bajaGuardaparque--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

--altaHistorial
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaHistorial'))
    DROP PROCEDURE PnSPabm.altaHistorial
GO;
CREATE PROCEDURE PnSPabm.altaHistorial (@Guardaparque INT, @parque INT, @fechaIni DATE, @fechaFin DATE, @razon varchar(40))
AS
BEGIN
    DECLARE @IDout TABLE(ID INT)

    IF( EXISTS(
    SELECT 1 
    FROM PnTablas.tieneHistorial AS tH 
    JOIN 
    PnTablas.Historial AS H 
    ON (tH.registro = H.IDregistro) 
    WHERE tH.Guardaparque = @Guardaparque AND H.FechaInicio = @fechaIni) )
        PRINT 'ERROR: registro ya presente.'
    ELSE
    BEGIN
        INSERT INTO PnTablas.Historial (FechaInicio, FechaEgreso, RazonEgreso)
        OUTPUT inserted.IDregistro INTO @IDout(ID)
        VALUES (@fechaIni, @fechaFin, @razon)

        INSERT INTO PnTablas.tieneHistorial (Guardaparque, Parque, Registro)
		VALUES (@Guardaparque, @parque, (SELECT ID FROM @IDout))
    END
END;
GO
PRINT '--Creado SP: altaHistorial--';
GO

--modificacionRazonHistorial
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionRazonHistorial'))
    DROP PROCEDURE PnSPabm.modificacionRazonHistorial
GO;
CREATE PROCEDURE PnSPabm.modificacionRazonHistorial (@Guardaparque INT, @parque INT, @fechaFin DATE, @razonNEW varchar(40))
AS
BEGIN
    UPDATE PnTablas.Historial
    SET RazonEgreso = @razonNEW
    WHERE IDRegistro = 
    (
        SELECT H.IDRegistro
        FROM 
        PnTablas.tieneHistorial AS tH 
        JOIN
        PnTablas.Historial AS H
        ON (th.registro = H.IDRegistro)
        WHERE th.Parque = @parque AND th.Guardaparque = @Guardaparque AND H.FechaInicio = @fechaFin
    )
END;
GO
PRINT '--Creado SP: modificacionRazonHistorial--';
GO

--bajaHistorial
--baja de todo el historial de un Guardaparque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaHistorial'))
    DROP PROCEDURE PnSPabm.bajaHistorial
GO;
CREATE PROCEDURE PnSPabm.bajaHistorial (@Guardaparque INT)
AS
BEGIN
    DECLARE @IDregistros TABLE(ID INT)

    INSERT INTO @IDregistros
    SELECT Registro
    FROM PnTablas.tieneHistorial
    WHERE Guardaparque = @Guardaparque

    DELETE FROM PnTablas.tieneHistorial
    WHERE Guardaparque = @Guardaparque

    DELETE FROM PnTablas.Historial
    WHERE IDRegistro IN (SELECT ID FROM @IDregistros)
END;
GO
PRINT '--Creado SP: bajaHistorial--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

--altaGuia
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaGuia'))
    DROP PROCEDURE PnSPabm.altaGuia
GO;
create procedure PnSPabm.altaGuia
    @idPersona int,
    @titulo varchar(100),
    @vencimientoHabilitacion date,
    @numeroHabilitacion int
as
begin
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidezDatos
    IF(@numeroHabilitacion <= 0)
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Numero de habilitacion invalido.'
    END

    IF( @vencimientoHabilitacion <= cast(getdate() as date) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Habilitacion vencida.'
    END

    --controlExistencia
    if ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Persona WHERE IDPersona = @IDPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- La persona no existe.'
    END

    --controlReferencias
    if ( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Persona WHERE IDPersona = @IDPersona AND Rol NOT LIKE 'Guia') )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- La persona tiene un rol diferente asignado.'
    END

    --controlDuplicidad
    if ( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Guia WHERE IDGuia = @IDPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Guia ya presente.'
    END

    IF(@errorCount = 0)
    BEGIN
        insert into PnTablas.Guia(IDGuia, titulo, vencimientoHabilitacion, numeroHabilitacion)
        values (@idPersona, @titulo, @vencimientoHabilitacion, @numeroHabilitacion)
    END
    ELSE
        PRINT @errorLine
end
go
PRINT '--Creado SP: altaGuia--';
GO

--bajaGuia
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaGuia'))
    DROP PROCEDURE PnSPabm.bajaGuia
GO;
create procedure PnSPabm.bajaGuia
@idPersona int
as
begin
    DECLARE @errorCount INT

    SET @errorCount = 0

    if not exists (select 1 from PnTablas.Guia where IDGuia = @idPersona)
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'El idPersona no es de ningun guia registrado.'
    END

    if ( (@errorCount = 0) AND exists (select 1 from PnTablas.Actividad where Guia = @idPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'El guia tiene actividades asignadas. Desasigne al guia antes de proceder.'
    END
    
    IF(@errorCount = 0)
    BEGIN
        EXECUTE desasignarEspecialidades @guia = @idPersona

        delete from PnTablas.Guia
        where IDGuia = @idPersona;
    END
end
go
PRINT '--Creado SP: bajaGuia--';
GO

--modificacionGuia
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionGuia'))
    DROP PROCEDURE PnSPabm.modificacionGuia
GO;
create procedure PnSPabm.modificacionGuia
    @idPersona                   int,
    @tituloNuevo                 varchar(100) = null,
    @vencimientoHabilitacionNuevo date        = null,
    @numeroHabilitacionNuevo     int          = null
as
begin
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidezDatos
    IF(@numeroHabilitacionNuevo <= 0)
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Numero de habilitacion invalido.'
    END

    IF( @vencimientoHabilitacionNuevo <= cast(getdate() as date) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Habilitacion vencida.'
    END

    --controlExistencia
    if ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Guia WHERE IDGuia = @IDPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- El guia no existe.'
    END

    IF(@errorCount = 0)
    BEGIN
        update PnTablas.Guia
        set
        titulo = isnull(@tituloNuevo, titulo),
        vencimientoHabilitacion = isnull(@vencimientoHabilitacionNuevo, vencimientoHabilitacion),
        numeroHabilitacion = isnull(@numeroHabilitacionNuevo, numeroHabilitacion)
        where IDGuia = @idPersona;
    END
end;
go
PRINT '--Creado SP: modificacionGuia--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

--altaEspecialidad
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaEspecialidad'))
    DROP PROCEDURE PnSPabm.altaEspecialidad
GO;
create procedure PnSPabm.altaEspecialidad
@descripcion varchar(20)
as
begin
    DECLARE @errorCount INT

    SET @errorCount = 0

    if exists (select 1 from PnTablas.Especialidad where DescripcionEspecialidad = @descripcion)
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: Ya existe una especialidad con esa descripcion.'
    END

    IF(@errorCount = 0)
        insert into PnTablas.Especialidad(DescripcionEspecialidad) values (@descripcion)
end
go
PRINT '--Creado SP: altaEspecialidad--';
GO

--modificacionEspecialidad
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionEspecialidad'))
    DROP PROCEDURE PnSPabm.modificacionEspecialidad
GO;
create procedure PnSPabm.modificacionEspecialidad
@idEspecialidad    int,
@descripcionNueva  varchar(20)
as
begin
    DECLARE @errorCount INT

    SET @errorCount = 0

    if not exists (select 1 from PnTablas.Especialidad where idEspecialidad = @idEspecialidad)
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: La especialidad a modificar no existe.'
    END

    if ( (@errorCount = 0) AND exists (select 1 from PnTablas.Especialidad where DescripcionEspecialidad = @descripcionNueva and idEspecialidad != @idEspecialidad) )
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: Ya existe otra especialidad con esa descripcion.'
    END

    IF(@errorCount = 0)
    BEGIN
        update PnTablas.Especialidad
        set DescripcionEspecialidad = @descripcionNueva
        where idEspecialidad = @idEspecialidad;
    END
end;
go
PRINT '--Creado SP: modificacionEspecialidad--';
GO

--bajaEspecialidad
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaEspecialidad'))
    DROP PROCEDURE PnSPabm.bajaEspecialidad
GO;
create procedure PnSPabm.bajaEspecialidad
@idEspecialidad int
as
begin
    DECLARE @errorCount INT

    SET @errorCount = 0

    if not exists (select 1 from PnTablas.Especialidad where idEspecialidad = @idEspecialidad)
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: La especialidad a modificar no existe.'
    END

    if exists (select 1 from PnTablas.TieneEspecialidad where Guia = @idEspecialidad)
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: Hay guias con esa especialidad. Desvinculelos antes de continuar.'
    END

    IF(@errorCount = 0)
        delete from PnTablas.Especialidad where idEspecialidad = @idEspecialidad
end;
go
PRINT '--Creado SP: bajaEspecialidad--';
GO

--asignarEspecialidad
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.asignarEspecialidad'))
    DROP PROCEDURE PnSPabm.asignarEspecialidad
GO;
CREATE PROCEDURE asignarEspecialidad (@guia INT, @especialidad INT)
AS
BEGIN
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidezDatos
    IF((@guia IS NULL) OR (@guia <= 0))
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- ID de guia invalido.'
    END

    IF((@especialidad IS NULL) OR (@especialidad <= 0))
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- ID de especialidad invalido.'
    END

    --controlExistencia
    IF(@errorCount = 0)
    BEGIN
        IF( NOT EXISTS(SELECT 1 FROM PnTablas.Guia WHERE IDGuia = @guia) )
        BEGIN
            SET @errorCount = @errorCount + 1
            SET @errorLine = @errorLine + CHAR(13) + '- Guia inexistente.'
        END

        IF( NOT EXISTS(SELECT 1 FROM PnTablas.Especialidad WHERE IDEspecialidad = @especialidad) )
        BEGIN
            SET @errorCount = @errorCount + 1
            SET @errorLine = @errorLine + CHAR(13) + '- Especialidad inexistente.'
        END
    END

    --controlDuplicidad
    IF( EXISTS(SELECT 1 FROM PnTablas.tieneEspecialidad WHERE Guia = @guia AND Especialidad = @especialidad) )
    BEGIN
       SET @errorCount = @errorCount + 1
       SET @errorLine = @errorLine + CHAR(13) + '- Especialidad ya asignada para ese guia.' 
    END

    IF(@errorCount = 0)
    BEGIN
        INSERT INTO PnTablas.tieneEspecialidad(Guia, Especialidad)
        VALUES(@guia, @especialidad)
    END
END;
GO
PRINT '--Creado SP: asignarEspecialidad--';
GO

--desasignarEspecialidad
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.desasignarEspecialidad'))
    DROP PROCEDURE PnSPabm.desasignarEspecialidad
GO;
CREATE PROCEDURE desasignarEspecialidad (@guia INT, @especialidad INT)
AS
BEGIN
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidezDatos
    IF((@guia IS NULL) OR (@guia <= 0))
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- ID de guia invalido.'
    END

    IF((@especialidad IS NULL) OR (@especialidad <= 0))
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- ID de especialidad invalido.'
    END

    --controlExistencia
    IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.tieneEspecialidad WHERE Guia = @guia AND Especialidad = @especialidad) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Asociacion inexistente.'
    END

    IF(@errorCount = 0)
    BEGIN
        DELETE FROM PnTablas.tieneEspecialidad
        WHERE Guia = @guia AND Especialidad = @especialidad
    END
END;
GO
PRINT '--Creado SP: desasignarEspecialidad--';
GO

--desasignarEspecialidades
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.desasignarEspecialidades'))
    DROP PROCEDURE PnSPabm.desasignarEspecialidades
GO;
CREATE PROCEDURE desasignarEspecialidades (@guia INT)
AS
BEGIN
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidezDatos
    IF((@guia IS NULL) OR (@guia <= 0))
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- ID de guia invalido.'
    END

    --controlExistencia
    IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.tieneEspecialidad WHERE Guia = @guia) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- El guia no tiene ninguna especializacion.'
    END

    IF(@errorCount = 0)
    BEGIN
        DELETE FROM PnTablas.tieneEspecialidad
        WHERE Guia = @guia
    END
END;
GO
PRINT '--Creado SP: desasignarEspecialidades--';
GO

--reasignarEspecialidad
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.reasignarEspecialidad'))
    DROP PROCEDURE PnSPabm.reasignarEspecialidad
GO;
CREATE PROCEDURE reasignarEspecialidad (@guia INT, @especialidadOLD INT, @especialidadNEW INT)
AS
BEGIN
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidezDatos
    IF((@guia IS NULL) OR (@guia <= 0))
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- ID de guia invalido.'
    END

    IF((@especialidadOLD IS NULL) OR (@especialidadOLD <= 0))
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- ID de especialidad actual invalido.'
    END

    IF((@especialidadNEW IS NULL) OR (@especialidadNEW <= 0))
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- ID de especialidad nueva invalido.'
    END

    --controlExistencia
    IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.tieneEspecialidad WHERE Guia = @guia AND Especialidad = @especialidadOLD) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Asociacion inexistente.'
    END

    --controlDuplicidad
    IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.tieneEspecialidad WHERE Guia = @guia AND Especialidad = @especialidadNEW) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Nueva especilidad ya asociada a ese guia.'
    END

    IF(@errorCount = 0)
    BEGIN
        UPDATE PnTablas.tieneEspecialidad
        SET Especialidad = @especialidadNEW
        WHERE Guia = @guia AND Especialidad = @especialidadOLD
    END
END;
GO
PRINT '--Creado SP: reasignarEspecialidad--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

--asignarGuia
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.asignarGuia'))
    DROP PROCEDURE PnSPabm.asignarGuia
GO;
CREATE PROCEDURE PnSPtrans.asignarGuia (@guia INT, @actividad INT)
AS
BEGIN
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidezDatos
    IF((@guia IS NULL) OR (@guia <= 0))
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- ID de guia invalido.'
    END

    IF((@actividad IS NULL) OR (@actividad <= 0))
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- ID de actividad invalido.'
    END

    --controlExistencia
    IF(@errorCount = 0)
    BEGIN
        IF( NOT EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE IDActividad = @actividad) )
        BEGIN
            SET @errorCount = @errorCount + 1
            SET @errorLine = @errorLine + CHAR(13) + '- Actividad inexistente.'
        END

        IF( NOT EXISTS(SELECT 1 FROM PnTablas.Guia WHERE IDGuia = @guia) )
        BEGIN
            SET @errorCount = @errorCount + 1
            SET @errorLine = @errorLine + CHAR(13) + '- Guia inexistente.'
        END
    END

    IF(@errorCount = 0)
    BEGIN
        BEGIN TRANSACTION
        BEGIN TRY
            IF( EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE IDActividad = @actividad AND Guia IS NOT NULL) )
                THROW 50000, '-Actividad ya tiene un guia asignado.', 1

            IF( EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE IDActividad = @actividad AND Guia = @guia) )
                THROW 50000, '-Actividad ya tiene asignado este guia.', 1

            UPDATE PnTablas.Actividad
            SET Guia = @guia
            WHERE IDActividad = @actividad

            COMMIT TRANSACTION
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

            DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
            DECLARE @Num INT           = ERROR_NUMBER();
            PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        END CATCH
    END
    ELSE
        PRINT @errorLine
END;
GO
PRINT '--Creado SP: asignarGuia--';
GO

--desasignarGuia
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.desasignarGuia'))
    DROP PROCEDURE PnSPabm.desasignarGuia
GO;
CREATE PROCEDURE PnSPtrans.desasignarGuia (@guia INT, @actividad INT)
AS
BEGIN
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidezDatos
    IF((@guia IS NULL) OR (@guia <= 0))
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- ID de guia invalido.'
    END

    IF((@actividad IS NULL) OR (@actividad <= 0))
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- ID de actividad invalido.'
    END

    --controlExistencia
    IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE IDActividad = @actividad AND Guia = @guia) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- No existe tal asociacion.'
    END

    IF(@errorCount = 0)
    BEGIN
        BEGIN TRANSACTION
        BEGIN TRY
            IF( EXISTS(SELECT 1 FROM PnTablas.Actividad WHERE IDActividad = @actividad AND Guia IS NULL) )
                THROW 50000, '-Actividad no tiene a nadie por desasignar.', 1

            UPDATE PnTablas.Actividad
            SET Guia = NULL
            WHERE IDActividad = @actividad

            COMMIT TRANSACTION
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

            DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
            DECLARE @Num INT           = ERROR_NUMBER();
            PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        END CATCH
    END
    ELSE
        PRINT @errorLine
END;
GO
PRINT '--Creado SP: desasignarGuia--';
GO
