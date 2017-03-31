
CREATE TABLE [dbo].[registros_swap](
	[idbdatos] [char](32) NOT NULL,
	[idpmuestreo] [char](32) NOT NULL,
	[idelemento] [char](32) NOT NULL,
	[fecha] [datetime] NOT NULL,
	[valor] [float] NULL,
	[estatus] [char](1) NULL
) ON [PRIMARY]

