/*
--/--/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

Cifrado de datos sensibles mediante TDE y cifr simetrico a nivel de columna.

Datos sensibles identificados:
  - Persona.DNI
  - Persona.Telefono
  - Guia.NumeroHabilitacion
  - Historial.RazonEgreso

Estrategia:
  - TDE: cifra el archivo .mdf completo en reposo (a nivel de base de datos).
  - Cifrado simetrico a nivel de columna: columnas especificas en tablas. Los SP de consulta decifran con OPEN SYMMETRIC KEY.
  - Las columnas cifradas se almacenan como varbinary.
  - Los SP abm existentes se modifican para cifrar al escribir y descifrar al leer.
*/

if exists (select name from sys.databases where name = 'ParquesNacionales')
begin
	use ParquesNacionales
	print '--Usando BD: ParquesNacionales--' 
end;
go

-- ============================================================
-- TRANSPARENT DATA ENCRYPTION (TDE)
-- Cifra el archivo de datos en reposo a nivel de base de datos.
-- ============================================================

print '-- [1/4] Configurando Transparent Data Encryption...';
go

-- Crear master key en la base master si no existe
use master;
go
if not exists (select 1 from sys.symmetric_keys where name = '##MS_DatabaseMasterKey##')
begin
    create master key encryption by password = 'Pn_MasterKey_2026!Seguro';
    print '   -- Master Key creada en [master].'
end
else
    print '   -- Master Key ya existente en [master].';
go

-- Crear certificado para TDE
if not exists (select 1 from sys.certificates where name = 'CertTDE_ParquesNacionales')
begin
    create certificate CertTDE_ParquesNacionales
    with subject = 'Certificado TDE - ParquesNacionales 2026';
    print '   -- Certificado TDE creado.'
end
else
    print '   -- Certificado TDE ya existente.';
go

-- Crear database encryption key en la BD del proyecto
use ParquesNacionales;
go
if not exists (select 1 from sys.dm_database_encryption_keys where database_id = db_id())
begin
    create database encryption key
    with algorithm = aes_256
    encryption by server certificate CertTDE_ParquesNacionales;
    print '   -- Database Encryption Key creada.'
end
else
    print '   -- Database Encryption Key ya existente.';
go

-- Activar TDE
alter database ParquesNacionales set encryption on;
go
print '-- TDE activado sobre ParquesNacionales.';
go

-- ===========================================================
-- CIFRADO SIMETRICO A NIVEL DE COLUMNA
-- Columnas: DNI, Telefono, NumeroHabilitacion, RazonEgreso
-- ===========================================================

print '-- [2/4] Configurando cifrado simetrico a nivel de columna...';
go

-- Master Key de la base de datos de aplicacion
if not exists (select 1 from sys.symmetric_keys where name = '##MS_DatabaseMasterKey##')
begin
    create master key encryption by password = 'Pn_AppMasterKey_2026!Seguro';
    print '   -- Database Master Key creada en ParquesNacionales.'
end
else
    print '   -- Database Master Key ya existente en ParquesNacionales.';
go

-- Certificado para cifrado de columnas
if not exists (select 1 from sys.certificates where name = 'CertColumnas_Pn')
begin
    create certificate CertColumnas_Pn
    with subject = 'Certificado cifrado de columnas - ParquesNacionales';
    print '   -- Certificado de columnas creado.'
end
else
    print '   -- Certificado de columnas ya existente.';
go

-- Clave simetrica AES-256 protegida por el certificado
if not exists (select 1 from sys.symmetric_keys where name = 'SymKey_DatosSensibles')
begin
    create symmetric key SymKey_DatosSensibles
    with algorithm = aes_256
    encryption by certificate CertColumnas_Pn;
    print '   -- Clave simetrica SymKey_DatosSensibles creada.'
end
else
    print '   -- Clave simetrica ya existente.';
go

-- ============================================================
-- MODIFICACION DE TABLAS
-- Se agregan columnas cifradas y se mantienen las originales
-- durante la migracion, al final se eliminan.
-- ============================================================

print '-- [3/4] Migrando columnas sensibles a formato cifrado...';
go

-- -------------
-- Tabla Persona
-- -------------

-- Agregar columnas cifradas si no existen
if not exists (select 1 from sys.columns where object_id = object_id('PnTablas.Persona') and name = 'DNI_Cifrado')
begin
    alter table PnTablas.Persona add
        DNI_Cifrado      varbinary(256) null,
        Telefono_Cifrado varbinary(256) null,
        HashDNI          varbinary(32)  null;
    print '   -- Columnas DNI_Cifrado, Telefono_Cifrado y HashDNI agregadas a Persona.'
