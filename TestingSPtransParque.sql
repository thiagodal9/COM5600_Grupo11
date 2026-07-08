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

-- Testing de los SP transaccionales asociados a las tablas Parque
-- Los SP ABM de la tabla HorarioParque se testean junto a los SP transaccionales de dicha tabla

SET NOCOUNT ON;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

-------------------------------------------------------------------------------------
---- Chequeo de datos cargados inicialmente

SELECT 
    IDHorarioP, 
    CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
    CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
    Temporada
FROM PnTablas.HorarioParque;

SELECT *
FROM PnTablas.Abre;
GO

-------------------------------------------------------------------------------------
---- TESTING HorarioParque

--RESULTADOS ESPERADOS: Inserciones Fallidas

-- Falla por parámetros nulos
EXECUTE PnSPtrans.altaHorario @parque = NULL, @dia = NULL, @hapertura = NULL, @hcierre = NULL, @temporada = NULL;
-- Falla por falta de hora de apertura
EXECUTE PnSPtrans.altaHorario @parque = 1, @dia = 1, @hapertura = NULL, @hcierre = '17:00', @temporada = 'Invierno';
-- Falla por inconsistencia horaria (Apertura posterior al Cierre)
EXECUTE PnSPtrans.altaHorario @parque = 1, @dia = 1, @hapertura = '17:00', @hcierre = '10:30', @temporada = 'Invierno';
-- Falla por temporada inexistente (violación de dominio)
EXECUTE PnSPtrans.altaHorario @parque = 1, @dia = 1, @hapertura = '10:30', @hcierre = '17:00', @temporada = 'Amarillo';
-- Falla por Parque inexistente (violación de FK)
EXECUTE PnSPtrans.altaHorario @parque = 89, @dia = 28, @hapertura = '10:30', @hcierre = '17:00', @temporada = 'Invierno';
-- Falla por registro duplicado / solapamiento
EXECUTE PnSPtrans.altaHorario @parque = 1, @dia = 1, @hapertura = '10:30', @hcierre = '17:00', @temporada = 'Invierno';
GO

-- Verificación post-inserciones fallidas
SELECT 
    IDHorarioP, 
    CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
    CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
    Temporada
FROM PnTablas.HorarioParque;

SELECT * FROM PnTablas.Abre;
GO

--RESULTADOS ESPERADOS: Modificaciones Fallidas

-- Falla por parámetros nulos
EXECUTE PnSPabm.modificarHorario @horario = NULL, @haperturaNEW = NULL, @hcierreNew = NULL;
-- Falla por inconsistencia horaria (Apertura posterior al Cierre)
EXECUTE PnSPabm.modificarHorario @horario = 1, @haperturaNEW = '21:00', @hcierreNew = '20:00';
-- Falla por ID de horario inexistente
EXECUTE PnSPabm.modificarHorario @horario = 18, @haperturaNEW = '18:00', @hcierreNew = '20:00';
GO

-- Verificación post-modificaciones fallidas
SELECT 
    IDHorarioP, 
    CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
    CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
    Temporada
FROM PnTablas.HorarioParque;
GO

--RESULTADO ESPERADO: Modificación Exitosa

-- Actualiza correctamente los horarios para el ID 1
EXECUTE PnSPabm.modificarHorario @horario = 1, @haperturaNEW = '18:00', @hcierreNew = '20:00';
GO

-- Verificación post-modificación exitosa
SELECT 
    IDHorarioP, 
    CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
    CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
    Temporada
FROM PnTablas.HorarioParque;
GO

--RESULTADOS ESPERADOS: Borrado (One) Fallido

-- Falla por parámetro nulo
EXECUTE PnSPtrans.bajaHorarioOne @horario = NULL;
-- Falla por ID de horario inexistente
EXECUTE PnSPtrans.bajaHorarioOne @horario = 18;
GO

-- Verificación post-borrados fallidos
SELECT 
    IDHorarioP, 
    CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
    CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
    Temporada
FROM PnTablas.HorarioParque;

SELECT * FROM PnTablas.Abre;
GO

--RESULTADO ESPERADO: Borrado (One) Exitoso

-- Elimina correctamente el horario con ID 2
EXECUTE PnSPtrans.bajaHorarioOne @horario = 2;
GO

-- Verificación post-borrado exitoso
SELECT 
    IDHorarioP, 
    CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
    CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
    Temporada
FROM PnTablas.HorarioParque;

SELECT * FROM PnTablas.Abre;
GO

--RESULTADOS ESPERADOS: Borrado (All) Fallido

-- Falla por parámetro nulo
EXECUTE PnSPtrans.bajaHorarioAll @parque = NULL;
-- Falla por ID de parque inexistente
EXECUTE PnSPtrans.bajaHorarioAll @parque = 42;
GO

-- Verificación post-borrados fallidos
SELECT 
    IDHorarioP, 
    CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
    CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
    Temporada
FROM PnTablas.HorarioParque;

SELECT * FROM PnTablas.Abre;
GO

--RESULTADO ESPERADO: Borrado (All) Exitoso

-- Elimina correctamente todos los horarios asociados al Parque 2
EXECUTE PnSPtrans.bajaHorarioAll @parque = 2;
GO

-- Verificación final
SELECT 
    IDHorarioP, 
    CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
    CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
    Temporada
FROM PnTablas.HorarioParque;

SELECT * FROM PnTablas.Abre;
GO