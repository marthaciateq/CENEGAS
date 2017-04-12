CREATE TABLE registros(
	idregistro char(32) NOT NULL,
	idbdatos char(32) NOT NULL,
	idpmuestreo char(32) NOT NULL,
	idelemento char(32) NOT NULL,	
	fecha datetime NOT NULL,
	valor float NOT NULL,
	estado int NOT NULL, -- Capturado (0), Aprobado (1), Cancelado (2)
	iduaprobo char(32),
	faprobo datetime,
	iducancelo char(32),
	fcancelo datetime,
	CONSTRAINT PK_registros PRIMARY KEY (idregistro)
)
GO

ALTER TABLE registros ADD CONSTRAINT FK_registros_bdatos FOREIGN KEY(idbdatos) REFERENCES bdatos(idbdatos)
GO

ALTER TABLE registros ADD CONSTRAINT FK_registros_pmuestreo FOREIGN KEY(idpmuestreo) REFERENCES pmuestreo(idpmuestreo)
GO

ALTER TABLE registros ADD CONSTRAINT FK_registros_elementos FOREIGN KEY(idelemento) REFERENCES elementos(idelemento)
GO

ALTER TABLE registros ADD CONSTRAINT FK_registros_usuarios_1 FOREIGN KEY(iduaprobo) REFERENCES usuarios(idusuario)
GO

ALTER TABLE registros ADD CONSTRAINT FK_registros_usuarios_2 FOREIGN KEY(iducancelo) REFERENCES usuarios(idusuario)
GO

CREATE INDEX FK_registros_01 on registros(idpmuestreo)
CREATE INDEX FK_registros_02 on registros(idpmuestreo,idelemento)
CREATE INDEX FK_registros_03 on registros(idpmuestreo,idelemento,fecha)
GO 

