CREATE PROCEDURE sps_elementos_guardar 
	@idsesion varchar(max),
	@idelemento char(32),
	@descripcion varchar(max),
	@codigo varchar(20),
	@simbolo varchar(max),
	@unidad varchar(max),	
	@abreviatura varchar(max),
	@orden int,
	@deleted  char(1)
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)

	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		
		if @descripcion is null execute sp_error 'U', 'Nombre requerido.'
		if @unidad is null execute sp_error 'U', 'Unidad requerida.'		
		if @codigo is null execute sp_error 'U', 'Código requerido.'	
		if @abreviatura is null execute sp_error 'U', 'Abrevitura requerida.'									
		if @orden is null execute sp_error 'U', 'Orden requerida.'							
		
		if (select COUNT(*) from elementos where descripcion = @descripcion and (@idelemento is null or (idelemento<>@idelemento))) > 0
				execute sp_error 'U', 'Ya existe el elemento'
				
		begin try
			begin transaction
				if @idelemento is null
				begin
					execute sp_randomKey @idelemento output
					insert into elementos values(@idelemento,@descripcion,@codigo,@simbolo,@unidad,@abreviatura,@orden,@deleted)
				end
				else
				begin 
					update elementos set descripcion = @descripcion, simbolo=@simbolo, codigo=@codigo, unidad=@unidad, abreviatura=@abreviatura,orden=@orden,deleted=@deleted
					where idelemento = @idelemento
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