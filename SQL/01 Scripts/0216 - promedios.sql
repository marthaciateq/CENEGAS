CREATE TABLE PROMEDIOS(
	punto nvarchar(50) NOT NULL,
	nalterno nvarchar(100) NOT NULL,
	fecha nvarchar(100) NOT NULL,	
	metano decimal(10,4),
	bcarbono decimal(10,4),
	nitrogeno decimal(10,4),
	totalinertes decimal(10,4),
	etano decimal(10,4),
	temprocio decimal(10,4),
	humedad decimal(10,4),
	podercalorifico decimal(10,4),
	indicewoobe decimal(10,4),
	acidosulfidrico decimal(10,4),
	oxigeno decimal(10,4),
	azufretotal decimal(10,4)
)
GO
CREATE CLUSTERED INDEX IX_PROMEDIOS
    ON PROMEDIOS (punto,nalterno,fecha);   