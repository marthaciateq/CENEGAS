CREATE PROCEDURE sps_arboles_borrar 
	@idsesion varchar(max),
	@arboles varchar(max)
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	
	declare @borrados table(idarbol varchar(max))
	declare @eliminados table(idarbol varchar(max))
	
	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		declare @idarbol varchar(max)
		declare cursor1 cursor fast_forward for select col1 from fn_table(1,@arboles) order by 1 desc
		open cursor1
		fetch cursor1 into @idarbol
		while @@FETCH_STATUS=0
		begin
			begin try
				delete from arboles where idarbol = @idarbol
				insert into @eliminados values(@idarbol)
			end try
			begin catch
				update arboles set deleted = 'S' where idarbol = @idarbol
				insert into @borrados values(@idarbol)
			end catch
			fetch cursor1 into @idarbol
		end
		close cursor1
		deallocate cursor1
		select * from @borrados
		select * from @eliminados
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END