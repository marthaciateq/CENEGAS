CREATE PROCEDURE sps_especificaciones_guardar 
	@idsesion varchar(max),
	@idespecificacion varchar(max),
	@idelemento varchar(max),
	@zona char(1),
	@fecha varchar(max),
	@minimo float,	
	@maximo float,
	@max_diaria float
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)

	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		
		if @idelemento is null execute sp_error 'U', 'Campo elemento requerido.'		
		if @zona is null execute sp_error 'U', 'Campo zona requerido.'				
		if @fecha is null execute sp_error 'U', 'Fecha a partir de la cual se toma la especificación.'						
		
		if (select COUNT(*) from idelemento where fecha = convert(date,@fecha,103) and zona=@zona and (@idespecificacion is null or (idespecificacion<>@idespecificacion))) > 0
				execute sp_error 'U', 'Ya existe una especificacion a partir de la fecha indicada'
				
		begin try
			begin transaction
				if @idespecificacion is null
				begin
					execute sp_randomKey @idespecificacion output
					insert into especificaciones values(@idespecificacion,@idelemento,@zona,@fecha,@minimo,@maximo,@max_diaria)
				end
				else
				begin 
					update especificaciones set idelemento = @idelemento, zona=@zona, fecha=@fecha, minimo=@minimo, max_diaria=@max_diaria
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