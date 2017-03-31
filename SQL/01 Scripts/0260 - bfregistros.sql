CREATE TABLE bfregistros(
	idbfregistro char(32) NOT NULL,
	idbdatos char(32) NOT NULL,
	idpmuestreo char(32) NOT NULL,
	idelemento char(32) NOT NULL,	
	fecha datetime NOT NULL,
	CONSTRAINT PK_bfregistros PRIMARY KEY (idbfregistro)
)
GO

ALTER TABLE bfregistros ADD CONSTRAINT FK_bfregistros_bdatos FOREIGN KEY(idbdatos) REFERENCES bdatos(idbdatos)
GO

ALTER TABLE bfregistros ADD CONSTRAINT FK_bfregistros_pmuestreo FOREIGN KEY(idpmuestreo) REFERENCES pmuestreo(idpmuestreo)
GO

ALTER TABLE bfregistros ADD CONSTRAINT FK_brfegistros_elementos FOREIGN KEY(idelemento) REFERENCES elementos(idelemento)
GO

