declare @finicial datetime
declare @ffinal datetime
declare @fcero datetime
declare @fechas table(
	fecha datetime
)

set @finicial='2017-03-01'
set @ffinal='2017-03-31'
set @fcero=@finicial

while @fcero<@ffinal
begin
	set @fcero=dateadd(hh,1,@fcero)
	insert into @fechas values(@fcero)
end

select b.nalterno,a.fecha,c.descripcion from @fechas a, pmedicion b, elementos c
where b.deleted='N'
order by b.nalterno

drop table #fespecificacion
select a.*
,b.minimo,b.maximo
	into #fespecificacion
from
(
	select idpmedicion,a.idelemento,b.descripcion,dbo.fn_datetimeToString(a.fecha,1) fecha,avg(isnull(a.valor,0)) pdia
	from registros a
		inner join elementos b on a.idelemento=b.idelemento
	where 
		a.deleted='N'
	group by idpmedicion,a.idelemento,b.descripcion,dbo.fn_datetimeToString(a.fecha,1)
) a
	inner join especificaciones b on a.idelemento=b.idelemento and b.zona='S'
	inner join elementos c on a.idelemento=c.idelemento
where 
	(b.minimo is null or a.pdia<b.minimo)
	and (b.maximo is null or a.pdia>b.maximo)
select * from #fespecificacion order by idpmedicion,idelemento,fecha
	
select a.idpmedicion,a.idelemento,a.fecha,a.valor 
from registros a
	inner join #fespecificacion b on a.idpmedicion=b.idpmedicion and a.idelemento=b.idelemento and dbo.fn_datetimeToString(a.fecha,1)=b.fecha
where a.deleted='N'
order by a.idpmedicion,a.idelemento,fecha
	



