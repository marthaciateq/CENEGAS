CREATE PROCEDURE sps_reporte_especificaciones
	@idsesion varchar(max),
	@pmuestreo varchar(max),
	@elementos varchar(max),
	@finicial varchar(max),
	@ffinal varchar(max),
	@formato varchar(max),
	@resultado int, --(1) Solo puntos de muestreo que cuentan con información fuera de especificacion (2) Informacion completa
	@reporte varchar(max), -- (G) General (D) detalle 
	@separacion char(1), -- (P) Punto de Muestreo, (E) Elemento
	@bloque int -- Generar reporte por bloque de 10 puntos de muestreo
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
		
		if( 
			(@separacion='E' or @separacion='P') 
			and @reporte='D' 
			and @bloque is null 
			and (@pmuestreo is null or (select count(col1) from dbo.fn_table(1,@pmuestreo)) > 10 )
		) execute sp_error 'U','El máximo número de puntos de muestreo a consultar son 10'
		if (@pmuestreo is null and @bloque is null and DATEDIFF(day,@d_finicial,@d_ffinal)>15)
			execute sp_error 'U','El máximo rango de consulta sin puntos de muestreo son 15 dias'
	
		declare @fcero datetime
		declare @fechas table(
			fecha datetime
		)
		declare @totalrowsXelemento table(
			idpmuestreo varchar(max),
			idelemento varchar(max),
			totalrowsXelemento float
		)
		declare @registros int
		set @registros= @bloque*10
		
		select a.*
		into #base_rpromedio
		from v_promedios a
			left join v_pmuestreo b on a.idpmuestreo=b.idpmuestreo
		where 
			(fecha>=@d_finicial and convert(date,fecha)<=@d_ffinal)
			and (@pmuestreo is null or a.idpmuestreo in (select col1 from dbo.fn_table(1,@pmuestreo)))
			and (@elementos is null or a.idelemento in (select col1 from dbo.fn_table(1,@elementos)))	
			and (@bloque is null or (b.orden>@registros-10 and b.orden<=@registros))						

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
			if @separacion='P'
				select 
					distinct a.idpmuestreo,
					cast(b.orden as varchar(max))+'.'+b.abreviatura pmuestreo,
					b.abreviatura abrev_pmuestreo,
					b.orden npmuestreo,				
					null as idelemento,
					null as descripcion,
					null as abrev_elemento,
					null as nelemento
				from 
					#fespecificacion a
						left join v_pmuestreo b on a.idpmuestreo=b.idpmuestreo
			else
				select 
					distinct a.idpmuestreo,
					cast(c.orden as varchar(max))+'.'+c.abreviatura pmuestreo,
					a.idelemento,
					a.celemento,
					b.abreviatura abrev_elemento,
					b.orden nelemento,
					c.abreviatura abrev_pmuestreo,
					c.orden npmuestreo
				from 
					#fespecificacion a
						left join v_elementos b on a.idelemento=b.idelemento
						left join v_pmuestreo c on a.idpmuestreo=c.idpmuestreo
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
					a.celemento,
					a.zona,
					case 
						when a.zona='S' then 'SUR' 
						when a.zona='R' then 'RESTO DEL PAIS'
					end zonaS,
					@formato formato,
					@finicial finicial,
					@ffinal ffinal,
					@reporte reporte,
					0 as totalrowsXelemento
				from #fespecificacion a
					left join v_pmuestreo b on a.idpmuestreo=b.idpmuestreo
				order by b.orden,a.nalterno,a.celemento,a.fecha				
			else
				begin
				insert into @totalrowsXelemento
				select
					a.idpmuestreo,
					a.idelemento,
					count(*) as  totalrowsXelemento
				from #fespecificacion a
					left join v_horarios b on a.idpmuestreo=b.idpmuestreo 
						and a.idelemento=b.idelemento 
						and b.fecha<=a.rango and b.fecha>=a.fcorte	
					group by a.idpmuestreo,a.idelemento			
					
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
					a.celemento,
					a.zona,
					case 
						when a.zona='S' then 'SUR' 
						when a.zona='R' then 'RESTO DEL PAIS'
					end zonaS,
					@formato formato,
					@finicial finicial,
					@ffinal ffinal,
					@reporte reporte,
					ROW_NUMBER() OVER(PARTITION BY d.orden,a.nalterno,a.celemento ORDER BY d.orden,a.nalterno,a.celemento,a.fecha,b.fecha) as nrow,
					totalrowsXelemento
				from #fespecificacion a
					left join v_horarios b on a.idpmuestreo=b.idpmuestreo 
						and a.idelemento=b.idelemento 
						and b.fecha<=a.rango and b.fecha>=a.fcorte
					left join @totalrowsXelemento c on b.idpmuestreo=c.idpmuestreo and b.idelemento=c.idelemento
					left join v_pmuestreo d on a.idpmuestreo=d.idpmuestreo
				order by d.orden,a.nalterno,a.celemento,a.fecha,b.fecha
			end
				
		
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
	
