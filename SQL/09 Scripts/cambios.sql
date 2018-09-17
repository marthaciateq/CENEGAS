ALTER TABLE PMUESTREO ADD TCRE VARCHAR(MAX)
GO

ALTER PROCEDURE [dbo].[sps_reporte_mensualCRE]
	@idsesion varchar(max),
	@pmuestreo varchar(max),
	@finicial varchar(max),
	@ffinal varchar(max),
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
			a.nalterno,
			a.elemento,
			a.fecha fpromedio,
			b.fecha fhorario,
			b.valor
		into #horarios
		from #base_rpromedio a 
			left join v_horarios b on a.idpmuestreo=b.idpmuestreo and a.idelemento=b.idelemento
				and b.fecha>=a.rango and b.fecha<=a.fcorte
				
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
				#base_rpromedio a
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
			
			--Información para separación de hojas 
			select idpmuestreo,idelemento,pmuestreo,elemento,fpromedio,prom_horario valor,'grupo1' grupo into #tabla1 from #maximos_horarios
			union
			select idpmuestreo,idelemento,pmuestreo,elemento,fpromedio,max_horario valor,'grupo2' grupo  from #maximos_horarios
			union
			select idpmuestreo,idelemento,pmuestreo,elemento,fpromedio,min_horario valor,'grupo3' grupo from #maximos_horarios
	

			select 
				idpmuestreo,
				idelemento,
				pmuestreo,
				elemento,		
				min(prom_horario) minimo,
				max(prom_horario) maximo,
				avg(prom_horario) promedio,
				stdev(prom_horario) desviacion,
				'grupo1' grupo2	
			into #tabla2						
			from #maximos_horarios
			group by idpmuestreo,idelemento,pmuestreo,elemento	
			union
			select 
				idpmuestreo,
				idelemento,
				pmuestreo,
				elemento,		
				min(max_horario) minimo,
				max(max_horario) maximo,
				avg(max_horario) promedio,
				stdev(max_horario) desviacion,
				'grupo2' grupo2
			from #maximos_horarios
			group by idpmuestreo,idelemento,pmuestreo,elemento
			union
			select 
				idpmuestreo,
				idelemento,
				pmuestreo,
				elemento,		
				min(min_horario) minimo,
				max(min_horario) maximo,
				avg(min_horario) promedio,
				stdev(min_horario) desviacion,
				'grupo3' grupo2			
			from #maximos_horarios
			group by idpmuestreo,idelemento,pmuestreo,elemento								
			
			select a.idpmuestreo,
				a.idelemento,
				a.pmuestreo,
				a.elemento+ CHAR(13)+CHAR(10)+'('+c.unidad+')' as elemento,
				a.fpromedio,
				a.valor,
				a.grupo,
				b.minimo,b.maximo,b.promedio,b.desviacion,b.grupo2,
				dbo.fn_datetimeToString(a.fpromedio,1) fpromedioS,
				'Fecha de Corte: '+ dbo.fn_datetimeToString(a.fpromedio,5) observaciones,
				d.zonaS,
				d.tcre
			from #tabla1 a
				left join #tabla2 b on a.idpmuestreo=b.idpmuestreo and a.idelemento=b.idelemento
				left join v_elementos c on a.idelemento=c.idelemento
				left join v_pmuestreo d on a.idpmuestreo=d.idpmuestreo
				left join @elementos e on c.codigo=e.celemento
			order by d.orden,a.pmuestreo,a.grupo,e.orden
			
		end
		
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END

go

CREATE PROCEDURE sps_pmuestreo_guardar 
	@idsesion varchar(max),
	@idpmuestreo varchar(max),
	@punto varchar(max),	
	@nalterno varchar(max),
	@descripcion varchar(max),	
	@zona char(1),
	@hcorte int,
	@abreviatura varchar(max),
	@orden int,
	@deleted varchar(max),
	@tcre varchar(max)
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)

	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		
		if @punto is null execute sp_error 'U', 'Campo punto(s) requerido.'
		if @zona is null execute sp_error 'U', 'Campo zona requerida.'		
		if @nalterno is null execute sp_error 'U', 'Campo nombre alterno requerido.'
		if @descripcion is null execute sp_error 'U', 'Campo descripcion requerido.'
		if @hcorte is null execute sp_error 'U', 'Campo hora de corte requerido.'
		if @abreviatura is null execute sp_error 'U', 'Campo abreviatura requerido.'						
		if @orden is null execute sp_error 'U', 'Campo órden requerido.'				
		
		if (@hcorte<0 or @hcorte>23) execute sp_error 'U', 'La hora de corte debe de estar en el rango de [0-23] hrs.'	
		
		if (select COUNT(*) from pmuestreo where punto = @punto and dbo.fn_depurateText(nalterno)=dbo.fn_depurateText(@nalterno) and (@idpmuestreo is null or idpmuestreo <> @idpmuestreo)) > 0
				execute sp_error 'U', 'Ya existe un punto de muestreo con el mismo punto y descripcion.'
				
		begin try
			begin transaction
				if @idpmuestreo is null
				begin
					execute sp_randomKey @idpmuestreo output
					insert into pmuestreo values(@idpmuestreo,@punto,@nalterno,@descripcion,@zona,@hcorte,@abreviatura,@orden,@deleted,@tcre)
				end
				else
				begin 
					update pmuestreo set punto = @punto, nalterno=@nalterno, descripcion=@descripcion, zona=@zona,hcorte=@hcorte,abreviatura=@abreviatura, orden=@orden,deleted=@deleted,tcre=@tcre
					where idpmuestreo = @idpmuestreo
					
				end					
			commit
		end try
		begin catch
			rollback
			set @error = error_message()
		execute sp_error 'S', @error
			end catch
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END

GO

CREATE VIEW v_pmuestreo (
	idpmuestreo,
	punto,
	nalterno,
	descripcion,
	zona,
	hcorte,
	abreviatura,
	orden,
	deleted,
	tcre,
	deletedS,
	zonaS,
	pmuestreo
) AS
	select 
		a.*,
		dbo.fn_deleted(a.deleted) deletedS,
		case when zona='S' then 'SUR' else 'RESTO DEL PAIS' end,
		a.punto + ' ' + a.nalterno + ' ' + case when zona='S' then 'SUR' else 'RESTO DEL PAIS' end
	from pmuestreo a

GO