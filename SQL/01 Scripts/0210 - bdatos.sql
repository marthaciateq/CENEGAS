CREATE TABLE bdatos(
	idbdatos char(32) NOT NULL,
	idusuario char(32) NOT NULL,
	finicial datetime NULL,
	ffinal datetime NULL,
	actualizar char(1) NOT NULL,
	fcarga datetime NOT NULL,
	narchivo varchar(256) NOT NULL,
	noriginal varchar(256) NOT NULL,
	nuevosPuntos char(1) NULL,
	insertados int NOT NULL,
	actualizados int NOT NULL,
	ignorados int NULL,
	fueraFecha int NULL,
	tipoArchivo char(1) NOT NULL,
	deleted char(1) NOT NULL,
	idusuariodelete char(32) NULL,
	fdelete datetime NULL,
	CONSTRAINT PK_bdatos PRIMARY KEY (idbdatos),
	CONSTRAINT CK_bdatos_01 CHECK (actualizar in ('S','N')),		
	CONSTRAINT CK_bdatos_02 CHECK (deleted in ('S','N'))	
)
GO

ALTER TABLE bdatos ADD CONSTRAINT FK_bdatos_idusuario       FOREIGN KEY(idusuario) REFERENCES usuarios(idusuario)
ALTER TABLE bdatos ADD CONSTRAINT FK_bdatos_idusuariodelete FOREIGN KEY([idusuariodelete]) REFERENCES usuarios(idusuario)
GO

