CREATE PROCEDURE sps_files_read
	@idsesion varchar(max),
	@idfiles varchar(max)
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	
	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		select idfile, name, clength, ctype, data from files where idfile in (select col1 from dbo.fn_table(1,@idfiles));
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END