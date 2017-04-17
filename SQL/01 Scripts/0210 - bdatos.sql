CREATE TABLE bdatos(
	idbdatos char(32) NOT NULL,
	idusuario char(32) NOT NULL,
	finicial datetime NULL,
	ffinal datetime NULL,
	actualizar char(1) NOT NULL,
	fcarga datetime NOT NULL,
	narchivo varchar(256) NOT NULL,
	noriginal varchar(256) NOT NULL,
	insertados int NOT NULL,
	actualizados int NOT NULL,
	ignorados int NULL,
	fueraFecha int NULL,
	tipoArchivo char(1) NOT NULL,
	CONSTRAINT PK_bdatos PRIMARY KEY (idbdatos),
	CONSTRAINT CK_bdatos_01 CHECK (actualizar in ('S','N'))			
)
GO

ALTER TABLE bdatos ADD CONSTRAINT FK_bdatos_idusuario FOREIGN KEY(idusuario) REFERENCES usuarios(idusuario)
GO

