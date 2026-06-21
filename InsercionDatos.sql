/*
17/06/2026
Universidad Nacional de La Matanza
Bases de Datos Aplicada
DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

En este script se realiza la importación de datos
*/


use ParquesNacionales
go


--Creo la tabla
if not exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE
TABLE_SCHEMA = 'PnTablas' AND TABLE_NAME = 'Visitas')
begin
create table PnTablas.Visitas(
fechaVisita date,
origenVisitante nvarchar(30),
cantVisitas decimal(10,2),
observaciones nvarchar(200)
)
end
go

Emergencia sanitaria. Continuan las restricciones a la circulacion de las personas por las fronteras del pais

"Desde el 2021, el PN Lago Puelo dej├│ de cobrar derechos de acceso, por tal motivo, se dej├│ de contabilizar las visitas"


alter table PnTablas.Visitas
alter column observaciones nvarchar(200)
go

--Inserto datos de un CSV
BULK INSERT PnTablas.Visitas
FROM 'C:\Importar\visitas-residentes-y-no-residentes.csv'
WITH(
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIRSTROW = 2
);

select * from PnTablas.Visitas

delete PnTablas.Visitas

SELECT *
FROM OPENROWSET(
    BULK 'C:\Importar\visitas-residentes-y-no-residentes.csv',
    SINGLE_CLOB
) AS Archivo;


create table PnTablas.visitasXRegion(
indice_tiempo date,
region_destino nvarchar(100),
origen_visitante char(50),
visitas decimal(10,2),
observaciones nvarchar(100)
)
go

select * from PnTablas.visitasXRegion
go


bulk insert PnTablas.visitasXRegion
from 'C:\Importar\visitas-residentes-y-no-residentes-por-region.csv'
with(
FIELDTERMINATOR = ',', 
ROWTERMINATOR =  '\n', 
CODEPAGE = 'ACP',
firstrow = 2
)
go

































