CREATE VIEW v_horarios AS
SELECT b.idpmuestreo,b.punto,b.nalterno,b.descripcion,b.zona,c.idelemento,c.descripcion elemento,dbo.fn_datetimeStringToDatetime(fecha) fecha,concepto,valor
FROM 
   (SELECT horarios.*
   FROM horarios) p
UNPIVOT
   (valor FOR concepto IN 
      (metano, bcarbono, nitrogeno, totalinertes,etano,temprocio,humedad,podercalorifico,indicewoobe,acidosulfidrico,oxigeno,azufretotal)
)AS a
	inner join pmuestreo b on a.punto=b.punto
		inner join elementos c on c.codigo=a.concepto
;

