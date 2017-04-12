MERGE HORARIOS AS a
USING OPENROWSET (
    BULK 'C:\proyectos\cenegas\otros\febreropromedio.csv',
    FORMATFILE = 'C:\proyectos\cenegas\otros\bcp.xml'
    ) AS b
ON a.punto = b.punto and a.nalterno=b.nalterno and a.fecha=b.fecha
WHEN MATCHED and(
		a.metano<>b.metano 
		or a.bcarbono<>b.bcarbono
		or a.nitrogeno<>b.nitrogeno
		or a.totalinertes<>b.totalinertes
		or a.etano<>b.etano
		or a.temprocio<>b.temprocio
		or a.humedad<>b.humedad
		or a.podercalorifico<>b.podercalorifico
		or a.indicewoobe<>b.indicewoobe
		or a.acidosulfidrico<>b.acidosulfidrico
	)
	THEN UPDATE SET metano=b.metano
WHEN NOT MATCHED THEN INSERT VALUES (punto,nalterno,b.fecha,metano,bcarbono,nitrogeno,totalinertes,etano,temprocio,humedad,podercalorifico,indicewoobe,acidosulfidrico,null,null)
OUTPUT $action, inserted.*, deleted.*;

