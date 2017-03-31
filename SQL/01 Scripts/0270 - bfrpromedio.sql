CREATE TABLE bfrpromedio(
	idbfrpromedio char(32) NOT NULL,
	idbdatos char(32) NOT NULL,
	idpmuestreo char(32) NOT NULL,
	idelemento char(32) NOT NULL,	
	fecha datetime NOT NULL,
	CONSTRAINT PK_bfrpromedio PRIMARY KEY (idbfrPROMEDIO)
)
GO

ALTER TABLE bfrpromedio ADD CONSTRAINT FK_bfrpromedio_bdatos FOREIGN KEY(idbdatos) REFERENCES bdatos(idbdatos)
GO

ALTER TABLE bfrpromedio ADD CONSTRAINT FK_bfrpromedio_pmuestreo FOREIGN KEY(idpmuestreo) REFERENCES pmuestreo(idpmuestreo)
GO

ALTER TABLE bfrpromedio ADD CONSTRAINT FK_bfrpromedio_elementos FOREIGN KEY(idelemento) REFERENCES elementos(idelemento)
GO

