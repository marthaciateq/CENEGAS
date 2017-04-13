CREATE TABLE elementos(
	idelemento char(32) NOT NULL,
	descripcion varchar(256) NOT NULL,
	codigo varchar(20) NOT NULL,
	simbolo varchar(10) ,
	unidad varchar(256) NOT NULL,
	deleted char(1) NOT NULL,
	CONSTRAINT PK_elementos PRIMARY KEY (idelemento),
	CONSTRAINT CK_elementos_01 CHECK (deleted in ('S','N')),
)
GO

insert into elementos values('20170309015853370572487661852156','Metano','metano','CH4','% vol','N');
insert into elementos values('20170309015901120264999557990182','Oxígeno','oxigeno','O2','% vol','S');
insert into elementos values('20170309015908920302612186275755','Bióxido de Carbono','bioxidocarbono','CO2','%vol','N');
insert into elementos values('20170309015928330107009458012671','Nitrógeno','nitrogeno','N2','% vol','N');
insert into elementos values('20170309015944683851382958625331','Total de inertes','totalinertes','CO2 y N2','% vol','N');
insert into elementos values('20170309015951417199240994016694','Etano','etano',NULL,'% vol','N');
insert into elementos values('20170309015957970566087161253495','Temperatura de rocío de hidrocarburos','temprocio',NULL,'K(°C)','N');
insert into elementos values('20170309020008463989527069460466','Humedad','humedad',NULL,'mg/m3','N');
insert into elementos values('20170309020015170210604185856522','Poder calorífico','podercalorifico',NULL,'MJ/m3','N');
insert into elementos values('20170309020026853780619637897140','Índice Wobbe','indicewoobe',NULL,'MJ/m3','N');
insert into elementos values('20170309020037077750203474849206','Acido sulfhídrico','acidosulfhidrico','H2S','mg/m3','N');
insert into elementos values('20170309025552797692799663893621','Azufre Total','azufretotal','S','mg/m3','S');


