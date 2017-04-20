alter PROCEDURE sps_reporte_mensualCRE
	@idsesion varchar(max),
	@pmuestreo varchar(max),
	@finicial varchar(max),
	@ffinal varchar(max)
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
	
		declare @fcero datetime
		declare @fechas table(
			fecha datetime
		)
		
		select a.*,
			dateadd(hh,a.hcorte,convert(datetime,convert(date,a.fecha))) fcorte,	
			dateadd(hh, -23, dateadd(hh,a.hcorte,convert(datetime,convert(date,a.fecha)))) rango		
		into #base_rpromedio
		from v_promedios a
		where 
			(fecha>=@d_finicial and convert(date,fecha)<=@d_ffinal)
			and (@pmuestreo is null or idpmuestreo in (select col1 from dbo.fn_table(1,@pmuestreo)))

		select @d_finicial=min(fecha),@d_ffinal=max(fecha) 
		from #base_rpromedio
		
		select 
			a.idpmuestreo,
			a.idelemento,
			a.elemento,
			a.fecha fpromedio,
			b.fecha fhorario,
			b.valor
		into #horarios
		from #base_rpromedio a 
			left join v_horarios b on a.idpmuestreo=b.idpmuestreo and a.idelemento=b.idelemento
				and b.fecha>=a.rango and b.fecha<=a.fcorte

		select 
			idpmuestreo,
			idelemento,
			elemento,
			fpromedio,
			max(valor) max_horario,
			avg(valor) prom_horario,
			min(valor) min_horario,			
		into #maximos_horarios
		from #horarios
		group by idpmuestreo,idelemento,elemento,fpromedio
		
		--select * from #maximos_horarios
		
		select 
			idpmuestreo,
			idelemento,
			elemento,		
			min(max_horario) minimo,
			max(max_horario) maximo,
			avg(max_horario) promedio,
			stdev(max_horario) desviacion
		from #maximos_horarios
		group by idpmuestreo,idelemento,elemento,fpromedio		
		
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END
	




