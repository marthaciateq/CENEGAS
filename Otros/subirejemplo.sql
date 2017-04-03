drop table valores
create table valores(
	columna1 varchar(max),
	columna2 varchar(max),
	columna3 varchar(max),
	columna4 varchar(max),
	columna5 float,
	columna6 float,
	columna7 float,
	columna8 float,
	columna9 float,	
	columna10 float,
	columna11 float,		
	columna12 float,
	columna13 float,
	columna14 float
)		

GO

BULK INSERT valores
	from 'c:\meth\cenegas\valores1.csv'
	with(
		fieldterminator=',',
		rowterminator='\n'
	)
go

