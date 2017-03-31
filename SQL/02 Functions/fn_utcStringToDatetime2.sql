CREATE  FUNCTION fn_datetimeStringToDatetime
(
	@datetimeString varchar(max)
)
RETURNS datetime
AS
BEGIN
	declare @anio varchar(max)
	declare @mes varchar(max)
	declare @dia varchar(max)
	declare @hora varchar(max)
	declare @min varchar(max)
	declare @seg varchar(max)
	declare @mili varchar(max)
	declare @fecha varchar(max)
	
	set @dia=SUBSTRING(@datetimeString, 1, 2);
	set @mes=SUBSTRING(@datetimeString, 4, 2);
	set @anio=SUBSTRING(@datetimeString, 7, 2);	
	set @hora=SUBSTRING(@datetimeString, 9, 9);	
	set @fecha=@mes+'/'+@dia+'/'+@anio+@hora
	
	return cast(@fecha as datetime)

END

