CREATE PROCEDURE sps_elementos_buscar 
	@idsesion varchar(max),
	@buscar varchar(max) = null
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)

	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		select
			a.*
		from v_elementos a
		where (@buscar is null or dbo.fn_buscar(@buscar, a.elemento,null,null,null,null) = 'S') 
		order by a.descripcion
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END