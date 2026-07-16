/*
==============================================================================
Fecha: Junio 2026
Integrantes: DAL SECCO THIAGO
LEANDRO LEONEL VILLALBA
MAXIMO ANDINO
LEOPALDI PINAZZI AGUSTIN EMANUEL

Descripción: Habilitación de OLE Automation y SPs para consumir APIs Externas 
             (Dolar Oficial y Clima) cumpliendo el Requisito F.
Fuentes de datos utilizadas: 
1. https://dolarapi.com/v1/dolares/oficial (API Pública de Cotización)
2. https://api.open-meteo.com/ (API Pública Meteorológica)
==============================================================================
*/

USE ParquesNacionales;
GO

-- ============================================================================
-- 1. HABILITACIÓN DE CONFIGURACIONES AVANZADAS
-- ============================================================================
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;
GO

/*
================================================================
API 1: Cotización del Dólar
================================================================
*/
CREATE OR ALTER PROCEDURE PnSPabm.ObtenerCotizacionDolar
    @ValorVentaDolar DECIMAL(18,2) OUTPUT
AS
BEGIN
    DECLARE @URL VARCHAR(8000) = 'https://dolarapi.com/v1/dolares/oficial';
    DECLARE @Object INT;
    DECLARE @ResponseText NVARCHAR(4000); 
    DECLARE @HR INT;

    BEGIN TRY
        EXEC @HR = sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @Object OUT;
        EXEC @HR = sp_OAMethod @Object, 'open', NULL, 'GET', @URL, 'false';
        EXEC @HR = sp_OAMethod @Object, 'send';
        
        EXEC @HR = sp_OAGetProperty @Object, 'responseText', @ResponseText OUT;
        
        PRINT '--- DIAGNÓSTICO DÓLAR ---';
        PRINT 'Respuesta de la API: ' + ISNULL(@ResponseText, 'LA API NO DEVOLVIÓ NADA');

        EXEC sp_OADestroy @Object;

        -- Extraer valor exacto
        SET @ValorVentaDolar = CAST(JSON_VALUE(@ResponseText, '$.venta') AS DECIMAL(18,2));
    END TRY
    BEGIN CATCH
        PRINT 'Error de ejecución Dólar: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

/*
================================================================
API 2: Clima Actual
================================================================
*/
CREATE OR ALTER PROCEDURE PnSPabm.ObtenerClimaActual
    @Latitud VARCHAR(20) = '-34.61', 
    @Longitud VARCHAR(20) = '-58.38',
    @Temperatura DECIMAL(5,2) OUTPUT,
    @EsLluvioso BIT OUTPUT
AS
BEGIN
    DECLARE @URL VARCHAR(8000) = 'https://api.open-meteo.com/v1/forecast?latitude=' + @Latitud + '&longitude=' + @Longitud + '&current_weather=true';
    DECLARE @Object INT;
    DECLARE @ResponseText NVARCHAR(4000);
    DECLARE @WeatherCode INT;
    DECLARE @HR INT;

    BEGIN TRY
        EXEC @HR = sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @Object OUT;
        EXEC @HR = sp_OAMethod @Object, 'open', NULL, 'GET', @URL, 'false';
        EXEC @HR = sp_OAMethod @Object, 'send';
        
        EXEC @HR = sp_OAGetProperty @Object, 'responseText', @ResponseText OUT;
        
        -- Depuración para ver en la pestaña "Messages"
        PRINT '--- DIAGNÓSTICO CLIMA ---';
        PRINT 'Respuesta de la API: ' + ISNULL(@ResponseText, 'LA API NO DEVOLVIÓ NADA');

        EXEC sp_OADestroy @Object;

        SET @Temperatura = CAST(JSON_VALUE(@ResponseText, '$.current_weather.temperature') AS DECIMAL(5,2));
        SET @WeatherCode = CAST(JSON_VALUE(@ResponseText, '$.current_weather.weathercode') AS INT);

        IF @WeatherCode IN (51, 53, 55, 61, 63, 65, 80, 81, 82, 95, 96, 99)
            SET @EsLluvioso = 1;
        ELSE
            SET @EsLluvioso = 0;

    END TRY
    BEGIN CATCH
        PRINT 'Error de ejecución Clima: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

/*
================================================================
TESTING FINAL 
================================================================
*/
DECLARE @PrecioDolar DECIMAL(18,2);
DECLARE @TempActual DECIMAL(5,2);
DECLARE @Lluvia BIT;
DECLARE @EstadoClima VARCHAR(50);

EXEC PnSPabm.ObtenerCotizacionDolar @ValorVentaDolar = @PrecioDolar OUTPUT;
EXEC PnSPabm.ObtenerClimaActual @Temperatura = @TempActual OUTPUT, @EsLluvioso = @Lluvia OUTPUT;

IF @Lluvia = 1 SET @EstadoClima = 'Jornada Lluviosa'; ELSE SET @EstadoClima = 'Condiciones Favorables';

SELECT 
    @PrecioDolar AS [Cotización Dólar Oficial],
    @TempActual AS [Temperatura Actual (°C)],
    @EstadoClima AS [Estado del Clima];
GO