CREATE PROCEDURE sps_registros_aprobar
	@idsesion varchar(max),
	@finicial varchar(max),
	@ffinal varchar(max)
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)

	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		declare @terrores table(idregistro varchar(max))
		declare @registros table(idregistro varchar(max))
		declare @idpoliza varchar(max)
		declare @validador varchar(max)
		
		insert into @registros
			select idregistro from registros where fecha>=@finicial and fecha<=@fecha final
		
		declare cursor1 cursor fast_forward for select col1, col2 from fn_table(2,@registros)
		open cursor1
		fetch cursor1 into @idpoliza, @validador
		while @@FETCH_STATUS = 0
		begin
			begin try
				execute sp_polizas_workflow @idpoliza, @idusuarioSesion, 'APROBAR', @validador, @comentarios, null, null
			end try
			begin catch
				set @error = dbo.fn_error(error_message())
				if @error is null set @error = 'Error no controlado.'
				insert into @terrores values(@idpoliza, @error)
			end catch
			fetch cursor1 into @idpoliza, @validador
		end
		close cursor1
		deallocate cursor1
		select * from @terrores
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END