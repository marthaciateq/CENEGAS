CREATE PROCEDURE sps_arboles_buscar 
	@idsesion varchar(max),
	@idarbol varchar(max) = null,
	@idpadre varchar(max) = null,
	@descripcion varchar(max) = null,
	@deleted varchar(max) = null
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	
	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		select
			*,
			dbo.fn_deleted(deleted) deletedS
		from arboles
		where 
			(@idarbol is null or idarbol = @idarbol)
			and (@idpadre is null or idpadre = @idpadre)
			and (@descripcion is null or descripcion like '%' + @descripcion + '%')
			and (@deleted is null or deleted = @deleted)
		order by descripcion
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END