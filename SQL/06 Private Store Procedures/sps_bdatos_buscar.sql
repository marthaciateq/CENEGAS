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
			, nuevosPuntos
			, horariosInsertados
			, promediosInsertados
			, idusuario
			, nombreOriginalArchivoHorarios
			, nombreOriginalArchivoPromedios
		INTO #bDatosTable
		FROM (
			SELECT
				  horariosTable.idbdatos AS idHorarios
				, horariosTable.idusuario AS idusuario
				, dbo.fn_dateToString(horariosTable.finicial) AS finicial
				, dbo.fn_dateToString(horariosTable.ffinal)   AS ffinal
				
				, horariosTable.fcarga
				, horariosTable.narchivo     AS nombreArchivoHorarios
				, horariosTable.noriginal    AS nombreOriginalArchivoHorarios
				, horariosTable.nuevosPuntos
				, horariosTable.insertados   AS horariosInsertados
			FROM dbo.bdatos AS horariosTable
			WHERE tipoArchivo = 'H'
				AND ( @fechaInicial IS NULL OR CAST(finicial AS DATE) >= CAST( @fechaInicial AS DATE )  )
				AND ( @fechaFinal   IS NULL OR CAST(ffinal AS DATE) <= CAST( @fechaFinal AS DATE))
				AND deleted = 'N'
			
			) AS horariosTable
		
			INNER JOIN (
				SELECT
					  promediosTable.idbdatos AS idPromedios
					, promediosTable.fcarga
					, promediosTable.narchivo     AS nombreArchivoPromedios
					, promediosTable.noriginal    AS nombreOriginalArchivoPromedios
					, promediosTable.insertados   AS promediosInsertados
				FROM dbo.bdatos AS promediosTable
				WHERE tipoArchivo = 'P'
				AND ( @fechaInicial IS NULL OR CAST(finicial AS DATE) >= CAST( @fechaInicial AS DATE )  )
				AND ( @fechaFinal   IS NULL OR CAST(ffinal AS DATE) <= CAST( @fechaFinal AS DATE))
				AND deleted = 'N'
				
			) AS promediosTable
		
			ON horariosTable.fcarga = promediosTable.fcarga
		
		
		
		SELECT bDatos.*, usuarios.nombres + ' ' +  usuarios.apaterno + ' ' + usuarios.amaterno AS nombreCompleto
		FROM #bDatosTable AS bDatos
			INNER JOIN dbo.usuarios AS usuarios ON usuarios.idusuario = bDatos.idusuario
		
		
		DROP TABLE #bDatosTable;
	end try
	begin catch
		set @error = error_message()
		execute sp_error 'S', @error
	end catch
END

