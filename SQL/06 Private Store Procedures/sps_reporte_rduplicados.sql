CREATE PROCEDURE sps_reporte_rduplicados
	@idsesion varchar(max),
	@idbdatos varchar(max)
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	declare @d_finicial date
	declare @d_ffinal date

	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		if @idbdatos is null execute sp_error 'U','Favor de seleccionar una base de datos'
		
		select * from importacionesRegistrosDuplicados a
			where a.idbdatos=@idbdatos
			
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END
	