end
go

-- Antes de intentar hacer el UPDATE, verificamos si la columna existe
if exists (select 1 from sys.columns where object_id = object_id('[PnTablas].[Historial]') and name = 'RazonEgreso')
begin
    open symmetric key SymKey_DatosSensibles
        decryption by certificate CertColumnas_Pn;

    update [PnTablas].[Historial]
    set RazonEgreso_Cifrada = encryptbykey(key_guid('SymKey_DatosSensibles'), convert(varbinary, RazonEgreso))
    where RazonEgreso is not null;

    close symmetric key SymKey_DatosSensibles;
    print '   -- Datos de Historial.RazonEgreso migrados a columna cifrada.';
end
go

-- Luego, el borrado también condicionado
if exists (select 1 from sys.columns where object_id = object_id('[PnTablas].[Historial]') and name = 'RazonEgreso')
begin
    alter table [PnTablas].[Historial] drop column RazonEgreso;
    print '   -- Columna Historial.RazonEgreso (sin cifrar) eliminada.'
end
go

-- Buscar y eliminar la restricción UNIQUE sobre DNI de forma precisa
DECLARE @constraintName NVARCHAR(256);
SELECT @constraintName = kc.name
FROM sys.key_constraints kc
JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE kc.parent_object_id = OBJECT_ID('PnTablas.Persona')
  AND c.name = 'DNI'
  AND kc.type = 'UQ';

IF @constraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE PnTablas.Persona DROP CONSTRAINT ' + @constraintName);
    PRINT '   -- Constraint UNIQUE en Persona.DNI eliminado.';
END
GO

-- Eliminar columna DNI original
if exists (select 1 from sys.columns where object_id = object_id('PnTablas.Persona') and name = 'DNI')
begin
    alter table PnTablas.Persona drop column DNI;
    print '   -- Columna Persona.DNI (sin cifrar) eliminada.'
end
go

-- Eliminar columna Telefono original
if exists (select 1 from sys.columns where object_id = object_id('PnTablas.Persona') and name = 'Telefono')
begin
    alter table PnTablas.Persona drop column Telefono;
    print '   -- Columna Persona.Telefono (sin cifrar) eliminada.'
end
go

-- ----------
-- Tabla Guia
-- ----------

-- Agregar columnas cifradas si no existen
if not exists (select 1 from sys.columns where object_id = object_id('PnTablas.Guia') and name = 'NumeroHabilitacion_Cifrado')
    alter table PnTablas.Guia add NumeroHabilitacion_Cifrado varbinary(256) null;
go

-- Migrar datos existentes a las columnas cifradas
if exists (select 1 from sys.columns where object_id = object_id('PnTablas.Guia') and name = 'NumeroHabilitacion')
begin
    open symmetric key SymKey_DatosSensibles
        decryption by certificate CertColumnas_Pn;

    update PnTablas.Guia
    set NumeroHabilitacion_Cifrado =
        encryptbykey(key_guid('SymKey_DatosSensibles'), convert(varbinary, convert(varchar, NumeroHabilitacion)))
    where NumeroHabilitacion is not null;

    close symmetric key SymKey_DatosSensibles;
    print '   -- Datos de Guia.NumeroHabilitacion migrados a columna cifrada.';
end
go

-- Eliminar columna original
if exists (select 1 from sys.columns where object_id = object_id('PnTablas.Guia') and name = 'NumeroHabilitacion')
begin
    alter table PnTablas.Guia drop column NumeroHabilitacion;
    print '   -- Columna Guia.NumeroHabilitacion (sin cifrar) eliminada.'
end
go

-- ---------------
-- Tabla Historial
-- ---------------

-- Agregar columnas cifradas si no existen
if not exists (select 1 from sys.columns where object_id = object_id('PnTablas.Historial') and name = 'RazonEgreso_Cifrada')
    alter table PnTablas.Historial add RazonEgreso_Cifrada varbinary(512) null;
go

-- Migrar datos existentes a las columnas cifradas
if exists (select 1 from sys.columns where object_id = object_id('[PnTablas].[Historial]') and name = 'RazonEgreso')
begin
    open symmetric key SymKey_DatosSensibles
        decryption by certificate CertColumnas_Pn;

    update [PnTablas].[Historial]
    set RazonEgreso_Cifrada = encryptbykey(key_guid('SymKey_DatosSensibles'), convert(varbinary, RazonEgreso))
    where RazonEgreso is not null;

    close symmetric key SymKey_DatosSensibles;
    print '   -- Datos de Historial.RazonEgreso migrados a columna cifrada.';
