ALTER PROCEDURE sps_reporte_falta_informacion
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
		
		if(@d_finicial>@d_ffinal) execute sp_error 'U','La fecha inicial debe ser menor que la final'
		if DATEDIFF(day,@d_finicial,@d_ffinal)>15 execute sp_error 'U','El máximo rango de consulta son 15 días'		
		
		set @d_finicial=convert(date,@finicial,103)
		set @d_ffinal=convert(date,@ffinal,103)	
		
		declare @t_pmuestreo table(
			idpmuestreo char(32),
			punto varchar(max),
			nalterno varchar(max)
		)
		declare @fcero datetime
		declare @fechas table(
			fecha datetime
		)	
			
		select *
		into #base_registros
		from registros
		where 
			(
			  (@idbdatos is null and fecha>=@d_finicial and fecha<DATEADD(day,1,@d_ffinal)) 
			   or idbdatos=@idbdatos
			)
			and estado=1
			and (@pmuestreo is null or idpmuestreo in (select col1 from dbo.fn_table(1,@pmuestreo)))
			and (@elementos is null or idelemento in ( select col1 from dbo.fn_table(1,@elementos)))
			
		select *
		into #base_rpromedio
		from rpromedio
		where 
			(
			  (@idbdatos is null and fecha>=@d_finicial and fecha<DATEADD(day,1,@d_ffinal))
			   or idbdatos=@idbdatos
			)
			and estado=1
			and (@pmuestreo is null or idpmuestreo in (select col1 from dbo.fn_table(1,@pmuestreo)))
			and (@elementos is null or idelemento in (select col1 from dbo.fn_table(1,@elementos)))								
			
		if(@pmuestreo is null) insert into @t_pmuestreo select idpmuestreo,punto,nalterno from pmuestreo where deleted='N'
		else insert into @t_pmuestreo select idpmuestreo,punto,nalterno from pmuestreo where deleted='N' and idpmuestreo in (select col1 from dbo.fn_table(1,@pmuestreo))
	
		select 
			@d_finicial=convert(date,min(fminima)),
			@d_ffinal=convert(date,max(fmaxima))
		from(
			select min(fecha) fminima,max(fecha) fmaxima
			from #base_registros
			union
			select min(fecha) fminima,max(fecha) fmaxima 
			from #base_rpromedio			
		)a
		
		set @fcero=@d_finicial
		while @fcero<dateadd(dd,1,@d_ffinal)		
		begin
			insert into @fechas values(@fcero)
			set @fcero=dateadd(hh,1,@fcero)			
		end
	
		--TOTAL DE FECHAS
		select
			a.idpmuestreo,
			a.punto,
			a.nalterno,
			b.descripcion,
			c.fecha
		into #tcompleta_horarios		
		from @t_pmuestreo a,(select * from elementos where deleted='N') b,@fechas c
			
		--TOTAL DE FECHAS PROMEDIO
		select
			distinct
			idpmuestreo,
			punto,
			nalterno,
			descripcion,
			convert(date,fecha) fecha
		into #tcompleta_promedios
		from #tcompleta_horarios 
		
		-- TOTAL REGISTROS
		select
			b.idpmuestreo,
			b.punto,
			b.nalterno,
			c.descripcion,
			a.fecha
		into #registros			
		from #base_registros a
			inner join pmuestreo b on a.idpmuestreo=b.idpmuestreo
			inner join elementos c on a.idelemento=c.idelemento

		-- TOTAL REGISTROS PROMEDIO
		select
			b.idpmuestreo,
			b.punto,
			b.nalterno,
			c.descripcion,
			convert(date,a.fecha) fecha
		into #rpromedio	
		from #base_rpromedio a
			inner join pmuestreo b on a.idpmuestreo=b.idpmuestreo
			inner join elementos c on a.idelemento=c.idelemento

		--REGISTRO QUE NO ESTAN EN LA TABLA COMPLETA DE HORARIOS
		select * 
		into #incompleta_horarios
		from 
		#tcompleta_horarios 
		EXCEPT
		select * from 
		#registros 
		
		-- REGISTROS PROMEDIO QUE NO ESTAN EN LA TABLA COMPLETA DE PROMEDIO
		select * 
		into #incompleta_promedios
		from 
		#tcompleta_promedios
		EXCEPT
		select 
			*
		from
		#rpromedio
		
		select 
		distinct
			a.idpmuestreo,
			a.punto,
			a.nalterno,
			a.descripcion,
			convert(date,a.fecha) fecha
		into #fincompletas_horarios
		from #incompleta_horarios a
		
		SELECT
		isnull(a.idpmuestreo,b.idpmuestreo) idpmuestreo,
		isnull(a.punto,b.punto) punto,
		isnull(a.nalterno,b.nalterno) nalterno,
		isnull(a.descripcion,b.descripcion) descripcion,
		isnull(a.fecha,b.fecha) fecha,
		dbo.fn_dateToString(isnull(a.fecha,b.fecha)) fechaS,
		case when a.fecha is not null
			then
				 (
					SELECT count(*)
					FROM #incompleta_horarios b where a.fecha=convert(date,b.fecha) and a.punto=b.punto and a.nalterno=b.nalterno and a.descripcion=b.descripcion
				)
			  else
				24
		end num_hfalta,		
		case when a.fecha is not null
			then
				STUFF((
					 SELECT ','+dbo.fn_datetimeToString(b.fecha,5)
					 FROM #incompleta_horarios b where a.fecha=convert(date,b.fecha) and a.punto=b.punto and a.nalterno=b.nalterno and a.descripcion=b.descripcion
					 FOR XML PATH('')
			   ),1,1,'') 
			  else
				'TODAS LAS HORAS'
		end hfalta,
		case when b.fecha is null
			then 'SI'
			else 'NO'
		end promedio,
		@formato formato,
		@finicial finicial,
		@ffinal ffinal				
        into #horarios
		FROM #fincompletas_horarios a
			full join #incompleta_promedios b on a.punto=b.punto and a.nalterno=b.nalterno and a.descripcion=b.descripcion and a.fecha=b.fecha
		
		if @resultado=1
		begin
			select 
				distinct idpmuestreo idpmuestreo,
				punto+'_'+replace(replace(replace(replace(replace(nalterno,' ',''),'"',''),'(',''),')',''),'Ú','U') pmuestreo
			from 
				#horarios
		end	
		else
		begin
			select * from #horarios
			order by punto,nalterno,descripcion,fecha
		end
		
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END
	




