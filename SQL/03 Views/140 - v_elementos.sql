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
		descripcion + ' (' + simbolo+ ') ' unidad
	from elementos a
		