end
go

-- Eliminar columna original
if exists (select 1 from sys.columns where object_id = object_id('PnTablas.Historial') and name = 'RazonEgreso')
begin
    alter table [PnTablas].[Historial] drop column RazonEgreso;
    print '   -- Columna Historial.RazonEgreso (sin cifrar) eliminada.'
end
go

-- ==========================================================
-- SP PARA OPERAR DATOS CIFRADOS
-- ==========================================================

print '-- [4/4] Creando/reemplazando SPs que operan con columnas cifradas...';
go

-- ---------------------------------------
-- SP altaPersona (reemplaza al anterior)
-- ---------------------------------------
if exists (select 1 from sys.objects where object_id = object_id('PnSPabm.altaPersona'))
    drop procedure PnSPabm.altaPersona;
go
create procedure PnSPabm.altaPersona
    @dni int,
    @nombre varchar(20),
    @apellido varchar(20),
    @telefono varchar(12),
    @rol varchar(10)
with execute as owner
as
begin
    declare @errorCount int = 0;
    declare @errorLine  varchar(200) = 'Error/es:';

    if (@dni is null or @dni <= 0 or @dni > 99999999)
    begin
        set @errorCount += 1;
        set @errorLine  += char(13) + '- Numero de DNI invalido.';
    end

    if (@rol not in ('Guardaparque', 'Guia'))
    begin
        set @errorCount += 1;
        set @errorLine  += char(13) + '- Rol invalido. Valores: Guardaparque, Guia.';
    end

    if (@nombre is null or ltrim(@nombre) = '')
    begin
        set @errorCount += 1;
        set @errorLine  += char(13) + '- Nombre invalido.';
    end

    if (@apellido is null or ltrim(@apellido) = '')
    begin
        set @errorCount += 1;
        set @errorLine  += char(13) + '- Apellido invalido.';
    end

    -- busca DNI cifrado comparando hash
    -- Usamos HASHBYTES para comparacion sin necesidad de abrir la clave en cada fila
    if (@errorCount = 0 and exists(
        select 1 from PnTablas.Persona
        where HashDNI = hashbytes('SHA2_256', convert(varbinary, convert(varchar, @dni)))
    ))
    begin
        set @errorCount += 1;
        set @errorLine  += char(13) + '- Persona con ese DNI ya presente.';
    end

    if @errorCount = 0
    begin
        open symmetric key SymKey_DatosSensibles
            decryption by certificate CertColumnas_Pn;

        insert into PnTablas.Persona (NombrePersona, Apellido, Rol, DNI_Cifrado, Telefono_Cifrado, HashDNI)
        values (
            @nombre,
            @apellido,
            @rol,
            encryptbykey(key_guid('SymKey_DatosSensibles'), convert(varbinary, convert(varchar, @dni))),
            encryptbykey(key_guid('SymKey_DatosSensibles'), convert(varbinary, @telefono)),
            hashbytes('SHA2_256', convert(varbinary, convert(varchar, @dni)))
        );
        close symmetric key SymKey_DatosSensibles;
    end
    else
        print @errorLine;
end;
go
print '   -- SP altaPersona actualizado con cifrado.';
go

-- ----------------------------------------------------------------
-- SP: consultarPersona (solo roles autorizados pueden ejecutarlo)
-- ----------------------------------------------------------------
if exists (select 1 from sys.objects where object_id = object_id('PnSPabm.consultarPersona'))
    drop procedure PnSPabm.consultarPersona;
go
create procedure PnSPabm.consultarPersona
    @IDPersona int = null   -- null = todas las personas
as
begin
    open symmetric key SymKey_DatosSensibles
        decryption by certificate CertColumnas_Pn;

    select
        p.IDPersona,
        p.NombrePersona,
        p.Apellido,
        p.Rol,
        convert(int, convert(varchar, decryptbykey(p.DNI_Cifrado))) as DNI,
        convert(varchar(12), decryptbykey(p.Telefono_Cifrado)) as Telefono
    from PnTablas.Persona p
    where (@IDPersona is null or p.IDPersona = @IDPersona);

    close symmetric key SymKey_DatosSensibles;
end;
go
print '-- SP consultarPersona creado.';
go

-- ------------------------------------
-- SP altaGuia (reemplaza al anterior)
-- ------------------------------------
if exists (select 1 from sys.objects where object_id = object_id('PnSPabm.altaGuia'))
    drop procedure PnSPabm.altaGuia;
