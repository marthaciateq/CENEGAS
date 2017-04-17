CREATE VIEW v_pmuestreo (
	idpmuestreo,
	punto,
	nalterno,
	descripcion,
	zona,
	hcorte,
	deleted,
	deletedS,
	zonaS,
	pmuestreo
) AS
	select 
		a.*,
		dbo.fn_deleted(a.deleted) deletedS,
		case when zona='S' then 'SUR' else 'RESTO DEL PAIS' end,
		a.punto + ' ' + a.nalterno + ' ' + case when zona='S' then 'SUR' else 'RESTO DEL PAIS' end
	from pmuestreo a
		