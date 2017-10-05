insert into roles values('20170913184718147808417954164977','BDatos','N')
insert into roles values('20170913181425713719198815103928','Reportes','N')

insert into rolesServicios
	select '20170913184718147808417954164977', servicio from v_servicios
		where servicio not in ('sps_usuarios_guardar','sps_usuarios_borrar','sps_usuarios_buscar',
			'sps_pmuestreo_guardar','sps_pmuestreo_borrar','sps_pmuestreo_buscar',
			'sps_elementos_guardar','sps_elementos_borrar','sps_elementos_buscar',
			'sps_especificaciones_guardar','sps_especificaciones_borrar','sps_especificaciones_buscar'
		)

insert into rolesServicios
	select '20170913181425713719198815103928', servicio from v_servicios
		where servicio not in ('sps_usuarios_guardar','sps_usuarios_borrar','sps_usuarios_buscar',
			'sps_pmuestreo_guardar','sps_pmuestreo_borrar','sps_pmuestreo_buscar',
			'sps_elementos_guardar','sps_elementos_borrar','sps_elementos_buscar',
			'sps_especificaciones_guardar','sps_especificaciones_borrar','sps_especificaciones_buscar',
			'sps_bdatos_borrar','sps_bdatos_buscar','sps_import'
		)
	


