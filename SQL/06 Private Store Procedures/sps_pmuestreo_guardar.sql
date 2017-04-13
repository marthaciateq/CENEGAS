CREATE PROCEDURE sps_pmuestreo_guardar 
	@idsesion varchar(max),
	@idpmuestreo varchar(max),
	@punto varchar(max),	
	@nalterno varchar(max),
	@descripcion varchar(max),	
	@zona char(1),
	@deleted varchar(max)
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)

	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		
		if @punto is null execute sp_error 'U', 'Campo punto(s) requerido.'
		if @nalterno is null execute sp_error 'U', 'Campo nombre alterno requerido.'
		if @descripcion is null execute sp_error 'U', 'Campo descripcion requerido.'		
		
		if (select COUNT(*) from pmuestreo where punto = @punto and nalterno=@nalterno and (@idpmuestreo is null or idpmuestreo <> @idpmuestreo)) > 0
				execute sp_error 'U', 'Ya existe un punto de muestreo con el mismo punto y descripcion.'
				
		begin try
			begin transaction
				if @idpmuestreo is null
				begin
					execute sp_randomKey @idpmuestreo output
					insert into pmuestreo values(@idpmuestreo,@punto,@nalterno,@descripcion,@zona,@deleted)
				end
				else
				begin 
					update pmuestreo set punto = @punto, nalterno=@nalterno, descripcion=@descripcion, zona=@zona, deleted=@deleted
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