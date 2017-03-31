CREATE PROCEDURE sps_files_write
	@idsesion varchar(max),
	@name varchar(max),
	@clength bigint,
	@ctype varchar(max),
	@data varbinary(max) = null
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	
	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		declare @idfile varchar(max)
		execute sp_randomKey @idfile output
		insert into files values(@idfile, @idusuarioSESION, @name, GETUTCDATE(), @clength, @ctype, @data)
		select @idfile iddfile
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END