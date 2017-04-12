CREATE VIEW v_horarios AS
SELECT a.*,b.punto,b.nalterno,b.descripcion,b.zona,c.descripcion elemento
from registros a 
	inner join pmuestreo b on a.idpmuestreo=b.idpmuestreo
		inner join elementos c on c.idelemento=a.idelemento


