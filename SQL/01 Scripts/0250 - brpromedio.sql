CREATE TABLE brpromedio(
	idbrpromedio char(32) NOT NULL,
	idbdatos char(32) NOT NULL,
	idpmuestreo char(32) NOT NULL,
	idelemento char(32) NOT NULL,	
	fecha datetime NOT NULL,
	promedio float NOT NULL,
	valido char(1) NOT NULL,
	CONSTRAINT PK_brpromedio PRIMARY KEY (idbrpromedio)
)
GO

ALTER TABLE brpromedio ADD CONSTRAINT FK_brpromedio_bdatos FOREIGN KEY(idbdatos) REFERENCES bdatos(idbdatos)
GO

ALTER TABLE brpromedio ADD CONSTRAINT FK_brpromedio_pmuestreo FOREIGN KEY(idpmuestreo) REFERENCES pmuestreo(idpmuestreo)
GO

ALTER TABLE brpromedio ADD CONSTRAINT FK_brpromedio_elementos FOREIGN KEY(idelemento) REFERENCES elementos(idelemento)
GO

