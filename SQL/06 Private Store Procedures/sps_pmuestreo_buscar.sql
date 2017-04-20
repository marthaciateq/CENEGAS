CREATE PROCEDURE sps_pmuestreo_buscar 
	@idsesion varchar(max),
	@buscar varchar(max) = null
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	declare @idempresaSESION varchar(max)
	
	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		select
			a.*
		from v_pmuestreo a
		where (@buscar is null or dbo.fn_buscar(@buscar, a.punto,a.nalterno,a.descripcion,null,null) = 'S') 
		order by a.zona,a.punto,a.nalterno
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END