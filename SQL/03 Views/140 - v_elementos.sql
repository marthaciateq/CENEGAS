CREATE VIEW v_elementos (
	idelemento,
	descripcion,
	unidad,
	deleted,
	deletedS,
	elemento
) AS
	select 
		a.*,
		dbo.fn_deleted(a.deleted) deletedS,
		descripcion + ' ' + unidad
	from elementos a
		