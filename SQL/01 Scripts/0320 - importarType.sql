<<<<<<< HEAD


CREATE TYPE [dbo].[importarType] AS TABLE(
	[punto] [char](32) NULL,
	[nombreAlterno] [varchar](256) NULL,
	[fecha] [datetime] NULL,
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
)


=======


CREATE TYPE [dbo].[importarType] AS TABLE(
	[punto] [char](32) NULL,
	[nombreAlterno] [varchar](256) NULL,
	[fecha] [datetime] NULL,
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
)


>>>>>>> parent of 85b61ad... Se quitaron las columnas azufreTotal y oxigeno
