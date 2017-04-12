CREATE VIEW v_especificaciones (
	idespecificacion,
	idelemento,
	zona,
	fecha,
	minimo,
	maximo,
	max_diaria,
	deleted,
	deletedS,
	zonaS
) AS
	select 
		a.*,
		dbo.fn_deleted(a.deleted) deletedS,
		case when zona='S' then 'SUR' else 'RESTO DEL PAIS' end
	from especificaciones a
		