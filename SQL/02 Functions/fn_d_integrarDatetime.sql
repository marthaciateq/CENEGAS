CREATE FUNCTION fn_d_integrarDatetime
(
	@fecha datetime,
	@hverano char(1)='S',
	@offset smallint=6
)
RETURNS datetime
AS
BEGIN
	DECLARE @LocalDate AS DATETIME
	SET @LocalDate = @fecha

	DECLARE @DaylightSavingOffset AS SMALLINT
	DECLARE @Year as SMALLINT
	DECLARE @DSTStartDate AS DATETIME
	DECLARE @DSTEndDate AS DATETIME
	
	IF @hverano='S'
	BEGIN
		SET @Year = YEAR(@LocalDate)

		--PRIMER DOMINGO DE ABRIL
		SET @DSTStartDate = CAST(@Year AS CHAR(4)) + '-04-01 02:00:00'
		WHILE (DATENAME(dw, @DSTStartDate) <> 'Sunday') SET @DSTStartDate = DATEADD(day, 1,@DSTStartDate)

		--ULTIMO DOMINGO DE OCTUBRE
		SET @DSTEndDate = CAST(@Year AS CHAR(4)) + '-11-01 02:00:00'
		WHILE (DATENAME(dw, @DSTEndDate) <> 'Sunday') SET @DSTEndDate = DATEADD(day,-1,@DSTEndDate)

		IF @LocalDate BETWEEN @DSTStartDate AND @DSTEndDate SET @offset=@Offset+1
	END

	RETURN DATEADD(hh, @Offset, @LocalDate)
END
GO