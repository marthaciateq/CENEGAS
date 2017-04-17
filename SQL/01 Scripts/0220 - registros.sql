CREATE TABLE registros(
	idregistro char(32) NOT NULL,
	idbdatos char(32) NOT NULL,
	idpmuestreo char(32) NOT NULL,
	idelemento char(32) NOT NULL,	
	fecha datetime NOT NULL,
	valor float NOT NULL,
	CONSTRAINT PK_registros PRIMARY KEY NONCLUSTERED(idregistro) 
)
GO

ALTER TABLE registros ADD CONSTRAINT FK_registros_bdatos FOREIGN KEY(idbdatos) REFERENCES bdatos(idbdatos)
GO

ALTER TABLE registros ADD CONSTRAINT FK_registros_pmuestreo FOREIGN KEY(idpmuestreo) REFERENCES pmuestreo(idpmuestreo)
GO

ALTER TABLE registros ADD CONSTRAINT FK_registros_elementos FOREIGN KEY(idelemento) REFERENCES elementos(idelemento)
GO

CREATE CLUSTERED INDEX FK_registros_01 on registros (idpmuestreo,idelemento,fecha)
CREATE INDEX FK_registros_02 on registros(idpmuestreo)
CREATE INDEX FK_registros_03 on registros(idpmuestreo,idelemento)
GO 

