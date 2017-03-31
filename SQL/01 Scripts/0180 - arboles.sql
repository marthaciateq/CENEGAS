CREATE TABLE arboles(
	idarbol char(32) NOT NULL,
	idpadre char(32),
	descripcion varchar(256) NOT NULL,
	deleted char(1) NOT NULL,
	CONSTRAINT PK_arboles PRIMARY KEY (idarbol),
	CONSTRAINT CK_arboles_01 CHECK (deleted in ('S','N'))
)
GO

ALTER TABLE arboles ADD CONSTRAINT FK_arboles_idpadre FOREIGN KEY(idpadre)
REFERENCES arboles(idarbol)
GO

