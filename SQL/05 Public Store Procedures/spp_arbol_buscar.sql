CREATE PROCEDURE spp_arbol_buscar
	@idpadre varchar(max),
	@buscar varchar(max) = null
AS
BEGIN
	if @idpadre is null return
	select
		idarbol,
		descripcion
	from arboles
	where idpadre = @idpadre
		and (@buscar is null or dbo.fn_buscar(@buscar, descripcion, null, null, null, null) = 'S')
		and deleted='N'
	order by descripcion
END