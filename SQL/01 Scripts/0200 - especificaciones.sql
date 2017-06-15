CREATE TABLE especificaciones(
	idespecificacion char(32) NOT NULL,
	idelemento char(32) NOT NULL,
	zona char(1) NOT NULL,
	fecha date NOT NULL,
	minimo decimal(10,4),
	maximo decimal(10,4),
	max_diaria decimal(10,4),	
	deleted char(1) NOT NULL,
	CONSTRAINT PK_especificaciones PRIMARY KEY (idespecificacion),
	CONSTRAINT CK_especificaciones_01 CHECK (deleted in ('S','N')),	
	CONSTRAINT CK_especificaciones_02 CHECK (zona in ('S','R'))	
)
GO

ALTER TABLE especificaciones ADD CONSTRAINT FK_especificaciones_idelemento FOREIGN KEY(idelemento) REFERENCES elementos(idelemento) --ON DELETE CASCADE

INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190121817141831986', N'20170309020015170210604185856522', N'S', CAST(0x493C0B00 AS Date), CAST(36.8000 AS Decimal(10, 4)), CAST(43.6000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190228205171114518', N'20170309015951417199240994016694', N'R', CAST(0x493C0B00 AS Date), NULL, CAST(11.0000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190258031242109495', N'20170309020026853780619637897140', N'S', CAST(0x493C0B00 AS Date), CAST(47.3000 AS Decimal(10, 4)), CAST(53.2000 AS Decimal(10, 4)), CAST(5.0000 AS Decimal(10, 4)), N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190290696531075639', N'20170309015853370572487661852156', N'R', CAST(0x493C0B00 AS Date), CAST(84.0000 AS Decimal(10, 4)), NULL, NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190308619048010703', N'20170309015928330107009458012671', N'R', CAST(0x493C0B00 AS Date), NULL, CAST(4.0000 AS Decimal(10, 4)), CAST(1.5000 AS Decimal(10, 4)), N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190325761348506295', N'20170309020008463989527069460466', N'S', CAST(0x493C0B00 AS Date), NULL, CAST(110.0000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190419659476524130', N'20170309025552797692799663893621', N'S', CAST(0x493C0B00 AS Date), NULL, CAST(150.0000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190566682730414663', N'20170309015957970566087161253495', N'S', CAST(0x493C0B00 AS Date), NULL, CAST(271.1500 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190830516137933530', N'20170309015957970566087161253495', N'R', CAST(0x493C0B00 AS Date), NULL, CAST(271.1500 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190840547634847247', N'20170309015951417199240994016694', N'S', CAST(0x493C0B00 AS Date), NULL, CAST(11.0000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190843515428888263', N'20170309020008463989527069460466', N'R', CAST(0x493C0B00 AS Date), NULL, CAST(110.0000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190904855408223182', N'20170309015944683851382958625331', N'R', CAST(0x493C0B00 AS Date), NULL, CAST(4.0000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190932554403592341', N'20170309015901120264999557990182', N'R', CAST(0x493C0B00 AS Date), NULL, CAST(0.2000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190974810773999582', N'20170309015908920302612186275755', N'R', CAST(0x493C0B00 AS Date), NULL, CAST(3.0000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714190988088603054878', N'20170309020037077750203474849206', N'S', CAST(0x493C0B00 AS Date), NULL, CAST(6.0000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714193210131883295062', N'20170309015944683851382958625331', N'S', CAST(0x493C0B00 AS Date), NULL, CAST(8.0000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714193232448553482930', N'20170309015901120264999557990182', N'S', CAST(0x493C0B00 AS Date), NULL, CAST(0.2000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714193562620086563604', N'20170309015908920302612186275755', N'S', CAST(0x493C0B00 AS Date), NULL, CAST(3.0000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714193707533519907789', N'20170309015853370572487661852156', N'S', CAST(0x493C0B00 AS Date), CAST(83.0000 AS Decimal(10, 4)), NULL, NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309031714193804934037437186', N'20170309015928330107009458012671', N'S', CAST(0x493C0B00 AS Date), NULL, CAST(8.0000 AS Decimal(10, 4)), CAST(1.5000 AS Decimal(10, 4)), N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309032030180228821296428112', N'20170309025552797692799663893621', N'R', CAST(0x493C0B00 AS Date), NULL, CAST(150.0000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309032030180584661295275118', N'20170309020015170210604185856522', N'R', CAST(0x493C0B00 AS Date), CAST(37.3000 AS Decimal(10, 4)), CAST(43.6000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309032030180731400966556224', N'20170309020037077750203474849206', N'R', CAST(0x493C0B00 AS Date), NULL, CAST(6.0000 AS Decimal(10, 4)), NULL, N'N')
INSERT [dbo].[especificaciones] ([idespecificacion], [idelemento], [zona], [fecha], [minimo], [maximo], [max_diaria], [deleted]) VALUES (N'20170309032030180922932219236033', N'20170309020026853780619637897140', N'R', CAST(0x493C0B00 AS Date), CAST(48.2000 AS Decimal(10, 4)), CAST(53.2000 AS Decimal(10, 4)), CAST(5.0000 AS Decimal(10, 4)), N'N')
GO