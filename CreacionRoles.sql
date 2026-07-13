/*
--/--/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada

Grupo 11
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

Creacion de roles de seguridad con permisos granulares.

Roles definidos:
    - pn_admin = Administrador, control de objetos y datos.
    - pn_operador = ABM de datos operativos.
    - pn_importador = Ejecucion de SPs de importacion masiva.
    - pn_consultas = Solo lectura a traves de SPs de reporte.
    - pn_auditoria = Acceso de lectura + historial descifrado.

Principio de minimo privilegio:
    - Ningun rol tiene acceso directo a tablas del schema PnTablas.
    - Todo acceso a datos pasa por SPs (PnSPabm / PnSPtrans).
    - Solo pn_admin y pn_auditoria pueden abrir la clave simetrica.
*/

if exists (select name from sys.databases where name = 'ParquesNacionales')
begin
	use ParquesNacionales
	print '--Usando BD: ParquesNacionales--' 
end;
go

print '-- Creando logins y usuarios...';
go

-- Login administrador del sistema
if not exists (select 1 from sys.server_principals where name = 'pn_admin_login')
    create login pn_admin_login with password = 'Admin_Pn2026!#Seguro';
go

-- Login operador de parques
if not exists (select 1 from sys.server_principals where name = 'pn_operador_login')
    create login pn_operador_login with password = 'Oper_Pn2026!#Seguro';
go

-- Login importador de datos
if not exists (select 1 from sys.server_principals where name = 'pn_importador_login')
    create login pn_importador_login with password = 'Import_Pn2026!#Seguro';
go

-- Login consultas / reportes
if not exists (select 1 from sys.server_principals where name = 'pn_consultas_login')
    create login pn_consultas_login with password = 'Consult_Pn2026!#Seguro';
go

-- Login auditoria
if not exists (select 1 from sys.server_principals where name = 'pn_auditoria_login')
    create login pn_auditoria_login with password = 'Audit_Pn2026!#Seguro';
go

-- Usuarios en la base de datos
if not exists (select 1 from sys.database_principals where name = 'pn_admin_user')
    create user pn_admin_user for login pn_admin_login;
go
if not exists (select 1 from sys.database_principals where name = 'pn_operador_user')
    create user pn_operador_user for login pn_operador_login;
go
if not exists (select 1 from sys.database_principals where name = 'pn_importador_user')
    create user pn_importador_user for login pn_importador_login;
go
if not exists (select 1 from sys.database_principals where name = 'pn_consultas_user')
    create user pn_consultas_user for login pn_consultas_login;
go
if not exists (select 1 from sys.database_principals where name = 'pn_auditoria_user')
    create user pn_auditoria_user for login pn_auditoria_login;
go

print '-- Logins y usuarios creados.';
go

-- ============================
-- CREAR ROLES
-- ============================

print '-- Creando roles de base de datos...';
go

if not exists (select 1 from sys.database_principals where name = 'pn_admin' and type = 'R')
    create role pn_admin;
go
if not exists (select 1 from sys.database_principals where name = 'pn_operador' and type = 'R')
    create role pn_operador;
go
if not exists (select 1 from sys.database_principals where name = 'pn_importador' and type = 'R')
    create role pn_importador;
go
if not exists (select 1 from sys.database_principals where name = 'pn_consultas' and type = 'R')
    create role pn_consultas;
go
if not exists (select 1 from sys.database_principals where name = 'pn_auditoria' and type = 'R')
    create role pn_auditoria;
go

print '-- Roles creados.';
go

-- =====================
-- PERMISOS POR ROL
-- =====================

-- ----------------------------------------------------------------
-- ROL: pn_admin
-- Permisos totales sobre schemas de SPs y tablas.
-- ----------------------------------------------------------------
print '-- Asignando permisos a pn_admin...';
go

-- Control total sobre schemas de SPs (puede crear, alterar, eliminar SPs)
grant control on schema::PnSPabm to pn_admin;
grant control on schema::PnSPtrans to pn_admin;
-- Acceso directo a tablas
grant select, insert, update, delete on schema::PnTablas to pn_admin;
-- Manejo de cifrado
grant control on symmetric key::SymKey_DatosSensibles to pn_admin;
grant control on certificate::CertColumnas_Pn to pn_admin;
-- Puede ver informacion del servidor
grant view database state to pn_admin;
-- Puede hacer backup
grant backup database to pn_admin;
grant backup log to pn_admin;
go

-- ----------------------------------------------------------------
-- ROL: pn_operador
-- ABM a traves de SPs. Sin acceso directo a tablas.
-- ----------------------------------------------------------------
print '-- Asignando permisos a pn_operador...';
go

