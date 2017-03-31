CREATE FUNCTION fn_gmtDatetimeToUTCDatetime
(
	@gmtNow varchar(max),
	@gmtDatetime datetime
)
RETURNS datetime
AS
BEGIN
	declare @d datetime = convert(datetime, @gmtNow, 121)
	return dateadd(hour,-round(datediff(minute, getutcdate(), @d) / 60.0, 0, null),@gmtDatetime);
END