Mi.windows = {
	windows: {},
	get: function (windowName) {
		if (this.windows[windowName]) return this.windows[windowName].element;
		return null;
	},
	addIcon: function (windowName, iconName, iconOnclick, iconService) {
		if (!this.windows[windowName]) throw 'No valid windowName.';
		this.windows[windowName].addIcon(iconName, iconOnclick, iconService);
	},
	set: function (windowName, element) {
		if (!(element instanceof $)) throw 'No JQuery element.';
		if (this.windows[windowName]) this.windows[windowName].element.remove();
		this.windows[windowName] = {
			element: element,
			icons: {},
			addIcon: function (iconName, iconOnclick, iconService) {
				var src = {
					activar: Mi.webHome + 'img/activar.png',
					actividades: Mi.webHome + 'img/actividades.png',
					actualizar: Mi.webHome + 'img/actualizar.png',
					agregar: Mi.webHome + 'img/agregar.png',
					aplicar: Mi.webHome + 'img/aplicar.png',
					aplicarPago: Mi.webHome + 'img/aplicarPago.png',
					aprobar: Mi.webHome + 'img/aprobar.png',
					bitacora: Mi.webHome + 'img/bitacora.png',
					borrar: Mi.webHome + 'img/borrar.png',
					cancelar: Mi.webHome + 'img/cancelar.png',
					cerrar: Mi.webHome + 'img/cerrar.png',
					checkList: Mi.webHome + 'img/checkList.png',
					definir: Mi.webHome + 'img/definir.png',
					devolverTrabajo: Mi.webHome + 'img/devolverTrabajo.png',
					editar: Mi.webHome + 'img/editar.png',
					excel: Mi.webHome + 'img/excel.png',
					filtrar: Mi.webHome + 'img/filtrar.png',
					generar: Mi.webHome + 'img/generar.png',
					guardar: Mi.webHome + 'img/guardar.png',
					generarPlan: Mi.webHome + 'img/generarPlan.png',
					listado: Mi.webHome + 'img/listado.png',
					nuevo: Mi.webHome + 'img/nuevo.png',
					ordenar: Mi.webHome + 'img/ordenar.png',
					pdf: Mi.webHome + 'img/pdf.png',
					recibirOrden: Mi.webHome + 'img/recibirOrden.png',
					recibirTrabajo: Mi.webHome + 'img/recibirTrabajo.png',
					terminarTrabajo: Mi.webHome + 'img/terminarTrabajo.png',
					revisar: Mi.webHome + 'img/revisar.png',
					sincHP: Mi.webHome + 'img/sincHP.png',
					solicitar: Mi.webHome + 'img/solicitar.png',
					ver: Mi.webHome + 'img/ver.png'
				}
				if (!src[iconName]) throw 'No valid iconName: ' + iconName;
				if ($.type(iconService) != 'string') this.icons[iconName] = $('<img src="' + src[iconName] + '"/>');
				else if (Mi.Cookie.get('SESIONDIETECH').servicios[iconService]) this.icons[iconName] = $('<img src="' + src[iconName] + '"/>');
				if (this.icons[iconName]) {
					this.icons[iconName].hide();
					this.icons[iconName].css({
						width: Mi.height * 0.08,
						height: Mi.height * 0.08,
						cursor: 'pointer'
					});
					$('#ICON_PANEL').append(this.icons[iconName]);
					if ($.type(iconOnclick) == 'function') this.icons[iconName].click(iconOnclick);
				}
			},
			showIcons: function () {
				$('#ICON_PANEL').children().hide();
				for (var i in this.icons) this.icons[i].show(800);
			}
		}
		this.windows[windowName].element.hide();
		this.windows[windowName].element.appendTo($('#BODY'));
	},
	show: function (windowName) {
		if (!this.windows[windowName]) return;
		for (var i in this.windows) this.windows[i].element.hide();
		this.windows[windowName].element.show(400);
		this.windows[windowName].showIcons();
	},
	hide: function () {
		for (var i in this.windows) this.windows[i].element.hide();
	}
}