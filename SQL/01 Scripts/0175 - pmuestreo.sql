CREATE TABLE pmuestreo(
	idpmuestreo char(32) NOT NULL,
	punto varchar(256) NOT NULL,
	nalterno varchar(256) NOT NULL,	
	descripcion varchar(256) NOT NULL,		
	zona char(1) NOT NULL,
	deleted char(1) NOT NULL,
	CONSTRAINT PK_pmuestreo PRIMARY KEY (idpmuestreo),
	CONSTRAINT CK_pmuestreo_01 CHECK (zona in ('S','R'))		
)
GO

INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120112112088856392', N'S-VCBGN070-TR01', N'"CRE 19 Venta Carpio 14"""', N'"Pto. de Calidad Ducto 22"" T.R."', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120120465220907310', N'S-REBGN260-TR07', N'"CRE 44 CPG Burgos 1', N'2 y 3",Pto. de Calidad CPG Burgos  criog. 1 2 3 T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120134012259936007', N'S-REBGN120-TR01', N'CRE 4 GIMSA', N'"Pto. de Calidad GIMSA 12"" T.R."', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120139680679038115', N'S-REBGN290-TR36', N'CRE 57 Nejo', N'Pto. de Calidad Nejo T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120150242505033548', N'S-MABGN160-TR03', N'CRE Iberdrola Altamira', N'Pto. de Calidad IBERDROLA T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120188305109283891', N'S-REBGN070-TR11', N'CRE 60 Kinder Morgan Reynosa', N'Pto. de Calidad Imp. Kinder Morgan T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120191428386701654', N'S-TXBGN050-TR06', N'CRE 24 Puebla', N'Pto. de Calidad Natgasmex (Xicotencatl)', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120283536001386183', N'S-REEGN011-TR38', N'CRE Mareografo', N'Pto. de Calidad Mareografo T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120310017353923134', N'S-CABGN060-TR08', N'"CRE 35 Troncal 48"""', N'Pto. de Calidad Pared¾n T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120327130527304410', N'S-MIBGN140-TR04', N'CRE 41 CPG La Venta', N'Pto. de Calidad La Venta T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120329155558844269', N'S-MTBGN190-TR23', N'CRE 9 Red Monclova', N'Pto. de Calidad Casta±os T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120331500847546218', N'S-VEBGN051-TR09', N'CRE 30 Cempoala Centro', N'Pto de Calidad de Cempoala al Centro T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120440519374229385', N'S-CMBGN030-TR01', N'CRE 26 Ciudad Mendoza', N'Pto. de Calidad Cd. Mendoza T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120465703804166480', N'S-MIBGN150-TR06', N'CRE 47 Pajaritos (CriogÚnica)', N'Pto. de Calidad Pajaritos B.P. T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120504177296306411', N'S-MTBGN221-TR24', N'CRE 1 Ramones', N'Pto. de Calidad Ramones T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120521056208991835', N'S-REBGN080-TR25', N'CRE 60 Tetco', N'Pto. de Calidad Imp. TETCO T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120527748804488486', N'S-HEBGN252-TR04', N'CRE 65 Naco-Hermosillo', N'Pto. de Calidad PR Fenosa T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120573653942708636', N'S-MABGN050-TR07', N'CRE 12 Madero I', N'Pto. de Calidad Lomas del Real T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120573818042682079', N'S-REBGN261-TR35', N'CRE 45 CPG Burgos 4', N'Pto. de Calidad CPG Burgos Criog. 4 T.R', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120639626635442993', N'S-VEBGN051-TR08', N'CRE 29 Cempoala Norte', N'Pto de Calidad a Cempoala del Norte T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120640165073550587', N'S-MTBGN612-TR22', N'CRE 53 Monclova', N'Pto. de Calidad Inyecci¾n PEP Santa Elena T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120642883282913690', N'S-VCBGN070-TR04', N'"CRE 18 Venta Carpio 24"""', N'"Pto. de Calidad Ducto 18"" T.R."', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120674192349641729', N'S-CABGN072-TR03', N'CRE 40 CPG Nuevo Pemex', N'Pto. de Calidad Nuevo Pemex T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120690014700586179', N'S-CABGN110-TR04', N'CRE 39 KM-100', N'Pto. de Calidad Km. 100 T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120707877271545111', N'S-MIBGN150-TR07', N'CRE 34 Caseta General Pajaritos', N'Pto. de Calidad Caseta Gral. Pajaritos T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120723761643452447', N'S-MABGN040-TR06', N'CRE 13 Madero II', N'Pto. de Calidad El Blanco T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120724807077285335', N'S-REBGN260-TR36', N'CRE 46 Burgos 5 y 6', N'Pto. de Calidad CPG Burgos Criog. 5 y 6 T.R', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120738217944377057', N'S-MIBGN091-TR02', N'CRE 32 Pecosa Alta', N'Pto. de Calidad Pecosa Alta Presi¾n T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120762484728652194', N'S-VEBGN051-TR07', N'CRE 28 Cempoala Sur', N'Pto de Calidad a Cempoala del Sur T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120765121661026334', N'S-SABGN130-TR01', N'CRE 21 Valtierrilla', N'Pto. de Calidad Valtierrilla T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120802719712250571', N'S-REBGN081-TR04', N'CRE 61 Tennessee', N'Pto. de Calidad Imp. Tennessee T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120805019421093154', N'S-VEBGN070-TR02', N'CRE 42 Matapionche', N'Pto. de Calidad Matapionche T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120808939699246287', N'S-MTBGN440-TR07', N'CRE Kinder Morgan Mty', N'Pto. de Calidad Kinder Morgan T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120809358725032753', N'S-CABGN090-TR01', N'CRE 37 CPG Ciudad Pemex', N'Pto. de Calidad CD. Pemex T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120836407206932636', N'S-CABGN072-TR02', N'CRE 38 CPG Cactus', N'Pto. de Calidad Cactus', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120856531092494304', N'S-MTBGN210-TR04', N'CRE 3 Escobedo Baja', N'Pto. de Calidad Cabezal Baja T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120862200716262195', N'S-MTBGN180-TR26', N'CRE 8 Apodaca', N'"Pto. de Calidad Apodaca 24"" T.R."', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120862762106349604', N'S-VCBGN070-TR03', N'"CRE 17 Venta Carpio 30"""', N'"Pto. de Calidad Ducto 30"" T.R."', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120873970994332758', N'S-MTBGN180-TR25', N'CRE 8 Apodaca', N'"Pto. de Calidad Apodaca 22"" T.R."', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120892660497338439', N'S-GUBGN030-TR01', N'CRE 23 Guadalajara', N'Pto. de Calidad El Castillo T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120914916117001571', N'S-VEBGN020-TR10', N'CRE 31 Veracruz', N'Pto. de Calidad CFE Dos Bocas T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120915383662832852', N'S-CHBGN060-TR01', N'CRE 11 Chihuahua (Avalos)', N'Pto. de Calidad Terminal Avalos T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120930194193239694', N'S-VCBGN070-TR02', N'"CRE 16 Venta de Carpio 36"""', N'"Pto. de Calidad Ducto 36"" T.R."', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120930528088224278', N'S-MTBGN040-TR15', N'CRE CFE CCC Huinala', N'Pto. de Calidad CCC Huinala T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120932581292738448', N'S-MTBGN210-TR05', N'CRE 2 Escobedo Alta', N'Pto. de Calidad Cabezal Alta T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120940524820727983', N'S-MIBGN030-TR12', N'CRE 33 Pecosa Baja', N'Pto. de Calidad Gas de Baja Mina T.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120950910622561064', N'S-REBGN270-TR08', N'CRE 63 Pandura', N'Pto. de Calidad CG N LaredoT.R.', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120977804552872460', N'S-TOBGN010-TR01', N'CRE 10 Torreon', N'Pto. de Calidad Est. Chßvez T.R.', N'R', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120986433467240368', N'S-CMEGN230-TR09', N'CRE 51 Papan', N'Pto. de Calidad Iny. PEP PAPAN', N'S', N'N')
INSERT [dbo].[pmuestreo] ([idpmuestreo], [punto], [nalterno], [descripcion], [zona], [deleted]) VALUES (N'20170309043836120991488409710355', N'S-VEEGN001-TR05', N'CRE 50 Playuela', N'Pto. de Calidad Playuela T.R.', N'S', N'N')

GO

