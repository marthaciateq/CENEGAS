-- =============================================
-- Author:		Angel Hernández
-- Create date: Abril 2017
-- Description:	Elimina de la DB los registros de la base de datos
-- =============================================
ALTER PROCEDURE [dbo].[sps_bdatos_borrar]
	@idsesion VARCHAR(32)
	, @idsHorarios VARCHAR(MAX)
	, @idsPromedios VARCHAR(MAX)
	
AS
BEGIN
	DECLARE @USERERROR     BIGINT = 50000
	DECLARE @SEVERITY      INT    = 15     --Severity levels from 0 through 18 can be specified by any user.
	DECLARE @STATE         INT    = 100    --Is an integer from 0 through 255. Negative values or values larger than 255 generate an error.
	DECLARE @errorMsg      VARCHAR(max)
	
	DECLARE @userId        VARCHAR(MAX)

	SET NOCOUNT ON;

	begin try
		EXECUTE sp_servicios_validar @idsesion, @@PROCID, @userId OUTPUT
	
	
	BEGIN TRY
	
		SELECT col1 AS idHorario
		INTO #horariosTable
		FROM  fn_table(1, @idsHorarios); 
		
		SELECT col1 AS idPromedio
		INTO #promediosTable
		FROM  fn_table(1, @idsPromedios) ;
	
		
		
		IF ( @idsPromedios IS NOT NULL  AND @idsHorarios IS NOT NULL) BEGIN
			BEGIN TRANSACTION;
	
			-- Registros de horarios
			DELETE FROM dbo.registros WHERE idbdatos IN (
				SELECT idHorario FROM #horariosTable
			);
			
			DELETE FROM dbo.horarios WHERE idbdatos IN (
				SELECT idHorario FROM #horariosTable
			);
			
			DELETE FROM dbo.bhorarios WHERE idbdatos IN (
				SELECT idHorario FROM #horariosTable
			);
			
			
			-- Registros de promedios
			DELETE FROM dbo.promedios WHERE idbdatos IN (
				SELECT idPromedio FROM #promediosTable
			);
			
			DELETE FROM dbo.rpromedio WHERE idbdatos IN (
				SELECT idPromedio FROM #promediosTable
			);
			
			DELETE FROM dbo.bpromedios WHERE idbdatos IN (
				SELECT idPromedio FROM #promediosTable
			);
			
			
			-- Marcar los registros como eliminados
			UPDATE bdatos 
			SET   bdatos.deleted = 'S'
				, bdatos.idusuariodelete = @userId
				, bdatos.fdelete = GETDATE()
			FROM dbo.bdatos AS bdatos
				INNER JOIN ( 
					SELECT idHorario AS id FROM #horariosTable
					UNION
					SELECT idPromedio FROM #promediosTable
				) AS bdatosTemp
			ON  bdatos.idbdatos = bdatosTemp.id;
			
			
			COMMIT TRANSACTION
		END
		
		
		
		DROP TABLE #horariosTable;
		DROP TABLE #promediosTable;
		
	END TRY	
	BEGIN CATCH
		ROLLBACK TRANSACTION
	
		SET @errorMsg= ERROR_MESSAGE();
		EXECUTE sp_error 'S', @errorMsg;
	END CATCH
	end try
	begin catch
		set @errorMsg = error_message()
		execute sp_error 'S', @errorMsg
	end catch
END
