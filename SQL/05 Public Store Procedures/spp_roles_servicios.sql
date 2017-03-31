CREATE PROCEDURE spp_roles_servicios 
	@idrol varchar(max)
AS
BEGIN
	declare @error varchar(max)
	begin try
		select servicio from rolesServicios where idrol=@idrol
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END