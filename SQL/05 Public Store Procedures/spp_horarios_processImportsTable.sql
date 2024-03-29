-- =============================================
-- Author:		Angel Hernandez
-- Create date: marzo 2017
-- Description:	Trata la información de la tabla de importaciones para ser guardada en la tabla destino registros.
-- =============================================
CREATE PROCEDURE [dbo].[spp_horarios_processImportsTable]
	-- Add the parameters for the stored procedure here
	    @idbdatos       VARCHAR(32)
	  , @viewHowChanges BIT
AS
BEGIN
	
	SET NOCOUNT ON;
	

	DECLARE @INSERTED_RECORDS INT = 0;
	

	
		
	MERGE dbo.HORARIOS AS targetTable
	USING dbo.importacionesHorarios AS sourceTable
	ON (     sourceTable.idbdatos    = @idbdatos
		 AND targetTable.idpmuestreo = sourceTable.idpmuestreo
		 AND targetTable.fecha       = sourceTable.fecha
	 )
	 WHEN NOT MATCHED BY TARGET THEN -- Si son registros nuevos, se insertan
		INSERT (idbdatos 
				, idpmuestreo
				, fecha
				, metano
				, bioxidoCarbono
				, nitrogeno
				, totalInertes
				, etano
				, tempRocio
				, humedad
				, poderCalorifico
				, indiceWoobe
				, acidoSulfhidrico
				, azufreTotal
				, oxigeno ) 
		VALUES (@idbdatos
				, sourceTable.idpmuestreo
				, sourceTable.fecha
				, sourceTable.metano
				, sourceTable.bioxidoCarbono
				, sourceTable.nitrogeno
				, sourceTable.totalInertes
				, sourceTable.etano
				, sourceTable.tempRocio
				, sourceTable.humedad
				, sourceTable.poderCalorifico
				, sourceTable.indiceWoobe
				, sourceTable.acidoSulfhidrico
				, sourceTable.azufreTotal
				, sourceTable.oxigeno)
	OUTPUT
		@idbdatos
		, INSERTED.idpmuestreo
		, INSERTED.fecha      
		, INSERTED.metano      
		, INSERTED.bioxidoCarbono
		
		, INSERTED.nitrogeno   
		, INSERTED.totalInertes
		, INSERTED.etano        
		, INSERTED.tempRocio    
		, INSERTED.humedad      
		
		, INSERTED.poderCalorifico  
		, INSERTED.indiceWoobe      
		, INSERTED.acidoSulfhidrico 
		, INSERTED.azufreTotal      
		, INSERTED.oxigeno          
		
		, SUBSTRING($ACTION, 1, 1)
		INTO BHORARIOS
	;
		
		
	
	
	IF ( @viewHowChanges = 0) BEGIN
	
		INSERT INTO REGISTROS( idregistro, idbdatos, idpmuestreo, idelemento, fecha,valor)
		SELECT dbo.fn_randomKey(),a.idbdatos,a.idpmuestreo,b.idelemento,a.fecha,valor
		FROM 
		   (SELECT idbdatos, idpmuestreo, fecha, metano, bioxidocarbono, nitrogeno, totalinertes,etano,temprocio,humedad,podercalorifico,indicewoobe,acidosulfhidrico,oxigeno,azufretotal
		   FROM horarios where idbdatos=@idbdatos) p
		UNPIVOT
		   (valor FOR concepto IN 
			  (metano, bioxidocarbono, nitrogeno, totalinertes,etano,temprocio,humedad,podercalorifico,indicewoobe,acidosulfhidrico,oxigeno,azufretotal)
		)AS a
			inner join elementos b on b.codigo=a.concepto;
			
		UPDATE x set valor=z.valor
			from registros x inner join (
				SELECT a.idpmuestreo,b.idelemento,a.fecha,valor
				FROM 
				   (
					   select @idbdatos AS idbdatos, idpmuestreo, fecha, metano, bioxidocarbono, nitrogeno, totalinertes,etano,temprocio,humedad,podercalorifico,indicewoobe,acidosulfhidrico,oxigeno,azufretotal
					   from bhorarios
					   where idbdatos=@idbdatos 
						and estatus='U' 
						and(
							metano<>null
							or bioxidocarbono<>null
							or nitrogeno<>null
							or totalinertes<>null
							or etano<>null
							or temprocio<>null
							or humedad<>null
							or podercalorifico<>null
							or indicewoobe<>null
							or acidosulfhidrico<>null			    
							or oxigeno<>null	
							or azufretotal<>null
						)	    			    
				   ) p
				UNPIVOT
				   (valor FOR concepto IN 
					  (metano, bioxidocarbono, nitrogeno, totalinertes,etano,temprocio,humedad,podercalorifico,indicewoobe,acidosulfhidrico,oxigeno,azufretotal)
				)AS a
					inner join elementos b on b.codigo=a.concepto	
		) z	 on x.idpmuestreo=z.idpmuestreo and x.fecha=z.fecha	and x.idelemento=z.idelemento		
		
		
	
	END
	
	SELECT @INSERTED_RECORDS = COUNT(idbdatos) FROM dbo.BHORARIOS WHERE idbdatos = @idbdatos AND estatus = 'I';
		
	UPDATE dbo.bdatos SET insertados = @INSERTED_RECORDS WHERE idbdatos = @idbdatos;
	
END





