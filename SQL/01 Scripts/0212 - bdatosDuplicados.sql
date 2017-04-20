CREATE TABLE [dbo].[bdatosDuplicados](
	[idbdatos] [char](32) NOT NULL,
	[idusuario] [char](32) NOT NULL,
	[fcarga] [datetime] NOT NULL,
	[noriginal] [varchar](256) NOT NULL,
	[tipoArchivo] [char](1) NOT NULL,
 CONSTRAINT [PK_bdatosDuplicados] PRIMARY KEY (idbdatos) 
) 
