-- =============================================
-- Author:		Angel Hernandez
-- Create date: abril 2017
-- Description:	Obtiene el nombre del archivo en el servidor mediante su ID
-- =============================================
CREATE PROCEDURE [dbo].[sps_getFileName]
	-- Add the parameters for the stored procedure here
	    @idbdatos            VARCHAR(32)
	  , @idsesion            VARCHAR(32)
AS
BEGIN
	DECLARE @NULLERROR     BIGINT = 515
	DECLARE @USERERROR     BIGINT = 50000
	DECLARE @SEVERITY      INT    = 15     --Severity levels from 0 through 18 can be specified by any user.
	DECLARE @STATE         INT    = 100    --Is an integer from 0 through 255. Negative values or values larger than 255 generate an error.
	DECLARE @errorMsg      VARCHAR(max)='SQL%d%s'
	
	
	DECLARE @userId     CHAR(32);
	
	SET NOCOUNT ON;
	
	BEGIN TRY 
		
		EXECUTE sp_servicios_validar @idsesion, @@PROCID, @userId OUTPUT;
	
	
		SELECT narchivo, noriginal  FROM dbo.bdatos WHERE idbdatos = @idbdatos;
		
	END TRY	
	BEGIN CATCH

		SET @errorMsg= ERROR_MESSAGE();
		EXECUTE sp_error 'S', @errorMsg;
	END CATCH

END

