-- =============================================
-- Author:		Angel Hernandez
-- Create date: marzo 2017
-- Description:	Inserta los reguistros fuera de fecha en la tabla de bitácora de registros
-- =============================================
CREATE PROCEDURE [dbo].[spp_horarios_processOutOfDateRecords]
	  @idbdatos    CHAR(32)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @outOfDateMessage VARCHAR(32) = 'FF';
	DECLARE @DAYS_AGO       INT      = 365 * -1;
	DECLARE @INIT_DATE        DATETIME =  DATEADD( DAY, @DAYS_AGO, GETDATE() );
	DECLARE @OUT_OF_DATE_RECORDS INT = 0;
	
	
	-- El manejo de la TRANSACCION y el CATCH se hacen en la llamada principal

	-- Insertar los registros que estan fuera de la fecha valida, desde el swap a la tabla de bitacora
	INSERT INTO dbo.bregistros ( idbregistro, idbdatos, idpmuestreo, idelemento, fecha, valor, mensaje )
	SELECT dbo.fn_randomKey()   AS idbregistro
			, idbdatos
			, idpmuestreo
			, idelemento
			, [fecha]
			, valor
			, @outOfDateMessage AS mensaje
	FROM 
			dbo.registros_swap
	WHERE
			idbdatos = @idbdatos
			AND dbo.fn_dateTimeToDate( fecha ) < dbo.fn_dateTimeToDate( @INIT_DATE ) ;
			
			
	SELECT @OUT_OF_DATE_RECORDS	= ISNULL( COUNT( idbdatos ), 0 ) FROM dbo.registros_swap WHERE idbdatos = @idbdatos AND dbo.fn_dateTimeToDate( fecha ) < dbo.fn_dateTimeToDate( @INIT_DATE ) ;
	
	UPDATE dbo.bdatos SET fueraFecha = @OUT_OF_DATE_RECORDS WHERE idbdatos = @idbdatos;
			

	-- Eliminar de la tabla de swap los registros que están fuera de fecha
	DELETE FROM dbo.registros_swap WHERE dbo.fn_dateTimeToDate( fecha ) < dbo.fn_dateTimeToDate( @INIT_DATE )  AND   idbdatos = @idbdatos;

	
END


