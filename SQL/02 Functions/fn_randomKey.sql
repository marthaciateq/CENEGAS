CREATE FUNCTION fn_randomKey()
RETURNS varchar(32)
BEGIN
	declare @key varchar(32)
	declare @rndValue decimal(18,18)
	set @key = REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(varchar(max),GETUTCDATE(),21),'-',''),' ',''),':',''),'.','')
	while len(@key)< 32
	begin
		SELECT @rndValue = rndResult FROM v_rnd
		set @key = @key + cast(cast( @rndValue * 10000000000000000 as bigint) as varchar(max))
	end
	set @key = substring(@key, 1, 32)
	return @key
END