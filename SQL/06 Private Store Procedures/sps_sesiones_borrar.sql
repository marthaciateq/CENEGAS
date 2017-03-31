CREATE PROCEDURE sps_sesiones_borrar 
	@idsesion varchar(max)
AS
BEGIN
	delete from sesiones where idsesion = @idsesion
END