ALTER VIEW v_promedios AS
SELECT a.*,b.punto,b.nalterno,b.descripcion,b.zona,b.hcorte,c.descripcion elemento, c.codigo celemento
from rpromedio a 
	inner join pmuestreo b on a.idpmuestreo=b.idpmuestreo
		inner join elementos c on c.idelemento=a.idelemento
;

