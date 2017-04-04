CREATE PROCEDURE [dbo].[sps_bdatos_buscar] 
	@idsesion varchar(max),
	@fecha datetime
AS
BEGIN
	declare @error varchar(max)
	declare @idusuarioSESION varchar(max)
	declare @idempresaSESION varchar(max)
	
	begin try
		execute sp_servicios_validar @idsesion, @@PROCID, @idusuarioSESION output
		
		
		SELECT 
			  idHorarios
			, idPromedios
			, dbo.fn_dateToString(horariosTable.fcarga) AS fcarga			  
			, finicial
			, ffinal
			, actualizar
			
			, horariosInsertados
			, horariosActualizados
			, promediosInsertados
			, promediosActualizados
			
			, nombreOriginalArchivoHorarios
			, nombreOriginalArchivoPromedios
		FROM (
			SELECT
				  horariosTable.idbdatos AS idHorarios
				, dbo.fn_dateToString(horariosTable.finicial) AS finicial
				, dbo.fn_dateToString(horariosTable.ffinal)   AS ffinal
				
				, horariosTable.actualizar
				, horariosTable.fcarga
				, horariosTable.narchivo     AS nombreArchivoHorarios
				, horariosTable.noriginal    AS nombreOriginalArchivoHorarios
				, horariosTable.insertados   AS horariosInsertados
				, horariosTable.actualizados AS horariosActualizados
			FROM dbo.bdatos AS horariosTable
			WHERE horariosTable.idusuario = @idusuarioSESION
					AND tipoArchivo = 'H'
			) AS horariosTable
		
			INNER JOIN (
				SELECT
					  promediosTable.idbdatos AS idPromedios
					, promediosTable.fcarga
					, promediosTable.narchivo     AS nombreArchivoPromedios
					, promediosTable.noriginal    AS nombreOriginalArchivoPromedios
					, promediosTable.insertados   AS promediosInsertados
					, promediosTable.actualizados AS promediosActualizados
				FROM dbo.bdatos AS promediosTable
				WHERE promediosTable.idusuario = @idusuarioSESION
						AND tipoArchivo = 'P'
			) AS promediosTable
		
			ON horariosTable.fcarga = promediosTable.fcarga
		
		
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END