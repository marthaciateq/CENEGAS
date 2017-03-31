CREATE TABLE rpromedio(
	idrpromedio char(32) NOT NULL,
	idbdatos char(32) NOT NULL,
	idpmuestreo char(32) NOT NULL,
	idelemento char(32) NOT NULL,	
	fecha datetime NOT NULL,
	promedio float NOT NULL,
	valido char(1) NOT NULL,
	CONSTRAINT PK_rpromedio PRIMARY KEY (idrpromedio)
)
GO

ALTER TABLE rpromedio ADD CONSTRAINT FK_rpromedio_bdatos FOREIGN KEY(idbdatos) REFERENCES bdatos(idbdatos)
GO

ALTER TABLE rpromedio ADD CONSTRAINT FK_rpromedio_pmuestreo FOREIGN KEY(idpmuestreo) REFERENCES pmuestreo(idpmuestreo)
GO

ALTER TABLE rpromedio ADD CONSTRAINT FK_rpromedios_elementos FOREIGN KEY(idelemento) REFERENCES elementos(idelemento)
GO

