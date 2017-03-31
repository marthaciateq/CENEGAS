CREATE VIEW v_pmuestreo (
	idpmuestreo,
	punto,
	nalterno,
	descripcion,
	zona,
	deleted,
	deletedS,
	zonaS
) AS
	select 
		a.*,
		dbo.fn_deleted(a.deleted) deletedS,
		case when zona='S' then 'SUR' else 'RESTO DEL PAIS' end
	from pmuestreo a
		