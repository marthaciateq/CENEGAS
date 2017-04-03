CREATE TABLE rpromedio(
	idrpromedio char(32) NOT NULL,
	idbdatos char(32) NOT NULL,
	idpmuestreo char(32) NOT NULL,
	idelemento char(32) NOT NULL,	
	fecha datetime NOT NULL,
	promedio float NOT NULL,
	estado int NOT NULL, -- Capturado (0), Aprobado (1), Cancelado (2)
	iduaprobo char(32),
	faprobo datetime,
	iducancelo char(32),
	fcancelo datetime,
	CONSTRAINT PK_rpromedio PRIMARY KEY (idrpromedio)
)
GO

ALTER TABLE rpromedio ADD CONSTRAINT FK_rpromedio_bdatos FOREIGN KEY(idbdatos) REFERENCES bdatos(idbdatos)
GO

ALTER TABLE rpromedio ADD CONSTRAINT FK_rpromedio_pmuestreo FOREIGN KEY(idpmuestreo) REFERENCES pmuestreo(idpmuestreo)
GO

ALTER TABLE rpromedio ADD CONSTRAINT FK_rpromedios_elementos FOREIGN KEY(idelemento) REFERENCES elementos(idelemento)
GO

ALTER TABLE registros ADD CONSTRAINT FK_rpromedio_usuarios_1 FOREIGN KEY(iduaprobo) REFERENCES usuarios(idusuario)
GO

ALTER TABLE registros ADD CONSTRAINT FK_rpromedio_usuarios_2 FOREIGN KEY(iducancelo) REFERENCES usuarios(idusuario)
GO

