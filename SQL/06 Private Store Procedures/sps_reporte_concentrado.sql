CREATE PROCEDURE sps_reporte_concentrado
	@idsesion varchar(max),
	@finicial varchar(max),
	@ffinal varchar(max),
	@formato varchar(max)
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	declare @d_finicial date
	declare @d_ffinal date
	declare @nelementos int

	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		if @finicial is null execute sp_error 'U','Favor de seleccionar fecha inicial'
		if @ffinal is null execute sp_error 'U','Favor de seleccionar fecha final'
		
		set @d_finicial=convert(date,@finicial,103)
		set @d_ffinal=convert(date,@ffinal,103)		
		
		if(@d_finicial>@d_ffinal) execute sp_error 'U','La fecha inicial debe ser menor que la final'

		
		
		select a.*,
			dateadd(hh,a.hcorte,convert(datetime,convert(date,a.fecha))) fcorte,	
			dateadd(hh, 23, dateadd(hh,a.hcorte,convert(datetime,convert(date,a.fecha)))) rango
		into #base_rpromedio
		from v_promedios a
			left join v_pmuestreo b on a.idpmuestreo=b.idpmuestreo
		where 
			(fecha>=@d_finicial and convert(date,fecha)<=@d_ffinal)

		--PROMEDIOS FUERA DE ESPECIFICACION

		select a.*
			into #fespecificacion
		from
			#base_rpromedio a 
			inner join especificaciones c on a.idelemento=c.idelemento and a.zona=c.zona and c.deleted='N' 
				and c.fecha=(select max(z.fecha) from especificaciones z 
								where z.idelemento=a.idelemento and z.zona=a.zona and convert(date,a.fecha)>=z.fecha)
		where 
			(a.promedio<c.minimo or a.promedio>c.maximo)
		order by a.idpmuestreo,a.idelemento

		-- CONCATENAR RECUERRENCIA DE ELEMENTOS FUERA DE ESPECIFICACION POR PUNTO DE MUESTREO
		select distinct c.orden,T2.idpmuestreo,T2.nalterno,
			STUFF(
				(
					select distinct ','+ b.abreviatura 
						from #fespecificacion T1
							inner join v_elementos b on T1.idelemento=b.idelemento
						where T1.nalterno=T2.nalterno 
						FOR XML PATH('') 
				)
			,1,1,'') elementos
		into #elementos
		from #fespecificacion T2
			inner join v_pmuestreo c on T2.idpmuestreo=c.idpmuestreo
	
		-- CALCULAR TOTALES DE RECURRENCIA POR PUNTO DE MUESTREO Y ELEMENTO
		select distinct c.orden,a.idpmuestreo,a.nalterno,a.idelemento,b.abreviatura,count(a.fecha) total 
		into #totales
		from #fespecificacion a
			inner join v_elementos b on a.idelemento=b.idelemento
			inner join v_pmuestreo c on a.idpmuestreo=c.idpmuestreo
		group by c.orden,a.idpmuestreo,a.nalterno,a.idelemento,b.abreviatura
		order by c.orden,b.abreviatura

		--select * from #totales
		
		-- CONCATENAR LOS TOTALES DE RECURRENCIA POR PUNTO DE MUESTREO Y ELEMENTO
		select distinct idpmuestreo,nalterno, 
			STUFF(
				(
					select concat(',',total) from #totales T1
						where T1.idpmuestreo=T2.idpmuestreo
						order by T1.orden,T1.abreviatura
						FOR XML PATH('') 
				)
			,1,1,'') total
		into #totales2
		from #totales T2

		-- CONSULTAR SI EL PUNTO DE MUESTREO REGISTRO LOS MISMOS VALORES HORARIOS EN EL DÍA O NO SE CUENTA CON ELLOS

		select distinct a.idpmuestreo,a.nalterno,a.idelemento,a.fecha
		into #mismosHorarios
		from #fespecificacion a
		left join v_horarios b on a.idpmuestreo=b.idpmuestreo
			and a.idelemento=b.idelemento 
			and b.fecha<=a.rango and b.fecha>=a.fcorte
		group by a.idpmuestreo,a.nalterno,a.idelemento,a.fecha
		having count(distinct (b.valor))<=1 

		select @nelementos=count(idelemento)*(datediff(DAY, @d_finicial, @d_ffinal)+1) from elementos where deleted='N'

		select idpmuestreo 
		into #temp1
		from #mismosHorarios 
		group by idpmuestreo
		having count(idpmuestreo)=@nelementos

		select a.* 
		into #pmuestreoFiltrados
		from #fespecificacion a
			where idpmuestreo in (select distinct idpmuestreo from #temp1)

		select 
			distinct idpmuestreo 
		into #pmuestreo_AB
		from #mismosHorarios
			where idpmuestreo not in(
				select distinct a.idpmuestreo
					from #pmuestreoFiltrados a
						full join #mismosHorarios b on a.idpmuestreo=b.idpmuestreo and a.idelemento=b.idelemento and a.fecha=b.fecha
					where a.fecha is null or b.fecha is null
			)

		--QUE PASA SI ESTOY CONSULTADO UN RANGO DE FECHAS Y EN UN SOLO DIA NO SE REGISTRAR HORARIOS ES "AB" OR "ABC"
		--Y SI PARA OTRO PUNTO DE MUESTREO PUEDE DARSE EL CASO DE QUE UN DIA SE TENGA EL MISMO VALOR Y PUEDE SER "AB"

		 --RESULTADO FINAL
		select 
			a.orden,
			a.nalterno,
			b.elementos,
			c.total,
			case when 
				d.idpmuestreo is not null then 'AB'
				else 'ABC'
			end treporte,
			@finicial finicial,
			@ffinal ffinal
		from v_pmuestreo a
			left join #elementos b on a.idpmuestreo=b.idpmuestreo
			left join #totales2 c on a.idpmuestreo=c.idpmuestreo
			left join #pmuestreo_AB d on a.idpmuestreo=d.idpmuestreo
		where deleted='N'
		order by a.orden
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END
	