-- Ejecutar todos los SPs del schema ABM
grant execute on schema::PnSPabm to pn_operador;
-- Ejecutar SPs transaccionales (asignaciones, ventas, etc.)
grant execute on schema::PnSPtrans to pn_operador;
-- Sin acceso directo a PnTablas
-- Sin acceso a cifrado
go

-- ----------------------------------------------------------------
-- ROL: pn_importador
-- Ejecutar exclusivamente SPs de importacion masiva.
-- ----------------------------------------------------------------
print '-- Asignando permisos a pn_importador...';
go

-- Solo SPs de importacion (schema PnSPtrans, SPs especificos)
-- Se listan explicitamente para maxima granularidad.
grant execute on schema::PnSPtrans to pn_importador;
-- Acceso de lectura a tablas de referencia necesarias para upsert
grant select on PnTablas.Parque to pn_importador;
grant select on PnTablas.Provincia to pn_importador;
grant select on PnTablas.TipoParque to pn_importador;
grant select on PnTablas.TipoActividad to pn_importador;
grant select on PnTablas.Actividad to pn_importador;
-- Sin acceso a tablas de personas ni cifrado
go

-- ----------------------------------------------------------------
-- ROL: pn_consultas
-- Solo lectura a traves de SPs de reporte.
-- ----------------------------------------------------------------
print '-- Asignando permisos a pn_consultas...';
go

-- Ejecutar SPs de reporte
-- Por ahora se otorga acceso al schema trans completo
grant execute on schema::PnSPtrans to pn_consultas;
-- Acceso de lectura a tablas NO sensibles
grant select on PnTablas.Parque            to pn_consultas;
grant select on PnTablas.TipoParque        to pn_consultas;
grant select on PnTablas.Provincia         to pn_consultas;
grant select on PnTablas.HorarioParque     to pn_consultas;
grant select on PnTablas.Abre              to pn_consultas;
grant select on PnTablas.Dia               to pn_consultas;
grant select on PnTablas.Actividad         to pn_consultas;
grant select on PnTablas.TipoActividad     to pn_consultas;
grant select on PnTablas.HorarioActividad  to pn_consultas;
grant select on PnTablas.Especialidad      to pn_consultas;
grant select on PnTablas.TieneEspecialidad to pn_consultas;
-- Puede ver nombre, apellido y rol de personas pero no los campos cifrados
grant select on PnTablas.Persona to pn_consultas;
-- Sin acceso a columnas cifradas ni a clave simetrica
deny select on PnTablas.Persona(DNI_Cifrado) to pn_consultas;
deny select on PnTablas.Persona(Telefono_Cifrado) to pn_consultas;
go

-- ----------------------------------------------------------------
-- ROL: pn_auditoria
-- Puede ejecutar SP consultarPersona y consultarHistorial.
-- ----------------------------------------------------------------
print '-- Asignando permisos a pn_auditoria...';
go

-- Ejecutar SPs de consulta con descifrado
grant execute on PnSPabm.consultarPersona to pn_auditoria;
grant execute on PnSPtrans.consultarHistorial to pn_auditoria;
-- Acceso a la clave simetrica para poder descifrar dentro de los SPs
grant control on symmetric key::SymKey_DatosSensibles to pn_auditoria;
grant control on certificate::CertColumnas_Pn to pn_auditoria;
-- Lectura de todas las tablas
grant select on schema::PnTablas to pn_auditoria;
-- Solo lectura, sin modificacion
go

-- ============================================================
-- ASIGNAR USUARIOS A ROLES
-- ============================================================

print '-- Asignando usuarios a roles...';
go

alter role pn_admin      add member pn_admin_user;
alter role pn_operador   add member pn_operador_user;
alter role pn_importador add member pn_importador_user;
alter role pn_consultas  add member pn_consultas_user;
alter role pn_auditoria  add member pn_auditoria_user;
go

print '-- Usuarios asignados a roles.';
go

-- ============================================================
-- VERIFICACION DE ROLES Y PERMISOS
-- ============================================================
print '-- Verificando configuracion de roles...';
go

-- Listar roles y sus miembros
select
    r.name as Rol,
    m.name as Usuario,
    m.type_desc as TipoUsuario
from sys.database_role_members drm
join sys.database_principals r on drm.role_principal_id = r.principal_id
join sys.database_principals m on drm.member_principal_id = m.principal_id
where r.name like 'pn_%'
order by r.name, m.name;
go

-- Listar permisos por rol
select
    dp.name as Rol,
    p.state_desc as Estado,
    p.permission_name as Permiso,
    coalesce(
        object_schema_name(p.major_id) + '.' + object_name(p.major_id),
        schema_name(p.major_id),
        '(base de datos)'
    ) as Objeto
from sys.database_permissions p
join sys.database_principals dp on p.grantee_principal_id = dp.principal_id
where dp.name like 'pn_%'
order by dp.name, p.permission_name;
go

print '== Roles: script completado ==';
go