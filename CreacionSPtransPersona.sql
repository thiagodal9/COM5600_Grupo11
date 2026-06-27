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

PRINT '--Creando SPtrans para tablas Persona...--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Persona
--Baja
--Este SP solo borra si no hay dependencias.
--De haberlas, primero se pide quitar las dependencias con los SP correspondientes.
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.bajaPersona'))
    DROP PROCEDURE PnSPtrans.bajaPersona
GO
create procedure PnSPtrans.bajaPersona
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
        BEGIN TRANSACTION
        BEGIN TRY
            EXECUTE PnSPabm.bajaGuia @idPersona = @IDPersona

            EXECUTE PnSPabm.bajaGuardaparque @IDPersona = @IDPersona, @razon = @razon

            delete from PnTablas.Persona 
            where idPersona = @idPersona

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
end;
go
PRINT '--Creado SP: bajaPersona--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Guardaparque
--asignarGuardaparque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.asignarGuardaparque'))
    DROP PROCEDURE PnSPtrans.asignarGuardaparque
GO
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
            SET Estado = 'Activo', Parque = @Parque, FechaInicio = CONVERT(DATE, GETDATE())
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

-------------------------------------------------------------------------------------
--reasignarGuardaparque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.reasignarGuardaparque'))
    DROP PROCEDURE PnSPabm.reasignarGuardaparque
GO
CREATE PROCEDURE PnSPabm.reasignarGuardaparque (@IDPersona INT, @Parque INT, @razon varchar(40))
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
            SET @fechaFin = CONVERT(DATE, GETDATE())

            EXECUTE PnSPabm.altaHistorial 
            @Guardaparque = @IDPersona, 
            @parque = @Parque, 
            @fechaIni = @fechaIni,
            @fechaFin = @fechaFin,
            @razon = @razon

            UPDATE PnTablas.Guardaparque
            SET Parque = @Parque, FechaInicio = CONVERT(DATE, GETDATE())
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

-------------------------------------------------------------------------------------
--desasignarGuardaparque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.desasignarGuardaparque'))
    DROP PROCEDURE PnSPtrans.desasignarGuardaparque
GO
CREATE PROCEDURE PnSPtrans.desasignarGuardaparque (@IDPersona INT, @Parque INT, @razon varchar(40))
AS
BEGIN
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)
    DECLARE @fechaIni DATE
    DECLARE @fechaFin DATE
    DECLARE @estado varchar(10)

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidez
    IF( (@IDPersona IS NULL) OR (@IDPersona <= 0) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Guardaparque invalido.'
    END

    IF( (@Parque IS NULL) OR (@Parque <= 0) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Parque invalido.'
    END

    IF(@razon IS NULL)
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Razon invalida.'
    END

    --controlExistencia
    IF(@errorCount = 0)
    BEGIN
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
    END

    --controlRelacion
    IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Guardaparque WHERE IDGuardaparque = @IDPersona AND Parque = @Parque) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- No existe tal relacion.'
    END

    IF(@errorCount <> 0)
        PRINT @errorLine
    ELSE
    BEGIN
        BEGIN TRANSACTION
        BEGIN TRY
            IF( EXISTS(SELECT 1 FROM PnTablas.Guardaparque WHERE IDGuardaparque = @IDPersona AND Estado = 'Inactivo') )
                THROW 50000, '-Guardaparque no activo.', 1
        
            SET @fechaIni = (SELECT FechaInicio FROM PnTablas.GuardaParque WHERE IDGuardaParque = @IDPersona)
            SET @fechaFin = CONVERT(DATE, GETDATE())

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

-------------------------------------------------------------------------------------
--bajaGuardaparque
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.bajaGuardaparque'))
    DROP PROCEDURE PnSPtrans.bajaGuardaparque
GO
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
END;
GO
PRINT '--Creado SP: bajaGuardaparque--';
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Guia

--asignarGuia
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.asignarGuia'))
    DROP PROCEDURE PnSPtrans.asignarGuia
GO
CREATE PROCEDURE PnSPtrans.asignarGuia (@guia INT, @actividad INT, @fecha DATE, @hora TIME)
AS
BEGIN
    DECLARE @errorCount INT
    DECLARE @errorLine varchar(100)
    DECLARE @actGuia INT

    SET @errorCount = 0
    SET @errorLine = 'Error/es:'

    --controlValidezDatos
    IF((@guia IS NULL) OR (@guia <= 0))
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- ID de guia invalido.'
    END

    IF( (@actividad IS NULL) OR (@actividad <= 0) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- ID de actividad invalido.'
    END

    IF( (@fecha IS NULL) OR (@fecha < CONVERT(DATE, GETDATE())) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Fecha invalida.'
    END

    IF( (@hora IS NULL) OR 
    ((@fecha = CONVERT(DATE, GETDATE())) AND (@hora < CONVERT(TIME, GETDATE()))) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Hora invalida.'
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

        IF( (@errorCount = 0) AND 
        NOT EXISTS(SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actividad AND FechaActividad = @fecha AND HoraInicio = @hora) )
        BEGIN
            SET @errorCount = @errorCount + 1
            SET @errorLine = @errorLine + CHAR(13) + '- No existe ese turno para la actividad.'
        END
    END

    IF(@errorCount = 0)
    BEGIN
        BEGIN TRANSACTION
        BEGIN TRY
            SET @actGuia = (SELECT Guia FROM PnTablas.HorarioActividad WHERE Actividad = @actividad AND FechaActividad = @fecha AND HoraInicio = @hora)

            IF( (@actGuia IS NOT NULL) AND (@actGuia != @guia) )
                THROW 50000, '-Actividad ya tiene un guia asignado.', 1

            IF( (@actGuia IS NOT NULL) AND (@actGuia = @guia) )
                THROW 50001, '-Actividad ya tiene asignado este guia.', 1

            UPDATE PnTablas.HorarioActividad
            SET Guia = @guia
            WHERE Actividad = @actividad AND FechaActividad = @fecha AND HoraInicio = @hora

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
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPtrans.desasignarGuia'))
    DROP PROCEDURE PnSPtrans.desasignarGuia
GO
CREATE PROCEDURE PnSPtrans.desasignarGuia (@guia INT, @actividad INT, @fecha DATE, @hora TIME)
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

    IF( (@fecha IS NULL) OR (@fecha < CONVERT(DATE, GETDATE())) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Fecha invalida.'
    END

    IF( (@hora IS NULL) OR 
    ((@fecha = CONVERT(DATE, GETDATE())) AND (@hora < CONVERT(TIME, GETDATE()))) )
    BEGIN
        SET @errorCount = @errorCount + 1
        SET @errorLine = @errorLine + CHAR(13) + '- Hora invalida.'
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

        IF( (@errorCount = 0) AND 
        NOT EXISTS(SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actividad AND FechaActividad = @fecha AND HoraInicio = @hora) )
        BEGIN
            SET @errorCount = @errorCount + 1
            SET @errorLine = @errorLine + CHAR(13) + '- No existe ese turno para la actividad.'
        END
    END

    IF(@errorCount = 0)
    BEGIN
        BEGIN TRANSACTION
        BEGIN TRY
            IF EXISTS(SELECT 1 FROM PnTablas.HorarioActividad WHERE Actividad = @actividad AND FechaActividad = @fecha AND HoraInicio = @hora AND Guia IS NULL)
                THROW 50000, '-El turno no tiene a guia para desasignar.', 1

            UPDATE PnTablas.HorarioActividad
            SET Guia = NULL
            WHERE Actividad = @actividad AND FechaActividad = @fecha AND HoraInicio = @hora

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