go
create procedure PnSPabm.altaGuia
    @idPersona int,
    @titulo varchar(100),
    @vencimientoHabilitacion date,
    @numeroHabilitacion int
with execute as owner
as
begin
    declare @errorCount int = 0;
    declare @errorLine  varchar(200) = 'Error/es:';

    if (@numeroHabilitacion is null or @numeroHabilitacion <= 0)
    begin
        set @errorCount += 1;
        set @errorLine  += char(13) + '- Numero de habilitacion invalido.';
    end

    if (@vencimientoHabilitacion is null or @vencimientoHabilitacion <= cast(getdate() as date))
    begin
        set @errorCount += 1;
        set @errorLine  += char(13) + '- Habilitacion vencida o invalida.';
    end

    if (@errorCount = 0 and not exists(select 1 from PnTablas.Persona where IDPersona = @idPersona))
    begin
        set @errorCount += 1;
        set @errorLine  += char(13) + '- La persona no existe.';
    end

    if (@errorCount = 0 and exists(select 1 from PnTablas.Persona where IDPersona = @idPersona and Rol <> 'Guia'))
    begin
        set @errorCount += 1;
        set @errorLine  += char(13) + '- La persona tiene un rol diferente asignado.';
    end

    if (@errorCount = 0 and exists(select 1 from PnTablas.Guia where IDGuia = @idPersona))
    begin
        set @errorCount += 1;
        set @errorLine  += char(13) + '- Guia ya presente.';
    end

    if @errorCount = 0
    begin
        open symmetric key SymKey_DatosSensibles
            decryption by certificate CertColumnas_Pn;

        insert into PnTablas.Guia (IDGuia, Titulo, VencimientoHabilitacion, NumeroHabilitacion_Cifrado)
        values (
            @idPersona,
            @titulo,
            @vencimientoHabilitacion,
            encryptbykey(key_guid('SymKey_DatosSensibles'), convert(varbinary, convert(varchar, @numeroHabilitacion)))
        );

        close symmetric key SymKey_DatosSensibles;
    end
    else
        print @errorLine;
end;
go
print '   -- SP altaGuia actualizado con cifrado.';
go

-- -----------------------------------------
-- SP: altaHistorial (reemplaza al anterior)
-- -----------------------------------------
if exists (select 1 from sys.objects where object_id = object_id('PnSPabm.altaHistorial'))
    drop procedure PnSPabm.altaHistorial;
go
create procedure PnSPabm.altaHistorial
    @Guardaparque int,
    @parque int,
    @fechaIni date,
    @fechaFin date,
    @razon varchar(40)
with execute as owner
as
begin
    if exists (
        select 1 from PnTablas.Historial
        where Guardaparque = @Guardaparque and FechaInicio = @fechaIni
    )
    begin
        print 'ERROR: Registro de historial ya presente para esa fecha.';
        return;
    end

    open symmetric key SymKey_DatosSensibles
        decryption by certificate CertColumnas_Pn;

    insert into PnTablas.Historial (Guardaparque, Parque, FechaInicio, FechaEgreso, RazonEgreso_Cifrada)
    values (
        @Guardaparque,
        @parque,
        @fechaIni,
        @fechaFin,
        encryptbykey(key_guid('SymKey_DatosSensibles'), convert(varbinary, @razon))
    );

    close symmetric key SymKey_DatosSensibles;
end;
go
print '   -- SP altaHistorial actualizado con cifrado.';
go

-- ---------------------------------------------
-- SP consultarHistorial — descifra RazonEgreso
-- ---------------------------------------------
if exists (select 1 from sys.objects where object_id = object_id('PnSPabm.consultarHistorial'))
    drop procedure PnSPabm.consultarHistorial;
go
create procedure PnSPabm.consultarHistorial
    @Guardaparque int = null
as
begin
    open symmetric key SymKey_DatosSensibles
        decryption by certificate CertColumnas_Pn;

    select
        h.IDregistro,
        h.Guardaparque,
        h.Parque,
        h.FechaInicio,
        h.FechaEgreso,
        convert(varchar(40), decryptbykey(h.RazonEgreso_Cifrada)) as RazonEgreso
    from PnTablas.Historial h
    where (@Guardaparque is null or h.Guardaparque = @Guardaparque)
    order by h.FechaInicio desc;

    close symmetric key SymKey_DatosSensibles;
end;
go
print '   -- SP consultarHistorial creado.';
go

print '== Cifrado: script completado ==';
go