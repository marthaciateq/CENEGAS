-- =============================================
-- Author:		Angel Hernandez
-- Create date: abril 2017
-- Description:	Lee de la tabla importacionRegistros los puntos unicos y su nombre alterno y agrega a la tabla de catálogo los registros de elementos que vienen en el archivo de importación que aun NO existen en la tabla
-- =============================================
CREATE PROCEDURE [dbo].[spp_insertNuevosPuntosMuestreo]
	-- Add the parameters for the stored procedure here
	  @idHours            CHAR(32)
	, @idSummary          CHAR(32)
	, @actionForNewPoints CHAR(1) = NULL  OUTPUT 
AS
BEGIN
	DECLARE @NULLERROR     BIGINT = 515
	DECLARE @USERERROR     BIGINT = 50000
	DECLARE @SEVERITY      INT    = 15     --Severity levels from 0 through 18 can be specified by any user.
	DECLARE @STATE         INT    = 100    --Is an integer from 0 through 255. Negative values or values larger than 255 generate an error.
	DECLARE @errorMsg      VARCHAR(max)='SQL%d%s'
	DECLARE @POINTS        INT = 0;
	DECLARE @puntos        VARCHAR(MAX)
	
	
	SET NOCOUNT ON;
	
		
			
	SELECT @puntos = COALESCE(@puntos + '', '') + RTRIM(LTRIM(punto)) + '|' + RTRIM(LTRIM(nalterno)) + '||'
	FROM(
		SELECT  A.punto, A.nombreAlterno AS nalterno FROM (
			SELECT DISTINCT punto, nombreAlterno FROM importacionesHorarios WHERE idbdatos = @idHours
		) AS A
			LEFT JOIN pmuestreo AS B ON
				dbo.fn_depurateText(A.punto) = dbo.fn_depurateText(B.punto)
			AND 
				dbo.fn_depurateText(A.nombreAlterno) = dbo.fn_depurateText(B.nalterno)
		WHERE idpmuestreo IS NULL
		UNION
		SELECT  A.punto, A.nombreAlterno AS nalterno FROM (
			SELECT DISTINCT punto, nombreAlterno FROM importacionesPromedios WHERE idbdatos = @idSummary
		) AS A
			LEFT JOIN pmuestreo AS B ON
				dbo.fn_depurateText(A.punto) = dbo.fn_depurateText(B.punto)
			AND 
				dbo.fn_depurateText(A.nombreAlterno) = dbo.fn_depurateText(B.nalterno)
		WHERE idpmuestreo IS NULL
	) AS puntos			
	
	
	
	IF ( LEN(@puntos) > 0 ) BEGIN
		
		
		INSERT INTO dbo.pmuestreo ( idpmuestreo, punto, nalterno, descripcion, zona, hcorte,abreviatura,orden,deleted )
		SELECT dbo.fn_randomKey() AS idpmuestreo, RTRIM(LTRIM(punto)), RTRIM(LTRIM(nalterno)), RTRIM(LTRIM(descripcion)), zona,hcorte,'abrev',100,deleted 
		FROM(
			SELECT  A.punto, A.nombreAlterno AS nalterno, A.nombreAlterno AS descripcion, 's' AS zona,9 AS hcorte, 'N' AS deleted FROM (
				SELECT DISTINCT punto, nombreAlterno FROM importacionesHorarios WHERE idbdatos = @idHours
			) AS A
				LEFT JOIN pmuestreo AS B ON
					dbo.fn_depurateText(A.punto) = dbo.fn_depurateText(B.punto)
				AND 
					dbo.fn_depurateText(A.nombreAlterno) = dbo.fn_depurateText(B.nalterno)
			WHERE idpmuestreo IS NULL
			UNION
			SELECT  A.punto, A.nombreAlterno AS nalterno, A.nombreAlterno AS descripcion, 's' AS zona,9 AS hcorte, 'N' AS deleted FROM (
				SELECT DISTINCT punto, nombreAlterno FROM importacionesPromedios WHERE idbdatos = @idSummary
			) AS A
				LEFT JOIN pmuestreo AS B ON
					dbo.fn_depurateText(A.punto) = dbo.fn_depurateText(B.punto)
				AND 
					dbo.fn_depurateText(A.nombreAlterno) = dbo.fn_depurateText(B.nalterno)
			WHERE idpmuestreo IS NULL
		) AS puntos			
		
		SET @actionForNewPoints = 'C'; -- C = Se crearon nuevos puntos en el catálogo
	END	
		
		
	

END




