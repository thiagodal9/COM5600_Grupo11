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

--Testing de los SP transaccionales asociados a las tablas Parque
--Los SP ABM de la tabla HorarioParque se testean junto a los SP transaccionales de dicha tabla

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----Chequeo de datos cargados
SELECT IDHorarioP, 
CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
Temporada
FROM PnTablas.HorarioParque;

SELECT *
FROM PnTablas.Abre;
GO
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
----TESTING

----HorarioParque
--Insercion fallida
EXECUTE PnSPtrans.altaHorario
@parque = NULL,
@dia = NULL, 
@hapertura = NULL,
@hcierre = NULL,
@temporada = NULL;
EXECUTE PnSPtrans.altaHorario
@parque = 1,
@dia = 1, 
@hapertura = NULL,
@hcierre = '17:00',
@temporada = 'Invierno';
EXECUTE PnSPtrans.altaHorario
@parque = 1,
@dia = 1, 
@hapertura = '17:00',
@hcierre = '10:30',
@temporada = 'Invierno';
EXECUTE PnSPtrans.altaHorario
@parque = 1,
@dia = 1, 
@hapertura = '10:30',
@hcierre = '17:00',
@temporada = 'Amarillo';
EXECUTE PnSPtrans.altaHorario
@parque = 89,
@dia = 28, 
@hapertura = '10:30',
@hcierre = '17:00',
@temporada = 'Invierno';
EXECUTE PnSPtrans.altaHorario
@parque = 1,
@dia = 1, 
@hapertura = '10:30',
@hcierre = '17:00',
@temporada = 'Invierno';
GO

SELECT IDHorarioP, 
CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
Temporada
FROM PnTablas.HorarioParque;

SELECT *
FROM PnTablas.Abre;
GO

----Modificacion Fallida
EXECUTE PnSPabm.modificarHorario 
@horario = NULL, 
@haperturaNEW = NULL, 
@hcierreNew = NULL;
EXECUTE PnSPabm.modificarHorario 
@horario = 1, 
@haperturaNEW = '21:00', 
@hcierreNew = '20:00';
EXECUTE PnSPabm.modificarHorario 
@horario = 18, 
@haperturaNEW = '18:00', 
@hcierreNew = '20:00';
GO

SELECT IDHorarioP, 
CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
Temporada
FROM PnTablas.HorarioParque;
GO

----Modificacion Exitosa
EXECUTE PnSPabm.modificarHorario 
@horario = 1, 
@haperturaNEW = '18:00', 
@hcierreNew = '20:00';
GO

SELECT IDHorarioP, 
CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
Temporada
FROM PnTablas.HorarioParque;
GO

----BorradoOne Fallido
--PnSPtrans.bajaHorarioOne (@horario INT)
EXECUTE PnSPtrans.bajaHorarioOne @horario = NULL;
EXECUTE PnSPtrans.bajaHorarioOne @horario = 18;
GO

SELECT IDHorarioP, 
CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
Temporada
FROM PnTablas.HorarioParque;

SELECT *
FROM PnTablas.Abre;
GO

----BorradoOne Exitoso
EXECUTE PnSPtrans.bajaHorarioOne @horario = 2;
GO

SELECT IDHorarioP, 
CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
Temporada
FROM PnTablas.HorarioParque;

SELECT *
FROM PnTablas.Abre;
GO

----BorradoAll Fallido
EXECUTE PnSPtrans.bajaHorarioAll @parque = NULL;
EXECUTE PnSPtrans.bajaHorarioAll @parque = 42;
GO

SELECT IDHorarioP, 
CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
Temporada
FROM PnTablas.HorarioParque;

SELECT *
FROM PnTablas.Abre;
GO

----BorradoAll Exitoso
EXECUTE PnSPtrans.bajaHorarioAll @parque = 2;
GO

SELECT IDHorarioP, 
CAST(HoraApertura AS char(5)) AS [Hora de Apertura],
CAST(HoraCierre AS char(5)) AS [Hora de Cierre],
Temporada
FROM PnTablas.HorarioParque;

SELECT *
FROM PnTablas.Abre;
GO