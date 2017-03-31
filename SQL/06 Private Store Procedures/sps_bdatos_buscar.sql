CREATE PROCEDURE sps_bdatos_buscar 
	@idsesion varchar(max),
	@fecha datetime
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	declare @idempresaSESION varchar(max)
	
	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		select
			a.*,
			dbo.fn_dateToString(convert(date,a.fcarga)) fechaS,
			b.nombres
		from bdatos a
			inner join usuarios b on a.idusuario=b.idusuario
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END