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

-- Testing de los SPs de manejo de API

SET NOCOUNT ON;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ParquesNacionales')
BEGIN
	USE ParquesNacionales
	PRINT '--Usando BD: ParquesNacionales--' 
END;
GO

-------------------------------------------------------------------------------------
DECLARE @PrecioDolar DECIMAL(18,2);
DECLARE @TempActual DECIMAL(5,2);
DECLARE @Lluvia BIT;
DECLARE @EstadoClima VARCHAR(50);

EXEC PnSPabm.ObtenerCotizacionDolar @ValorVentaDolar = @PrecioDolar OUTPUT;
EXEC PnSPapi.ObtenerClimaActual @Latitud = '20.50', @Longitud = '45.23', @EsLluvioso = @Lluvia OUTPUT;

IF @Lluvia = 1 SET @EstadoClima = 'Jornada Lluviosa'; ELSE SET @EstadoClima = 'Condiciones Favorables';

SELECT 
    @PrecioDolar AS [Cotización Dólar Oficial],
    @TempActual AS [Temperatura Actual (°C)],
    @EstadoClima AS [Estado del Clima];
GO