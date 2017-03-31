CREATE PROCEDURE spp_roles_usuarios
	@idusuario varchar(max)
AS
BEGIN
	declare @error varchar(max)
	begin try
		select a.idrol,b.nombre from rolesUsuarios a
			inner join roles b on a.idrol=b.idrol
		where idusuario=@idusuario
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END