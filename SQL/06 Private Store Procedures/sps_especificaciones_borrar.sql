CREATE PROCEDURE sps_especificaciones_borrar 
	@idsesion varchar(max),
	@especificaciones varchar(max)
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	declare @idempresaSESION varchar(max)
	
	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		declare @idespecificacion varchar(max)
		declare cursor1 cursor fast_forward for select col1 from fn_table(1,@especificaciones)
		open cursor1
		fetch cursor1 into @idespecificacion
		while @@FETCH_STATUS=0
		begin
				begin try
					begin transaction
						delete from especificaciones where idespecificacion = @idespecificacion
					commit
				end try
				begin catch
					rollback
					begin try
						begin transaction
							update especificaciones set deleted = 'S' where idespecificacion = @idespecificacion
						commit
					end try
					begin catch
						rollback
					end catch
				end catch
			fetch cursor1 into @idespecificacion
		end
		close cursor1
		deallocate cursor1
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END