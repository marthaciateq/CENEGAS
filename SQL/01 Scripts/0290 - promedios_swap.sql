
CREATE TABLE [dbo].[rpromedio_swap](
	[idbdatos] [char](32) NOT NULL,
	[idpmuestreo] [char](32) NOT NULL,
	[idelemento] [char](32) NOT NULL,
	[fecha] [datetime] NOT NULL,
	[promedio] [float] NULL,
	[estatus] [char](1) NULL
) ON [PRIMARY]


