CREATE PROCEDURE [dbo].[sps_bdatos_buscar] 
	  @idsesion varchar(max)
	, @fechaInicial DATETIME = NULL
	, @fechaFinal DATETIME   = NULL
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
			, horariosTable.fcarga
			, horariosNuevosPuntos AS nuevosPuntos
			, horariosInsertados
			, horariosActualizados
			, horariosFueraFecha
			, promediosInsertados
			, promediosActualizados
			, promediosFueraFecha
			
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
				, horariosTable.nuevosPuntos AS horariosNuevosPuntos
				, horariosTable.insertados   AS horariosInsertados
				, horariosTable.actualizados AS horariosActualizados
				, horariosTable.fueraFecha   AS horariosFueraFecha
			FROM dbo.bdatos AS horariosTable
			WHERE tipoArchivo = 'H'
				AND ( @fechaInicial IS NULL OR CAST(finicial AS DATE) >= CAST( @fechaInicial AS DATE )  )
				AND ( @fechaFinal   IS NULL OR CAST(ffinal AS DATE) <= CAST( @fechaFinal AS DATE))
			
			) AS horariosTable
		
			INNER JOIN (
				SELECT
					  promediosTable.idbdatos AS idPromedios
					, promediosTable.fcarga
					, promediosTable.narchivo     AS nombreArchivoPromedios
					, promediosTable.noriginal    AS nombreOriginalArchivoPromedios
					, promediosTable.nuevosPuntos AS promediosNuevosPuntos
					, promediosTable.insertados   AS promediosInsertados
					, promediosTable.actualizados AS promediosActualizados
					, promediosTable.fueraFecha   AS promediosFueraFecha
				FROM dbo.bdatos AS promediosTable
				WHERE tipoArchivo = 'P'
				AND ( @fechaInicial IS NULL OR CAST(finicial AS DATE) >= CAST( @fechaInicial AS DATE )  )
				AND ( @fechaFinal   IS NULL OR CAST(ffinal AS DATE) <= CAST( @fechaFinal AS DATE))
				
			) AS promediosTable
		
			ON horariosTable.fcarga = promediosTable.fcarga
		
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END

