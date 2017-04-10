CREATE PROCEDURE sps_pmuestreo_borrar 
	@idsesion varchar(max),
	@pmuestreo varchar(max)
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	declare @idempresaSESION varchar(max)
	
	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		declare @idpmuestreo varchar(max)
		declare cursor1 cursor fast_forward for select col1 from fn_table(1,@pmuestreo)
		open cursor1
		fetch cursor1 into @idpmuestreo
		while @@FETCH_STATUS=0
		begin
				begin try
					begin transaction
						delete from pmuestreo where idpmuestreo = @idpmuestreo
					commit
				end try
				begin catch
					rollback
					begin try
						begin transaction
							update pmuestreo set deleted = 'S' where idpmuestreo = @idpmuestreo
						commit
					end try
					begin catch
						rollback
					end catch
				end catch
			fetch cursor1 into @idpmuestreo
		end
		close cursor1
		deallocate cursor1
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END