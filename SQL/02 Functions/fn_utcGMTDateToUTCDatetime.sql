CREATE FUNCTION fn_utcGMTDateToUTCDatetime
(
	@gmtNow varchar(max),
	@utcGMTDate datetime
)
RETURNS datetime
AS
BEGIN
	declare @d datetime = convert(datetime, @gmtNow, 121)
	return dbo.fn_gmtDatetimeToUTCDatetime(@gmtNow, CONVERT(date, dbo.fn_utcDatetimeToGMTDatetime(@gmtNow,@utcGMTDate)))
END