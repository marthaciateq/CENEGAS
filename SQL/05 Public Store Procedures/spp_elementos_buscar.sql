CREATE PROCEDURE spp_elementos_buscar 
	@buscar varchar(max) = null
AS
BEGIN
	select * 
	from v_elementos
	where (@buscar is null or dbo.fn_buscar(@buscar,descripcion,unidad,null,null,null) = 'S') 
	order by descripcion
END
