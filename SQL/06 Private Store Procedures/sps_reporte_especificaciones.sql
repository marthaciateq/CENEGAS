CREATE PROCEDURE sps_reporte_especificaciones
	@idsesion varchar(max),
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
		if ( (@pmuestreo is null and DATEDIFF(day,@d_finicial,@d_ffinal)>15) or (@pmuestreo is not null and DATEDIFF(day,@d_finicial,@d_ffinal)>90) )
			execute sp_error 'U','El máximo rango de consulta sin puntos de muestreo son 15 dias y con puntos de muestreo 3 meses'
	
		declare @fcero datetime
		declare @fechas table(
			fecha datetime
		)
		
		select a.*
		into #base_rpromedio
		from v_promedios a
		where 
			(fecha>=@d_finicial and convert(date,fecha)<=@d_ffinal)
			and (@pmuestreo is null or a.idpmuestreo in (select col1 from dbo.fn_table(1,@pmuestreo)))
			and (@elementos is null or a.idelemento in (select col1 from dbo.fn_table(1,@elementos)))								

		select @d_finicial=min(fecha),@d_ffinal=max(fecha) 
		from #base_rpromedio
		
		--PROMEDIOS FUERA DE ESPECIFICACION

		select a.*,
			dateadd(hh,a.hcorte,convert(datetime,convert(date,a.fecha))) fcorte,	
			dateadd(hh, 23, dateadd(hh,a.hcorte,convert(datetime,convert(date,a.fecha)))) rango
			into #fespecificacion
		from
			#base_rpromedio a 
			inner join especificaciones c on a.idelemento=c.idelemento and a.zona=c.zona and c.deleted='N' 
				and c.fecha=(select max(z.fecha) from especificaciones z 
								where z.idelemento=a.idelemento and z.zona=a.zona and convert(date,a.fecha)>=z.fecha)
		where 
			(a.promedio<c.minimo or a.promedio>c.maximo)
			
		if @resultado=1
		begin
			select 
				distinct idpmuestreo,
				punto+'_'+dbo.fn_depurateText(nalterno) pmuestreo
			from 
				#fespecificacion
		end	
		else
		begin
			if(@reporte='G')
				select
					a.idpmuestreo,
					a.idelemento,	
					convert(date,a.fecha) fpromedio,	
					dbo.fn_dateToString(convert(date,a.fecha)) fpromedioS,						
					a.punto,
					a.nalterno,
					a.elemento descripcion,
					a.promedio,
					a.zona,
					case 
						when a.zona='S' then 'SUR' 
						when a.zona='R' then 'RESTO DEL PAIS'
					end zonaS,
					@formato formato,
					@finicial finicial,
					@ffinal ffinal,
					@reporte reporte
				from #fespecificacion a
				order by a.nalterno,a.fecha						
			else
				select 
					a.idpmuestreo,
					a.idelemento,	
					b.fecha,		
					dbo.fn_datetimeToString(b.fecha,2) fechaS,
					b.valor,
					convert(date,a.fecha) fpromedio,	
					dbo.fn_dateToString(convert(date,a.fecha)) fpromedioS,						
					a.punto,
					a.nalterno,
					a.elemento descripcion,
					a.promedio,
					a.zona,
					case 
						when a.zona='S' then 'SUR' 
						when a.zona='R' then 'RESTO DEL PAIS'
					end zonaS,
					@formato formato,
					@finicial finicial,
					@ffinal ffinal,
					@reporte reporte
				from #fespecificacion a
					left join v_horarios b on a.idpmuestreo=b.idpmuestreo 
						and a.idelemento=b.idelemento 
						and b.fecha<=a.rango and b.fecha>=a.fcorte
				order by a.nalterno,a.fecha,b.fecha
				
		
				--GENERAR ENCABEZADOS DINAMICOS
				
				--declare @cols varchar(max)
				--select @cols = STUFF(
				--					(SELECT ',[' + codigo + ']'
				--						from v_elementos
				--						FOR XML PATH('')
				--					) ,1,1,'')
				--select @cols

				select zona,[metano],[oxigeno],[bioxidocarbono],[nitrogeno],[totalinertes],[etano],[temprocio],[humedad],[podercalorifico],[indicewoobe],[acidosulfhidrico],[azufretotal]
				into #especificaciones
				from
				(
					select 	
						a.zona,	
						b.descripcion 
						+ case when b.simbolo is not null then ' (' + b.simbolo + ') ' else '' end  
						+ CHAR(13) + CHAR(10) +
						+ ' ' + b.unidad
						+ CHAR(13) + CHAR(10) 
						+ '( ' +
						isnull(convert(varchar(max),a.minimo),'') 
							+ case when a.maximo is not null and a.minimo is not null then ' - '  else '' end 
							+ isnull(convert(varchar(max),a.maximo),'')
						+' )' 
						+ CHAR(13) + CHAR(10) 
						+ case when a.max_diaria is not null then 'Desv. máxima: ' + convert(varchar(max),a.max_diaria) else '' end  valores,
						b.codigo
					from especificaciones a
						inner join elementos b on a.idelemento=b.idelemento
					where a.fecha<=@d_ffinal
						and a.fecha=(select max(fecha) from especificaciones z where z.idelemento=a.idelemento and z.zona=a.zona and z.fecha<=@d_ffinal)	
				)as source
				PIVOT( 
					min(valores) FOR codigo in ([metano],[oxigeno],[bioxidocarbono],[nitrogeno],[totalinertes],[etano],[temprocio],[humedad],[podercalorifico],[indicewoobe],[acidosulfhidrico],[azufretotal])
				) as pivot_table

				select * from #especificaciones where zona='S'		
				select * from #especificaciones where zona='R'
		
		end

					
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END
	




