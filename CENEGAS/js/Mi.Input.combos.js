Mi.Input.comboArbol = function (params) {
	if (!$.isPlainObject(params)) params = {};
	if (!$.isPlainObject(params.data)) params.data = {};
	if (!$.isArray(params.initialValue) && $.type(params.initialValue) != 'numeric' && $.type(params.initialValue) != 'string') params.initialValue = null;
	if (params.normalCombo) {
		var e = Mi.Input.combo({ mask: params.mask });
		Mi.AJAX.request({
			data: {
				NAME: 'spp_arbol_buscar',
				idpadre: params.data.idpadre
			},
			onsuccess: function (r) {
				e.MiFill(r, { value: 'idarbol', text: 'descripcion' });
				if (params.initialValue != null) e.MiVal(params.initialValue);
			}
		});
	} else {
		params.data.NAME = 'spp_arbol_buscar';
		params.filter = 'buscar';
		params.value = 'idarbol';
		params.text = 'descripcion';
		var e = Mi.Input.comboFilter(params);
		e.addClass('MiInputComboArbol');
		e.children('.MiInputCombo').width(Mi.width * 0.15);
	}
	return e;
}
Mi.Input.comboPmuestreo = function (params) {
    var e = $('<select/>');
    e.MiInputCombo(params);
    Mi.AJAX.request({
        data: { NAME: 'spp_pmuestreo_buscar' },
        onsuccess: function (r) {
            e.MiFill(r, { value: 'idpmuestreo', text: 'nalterno' });
            e.addClass('chzn-select');
            e.chosen({ width: "100%" });
        }
    });
    return e;
}
Mi.Input.comboElementos = function (params) {
    var e = $('<select/>');
    e.MiInputCombo(params);
    Mi.AJAX.request({
        data: { NAME: 'spp_elementos_buscar' },
        onsuccess: function (r) {
            e.MiFill(r, { value: 'idelemento', text: 'elemento' });
            e.addClass('chzn-select');
            e.chosen({ width: "100%" });
        }
    });
    return e;
}
Mi.Input.comboDeleted = function (params) {
	var e = $('<select/>');
	e.MiInputCombo(params);
	e.MiFill([['N', 'Activo'], ['S', 'Borrado']]);
	return e;
}
Mi.Input.comboReportes = function (params) {
    var e = $('<select/>');
    e.MiInputCombo(params);
    e.MiFill([['D', 'NOM-001-SECRE-2010'], ['G', 'NOM-001-SECRE-2010 (Solo punto A y B)'], ['F', 'Información Faltante'], ['T', 'Gráfico de Tendencia']]);
    return e;
}
Mi.Input.comboFormatos = function (params) {
    var e = $('<select/>');
    e.MiInputCombo(params);
    e.MiFill([['EXCEL', 'EXCEL'], ['PDF', 'PDF']]);
    return e;
}
Mi.Input.comboUsuarios = function (params) {
	if (!$.isPlainObject(params)) params = {};
	if (!$.isPlainObject(params.data)) params.data = {};
	params.data.NAME = 'spp_usuarios_buscar';
	params.filter = 'buscar';
	params.value = 'idusuario';
	params.text = 'persona';
	var e = Mi.Input.comboFilter(params);
	e.addClass('MiInputComboUsuarios');
	e.children('.MiInputCombo').width(Mi.width * 0.15);
	return e;
}
