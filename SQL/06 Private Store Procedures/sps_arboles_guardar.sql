CREATE PROCEDURE sps_arboles_guardar 
	@idsesion varchar(max),
	@idarbol varchar(max),
	@idpadre varchar(max),
	@descripcion varchar(max),
	@deleted varchar(max)
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	
	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		if @descripcion is null execute sp_error 'U', 'Campo "Descripción" requerido.'
		if (select COUNT(*) from arboles where descripcion=@descripcion and (@idpadre is null or idpadre=@idpadre) and (@idarbol is null or idarbol<>@idarbol))>0
			execute sp_error 'U', 'Campo "Descripción" ya existe.'
		begin try
			begin transaction
				if @idarbol is null
				begin
					execute sp_randomKey @idarbol output
					insert into arboles values(@idarbol, @idpadre, @descripcion, @deleted)
				end
				else
					update arboles set descripcion = @descripcion, deleted = @deleted where idarbol = @idarbol
			commit
			select *, dbo.fn_deleted(deleted) deletedS from arboles where idarbol=@idarbol
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