CREATE PROCEDURE [dbo].[sps_bdatos_borrarMes] 
	  @idsesion varchar(max)
	, @mes INT
	, @anio INT
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	declare @idempresaSESION varchar(max)
	
	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		
		
		DELETE FROM dbo.HORARIOS  WHERE MONTH(fecha) = @mes AND YEAR(fecha) = @anio;
		DELETE FROM dbo.PROMEDIOS WHERE MONTH(fecha) = @mes AND YEAR(fecha) = @anio;
		DELETE FROM dbo.registros WHERE MONTH(fecha) = @mes AND YEAR(fecha) = @anio;
		DELETE FROM dbo.rpromedio WHERE MONTH(fecha) = @mes AND YEAR(fecha) = @anio;
		
		INSERT INTO dbo.bbdatos(idbbdatos, idusuario, fecha, mes, anio) 
		VALUES(dbo.fn_randomKey(), @idusuarioSESION, GETDATE(), @mes, @anio);
		
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'U', @error
	end catch
END

