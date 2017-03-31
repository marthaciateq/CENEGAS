CREATE PROCEDURE spp_pmuestreo_buscar 
	@buscar varchar(max) = null
AS
BEGIN
	select * 
	from v_pmuestreo
	where (@buscar is null or dbo.fn_buscar(@buscar,punto,nalterno,descripcion,null,null) = 'S') 
		and deleted = 'N'
	order by nalterno,descripcion
END
