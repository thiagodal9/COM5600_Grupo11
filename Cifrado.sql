/*
--/--/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

Cifrado de datos sensibles mediante cifr simetrico a nivel de columna.


Se queria implementar cifrado mediante TDE pero SQL Server 2025 Express Edition no es compatible
SELECT @@VERSION AS [Version_Info];


Datos sensibles identificados:
  - Persona.DNI
  - Persona.Telefono
  - Guia.NumeroHabilitacion
  - Historial.RazonEgreso

Estrategia:
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
/*
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
*/
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

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('PnTablas.Persona') AND name = 'DNI_Cifrado')
BEGIN
    ALTER TABLE PnTablas.Persona ADD 
        DNI_Cifrado      VARBINARY(256) NULL,
        Telefono_Cifrado VARBINARY(256) NULL,
        HashDNI          VARBINARY(32)  NULL;
    PRINT '   -- Columnas cifradas agregadas a Persona.';
END
GO

-- Migración de datos usando SQL Dinámico (Evita el error 207)
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('PnTablas.Persona') AND name = 'DNI')
BEGIN
    EXEC('
        OPEN SYMMETRIC KEY SymKey_DatosSensibles DECRYPTION BY CERTIFICATE CertColumnas_Pn;
        UPDATE PnTablas.Persona 
        SET DNI_Cifrado = ENCRYPTBYKEY(KEY_GUID(''SymKey_DatosSensibles''), CONVERT(VARBINARY, CONVERT(VARCHAR, DNI))),
            Telefono_Cifrado = ENCRYPTBYKEY(KEY_GUID(''SymKey_DatosSensibles''), CONVERT(VARBINARY, Telefono)),
            HashDNI = HASHBYTES(''SHA2_256'', CONVERT(VARBINARY, CONVERT(VARCHAR, DNI)))
        WHERE DNI IS NOT NULL;
        CLOSE SYMMETRIC KEY SymKey_DatosSensibles;
    ');
    PRINT '   -- Datos de Persona migrados.';
END
GO

-- Eliminación de CONSTRAINT y columnas (Lógica que ya tenías)
DECLARE @constraintName NVARCHAR(256);
SELECT @constraintName = kc.name
FROM sys.key_constraints kc
JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE kc.parent_object_id = OBJECT_ID('PnTablas.Persona') AND c.name = 'DNI' AND kc.type = 'UQ';

IF @constraintName IS NOT NULL
    EXEC('ALTER TABLE PnTablas.Persona DROP CONSTRAINT ' + @constraintName);

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('PnTablas.Persona') AND name = 'DNI')
    ALTER TABLE PnTablas.Persona DROP COLUMN DNI;

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('PnTablas.Persona') AND name = 'Telefono')
    ALTER TABLE PnTablas.Persona DROP COLUMN Telefono;
GO

-- ----------
-- Tabla Guia
-- ----------

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('PnTablas.Guia') AND name = 'NumeroHabilitacion_Cifrado')
BEGIN
    ALTER TABLE PnTablas.Guia ADD NumeroHabilitacion_Cifrado VARBINARY(256) NULL;

    EXEC('
        OPEN SYMMETRIC KEY SymKey_DatosSensibles DECRYPTION BY CERTIFICATE CertColumnas_Pn;
        UPDATE PnTablas.Guia 
        SET NumeroHabilitacion_Cifrado = ENCRYPTBYKEY(KEY_GUID(''SymKey_DatosSensibles''), CONVERT(VARBINARY, CONVERT(VARCHAR, NumeroHabilitacion)))
        WHERE NumeroHabilitacion IS NOT NULL;
        CLOSE SYMMETRIC KEY SymKey_DatosSensibles;
    ');

    ALTER TABLE PnTablas.Guia DROP COLUMN NumeroHabilitacion;
    PRINT '   -- Guia: Migración completada.';
END
GO

-- ---------------
-- Tabla Historial
-- ---------------

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('PnTablas.Historial') AND name = 'RazonEgreso_Cifrada')
    ALTER TABLE PnTablas.Historial ADD RazonEgreso_Cifrada VARBINARY(512) NULL;
GO

-- Migración usando SQL Dinámico
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = object_id('PnTablas.Historial') AND name = 'RazonEgreso')
BEGIN
    EXEC('
        OPEN SYMMETRIC KEY SymKey_DatosSensibles DECRYPTION BY CERTIFICATE CertColumnas_Pn;
        UPDATE PnTablas.Historial 
        SET RazonEgreso_Cifrada = ENCRYPTBYKEY(KEY_GUID(''SymKey_DatosSensibles''), CONVERT(VARBINARY, RazonEgreso))
        WHERE RazonEgreso IS NOT NULL;
        CLOSE SYMMETRIC KEY SymKey_DatosSensibles;
    ');
    PRINT '   -- Datos de Historial migrados.';
    
    ALTER TABLE PnTablas.Historial DROP COLUMN RazonEgreso;
    PRINT '   -- Columna Historial.RazonEgreso eliminada.';
END
GO

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
    SET NOCOUNT ON;
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

    IF @errorCount = 0
    BEGIN
        BEGIN TRY
            OPEN SYMMETRIC KEY SymKey_DatosSensibles
                DECRYPTION BY CERTIFICATE CertColumnas_Pn;

            INSERT INTO PnTablas.Persona (NombrePersona, Apellido, Rol, DNI_Cifrado, Telefono_Cifrado, HashDNI)
            VALUES (
                @nombre,
                @apellido,
                @rol,
                ENCRYPTBYKEY(KEY_GUID('SymKey_DatosSensibles'), CONVERT(VARBINARY, CONVERT(VARCHAR, @dni))),
                ENCRYPTBYKEY(KEY_GUID('SymKey_DatosSensibles'), CONVERT(VARBINARY, @telefono)),
                HASHBYTES('SHA2_256', CONVERT(VARBINARY, CONVERT(VARCHAR, @dni)))
            );
            CLOSE SYMMETRIC KEY SymKey_DatosSensibles;
        END TRY
        BEGIN CATCH
            IF SYMKEYPROPERTY(KEY_ID('SymKey_DatosSensibles'), 'IsOpen') = 1
                CLOSE SYMMETRIC KEY SymKey_DatosSensibles;
            
            PRINT 'Error grave al intentar cifrar los datos. Verifique la configuración del certificado.';
            THROW; 
        END CATCH
    END
    ELSE
        PRINT @errorLine;
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