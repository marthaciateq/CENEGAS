CREATE TABLE roles(
	idrol char(32) NOT NULL,
	nombre varchar(256) NOT NULL,
	deleted char(1) NOT NULL,
	CONSTRAINT PK_roles PRIMARY KEY (idrol),
	CONSTRAINT CK_roles_02 CHECK (deleted in ('S','N'))
)
GO

CREATE UNIQUE INDEX IX_roles_01 on roles(nombre)
GO

BEGIN
	insert into roles values('15283614250832728429629473271945','Administrador','N')
END
GO
