CREATE PROCEDURE sps_roles_borrar 
	@idsesion varchar(max),
	@roles varchar(max)
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	
	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		declare @idrol varchar(max)
		declare cursor1 cursor fast_forward for select col1 from fn_table(1,@roles) where col1 <> '15283614250832728429629473271945'
		open cursor1
		fetch cursor1 into @idrol
		while @@FETCH_STATUS=0
		begin
			begin try
				delete from roles where idrol = @idrol
			end try
			begin catch
				update roles set deleted = 'S' where idrol = @idrol
			end catch
			fetch cursor1 into @idrol
		end
		close cursor1
		deallocate cursor1
		if (select COUNT(*) from fn_table(1,@roles) where col1 = '15283614250832728429629473271945') > 0
			execute sp_error 'U', 'El rol "Adminsitrador" no puede ser borrado.'
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END