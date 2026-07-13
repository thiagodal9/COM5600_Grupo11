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
----Persona
--altaPersona
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaPersona'))
    DROP PROCEDURE PnSPabm.altaPersona
GO
create procedure PnSPabm.altaPersona
@dni int,
@nombre varchar(20),
@apellido varchar(20),
@telefono char(12),
@rol varchar(12)
as
begin
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidezDatos
    IF( (@dni IS NULL) OR ((@dni <= 0) OR (99999999 < @dni)) )
    BEGIN
        SET @errorCount = @errorCount + 1
	    SET @errorLine = @errorLine + CHAR(13) + '- Numero de DNI invalido.'
    END

    IF(@nombre IS NULL)
    BEGIN
        SET @errorCount = @errorCount + 1
	    SET @errorLine = @errorLine + CHAR(13) + '- Nombre invalido.'
    END

    IF(@apellido IS NULL)
    BEGIN
        SET @errorCount = @errorCount + 1
	    SET @errorLine = @errorLine + CHAR(13) + '- Apellido invalido.'
    END

    IF(@telefono IS NULL)
    BEGIN
        SET @errorCount = @errorCount + 1
	    SET @errorLine = @errorLine + CHAR(13) + '- Telefono invalido.'
    END

    IF( (@rol IS NULL) OR (@rol NOT IN('Guardaparque', 'Guia')) )
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
GO
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
    IF( (@IDPersona IS NULL) AND (@IDPersona <= 0) )
    BEGIN
        SET @errorCount = @errorCount + 1
	    SET @errorLine = @errorLine + CHAR(13) + '- Persona invalida.'
    END

    if ( (@dniNuevo IS NOT NULL) AND ( (@dniNuevo <= 0) OR (99999999 < @dniNuevo) ) )
    BEGIN
        SET @errorCount = @errorCount + 1
	    SET @errorLine = @errorLine + CHAR(13) + '- Numero de DNI invalido.'
    END

    IF( (@rolNuevo IS NOT NULL) AND (@rolNuevo NOT IN ('Guardaparque', 'Guia')) )
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
    if ( (@errorCount = 0) AND (@dniNuevo IS NOT NULL) AND EXISTS(SELECT 1 FROM PnTablas.Persona WHERE DNI = @dniNuevo AND IDPersona != @IDPersona) )
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

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
--Guardaparque
--altaGuardaParque
--Solo registra al guardaparques, no asigna. Ingresa como inactivo.
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaGuardaParque'))
    DROP PROCEDURE PnSPabm.altaGuardaParque
