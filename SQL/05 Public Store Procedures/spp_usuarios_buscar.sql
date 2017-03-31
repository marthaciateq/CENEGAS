CREATE PROCEDURE spp_usuarios_buscar
	@buscar varchar(max),
	@idusuario varchar(max)
AS
BEGIN
	declare @error varchar(max)
	begin try
		select
			a.*
		from v_usuarios a
		where a.deleted = 'N'
			and (@buscar is null or dbo.fn_buscar(@buscar, a.login, a.nombre,a.apaterno,a.amaterno, null) = 'S')
			and (@idusuario is null or a.idusuario = @idusuario)
		order by a.nombre
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END