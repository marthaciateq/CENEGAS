CREATE PROCEDURE sps_reporte_grafico_tendencia
	@idsesion varchar(max),
	@idbdatos varchar(max),
	@pmuestreo varchar(max),
	@elementos varchar(max),
	@finicial varchar(max),
	@ffinal varchar(max),
	@formato varchar(max),
	@resultado int, --(1) Solo puntos de muestreo que cuentan con información fuera de especificacion (2) Informacion completa
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
			and @bloque is null 
			and (@pmuestreo is null or (select count(col1) from dbo.fn_table(1,@pmuestreo)) > 10 )
		) execute sp_error 'U','El máximo número de puntos de muestreo a consultar son 10'
		if ( (@pmuestreo is null and @bloque is null and DATEDIFF(day,@d_finicial,@d_ffinal)>7) or (@pmuestreo is not null and DATEDIFF(day,@d_finicial,@d_ffinal)>90) )
			execute sp_error 'U','El máximo rango de consulta sin puntos de muestreo es una semana y con puntos de muestreo 3 meses'
			
		declare @query varchar(max)
		declare @cols varchar(max)
		declare @fechas table(
			fecha date
		)
		declare @registros int
		set @registros= @bloque*10		
		
		select a.*
		into #base_rpromedio
		from v_promedios a
			left join v_pmuestreo b on a.idpmuestreo=b.idpmuestreo		
		where 
	        (@idbdatos is null and fecha>=@d_finicial and fecha<DATEADD(day,1,@d_ffinal))
			and (@pmuestreo is null or a.idpmuestreo in (select col1 from dbo.fn_table(1,@pmuestreo)))
			and (@elementos is null or a.idelemento in (select col1 from dbo.fn_table(1,@elementos)))			
			and (@bloque is null or (b.orden>@registros-10 and b.orden<=@registros))														
		
		if @resultado=1
		begin
			if @separacion='P'
				select 
					distinct a.idpmuestreo,
					cast(b.orden as varchar(max))+'.'+b.abreviatura pmuestreo,
					b.orden npmuestreo,
					b.abreviatura abrev_pmuestreo,
					null as idelemento,
					null as descripcion
				from 
					#base_rpromedio a
						left join v_pmuestreo b on a.idpmuestreo=b.idpmuestreo
			else
				select 
					distinct a.idpmuestreo,
					cast(b.orden as varchar(max))+'.'+b.abreviatura pmuestreo,
					b.orden npmuestreo,
					b.abreviatura abrev_pmuestreo,
					a.idelemento,
					a.celemento,
					c.abreviatura abrev_elemento,
					c.orden nelemento
				from 
					#base_rpromedio a
						left join v_pmuestreo b on a.idpmuestreo=b.idpmuestreo
						left join v_elementos c on a.idelemento=c.idelemento
		end
		else
		begin
			declare @fechaCero date
			set @fechaCero=@d_finicial
			while @fechaCero<=@d_ffinal
			begin
				insert into @fechas select @fechaCero
				set @fechaCero=dateadd(dd,1,@fechaCero)
			end

			select @cols = STUFF((SELECT ',' + '[F_'+replace(convert(varchar(max),fecha,103),'/','')+']'  from @fechas
						FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')

			select
				idpmuestreo,
				punto,
				nalterno,
				idelemento,
				descripcion,
				fecha,
				concept,
				value
			into #unpivot
			from(
				select
					a.idpmuestreo,
					a.punto,
					a.nalterno,
					a.idelemento,
					a.elemento descripcion,
					replace(convert(varchar(max),a.fecha,103),'/','-') fecha,
					convert(float,a.promedio) promedio,
					convert(float,d.minimo) minimo,
					convert(float,d.maximo) maximo,
					(
						select convert(float,avg(promedio))
						from v_promedios z 
						where  
							a.idpmuestreo=z.idpmuestreo
							and a.idelemento=z.idelemento
							and dateadd(dd,-4,a.fecha)<=z.fecha 
							and z.fecha<=a.fecha
					) tendencia
					
				from #base_rpromedio a
					inner join especificaciones d on a.idelemento=d.idelemento and a.zona=d.zona
						and d.fecha=(select max(z.fecha) from especificaciones z where z.idelemento=a.idelemento and z.zona=a.zona and convert(date,a.fecha)>=z.fecha)					
						and d.deleted='N'
			) SOURCE
			unpivot (value FOR concept IN ( tendencia,promedio,minimo,maximo )) as pivottable
			
			select idpmuestreo,idelemento,descripcion,min(value) min_valorY,max(value) max_valorY
			into #valoresY
			from #unpivot
			where value is not null 
			group by idpmuestreo,punto,nalterno,idelemento,descripcion
			order by punto,nalterno,idelemento,descripcion

			select
				a.punto,
				a.nalterno,
				a.elemento descripcion,
				convert(date,a.fecha) fecha,
				dbo.fn_dateToString(convert(date,a.fecha)) fechaS,
				a.promedio,
				convert(float,d.minimo) minimo,
				convert(float,d.maximo) maximo,
				(
					select avg(z.promedio) 
					from v_promedios z 
					where  
						a.idpmuestreo=z.idpmuestreo
						and dateadd(dd,-4,a.fecha)<=z.fecha 
						and z.fecha<=a.fecha
						and z.idelemento=a.idelemento
				) tendencia,
				e.min_valorY - (e.min_valorY*0.1) as min_valorY,
				e.max_valorY + (e.max_valorY*0.1) as max_valorY,
				@finicial finicial,
				@ffinal ffinal,
				@formato formato
			from #base_rpromedio a
				inner join especificaciones d on a.idelemento=d.idelemento and a.zona=d.zona 
					and d.fecha=(select max(z.fecha) from especificaciones z where z.idelemento=a.idelemento and z.zona=a.zona and convert(date,a.fecha)>=z.fecha)
					and deleted='N'					
				inner join #valoresY e on a.idpmuestreo=e.idpmuestreo and a.idelemento=e.idelemento
				left join v_pmuestreo f on a.idpmuestreo=f.idpmuestreo
				left join v_elementos g on a.idelemento=g.idelemento
			order by f.orden,a.nalterno,g.orden,a.elemento,convert(date,a.fecha)

		end
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END