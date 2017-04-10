CREATE PROCEDURE sps_elementos_borrar 
	@idsesion varchar(max),
	@elementos varchar(max)
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	declare @idempresaSESION varchar(max)
	
	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		declare @idelemento varchar(max)
		declare cursor1 cursor fast_forward for select col1 from fn_table(1,@elementos)
		open cursor1
		fetch cursor1 into @idelemento
		while @@FETCH_STATUS=0
		begin
				begin try
					begin transaction
						delete from elementos where idelemento = @idelemento
					commit
				end try
				begin catch
					rollback
					begin try
						begin transaction
							update elementos set deleted = 'S' where idelemento = @idelemento
						commit
					end try
					begin catch
						rollback
					end catch
				end catch
			fetch cursor1 into @idelemento
		end
		close cursor1
		deallocate cursor1
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END