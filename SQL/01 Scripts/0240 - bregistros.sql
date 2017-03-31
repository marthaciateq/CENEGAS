CREATE TABLE bregistros(
	idbregistro char(32) NOT NULL,
	idbdatos char(32) NOT NULL,
	idpmuestreo char(32) NOT NULL,
	idelemento char(32) NOT NULL,	
	fecha datetime NOT NULL,
	valor float NOT NULL,
	mensaje varchar(32) NOT NULL,
	CONSTRAINT PK_bregistros PRIMARY KEY (idbregistro)
)
GO

ALTER TABLE bregistros ADD CONSTRAINT FK_bregistros_bdatos FOREIGN KEY(idbdatos) REFERENCES bdatos(idbdatos)
GO

ALTER TABLE bregistros ADD CONSTRAINT FK_bregistros_pmuestreo FOREIGN KEY(idpmuestreo) REFERENCES pmuestreo(idpmuestreo)
GO

ALTER TABLE bregistros ADD CONSTRAINT FK_bregistros_elementos FOREIGN KEY(idelemento) REFERENCES elementos(idelemento)
GO

