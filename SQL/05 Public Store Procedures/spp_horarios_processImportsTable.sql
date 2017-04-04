-- =============================================
-- Author:		Angel Hernandez
-- Create date: marzo 2017
-- Description:	Trata la información de la tabla de importaciones para ser guardada en la tabla destino registros.
-- =============================================
CREATE PROCEDURE [dbo].[spp_horarios_processImportsTable]
	-- Add the parameters for the stored procedure here
	    @idbdatos   VARCHAR(32)
	  , @isUpdate   BIT
AS
BEGIN
	DECLARE @ELEMENTS_TABLE   TABLE([INDEX] INT, ID VARCHAR(32), ELEMENT VARCHAR(32));
	DECLARE @fecha            DATETIME;
	DECLARE @idPunto          VARCHAR(32);
	DECLARE @idElemento       VARCHAR(32);
	DECLARE @punto            VARCHAR(256);
	DECLARE @elemento         VARCHAR(256);
	DECLARE @nombreAlterno    VARCHAR(256);
	
	DECLARE @maxFechas        INT;
	DECLARE @maxPuntos        INT;
	DECLARE @maxElementos     INT;
	
	DECLARE @indexFecha       INT = 1;
	DECLARE @indexPunto       INT = 1;
	DECLARE @indexElemento    INT = 1;
	
	
	SET NOCOUNT ON;
	
		--BEGIN TRY
			-- ======================================================================
			-- Constantes pertenecientes al catálogo de elementos
			-- ======================================================================
			INSERT INTO @ELEMENTS_TABLE([INDEX], ID, ELEMENT) VALUES(1 , '20170309015853370572487661852156', 'METANO'           );
			INSERT INTO @ELEMENTS_TABLE([INDEX], ID, ELEMENT) VALUES(2 , '20170309015908920302612186275755', 'BIOXIDO_CARBONO'  );
			INSERT INTO @ELEMENTS_TABLE([INDEX], ID, ELEMENT) VALUES(3 , '20170309015928330107009458012671', 'NITROGENO'        );
			INSERT INTO @ELEMENTS_TABLE([INDEX], ID, ELEMENT) VALUES(4 , '20170309015944683851382958625331', 'TOTAL_INERTES'    );
			INSERT INTO @ELEMENTS_TABLE([INDEX], ID, ELEMENT) VALUES(5 , '20170309015951417199240994016694', 'ETANO'            );
			
			INSERT INTO @ELEMENTS_TABLE([INDEX], ID, ELEMENT) VALUES(6 , '20170309015957970566087161253495', 'TEMP_ROCIO'       );
			INSERT INTO @ELEMENTS_TABLE([INDEX], ID, ELEMENT) VALUES(7 , '20170309020008463989527069460466', 'HUMEDAD'          );
			INSERT INTO @ELEMENTS_TABLE([INDEX], ID, ELEMENT) VALUES(8 , '20170309020015170210604185856522', 'PODER_CALORIFICO' );
			INSERT INTO @ELEMENTS_TABLE([INDEX], ID, ELEMENT) VALUES(9 , '20170309020026853780619637897140', 'INDICE_WOOBE'     );
			INSERT INTO @ELEMENTS_TABLE([INDEX], ID, ELEMENT) VALUES(10, '20170309020037077750203474849206', 'ACIDO_SULFHIDRICO');
			
			--INSERT INTO @ELEMENTS_TABLE([INDEX], ID, ELEMENT) VALUES(11, '20170309025552797692799663893621', 'AZUFRE_TOTAL'     );
			--INSERT INTO @ELEMENTS_TABLE([INDEX], ID, ELEMENT) VALUES(12, '20170309015901120264999557990182', 'OXIGENO'          );
			-- ======================================================================
			
			
			
			-- DIAS UNICOS
			SELECT  ROW_NUMBER() OVER ( ORDER BY fecha) AS [index], fecha 
			INTO #tmpFechas
			FROM (
				SELECT DISTINCT dbo.fn_dateTimeToDate(fecha) AS fecha
				FROM dbo.importacionesHorarios WHERE idbdatos = @idbdatos
			) AS fechas;
			
			
			-- PUNTOS UNICOS
			SELECT 
				ROW_NUMBER() OVER ( ORDER BY puntosUnicosTable.idpmuestreo) AS [index], puntosUnicosTable.idpmuestreo, punto, nalterno
			INTO #tmpPuntos
			FROM
				(	SELECT 
						DISTINCT idpmuestreo 
					FROM dbo.importacionesHorarios AS importacionesTable
						INNER JOIN dbo.pmuestreo AS puntosTable ON importacionesTable.punto = puntosTable.punto
					WHERE idbdatos = @idbdatos
				) AS puntosUnicosTable
				INNER JOIN pmuestreo ON puntosUnicosTable.idpmuestreo = pmuestreo.idpmuestreo 
			;
			
			
			
			SET @maxFechas    = ( SELECT ISNULL(COUNT([index]), 0)   FROM   #tmpFechas       );
			SET @maxPuntos    = ( SELECT ISNULL(COUNT([index]), 0)   FROM   #tmpPuntos       );
			SET @maxElementos = ( SELECT ISNULL(COUNT([INDEX]), 0)   FROM   @ELEMENTS_TABLE );
			
			
			--BEGIN TRANSACTION;
			
			-- Convertir la matriz de registros de medicion en registros individuales
			WHILE @indexFecha < @maxFechas BEGIN
				SELECT   @fecha = fecha   FROM   #tmpFechas   WHERE   [index] = @indexFecha;
				
				SET @indexPunto = 1;
				
				WHILE @indexPunto < @maxPuntos BEGIN
					SELECT   @idPunto = idpmuestreo, @punto = punto, @nombreAlterno = nalterno   FROM   #tmpPuntos   WHERE   [index] = @indexPunto; 
					
					SET @indexElemento = 1;
					
					WHILE @indexElemento < @maxElementos BEGIN
						SELECT   @idElemento = ID, @elemento = ELEMENT   FROM   @ELEMENTS_TABLE   WHERE   [INDEX] = @indexElemento;
						
						EXEC [dbo].[spp_horarios_insertToSwapTable] @idbdatos, @idPunto, @punto, @nombreAlterno, @idElemento, @elemento, @fecha;
						
						SET @indexElemento = @indexElemento + 1;
					END
					
					SET @indexPunto = @indexPunto + 1;
				END
				
				SET @indexFecha = @indexFecha + 1;
			END


			--COMMIT TRANSACTION

			---- Insertar en la bitacora de registros aquellos que están fuera de fecha.
			EXEC [dbo].[spp_horarios_processOutOfDateRecords]  @idbdatos;
			---- Insertar en la bitacora de registros aquellos que fueron ignorados.
			EXEC [dbo].[spp_horarios_mergeSwapTableAndRecords] @idbdatos, @isUpdate;
			
			
			
			DROP TABLE #tmpPuntos;
			DROP TABLE #tmpFechas;
			
		--END TRY	
		--BEGIN CATCH
		--	ROLLBACK TRANSACTION;
	
	
		--	DECLARE @error VARCHAR(256);
			
		--	SET @error = ERROR_MESSAGE();
			
			
		--	PRINT @error;
		--END CATCH
	
END

