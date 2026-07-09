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

	SET @errorCount = 0

	IF( (@idEmpresa IS NULL) OR (@idEmpresa <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Empresa invalida.'
	END

	IF( (@errorCount = 0) AND NOT EXISTS(SELECT 1 FROM PnTablas.Empresa WHERE IDEmpresa = @idEmpresa) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Empresa inexistente.'
	END

	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Concesion WHERE Empresa = @idEmpresa) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Existe al menos una concesion aun activa relacionada a esta empresa. Eliminela para continuar.'
	END

	IF(@errorCount = 0)
	BEGIN
		delete from PnTablas.Empresa
		where IDEmpresa = @idEmpresa
	END
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
