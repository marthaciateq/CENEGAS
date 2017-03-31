Mi.AJAX = {}
Mi.AJAX.request = function (params) {
	if (!$.isPlainObject(params)) params = {}
	if ($.type(params.url) != 'string') params.url = Mi.webHome + 'dispatch/ajax.aspx';
	if ($.type(params.onsuccess) != 'function') params.onsuccess = function () { }
	if ($.type(params.onerror) != 'function') params.onerror = function (r) { Mi.dialog({ content: r, modal: true }); }
	if ($.type(params.data) == 'undefined') params.data = null;
	if (!$.isPlainObject(params.parameters)) params.parameters = null;
	if (Mi.Cookie.exist('SESIONCENEGAS')) {
		if ($.isPlainObject(params.data)) params.data.idsesion = Mi.Cookie.get('SESIONCENEGAS').idsesion;
		else if ($.isArray(params.data)) for (var i = 0; i < params.data.length; i++) params.data[i].idsesion = Mi.Cookie.get('SESIONCENEGAS').idsesion
	}
	var request = {
		cache: false,
		type: 'post',
		error: function (jqXHR, textStatus, errorThrown) {
			params.onerror(errorThrown)
		},
		success: function (data, textStatus, jqXHR) {
			if (data.length == 0) params.onsuccess();
			else {
				var o = Mi.JSON.deserialize(data);
				if ($.isPlainObject(o)) if (o.type) if (o.type == 'EXCEPTION') {
					params.onerror(o.mensajeUsuario);
					return;
				}
				params.onsuccess(o);
			}
		},
		data: { DATA: Mi.JSON.serialize(params.data) }
	}
	if ($.isPlainObject(params.parameters)) {
		var invalidos = {}
		for (var x in request.data) invalidos[x] = x;
		for (var x in params.parameters)
			if (!invalidos[x]) request.data[x] = params.parameters[x];
		if (Mi.Cookie.exist('SESIONCENEGAS'))
			request['idsesion'] = Mi.Cookie.get('SESIONCENEGAS').idsesion;
	}
	$.ajax(params.url, request);
}
Mi.AJAX.uploadFiles = function (params) {
	if (!$.isPlainObject(params)) params = {}
	if ($.type(params.url) != 'string') params.url = Mi.webHome + 'dispatch/files.aspx';
	if ($.type(params.onsuccess) != 'function') params.onsuccess = function () { }
	if ($.type(params.onerror) != 'function') params.onerror = function (r) { Mi.dialog({ content: r, modal: true }); }
	if (!(params.files instanceof $)) {
		params.onerror('No se ha seleccionado ningún archivo.');
		return;
	}

	var i = 0, data = new FormData();
	params.files.each(function () {
		if ($(this).prop('type') == 'file')
			if (this.files.length > 0)
				data.append("file" + (i++), this.files[0]);
	});
	if (i == 0) {
		params.onerror('No se ha seleccionado ningún archivo.');
		return;
	}
	if (Mi.Cookie.exist('SESIONCENEGAS'))
		data.append("idsesion", Mi.Cookie.get('SESIONCENEGAS').idsesion);


	var request = {
		cache: false,
		type: 'post',
		contentType: false,
		processData: false,
		error: function (jqXHR, textStatus, errorThrown) {
			params.onerror(errorThrown)
		},
		success: function (data, textStatus, jqXHR) {
			if (data.length == 0) params.onsuccess();
			else {
				var o = Mi.JSON.deserialize(data);
				if ($.isPlainObject(o)) if (o.type) if (o.type == 'EXCEPTION') {
					params.onerror(o.mensajeUsuario);
					return;
				}
				params.onsuccess(o);
			}
		},
		data: data
	}
	$.ajax(params.url, request);
}