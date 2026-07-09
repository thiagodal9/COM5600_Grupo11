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

PRINT '--Creando SPabm para tablas Concesion...--';
GO

-------------------------------------------------------------------------------------
--Concesion
-------------------------------------------------------------------------------------
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaConcesion'))
    DROP PROCEDURE PnSPabm.altaConcesion
GO
create procedure PnSPabm.altaConcesion
@idEmpresa int,
@idParque int,
@rubro varchar(20),
@fechaInicio date,
@fechaFin date,
@precioAlquiler decimal(10,2)
as 
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF( (@idEmpresa IS NULL) OR (@idEmpresa <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Empresa invalida.'
	END

	IF( (@idParque IS NULL) OR (@idParque <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Parque invalido.'
	END

	if (@rubro IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Rubro invalido.'
	END

	IF(((@fechaInicio IS NULL) OR (@fechaFin IS NULL)) OR (@fechaInicio >= @fechaFin))
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Fechas invalidas.'
	END

	IF( (@precioAlquiler IS NULL) OR (@precioAlquiler <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Costo de alquiler invalido.'
	END

	--controlExistencia
	IF(@errorCount = 0)
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM PnTablas.Parque WHERE IDParque = @idParque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
		END

		IF NOT EXISTS(SELECT 1 FROM PnTablas.Empresa WHERE IDEmpresa = @idEmpresa)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Empresa inexistente.'
		END
	END

	IF(@errorCount = 0)
	BEGIN
		begin transaction
		begin try
			insert into PnTablas.Concesion(Empresa, Parque, Rubro, FechaInicioConcesion, FechaFinConcesion, CostoAlquiler) values
			(@idEmpresa, @idParque, @rubro, @fechaInicio, @fechaFin, @precioAlquiler);
			commit transaction;
		end try
		begin catch
			if @@TRANCOUNT > 0
				rollback transaction;
			declare @msj nvarchar(100) = error_message();
			declare @numError int = error_number();
			print concat('ERROR (', @numError,')',@msj);
		end catch
	END
	ELSE 
		PRINT @errorLine
end;
go
PRINT '--Creado SP: altaConcesion--';
GO

-------------------------------------------------------------------------------------
--Baja
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaConcesion'))
    DROP PROCEDURE PnSPabm.bajaConcesion
GO
create procedure PnSPabm.bajaConcesion
@idConcesion int
as
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	IF( (@idConcesion IS NULL) OR (@idConcesion <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Concesion invalida.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Concesion WHERE IDConcesion = @idConcesion) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Concesion inexistente.'
	END

	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.HistorialPago WHERE Concesion = @idConcesion) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos una entrada en el Historial de Pago relacionada a esta concesion. Eliminela para continuar.'
	END

	IF(@errorCount = 0)
	BEGIN
		begin transaction
		begin try
			delete from PnTablas.Concesion
			where idConcesion = @idConcesion;
			commit transaction;
		end try
		begin catch
			if @@TRANCOUNT > 0
				rollback transaction;

			declare @msj nvarchar(100) = error_message();
			declare @numError int = error_number();
			print concat('ERROR (', @numError,')',@msj);
		end catch
	END
	ELSE
		PRINT @errorLine
end;
go
PRINT '--Creado SP: bajaConcesion--';
GO

-------------------------------------------------------------------------------------
--Modificacion (Fecha Fin)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionFechaFConcesion'))
    DROP PROCEDURE PnSPabm.modificacionFechaFConcesion
GO
create procedure PnSPabm.modificacionFechaFConcesion
@idConcesion int,
@fechaFinNEW DATE
as
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)
	DECLARE @fecha DATE

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF( (@idConcesion IS NULL) OR (@idConcesion <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Concesion invalida.'
	END

	IF( (@fechaFinNEW IS NULL) OR (@fechaFinNEW < CONVERT(DATE, GETDATE())) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nueva fecha invalida.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Concesion WHERE IDConcesion = @idConcesion) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Concesion inexistente.'
	END

	--controlExtra
	SET @fecha = (SELECT FechaInicioConcesion FROM PnTablas.Concesion WHERE IDConcesion = @idConcesion)

	IF( (@errorCount = 0) AND (@fechaFinNEW < @fecha) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- La nueva fecha no puede ser anterior a la de inicio.'
	END

	IF(@errorCount = 0)
	BEGIN
		begin transaction
		begin try
			UPDATE PnTablas.Concesion
			SET FechaFinConcesion = @fechaFinNEW
			where idConcesion = @idConcesion;
			commit transaction;
		end try
		begin catch
			if @@TRANCOUNT > 0
				rollback transaction;

			declare @msj nvarchar(100) = error_message();
			declare @numError int = error_number();
			print concat('ERROR (', @numError,')',@msj);
		end catch
	END
	ELSE 
		PRINT @errorLine
end;
go
PRINT '--Creado SP: modificacionFechaFConcesion--';
GO

-------------------------------------------------------------------------------------
--Modificacion (Costo)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionCostoConcesion'))
    DROP PROCEDURE PnSPabm.modificacionCostoConcesion
GO
create procedure PnSPabm.modificacionCostoConcesion
@idConcesion int,
@costo DECIMAL(10,2)
as
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF( (@idConcesion IS NULL) OR (@idConcesion <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Concesion invalida.'
	END

	IF( (@costo IS NULL) OR (@costo <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nuevo costo invalido.'
	END

	--controlExistencia
	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Concesion WHERE IDConcesion = @idConcesion) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Concesion inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		begin transaction
		begin try
			UPDATE PnTablas.Concesion
			SET CostoAlquiler = @costo
			where idConcesion = @idConcesion;
			commit transaction;
		end try
		begin catch
			if @@TRANCOUNT > 0
				rollback transaction;

			declare @msj nvarchar(100) = error_message();
			declare @numError int = error_number();
			print concat('ERROR (', @numError,')',@msj);
		end catch
	END
	ELSE
		PRINT @errorLine
end;
go
PRINT '--Creado SP: modificacionCostoConcesion--';
GO

/*
================================================================
abm Empresa
================================================================
*/
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaEmpresa'))
    DROP PROCEDURE PnSPabm.altaEmpresa
GO
create procedure PnSPabm.altaEmpresa
@nombre varchar(20),
@descripcion varchar(30)
as 
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	if (@nombre IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nombre invalido.'
	END

	if (@descripcion IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Descripcion invalida.'
	END

	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Empresa WHERE NombreEmpresa LIKE @nombre) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Empresa ya presente.'
	END

	IF(@errorCount = 0)
	BEGIN
		insert into PnTablas.Empresa(NombreEmpresa, DescripcionEmpresa) 
		values (@nombre, @descripcion)
	END
	ELSE
		PRINT @errorLine
end;
go
PRINT '--Creado SP: altaEmpresa--';
GO

-------------------------------------------------------------------------------------
--Baja
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaEmpresa'))
    DROP PROCEDURE PnSPabm.bajaEmpresa
GO
create procedure PnSPabm.bajaEmpresa
@idEmpresa int
as
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = @errorLine + CHAR(13) + 'Error/es:'

	IF( (@idEmpresa IS NULL) OR (@idEmpresa <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Empresa invalida.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Empresa WHERE IDEmpresa = @idEmpresa) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Empresa inexistente.'
	END

	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Concesion WHERE Empresa = @idEmpresa) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos una concesion aun activa relacionada a esta empresa.'
	END

	IF(@errorCount = 0)
	BEGIN
		delete from PnTablas.Empresa
		where IDEmpresa = @idEmpresa
	END
	ELSE
		PRINT @errorLine
end;
go
PRINT '--Creado SP: bajaEmpresa--';
GO

-------------------------------------------------------------------------------------
--Modificacion (Nombre)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionNombreEmpresa'))
    DROP PROCEDURE PnSPabm.modificacionNombreEmpresa
GO
create procedure PnSPabm.modificacionNombreEmpresa
@idEmpresa int,
@nombreNuevo varchar(20)
as
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	IF( (@idEmpresa IS NULL) OR (@idEmpresa <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Empresa invalida.'
	END

	if (@nombreNuevo IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nuevo nombre invalido.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Empresa WHERE IDEmpresa = @idEmpresa) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Empresa inexistente.'
	END

	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Empresa WHERE IDEmpresa != @idEmpresa AND NombreEmpresa LIKE @nombreNuevo) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Ya hay otra empresa con ese nombre.'
	END
	
	IF(@errorCount = 0)
	BEGIN
		update PnTablas.Empresa
		set NombreEmpresa = @nombreNuevo
		where IDEmpresa = @idEmpresa;
	END
	ELSE
		PRINT @errorLine
end;
go
PRINT '--Creado SP: modificacionNombreEmpresa--';
GO

-------------------------------------------------------------------------------------
--Modificacion (Descripcion)
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionDescripcionEmpresa'))
    DROP PROCEDURE PnSPabm.modificacionDescripcionEmpresa
GO
create procedure PnSPabm.modificacionDescripcionEmpresa
@idEmpresa int,
@descripcionNueva varchar(30)
as
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	IF( (@idEmpresa IS NULL) OR (@idEmpresa <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Empresa invalida.'
	END

	if (@descripcionNueva IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Nueva descripcion es invalida.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Empresa WHERE IDEmpresa = @idEmpresa) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Empresa inexistente.'
	END
	
	IF(@errorCount = 0)
	BEGIN
		update PnTablas.Empresa
		set DescripcionEmpresa = @descripcionNueva
		where IDEmpresa = @idEmpresa;
	END
	ELSE
		PRINT @errorLine
end;
go
PRINT '--Creado SP: modificacionDescripcionEmpresa--';
GO