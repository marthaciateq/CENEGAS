drop table valores2
create table valores2(
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

BULK INSERT valores2
	from 'c:\meth\cenegas\valores2.csv'
	with(
		fieldterminator=',',
		rowterminator='\n'
	)
go

