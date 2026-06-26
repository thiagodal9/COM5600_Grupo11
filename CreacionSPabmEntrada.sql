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

PRINT '--Creando SPabm para tablas Entrada...--';
GO

/*
================================================================
abm TipoEntrada
================================================================
*/
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaTipoEntrada'))
	DROP PROCEDURE PnSPabm.altaTipoEntrada
GO
create procedure PnSPabm.altaTipoEntrada
@DescripcionTipoEntrada char(20)
as 
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	IF(@DescripcionTipoEntrada IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Descripcion invalida.'
	END
	
	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.TipoEntrada WHERE DescripcionTipoEntrada LIKE @DescripcionTipoEntrada) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Descripcion ya presente.'
	END

	IF(@errorCount = 0)
	BEGIN
		insert into PnTablas.TipoEntrada(DescripcionTipoEntrada) 
		values (@DescripcionTipoEntrada);
	END
	ELSE
		PRINT @errorLine
end
go

-------------------------------------------------------------------------------------
--Baja
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaTipoEntrada'))
	DROP PROCEDURE PnSPabm.bajaTipoEntrada
GO
create procedure PnSPabm.bajaTipoEntrada
@idTipoEntrada int
as
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	IF( (@idTipoEntrada IS NULL) OR (@idTipoEntrada <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Descripcion invalida.'
	END

	if( (@errorCount = 0) AND not exists (select 1 from PnTablas.TipoEntrada where idTipoEntrada = @idTipoEntrada) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo no existente.'
	END

	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Entrada WHERE TipoEntrada = @idTipoEntrada) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Este tipo tiene al menos una entrada relacionada. Eliminela para continuar.'
	END

	IF(@errorCount = 0)
	BEGIN
		delete from PnTablas.TipoEntrada
		where idTipoEntrada = @idTipoEntrada;
	END
	ELSE
		PRINT @errorLine
end
go

-------------------------------------------------------------------------------------
--Modificacion
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionTipoEntrada'))
	DROP PROCEDURE PnSPabm.modificacionTipoEntrada
GO
create procedure PnSPabm.modificacionTipoEntrada
@idTipoEntrada int,
@descripcionNueva varchar(30) --vease el tam en la tabla
as
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF( (@idTipoEntrada IS NULL) OR (@idTipoEntrada <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo invalido.'
	END

	IF (@descripcionNueva IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Descripcion invalida.'
	END

	--controlExistencia
	if( (@errorCount = 0) AND not exists (select 1 from PnTablas.TipoEntrada where idTipoEntrada = @idTipoEntrada) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo no existente.'
	END

	--controlDuplicidad
	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.TipoEntrada WHERE idTipoEntrada = @idTipoEntrada AND DescripcionTipoEntrada LIKE @descripcionNueva) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Ya hay otro tipo con esa descripcion.'
	END

	IF(@errorCount = 0)
	BEGIN
		update PnTablas.TipoEntrada
		set DescripcionTipoEntrada = @descripcionNueva
		where idTipoEntrada = @idTipoEntrada
	END
	ELSE
		PRINT @errorLine
end
go

/*
================================================================
abm Entrada
================================================================
*/
--Alta
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.altaEntrada'))
	DROP PROCEDURE PnSPabm.altaEntrada
GO
create procedure PnSPabm.altaEntrada
@idTipoEntrada int,
@precio decimal(10,2),
@parque int
as 
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF( (@idTipoEntrada IS NULL) OR (@idTipoEntrada <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Tipo invalido.'
	END

	IF( (@parque IS NULL) OR (@parque <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Parque invalido.'
	END

	IF( (@precio IS NULL) OR (@precio <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Precio invalido.'
	END

	--controlExistencia
	IF(@errorCount = 0)
	BEGIN
		if not exists  (select idTipoEntrada from PnTablas.TipoEntrada where idTipoEntrada = @idTipoEntrada)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Tipo inexistente.'
		END

		if not exists  (select idParque from PnTablas.Parque where idParque = @parque)
		BEGIN
			SET @errorCount = @errorCount + 1
			SET @errorLine = @errorLine + CHAR(13) + '- Parque inexistente.'
		END
	END

	--controlDuplicidad
	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Entrada WHERE Parque = @parque AND TipoEntrada = @idTipoEntrada) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Entrada ya existente.'
	END

	IF(@errorCount = 0)
	BEGIN
		insert into PnTablas.Entrada(TipoEntrada, precio, parque) 
		values(@idTipoEntrada, @precio, @parque);
	END
	ELSE
		PRINT @errorLine
end
go

-------------------------------------------------------------------------------------
--Baja
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.bajaEntrada'))
	DROP PROCEDURE PnSPabm.bajaEntrada
GO
create procedure PnSPabm.bajaEntrada
@idEntrada int
as
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	IF((@idEntrada IS NULL) OR (@idEntrada <= 0))
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Entrada invalida.'
	END

	if( (@errorCount = 0) AND not exists (select 1 from PnTablas.Entrada where idEntrada = @idEntrada) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Entrada inexistente.'
	END

	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.PagoPoseeEntrada WHERE idEntrada = @idEntrada) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Existe al menos una relacion entre esta entrada y ventas hechas. Elimine dicha relacion para continuar.'
	END

	IF(@errorCount = 0)
	BEGIN
		delete from PnTablas.Entrada
		where idEntrada = @idEntrada;
	END
	ELSE
		PRINT @errorLine
end
go

-------------------------------------------------------------------------------------
--Modificacion
IF EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID('PnSPabm.modificacionPrecioEntrada'))
	DROP PROCEDURE PnSPabm.modificacionPrecioEntrada
GO
create procedure PnSPabm.modificacionPrecioEntrada
@idEntrada int,
@precioNuevo decimal(10,2)
as
begin
	DECLARE @errorCount INT
	DECLARE @errorLine varchar(100)

	SET @errorCount = 0
	SET @errorLine = 'Error/es:'

	--controlValidez
	IF( (@idEntrada IS NULL) OR (@idEntrada <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Precio invalido.'
	END

	IF( (@precioNuevo IS NULL) OR (@precioNuevo <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		SET @errorLine = @errorLine + CHAR(13) + '- Precio invalido.'
	END

	--controlExistencia
	if( (@errorCount = 0) AND not exists (select 1 from PnTablas.Entrada where idEntrada = @idEntrada) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Entrada inexistente.'
	END

	IF(@errorCount = 0)
	BEGIN
		UPDATE PnTablas.Entrada
		SET Precio = @precioNuevo
		WHERE IDEntrada = @idEntrada
	END
	ELSE
		PRINT @errorLine
end
go