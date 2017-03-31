create table valores2(
	columna1 varchar(max),
	columna2 varchar(max),
	columna3 varchar(max)
)		

GO

BULK INSERT valores
	from 'c:\meth\catalogo.csv'
	with(
		fieldterminator=',',
		rowterminator='\n'
	)
go

