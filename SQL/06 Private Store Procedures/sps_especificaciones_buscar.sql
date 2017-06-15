CREATE PROCEDURE sps_especificaciones_buscar 
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
			a.*,
			dbo.fn_dateToString(a.fecha) fechaS,
			b.descripcion elemento
		from v_especificaciones a
			inner join v_elementos b on a.idelemento=b.idelemento
		where (@buscar is null or dbo.fn_buscar(@buscar, b.elemento,a.zonaS,null,null,null) = 'S') 
		order by b.orden,a.zona,a.fecha
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END