CREATE TABLE usuarios(
	idusuario char(32) NOT NULL,
	nombres varchar(256) NOT NULL,
	apaterno varchar(256) NOT NULL,
	amaterno varchar(256) NOT NULL,
	correo varchar(256) NOT NULL,
	login varchar(256) NOT NULL,
	password varchar(256) NOT NULL,
	deleted char(1) NOT NULL,
	CONSTRAINT PK_usuarios PRIMARY KEY (idusuario),
	CONSTRAINT CK_usuarios_01 CHECK (deleted in ('S','N'))
)
GO

CREATE UNIQUE INDEX IX_usuarios_01 on usuarios(login)
GO

BEGIN
	insert into usuarios values('20160617194441460203936886013010','Administrador','.','.','admin@gmail.com','admin','0OstU0qU6t5','N')
	insert into usuarios values('20170405155332240873987667335604','Cenegas','.','.','admin@gmail.com','cenegas','0OstU0qU6t5','N')
END


