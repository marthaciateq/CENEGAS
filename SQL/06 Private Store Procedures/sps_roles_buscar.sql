CREATE PROCEDURE sps_roles_buscar 
	@idsesion varchar(max),
	@idrol varchar(max) = null,
	@nombre varchar(max) = null,
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
		from roles
		where 
			(@idrol is null or idrol = @idrol)
			and (@nombre is null or nombre like '%' + @nombre + '%')
			and (@deleted is null or deleted = @deleted)
		order by nombre
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END