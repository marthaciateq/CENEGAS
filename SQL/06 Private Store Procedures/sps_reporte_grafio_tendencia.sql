declare @query varchar(max)
declare @cols varchar(max)
declare @fechas table(
	fecha date
)
declare @fechaCero date
set @fechaCero=convert(date,'2017-02-01')
while @fechaCero<=convert(date,'2017-02-10')
begin
	insert into @fechas select @fechaCero
	set @fechaCero=dateadd(dd,1,@fechaCero)
end

select @cols = STUFF((SELECT ',' + '['+replace(convert(varchar(max),fecha,103),'/','-')+']'  from @fechas
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

drop table #unpivot
	select
		punto,
		nalterno,
		descripcion,
		fecha,
		concepto,
		valor
	into #unpivot
	from(
		select
			b.punto,
			b.nalterno,
			c.descripcion,
			replace(convert(varchar(max),a.fecha,103),'/','-') fecha,
			a.promedio,
			convert(float,d.minimo) minimo,
			convert(float,d.maximo) maximo,
			(
				select avg(promedio) 
				from rpromedio z 
				where  
					a.idpmuestreo=z.idpmuestreo
					and dateadd(dd,-4,a.fecha)<=z.fecha and z.fecha<=a.fecha
			) tendencia
			
		from rpromedio a
			inner join pmuestreo b on a.idpmuestreo=b.idpmuestreo
			inner join elementos c on a.idelemento=c.idelemento
			inner join especificaciones d on a.idelemento=d.idelemento and b.zona=d.zona
	) SOURCE
	unpivot (valor FOR concepto IN ( tendencia,promedio,minimo )) as pivottable
	
select punto,nalterno,descripcion,min(valor) min_valor,max(valor) max_valor 
from #unpivot
group by punto,nalterno,descripcion
order by punto,nalterno,descripcion

select
	b.punto,
	b.nalterno,
	c.descripcion,
	convert(date,a.fecha) fecha,
	a.promedio,
	convert(float,d.minimo) minimo,
	convert(float,d.maximo) maximo,
	(
		select avg(promedio) 
		from rpromedio z 
		where  
			a.idpmuestreo=z.idpmuestreo
			and dateadd(dd,-4,a.fecha)<=z.fecha and z.fecha<=a.fecha
			and z.idelemento=a.idelemento
	) tendencia
from rpromedio a
	inner join pmuestreo b on a.idpmuestreo=b.idpmuestreo
	inner join elementos c on a.idelemento=c.idelemento
	inner join especificaciones d on a.idelemento=d.idelemento and b.zona=d.zona
order by b.nalterno,c.descripcion,convert(date,a.fecha)

set @query=
'SELECT 
		punto,
		nalterno,
		descripcion, 
		concepto,
		'+@cols+'
FROM
(
	select * from #unpivot
) UNPIVOT_TABLE
PIVOT ( min(UNPIVOT_TABLE.valor) FOR UNPIVOT_TABLE.fecha IN ('+@cols+')) as pivottable'

execute(@query)



