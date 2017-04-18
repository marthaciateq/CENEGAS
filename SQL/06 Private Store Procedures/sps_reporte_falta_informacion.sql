CREATE PROCEDURE sps_reporte_falta_informacion
	@idsesion varchar(max),
	@idbdatos varchar(max),
	@pmuestreo varchar(max),
	@elementos varchar(max),	
	@finicial varchar(max),
	@ffinal varchar(max),
	@formato varchar(max),
	@resultado int --(1) Solo puntos de muestreo que cuentan con información fuera de especificacion (2) Informacion completa
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
		if ( (@pmuestreo is null and DATEDIFF(day,@d_finicial,@d_ffinal)>15) or (@pmuestreo is not null and DATEDIFF(day,@d_finicial,@d_ffinal)>90) )
			execute sp_error 'U','El máximo rango de consulta sin puntos de muestreo son 15 dias y con puntos de muestreo 3 meses'
		
		declare @t_pmuestreo table(
			idpmuestreo char(32),
			punto varchar(max),
			nalterno varchar(max),
			hcorte int
		)
		declare @fcero datetime
		declare @fechas table(
			fecha datetime
		)
		declare @fechasp table(
			fecha date
		)			
			
		if(@pmuestreo is null) insert into @t_pmuestreo select idpmuestreo,punto,nalterno,hcorte from v_pmuestreo where deleted='N'
		else insert into @t_pmuestreo select idpmuestreo,punto,nalterno,hcorte from v_pmuestreo where deleted='N' and idpmuestreo in (select col1 from dbo.fn_table(1,@pmuestreo))
	
		set @fcero=dateadd(dd,-2,@d_finicial)
		while @fcero<dateadd(dd,2,@d_ffinal)		
		begin
			insert into @fechas values(@fcero)
			set @fcero=dateadd(hh,1,@fcero)			
		end
		
		set @fcero=@d_finicial
		while @fcero<dateadd(dd,1,@d_ffinal)		
		begin
			insert into @fechasp values(@fcero)
			set @fcero=dateadd(dd,1,@fcero)			
		end		
	
		--TOTAL DE FECHAS
		select
			a.idpmuestreo,
			b.idelemento,
			c.fecha
		into #tcompleta_horarios		
		from @t_pmuestreo a,(select * from v_elementos where deleted='N') b,@fechas c
		

		----TOTAL DE FECHAS PROMEDIO
		select
			a.idpmuestreo,
			a.punto,
			a.nalterno,
			a.hcorte,
			b.idelemento,
			b.elemento,
			c.fecha
		into #tcompleta_promedios
		from @t_pmuestreo a,(select * from v_elementos where deleted='N') b,@fechasp c
		
		select 
			a.idpmuestreo,a.punto,a.nalterno,a.idelemento,a.elemento,a.fecha fpromedio,b.fecha fhorario
		into #horarios_completos
		from (
			select *,
				dateadd(hh,hcorte,convert(datetime,convert(date,fecha))) fcorte,	
				dateadd(hh, -23, dateadd(hh,hcorte,convert(datetime,convert(date,fecha)))) rango					
			from #tcompleta_promedios
		)a 
			inner join #tcompleta_horarios b on a.idpmuestreo=b.idpmuestreo and a.idelemento=b.idelemento
				and b.fecha>=a.rango and b.fecha<=a.fcorte	
				
		--REGISTROS QUE NO ESTAN EN LA TABLA COMPLETA DE HORARIOS		
		select a.* 
		into #horarios
		from #horarios_completos a
			left join v_horarios b on a.idpmuestreo=b.idpmuestreo and a.idelemento=b.idelemento and a.fhorario=b.fecha
		where b.valor is null
		
		--REGISTROS QUE NO ESTAN EN LA TABLA COMPLETA DE PROMEDIOS
		select a.* 
		into #promedios
		from #tcompleta_promedios a
			left join v_promedios  b on a.idpmuestreo=b.idpmuestreo and a.idelemento=b.idelemento and a.fecha=convert(date,b.fecha)
		where b.promedio is null	
		
		select 
			isnull(a.idpmuestreo,b.idpmuestreo) idpmuestreo,
			isnull(a.punto,b.punto) punto,
			isnull(a.nalterno,b.nalterno) nalterno,
			isnull(a.elemento,b.elemento) descripcion,	
			isnull(b.fecha,a.fpromedio) fecha,
			dbo.fn_dateToString(isnull(b.fecha,a.fpromedio)) fechaS,				
			isnull(a.nhoras,0) num_hfalta,
			a.horas hfalta,
			case when b.fecha is null
				then 'SI'
				else 'NO'
			end promedio,
			@formato formato,
			@finicial finicial,
			@ffinal ffinal	
		into #horarios_1	
		from	
		(
			select a.idpmuestreo,a.punto,a.nalterno,a.idelemento,a.elemento,a.fpromedio,count(*) nhoras,
				STUFF((
						 SELECT ','+dbo.fn_datetimeToString(z.fhorario,2)
						 FROM #horarios z
						 where z.idpmuestreo=a.idpmuestreo and z.idelemento=a.idelemento
							and z.fpromedio=a.fpromedio		
						 order by z.fpromedio,z.fhorario		 
						 FOR XML PATH('')
				   ),1,1,'') horas		
			from #horarios a
			group by a.idpmuestreo,a.punto,a.nalterno,a.idelemento,a.elemento,a.fpromedio
		)a
		full join #promedios b on a.idpmuestreo=b.idpmuestreo and a.idelemento=b.idelemento and a.fpromedio=convert(date,b.fecha)

		if @resultado=1
		begin
			select 
				distinct idpmuestreo idpmuestreo,
				punto+'_'+dbo.fn_depurateText(nalterno) pmuestreo
			from 
				#horarios_1
		end	
		else
		begin
			select * from #horarios_1
			order by nalterno,fecha
		end
		
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END
	




