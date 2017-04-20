 CREATE PROCEDURE sps_especificaciones_guardar
	@idsesion varchar(max),
	@idespecificacion varchar(max),
	@idelemento varchar(max),
	@zona char(1),
	@fecha varchar(max),
	@minimo decimal(10,3),
	@maximo decimal(10,3),
	@max_diaria decimal(10,3),
	@deleted varchar(max)
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)

	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		
		if @idelemento is null execute sp_error 'U', 'Campo elemento requerido.'
		if @zona is null execute sp_error 'U', 'Campo zona requerido.'
		if @fecha is null execute sp_error 'U', 'Campo fecha requerido.'
		
		declare @fecha1 date
		set @fecha1=convert(date,@fecha,103)
		
		if (select COUNT(*) from especificaciones where idelemento = @idelemento and zona=@zona and fecha=@fecha1 and (@idespecificacion is null or idespecificacion <> @idespecificacion)) > 0
				execute sp_error 'U', 'Ya existe una especificación para el elemento y fecha indicada.'
				
		begin try
			begin transaction
				if @idespecificacion is null
				begin
					execute sp_randomKey @idespecificacion output
					insert into especificaciones values(@idespecificacion,@idelemento,@zona,convert(date,@fecha1,100),@minimo,@maximo,@max_diaria,@deleted)
				end
				else
				begin 
					update especificaciones set idelemento = @idelemento, zona=@zona, fecha=convert(date,@fecha1,100), minimo=@minimo, maximo=@maximo, max_diaria=@max_diaria, deleted=@deleted
					where idespecificacion = @idespecificacion
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