GO
create procedure PnSPabm.altaGuardaParque
@IDPersona INT
as
begin
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidez
    IF( (@IDPersona IS NULL) OR (@IDPersona <= 0) )
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: Persona invalida.'
    END

    --controlExistencia
    if ( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Persona WHERE IDPersona = @IDPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: La persona no existe.'
    END

    --controlReferencias
    if ( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Persona WHERE IDPersona = @IDPersona AND Rol NOT LIKE 'Guardaparque') )
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: La persona tiene un rol diferente asignado.'
    END

    --controlDuplicidad
    if ( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Guardaparque WHERE IDGuardaparque = @IDPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: Guardaparque ya presente.'
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

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Historial
--modificacionRazonHistorial
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionRazonHistorial'))
    DROP PROCEDURE PnSPabm.modificacionRazonHistorial
GO
CREATE PROCEDURE PnSPabm.modificacionRazonHistorial (@registro INT, @razonNEW varchar(40))
AS
BEGIN
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    IF( (@registro IS NULL) OR (@registro <= 0) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Registro invalido.'
    END

    IF(@razonNEW IS NULL)
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Razon invalida.'
    END

    IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Historial WHERE IDregistro = @registro) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Registro inexistente.'
    END

    IF(@errorCount = 0)
    BEGIN
        UPDATE PnTablas.Historial
        SET RazonEgreso = @razonNEW
        WHERE IDregistro = @registro
    END
    ELSE
        PRINT @errorLine
END;
GO
PRINT '--Creado SP: modificacionRazonHistorial--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Guia
--altaGuia
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaGuia'))
    DROP PROCEDURE PnSPabm.altaGuia
GO
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
    IF( (@idPersona IS NULL) OR (@idPersona <= 0) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Persona invalida.'
    END

    IF( (@numeroHabilitacion IS NULL) OR (@numeroHabilitacion <= 0) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Numero de habilitacion invalido.'
    END

    IF( (@vencimientoHabilitacion IS NULL) OR (@vencimientoHabilitacion <= cast(getdate() as date)) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Habilitacion invalida.'
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
        insert into PnTablas.Guia(IDGuia, titulo, vencimientoHabilitacion, NumeroHabilitacion)
        values (@idPersona, @titulo, @vencimientoHabilitacion, @numeroHabilitacion)
    END
    ELSE
        PRINT @errorLine
end
go
PRINT '--Creado SP: altaGuia--';
GO

-------------------------------------------------------------------------------------
--bajaGuia
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaGuia'))
    DROP PROCEDURE PnSPabm.bajaGuia
GO
create procedure PnSPabm.bajaGuia
@idPersona int
as
begin
    DECLARE @errorCount INT

    SET @errorCount = 0

    IF( (@idPersona IS NULL) OR (@idPersona <= 0) )
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: Persona invalida.'
    END

    if( (@errorCount = 0) AND not exists(select 1 from PnTablas.Guia where IDGuia = @idPersona) )
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'El idPersona no es de ningun guia registrado.'
    END

    if ( (@errorCount = 0) AND exists (select 1 from PnTablas.HorarioActividad where Guia = @idPersona) )
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

-------------------------------------------------------------------------------------
--modificacionGuia
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionGuia'))
    DROP PROCEDURE PnSPabm.modificacionGuia
GO
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
    IF( (@idPersona IS NULL) OR (@idPersona <= 0) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Persona invalida.'
    END

    IF( (@numeroHabilitacionNuevo IS NOT NULL) AND (@numeroHabilitacionNuevo <= 0) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Numero de habilitacion invalido.'
    END

    IF( (@vencimientoHabilitacionNuevo IS NOT NULL) AND (@vencimientoHabilitacionNuevo <= cast(getdate() as date)) )
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
        NumeroHabilitacion = isnull(@numeroHabilitacionNuevo, NumeroHabilitacion)
        where IDGuia = @idPersona;
    END
end;
go
PRINT '--Creado SP: modificacionGuia--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Especialidad
--altaEspecialidad
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaEspecialidad'))
    DROP PROCEDURE PnSPabm.altaEspecialidad
GO
create procedure PnSPabm.altaEspecialidad
@descripcion varchar(20)
as
begin
    DECLARE @errorCount INT

    SET @errorCount = 0

    IF(@descripcion IS NULL)
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: Descripcion invalida.'
    END

    if( (@errorCount = 0) AND exists(select 1 from PnTablas.Especialidad where DescripcionEspecialidad = @descripcion) )
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

-------------------------------------------------------------------------------------
--modificacionEspecialidad
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionEspecialidad'))
    DROP PROCEDURE PnSPabm.modificacionEspecialidad
GO
create procedure PnSPabm.modificacionEspecialidad
@idEspecialidad    int,
@descripcionNueva  varchar(20)
as
begin
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidez
    IF( (@idEspecialidad IS NULL) OR (@idEspecialidad <= 0) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Especialidad invalida.'
    END

    IF(@descripcionNueva IS NULL)
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Nueva Descripcion invalida.'
    END

    --controlExistencia
    if( (@errorCount = 0) AND not exists (select 1 from PnTablas.Especialidad where idEspecialidad = @idEspecialidad) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- La especialidad a modificar no existe.'
    END

    --controlDuplicidad
    if ( (@errorCount = 0) AND exists (select 1 from PnTablas.Especialidad where DescripcionEspecialidad = @descripcionNueva and idEspecialidad != @idEspecialidad) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Ya existe otra especialidad con esa descripcion.'
    END

    IF(@errorCount = 0)
    BEGIN
        update PnTablas.Especialidad
        set DescripcionEspecialidad = @descripcionNueva
        where idEspecialidad = @idEspecialidad;
    END
    ELSE
        PRINT @errorLine
end;
go
PRINT '--Creado SP: modificacionEspecialidad--';
GO

-------------------------------------------------------------------------------------
--bajaEspecialidad
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaEspecialidad'))
    DROP PROCEDURE PnSPabm.bajaEspecialidad
GO
create procedure PnSPabm.bajaEspecialidad
@idEspecialidad int
as
begin
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidez
    IF( (@idEspecialidad IS NULL) OR (@idEspecialidad <= 0) )
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: Especialidad invalida.'
    END

    --controlExistencia
    if( (@errorCount = 0) AND not exists (select 1 from PnTablas.Especialidad where idEspecialidad = @idEspecialidad) )
    BEGIN
        SET @errorCount = @errorCount + 1
        PRINT 'ERROR: La especialidad a modificar no existe.'
    END

    --controlReferencia
    if( (@errorCount = 0) AND exists(select 1 from PnTablas.TieneEspecialidad where Especialidad = @idEspecialidad) )
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

-------------------------------------------------------------------------------------
--asignarEspecialidad
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.asignarEspecialidad'))
    DROP PROCEDURE PnSPabm.asignarEspecialidad
GO
CREATE PROCEDURE PnSPabm.asignarEspecialidad (@guia INT, @especialidad INT)
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

-------------------------------------------------------------------------------------
--desasignarEspecialidad
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.desasignarEspecialidad'))
    DROP PROCEDURE PnSPabm.desasignarEspecialidad
GO
CREATE PROCEDURE PnSPabm.desasignarEspecialidad (@guia INT, @especialidad INT)
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

-------------------------------------------------------------------------------------
--desasignarEspecialidades
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.desasignarEspecialidades'))
    DROP PROCEDURE PnSPabm.desasignarEspecialidades
GO
CREATE PROCEDURE PnSPabm.desasignarEspecialidades (@guia INT)
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

-------------------------------------------------------------------------------------
--reasignarEspecialidad
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.reasignarEspecialidad'))
    DROP PROCEDURE PnSPabm.reasignarEspecialidad
GO
CREATE PROCEDURE PnSPabm.reasignarEspecialidad (@guia INT, @especialidadOLD INT, @especialidadNEW INT)
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
