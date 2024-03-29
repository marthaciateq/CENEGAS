ALTER PROCEDURE sps_reporte_mensualCRE
	@idsesion varchar(max),
	@pmuestreo varchar(max),
	@finicial varchar(max),
	@ffinal varchar(max),
	@resultado int, --(1) Solo puntos de muestreo que cuentan con información fuera de especificacion (2) Informacion completa	
	@tipo varchar(max)='MIN'-- 'PROM','MAX','MIN
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	declare @d_finicial date
	declare @d_ffinal date

	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		if @finicial is null execute sp_error 'U','Favor de seleccionar fecha inicial'
		if @ffinal is null execute sp_error 'U','Favor de seleccionar fecha final'
		
		set @d_finicial=convert(date,@finicial,103)
		set @d_ffinal=convert(date,@ffinal,103)		
		
		if(@d_finicial>@d_ffinal) execute sp_error 'U','La fecha inicial debe ser menor que la final'
		if ( (@pmuestreo is null and DATEDIFF(day,@d_finicial,@d_ffinal)>31) or (@pmuestreo is not null and DATEDIFF(day,@d_finicial,@d_ffinal)>90) )
			execute sp_error 'U','El máximo rango de consulta sin puntos de muestreo son 31 dias y con puntos de muestreo 3 meses'
	
		declare @fcero datetime
		declare @fechas table(
			fecha datetime
		)
		declare @elementos table(
			celemento varchar(max),
			orden int
		)
		insert into @elementos values('metano',1);
		insert into @elementos values('bioxidocarbono',2);
		insert into @elementos values('nitrogeno',3);		
		insert into @elementos values('totalinertes',4);		
		insert into @elementos values('etano',5);		
		insert into @elementos values('temprocio',6);		
		insert into @elementos values('humedad',7);		
		insert into @elementos values('podercalorifico',8);		
		insert into @elementos values('indicewoobe',9);		
		insert into @elementos values('acidosulfhidrico',10);												
		insert into @elementos values('azufretotal',11);														
		insert into @elementos values('oxigeno',12);

		set @fcero=@d_finicial
		while @fcero<=@d_ffinal
		begin
			insert into @fechas values(@fcero)
			set @fcero=dateadd(day,1,@fcero)
		end 

		select a.*,
			dateadd(hh,a.hcorte,convert(datetime,convert(date,a.fecha))) fcorte,	
			dateadd(hh,23, dateadd(hh,a.hcorte,convert(datetime,convert(date,a.fecha)))) rango		
		into #base_rpromedio
		from v_promedios a
		where 
			(fecha>=@d_finicial and convert(date,fecha)<=@d_ffinal)
			and (@pmuestreo is null or idpmuestreo in (select col1 from dbo.fn_table(1,@pmuestreo)))

		select 
			a.idpmuestreo,
			a.idelemento,
			a.nalterno,
			a.elemento,
			a.fecha fpromedio,
			b.fecha fhorario,
			b.valor
		into #horarios
		from #base_rpromedio a 
			left join v_horarios b on a.idpmuestreo=b.idpmuestreo and a.idelemento=b.idelemento	and b.fecha<=a.rango and b.fecha>=a.fcorte

		select 
			distinct b.*
		into #pmuestreo
		from 
			#horarios a
				inner join v_pmuestreo b on a.idpmuestreo=b.idpmuestreo

		select c.fecha,
				b.idelemento,
				b.descripcion elemento,
				b.unidad,
				b.codigo,
				b.orden oelemento,
				d.idpmuestreo,
				d.pmuestreo,
				d.tcre,
				d.zonaS,
				d.orden opmuestreo
		into #combinacion
		from @elementos a
			left join v_elementos b on a.celemento=b.codigo,
			@fechas c,#pmuestreo d

			
		select @d_finicial=min(fecha),@d_ffinal=max(fecha) 
		from #base_rpromedio
		

				
		if @resultado=1
		begin
			select 
				distinct a.idpmuestreo,
				cast(b.orden as varchar(max))+'.'+b.abreviatura pmuestreo,
				b.orden npmuestreo,
				b.abreviatura abrev_pmuestreo,
				null as idelemento,
				null as descripcion
			from 
				#horarios a
					left join v_pmuestreo b on a.idpmuestreo=b.idpmuestreo
		end
		else
		begin				

			select 
				idpmuestreo,
				idelemento,
				nalterno pmuestreo,
				elemento,
				fpromedio,
				max(valor) max_horario,
				avg(valor) prom_horario,
				min(valor) min_horario		
			into #maximos_horarios
			from #horarios
			group by idpmuestreo,idelemento,nalterno,elemento,fpromedio
			--select * from #maximos_horarios

			select 
				idpmuestreo,
				idelemento,
				pmuestreo,
				elemento,		
				min(case when @tipo='PROM' then prom_horario when @tipo='MAX' then max_horario else min_horario end) minimo,
				max(case when @tipo='PROM' then prom_horario when @tipo='MAX' then max_horario else min_horario end) maximo,
				avg(case when @tipo='PROM' then prom_horario when @tipo='MAX' then max_horario else min_horario end) promedio,
				stdev(case when @tipo='PROM' then prom_horario when @tipo='MAX' then max_horario else min_horario end) desviacion
			into #tabla1						
			from #maximos_horarios
			group by idpmuestreo,idelemento,pmuestreo,elemento	

			select 
				a.idpmuestreo,
				a.pmuestreo,
				a.idelemento,
				a.elemento+ CHAR(13)+CHAR(10)+'('
				+ case 
					when charindex('3',a.unidad)>0 then replace(a.unidad,'3',NCHAR(0x00B3))
					when charindex('2',a.unidad)>0 then replace(a.unidad,'2',NCHAR(0x00B2)) 
				else a.unidad end 
				+')' as elemento,	
				a.fecha,
				case when @tipo='PROM' then prom_horario when @tipo='MAX' then max_horario else min_horario end valor,
				c.minimo,c.maximo,c.promedio,c.desviacion,
				b.fpromedio,
				dbo.fn_datetimeToString(a.fecha,1) fpromedioS,
				'Hora de Corte: '+ dbo.fn_datetimeToString(b.fpromedio,5) observaciones,
				a.zonaS,
				a.tcre,
				a.codigo,
				@tipo tipo
			from #combinacion a
				left join #maximos_horarios b on a.idpmuestreo=b.idpmuestreo and a.idelemento=b.idelemento and a.fecha=convert(date,b.fpromedio)
					left join #tabla1 c on a.idpmuestreo=c.idpmuestreo and a.idelemento=c.idelemento
			order by a.opmuestreo,a.pmuestreo,a.fecha,oelemento						

		end
		
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END