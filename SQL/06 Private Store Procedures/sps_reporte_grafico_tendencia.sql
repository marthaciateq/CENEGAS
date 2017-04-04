CREATE PROCEDURE [dbo].[sps_reporte_grafico_tendencia]
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
		if DATEDIFF(day,@d_finicial,@d_ffinal)>30 execute sp_error 'U','El máximo rango de consulta son 30 días'
			
		declare @query varchar(max)
		declare @cols varchar(max)
		declare @fechas table(
			fecha date
		)
		
		
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

		
		
		declare @fechaCero date
		set @fechaCero=@d_finicial
		while @fechaCero<=@d_ffinal
		begin
			insert into @fechas select @fechaCero
			set @fechaCero=dateadd(dd,1,@fechaCero)
		end

		select @cols = STUFF((SELECT ',' + '[F_'+replace(convert(varchar(max),fecha,103),'/','')+']'  from @fechas
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'')

		select
			idpmuestreo,
			punto,
			nalterno,
			idelemento,
			descripcion,
			fecha,
			concepto,
			valor
		into #unpivot
		from(
			select
				a.idpmuestreo,
				b.punto,
				b.nalterno,
				a.idelemento,
				c.descripcion,
				replace(convert(varchar(max),a.fecha,103),'/','-') fecha,
				a.promedio,
				convert(float,d.minimo) minimo,
				convert(float,d.maximo) maximo,
				(
					select avg(promedio) 
					from rpromedio z 
					where  
						a.idpmuestreo=z.idpmuestreo
						and a.idelemento=z.idelemento
						and dateadd(dd,-4,a.fecha)<=z.fecha and z.fecha<=a.fecha
				) tendencia
				
			from #base_rpromedio a
				inner join pmuestreo b on a.idpmuestreo=b.idpmuestreo
				inner join elementos c on a.idelemento=c.idelemento
				inner join especificaciones d on a.idelemento=d.idelemento and b.zona=d.zona
		) SOURCE
		unpivot (valor FOR concepto IN ( tendencia,promedio,minimo,maximo )) as pivottable
		
		select idpmuestreo,idelemento,descripcion,min(valor) min_valorY,max(valor) max_valorY
		into #valoresY
		from #unpivot
		where valor is not null 
		group by idpmuestreo,punto,nalterno,idelemento,descripcion
		order by punto,nalterno,idelemento,descripcion

		select
			b.punto,
			b.nalterno,
			c.descripcion,
			convert(date,a.fecha) fecha,
			dbo.fn_dateToString(convert(date,a.fecha)) fechaS,
			a.promedio,
			convert(float,d.minimo) minimo,
			convert(float,d.maximo) maximo,
			(
				select avg(promedio) 
				from rpromedio z 
				where  
					a.idpmuestreo=z.idpmuestreo
					and dateadd(dd,-4,a.fecha)<=z.fecha and z.fecha<=a.fecha
					and z.idelemento=a.idelemento
			) tendencia,
			e.min_valorY - (e.min_valorY*0.1) as min_valorY,
			e.max_valorY + (e.max_valorY*0.1) as max_valorY,
			@finicial finicial,
			@ffinal ffinal
		from #base_rpromedio a
			inner join pmuestreo b on a.idpmuestreo=b.idpmuestreo
			inner join elementos c on a.idelemento=c.idelemento
			inner join especificaciones d on a.idelemento=d.idelemento and b.zona=d.zona
			inner join #valoresY e on a.idpmuestreo=e.idpmuestreo and a.idelemento=e.idelemento
		order by b.nalterno,c.descripcion,convert(date,a.fecha)

		--set @query=
		--'SELECT 
		--		punto,
		--		nalterno,
		--		descripcion, 
		--		concepto,
		--		'+@cols+'
		--FROM
		--(
		--	select * from #unpivot
		--) UNPIVOT_TABLE
		--PIVOT ( min(UNPIVOT_TABLE.valor) FOR UNPIVOT_TABLE.fecha IN ('+@cols+')) as pivottable'

		--execute(@query)
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END