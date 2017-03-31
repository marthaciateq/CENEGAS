
-- =============================================
-- Author:		Angel Hernandez
-- Create date: marzo 2017
-- Description:	Insertar el bloque de  registros del elemento
-- =============================================
CREATE PROCEDURE [dbo].[spp_horarios_insertToSwapTable]
	  @idbdatos    CHAR(32)
	, @idpmuestreo CHAR(32)
	, @punto       VARCHAR(256)
	, @nombreAlterno VARCHAR(256)
	, @idelemento  CHAR(32)
	, @elemento    CHAR(128)
	, @fecha       DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    INSERT INTO dbo.registros_swap ( idbdatos, idpmuestreo, idelemento, fecha, valor, estatus )
	SELECT @idbdatos       AS idbdatos
			, @idpmuestreo    AS idpmuestreo
			, @idelemento     AS idelemento
			, [fecha]
			, CASE @elemento 
				WHEN 'METANO'            THEN metano
				WHEN 'BIOXIDO_CARBONO'   THEN bioxidoCarbono
				WHEN 'NITROGENO'         THEN nitrogeno
				WHEN 'TOTAL_INERTES'     THEN totalInertes
				WHEN 'ETANO'             THEN etano
				WHEN 'TEMP_ROCIO'        THEN tempRocio
				WHEN 'HUMEDAD'           THEN humedad
				WHEN 'PODER_CALORIFICO'  THEN poderCalorifico
				WHEN 'INDICE_WOOBE'      THEN indiceWoobe
				WHEN 'ACIDO_SULFHIDRICO' THEN acidoSulfhidrico
				WHEN 'AZUFRE_TOTAL'      THEN azufreTotal
				WHEN 'OXIGENO'           THEN oxigeno
			  END AS valor
			  , '' AS estatus
	FROM 
			dbo.importacionesHorarios
	WHERE
			    idbdatos = @idbdatos
			AND dbo.fn_dateTimeToDate( fecha ) = dbo.fn_dateTimeToDate( @fecha )
			AND punto = @punto
			AND nombreAlterno = @nombreAlterno
			AND CASE @elemento 
				WHEN 'METANO'            THEN metano
				WHEN 'BIOXIDO_CARBONO'   THEN bioxidoCarbono
				WHEN 'NITROGENO'         THEN nitrogeno
				WHEN 'TOTAL_INERTES'     THEN totalInertes
				WHEN 'ETANO'             THEN etano
				WHEN 'TEMP_ROCIO'        THEN tempRocio
				WHEN 'HUMEDAD'           THEN humedad
				WHEN 'PODER_CALORIFICO'  THEN poderCalorifico
				WHEN 'INDICE_WOOBE'      THEN indiceWoobe
				WHEN 'ACIDO_SULFHIDRICO' THEN acidoSulfhidrico
				WHEN 'AZUFRE_TOTAL'      THEN azufreTotal
				WHEN 'OXIGENO'           THEN oxigeno
			  END IS NOT NULL;
			
			
	
END
