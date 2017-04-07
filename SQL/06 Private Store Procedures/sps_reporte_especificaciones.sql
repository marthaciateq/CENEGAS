ALTER PROCEDURE sps_reporte_especificaciones
	@idsesion varchar(max),
	@idbdatos varchar(max),
	@pmuestreo varchar(max),
	@elementos varchar(max),
	@finicial varchar(max),
	@ffinal varchar(max),
	@formato varchar(max),
	@resultado int, --(1) Solo puntos de muestreo que cuentan con información fuera de especificacion (2) Informacion completa
	@reporte varchar(max) -- (G) General (D) detalle 
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
		if DATEDIFF(day,@d_finicial,@d_ffinal)>15 execute sp_error 'U','El máximo rango de consulta son 15 días'
	
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

		select @d_finicial=min(fecha),@d_ffinal=max(fecha) 
		from #base_rpromedio
		
		--PROMEDIOS FUERA DE ESPECIFICACION

		select a.*,
			b.punto,
			b.nalterno,
			b.zona
			--b.minimo,
			--b.maximo,
			into #fespecificacion
		from
			#base_rpromedio a 
			inner join pmuestreo b on a.idpmuestreo=b.idpmuestreo
			inner join especificaciones c on a.idelemento=c.idelemento and b.zona=c.zona
		where 
			(a.promedio<c.minimo or a.promedio>c.maximo)
			
		select * from #fespecificacion
		
		if @resultado=1
		begin
			select 
				distinct idpmuestreo idpmuestreo,
				punto+'_'+replace(replace(replace(replace(replace(nalterno,' ',''),'"',''),'(',''),')',''),'Ú','U') pmuestreo
			from 
				#fespecificacion
		end	
		else
		begin
			select 
				a.idpmuestreo,
				a.idelemento,	
				a.fecha,		
				dbo.fn_datetimeToString(a.fecha,2) fechaS,
				a.valor,
				convert(date,a.fecha) fpromedio,	
				dbo.fn_dateToString(convert(date,a.fecha)) fpromedioS,						
				b.punto,
				b.nalterno,
				c.descripcion,
				b.promedio,
				b.zona,
				case 
					when b.zona='S' then 'SUR' 
					when b.zona='R' then 'RESTO DEL PAIS'
				end zonaS,
				@formato formato,
				@finicial finicial,
				@ffinal ffinal,
				@reporte reporte
			from #base_registros a
				inner join #fespecificacion b on a.idpmuestreo=b.idpmuestreo and a.idelemento=b.idelemento and convert(date,a.fecha)=convert(date,b.fecha)
				inner join elementos c on a.idelemento=c.idelemento
			order by b.nalterno,c.descripcion,a.fecha
		end
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END
	




