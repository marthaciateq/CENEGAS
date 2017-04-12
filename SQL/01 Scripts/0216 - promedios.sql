CREATE TABLE PROMEDIOS
	[idbdatos] [char](32) NOT NULL,
	[idpmuestreo] [char](32) NOT NULL,
	[fecha] [datetime] NOT NULL,
	[metano] [decimal](18, 10) NULL,
	[bioxidoCarbono] [decimal](18, 10) NULL,
	[nitrogeno] [decimal](18, 10) NULL,
	[totalInertes] [decimal](18, 10) NULL,
	[etano] [decimal](18, 10) NULL,
	[tempRocio] [decimal](18, 10) NULL,
	[humedad] [decimal](18, 10) NULL,
	[poderCalorifico] [decimal](18, 10) NULL,
	[indiceWoobe] [decimal](18, 10) NULL,
	[acidoSulfhidrico] [decimal](18, 10) NULL,
	[azufreTotal] [decimal](18, 10) NULL,
	[oxigeno] [decimal](18, 10) NULL
) ON [PRIMARY]

CREATE CLUSTERED INDEX Promedios_01
    ON Promedios (idpmuestreo,fecha);   
GO 




