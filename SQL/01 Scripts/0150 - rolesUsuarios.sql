CREATE TABLE rolesUsuarios(
	idrol char(32) NOT NULL,
	idusuario char(32) NOT NULL
)
GO

ALTER TABLE rolesUsuarios ADD CONSTRAINT FK_rolesUsuarios_idrol FOREIGN KEY(idrol)
REFERENCES roles(idrol) ON DELETE CASCADE
ALTER TABLE rolesUsuarios ADD CONSTRAINT FK_rolesUsuarios_idusuario FOREIGN KEY(idusuario)
REFERENCES usuarios(idusuario) ON DELETE CASCADE

CREATE INDEX IX_rolesUsuarios_01 on rolesUsuarios(idusuario) include(idrol)
GO

BEGIN
	insert into rolesUsuarios values('15283614250832728429629473271945','20160617194441460203936886013010')
	insert into rolesUsuarios values('15283614250832728429629473271945','20170405155332240873987667335604')
END
GO
