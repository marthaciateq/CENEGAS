CREATE TABLE elementos(
	idelemento char(32) NOT NULL,
	descripcion varchar(256) NOT NULL,
	codigo varchar(20) NOT NULL,
	simbolo varchar(10) ,
	unidad varchar(256) NOT NULL,
	abreviatura varchar(32) NOT NULL,
	orden int NOT NULL,
	deleted char(1) NOT NULL,
	CONSTRAINT PK_elementos PRIMARY KEY (idelemento),
	CONSTRAINT CK_elementos_01 CHECK (deleted in ('S','N')),
)
GO

INSERT [elementos] ([idelemento], [descripcion], [codigo], [simbolo], [unidad],[abreviatura],[orden], [deleted]) VALUES (N'20170309015853370572487661852156', N'Metano', N'metano', N'CH4', N'% vol','abrev',1, N'N')
INSERT [elementos] ([idelemento], [descripcion], [codigo], [simbolo], [unidad],[abreviatura],[orden], [deleted]) VALUES (N'20170309015901120264999557990182', N'Oxígeno', N'oxigeno', N'O2', N'% vol','abrev',11, N'S')
INSERT [elementos] ([idelemento], [descripcion], [codigo], [simbolo], [unidad],[abreviatura],[orden], [deleted]) VALUES (N'20170309015908920302612186275755', N'Bióxido de Carbono', N'bioxidocarbono', N'CO2', N'%vol','abrev',4, N'N')
INSERT [elementos] ([idelemento], [descripcion], [codigo], [simbolo], [unidad],[abreviatura],[orden], [deleted]) VALUES (N'20170309015928330107009458012671', N'Nitrógeno', N'nitrogeno', N'N2', N'% vol','abrev',3, N'N')
INSERT [elementos] ([idelemento], [descripcion], [codigo], [simbolo], [unidad],[abreviatura],[orden], [deleted]) VALUES (N'20170309015944683851382958625331', N'Total de inertes', N'totalinertes', N'CO2 y N2', N'% vol','abrev',5, N'N')
INSERT [elementos] ([idelemento], [descripcion], [codigo], [simbolo], [unidad],[abreviatura],[orden], [deleted]) VALUES (N'20170309015951417199240994016694', N'Etano', N'etano', NULL, N'% vol','abrev',2, N'N')
INSERT [elementos] ([idelemento], [descripcion], [codigo], [simbolo], [unidad],[abreviatura],[orden], [deleted]) VALUES (N'20170309015957970566087161253495', N'Temperatura de rocío de hidrocarburos', N'temprocio', NULL, N'K(°C)','abrev',8, N'N')
INSERT [elementos] ([idelemento], [descripcion], [codigo], [simbolo], [unidad],[abreviatura],[orden], [deleted]) VALUES (N'20170309020008463989527069460466', N'Humedad', N'humedad', NULL, N'mg/m3','abrev',9, N'N')
INSERT [elementos] ([idelemento], [descripcion], [codigo], [simbolo], [unidad],[abreviatura],[orden], [deleted]) VALUES (N'20170309020015170210604185856522', N'Poder calorífico', N'podercalorifico', NULL, N'MJ/m3','abrev',6, N'N')
INSERT [elementos] ([idelemento], [descripcion], [codigo], [simbolo], [unidad],[abreviatura],[orden], [deleted]) VALUES (N'20170309020026853780619637897140', N'Índice Wobbe', N'indicewoobe', NULL, N'MJ/m3','abrev',7, N'N')
INSERT [elementos] ([idelemento], [descripcion], [codigo], [simbolo], [unidad],[abreviatura],[orden], [deleted]) VALUES (N'20170309020037077750203474849206', N'Acido sulfhídrico', N'acidosulfhidrico', N'H2S', N'mg/m3','abrev',10, N'N')
INSERT [elementos] ([idelemento], [descripcion], [codigo], [simbolo], [unidad],[abreviatura],[orden], [deleted]) VALUES (N'20170309025552797692799663893621', N'Azufre Total', N'azufretotal', N'S', N'mg/m3','abrev',12, N'S')

GO