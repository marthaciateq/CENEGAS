CREATE FUNCTION fn_utcStringToDatetime
(
	@utcString varchar(max)
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
	
	declare @estado int = 1
	declare @token varchar(max) = ''
	declare @i int = 5
	declare @c char(1)
	
	if @utcString is null or LEN(@utcString) < 17 return null
	while @i <= LEN(@utcString)
	begin
		set @c = SUBSTRING(@utcString, @i, 1)
		if @c = ',' or @i = LEN(@utcString)
		begin
			if @estado = 1 set @anio = CONVERT(int,@token)
			else if @estado = 2 set @mes = CONVERT(int,@token)
			else if @estado = 3 set @dia = CONVERT(int,@token)
			else if @estado = 4 set @hora = CONVERT(int,@token)
			else if @estado = 5 set @min = CONVERT(int,@token)
			else if @estado = 6 set @seg = CONVERT(int,@token)
			else if @estado = 7
			begin
				set @mili = CONVERT(int,@token)
				return convert(datetime, @anio + '-' + @mes + '-' + @dia + ' ' +  @hora + ':' + @min + ':' + @seg + '.' + @mili,121)
			end
			set @estado = @estado + 1
			set @token = ''
		end else set @token = @token + @c
		set @i = @i + 1
	end
	
	return @estado
END

