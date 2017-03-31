CREATE TABLE files(
	idfile char(32) NOT NULL,
	idusuario char(32) NOT NULL,
	name varchar(512) NOT NULL,
	udate datetime NOT NULL,
	clength bigint NOT NULL,
	ctype varchar(max) NOT NULL,
	data varbinary(max)
	CONSTRAINT PK_files PRIMARY KEY (idfile)
)
GO

ALTER TABLE files ADD CONSTRAINT FK_files_01 FOREIGN KEY(idusuario) REFERENCES usuarios(idusuario)
CREATE INDEX FK_files_01 ON files(idusuario)
CREATE INDEX IX_files_01 ON files(name)
GO

