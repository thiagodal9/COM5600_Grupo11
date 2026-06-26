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
create procedure PnSPabm.altaTipoEntrada
@DescripcionTipoEntrada char(20)
as 
begin
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF(@DescripcionTipoEntrada IS NULL)
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Descripcion invalida.'
	END
	
	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.TipoEntrada WHERE DescripcionTipoEntrada LIKE @DescripcionTipoEntrada) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Descripcion ya presente.'
	END

	IF(@errorCount = 0)
	BEGIN
		insert into PnTablas.TipoEntrada(DescripcionTipoEntrada) 
		values (@DescripcionTipoEntrada);
	END
end
go

-------------------------------------------------------------------------------------
--Baja
create procedure PnSPabm.bajaTipoEntrada
@idTipoEntrada int
as
begin
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF( (@idTipoEntrada IS NULL) OR (@idTipoEntrada <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Descripcion invalida.'
	END

	if( (@errorCount = 0) AND not exists (select 1 from PnTablas.TipoEntrada where idTipoEntrada = @idTipoEntrada) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Tipo no existente.'
	END

	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.Entrada WHERE TipoEntrada = @idTipoEntrada) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Este tipo tiene al menos una entrada relacionada. Eliminela para continuar.'
	END

	IF(@errorCount = 0)
	BEGIN
		delete from PnTablas.TipoEntrada
		where idTipoEntrada = @idTipoEntrada;
	END
end
go

-------------------------------------------------------------------------------------
--Modificacion
create procedure PnSPabm.modificacionTipoEntrada
@idTipoEntrada int,
@descripcionNueva varchar
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
		set descripcion = @descripcionNueva
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
		insert into PnTablas.Entrada(idTipoEntrada, precio, parque) 
		values(@idTipoEntrada, @precio, @parque);
	END
end
go

-------------------------------------------------------------------------------------
--Baja
create procedure PnSPabm.bajaEntrada
@idEntrada int
as
begin
	DECLARE @errorCount INT

	SET @errorCount = 0

	IF( (@errorCount IS NULL) OR (@errorCount <= 0) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Entrada invalida.'
	END

	if( (@errorCount = 0) AND not exists (select 1 from PnTablas.Entrada where idEntrada = @idEntrada) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Entrada inexistente.'
	END

	IF( (@errorCount = 0) AND EXISTS(SELECT 1 FROM PnTablas.PagoPoseeEntrada WHERE idEntrada = @idEntrada) )
	BEGIN
		SET @errorCount = @errorCount + 1
		PRINT 'ERROR: Existe al menos una relacion entre esta entrada y ventas hechas. Elimine dicha relacion para continuar.'
	END

	IF(@errorCount = 0)
	BEGIN
		delete from PnTablas.Entrada
		where idEntrada = @idEntrada;
	END
end
go

-------------------------------------------------------------------------------------
--Modificacion
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
end
go