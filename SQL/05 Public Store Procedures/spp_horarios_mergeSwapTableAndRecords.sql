-- =============================================
-- Author:		Angel Hernandez
-- Create date: marzo 2017
-- Description:	Inserta y actualiza los datos de los Registros de medición
-- =============================================
ALTER PROCEDURE [dbo].[spp_horarios_mergeSwapTableAndRecords]
	-- Add the parameters for the stored procedure here
	    @idbdatos       VARCHAR(32)
	  , @updateRecords  BIT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @tableVar TABLE (MergeAction VARCHAR(20))
	DECLARE @IGNORED CHAR(1) = 'I';
	DECLARE @VALIDO  CHAR(1) = 1;
	
	
	DECLARE @UPDATED_RECORDS INT = 0;
	DECLARE @INSERTED_RECORDS INT = 0;
	

	IF ( @updateRecords = 1 ) BEGIN
	-- Se insertan nuevos registros y se actualiza el valor de los existentes porque así lo solicito el usuario
		MERGE dbo.Registros AS targetTable
		USING dbo.registros_swap AS sourceTable
		ON (     sourceTable.idbdatos    = @idbdatos
			 AND targetTable.idpmuestreo = sourceTable.idpmuestreo
			 AND targetTable.idelemento  = sourceTable.idelemento
			 AND targetTable.fecha       = sourceTable.fecha
		 )
		 WHEN NOT MATCHED BY TARGET THEN -- Si son registros nuevos, se insertan
			INSERT (idregistro        , idbdatos , idpmuestreo            , idelemento            , fecha            , valor            , estado ) 
			VALUES (dbo.fn_randomKey(), @idbdatos, sourceTable.idpmuestreo, sourceTable.idelemento, sourceTable.fecha, sourceTable.valor, @VALIDO)
		WHEN MATCHED THEN   -- Si ya existen, se actualizan
			UPDATE SET targetTable.valor = sourceTable.valor 
		OUTPUT
			$action INTO @tableVar
		;
		
		
		--SELECT MergeAction, COUNT(MergeAction) FROM @tableVar GROUP BY MergeAction;
		
		SELECT @INSERTED_RECORDS = ISNULL( COUNT(MergeAction), 0) FROM @tableVar WHERE MergeAction = 'INSERT';
		SELECT @UPDATED_RECORDS  = ISNULL( COUNT(MergeAction), 0) FROM @tableVar WHERE MergeAction = 'UPDATE';
		
		UPDATE dbo.bdatos SET insertados = @INSERTED_RECORDS, actualizados = @UPDATED_RECORDS WHERE idbdatos = @idbdatos;
		
		
	END
	ELSE BEGIN
		-- Los registros nuevos se agregan
		MERGE dbo.Registros AS targetTable
		USING dbo.registros_swap AS sourceTable
		ON (     sourceTable.idbdatos    = @idbdatos
			 AND targetTable.idpmuestreo = sourceTable.idpmuestreo
			 AND targetTable.idelemento  = sourceTable.idelemento
			 AND targetTable.fecha       = sourceTable.fecha
		 )
		 WHEN NOT MATCHED BY TARGET THEN
			INSERT (idregistro        , idbdatos , idpmuestreo            , idelemento            , fecha            , valor            , estado ) 
			VALUES (dbo.fn_randomKey(), @idbdatos, sourceTable.idpmuestreo, sourceTable.idelemento, sourceTable.fecha, sourceTable.valor, @VALIDO)
		OUTPUT
			$action INTO @tableVar
		;
	
	
		--SELECT MergeAction, COUNT(MergeAction) FROM @tableVar GROUP BY MergeAction;
		
		SELECT @INSERTED_RECORDS = ISNULL( COUNT(MergeAction), 0) FROM @tableVar WHERE MergeAction = 'INSERT';
		
		
		UPDATE dbo.bdatos SET insertados = @INSERTED_RECORDS WHERE idbdatos = @idbdatos;
		
	
		-- Se marcan como ignorados los registros existentes en la tabla swap
		MERGE dbo.registros_swap AS targetTable
		USING dbo.Registros AS sourceTable
		ON (     sourceTable.idbdatos    = @idbdatos
			 AND targetTable.idpmuestreo = sourceTable.idpmuestreo
			 AND targetTable.idelemento  = sourceTable.idelemento
			 AND targetTable.fecha       = sourceTable.fecha
		 )
		WHEN MATCHED THEN
			UPDATE SET targetTable.estatus = @IGNORED
		;


		-- Se insertan los registros marcados en la bitácora
		INSERT INTO bregistros ( idbregistro       , idbdatos , idpmuestreo, idelemento, fecha, valor, mensaje )
		                  SELECT dbo.fn_randomKey(), @idbdatos, idpmuestreo, idelemento, fecha, valor, @IGNORED 
		FROM dbo.registros_swap
		WHERE idbdatos = @idbdatos
			AND estatus = @IGNORED;

		-- Se eliminan los registros marcados de la tabla origen.
		DELETE FROM dbo.registros_swap WHERE idbdatos = @idbdatos   AND   estatus = @IGNORED;
	END

END

