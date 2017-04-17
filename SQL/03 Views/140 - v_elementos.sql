CREATE VIEW v_elementos (
	idelemento,
	descripcion,
	codigo,
	simbolo,
	unidad,
	deleted,
	deletedS,
	elemento
) AS
	select 
		a.*,
		dbo.fn_deleted(a.deleted) deletedS,
		descripcion + case when simbolo is not null then ' (' + simbolo + ') ' else '' end  + ' ' + unidad unidad
	from elementos a
		