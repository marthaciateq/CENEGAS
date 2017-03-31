Mi.Reports = {};

Mi.Reports.request = function (params) {
    if (!$.isPlainObject(params)) params = {}
    if ($.type(params.data) == 'undefined') params.data = null;
    if ($.type(params.url) != 'string') params.url = Mi.webHome + 'dispatch/reports.aspx';
    if (!params.nombre) throw 'Se debe especificar el objeto [params.nombre]';
    if (params.format != 'EXCEL' && params.format != 'WORD') params.format = 'PDF';
    if (Mi.Cookie.exist('SESIONCENEGAS')) params.data.idsesion = Mi.Cookie.get('SESIONCENEGAS').idsesion;
    var request = {
        data: {
            idsesion: params.data.idsesion,
            nombre: params.nombre,
            format: params.format,
            DATA: Mi.JSON.serialize(params.data)
        }
    }
    if (!params.toFile) {
        var frm01 = document.createElement('form');
        frm01.style.display = 'none';
        frm01.method = 'post';
        frm01.action = params.url;
        document.body.appendChild(frm01);
        for (var i in request.data) {
            if (i != null && i != undefined) {
                input = document.createElement('input');
                input.name = i;
                input.value = request.data[i];
                frm01.appendChild(input);
            }
        }
        frm01.submit();
        document.body.removeChild(frm01);
    } else {
        if ($.type(params.onsuccess) != 'function') params.onsuccess = function () { }
        if ($.type(params.onerror) != 'function') params.onerror = function (r) { Mi.dialog({ content: r, modal: true }); }
        request.data.toFile = 'S';
        request.cache = false;
        request.type = 'post';
        request.error = function (jqXHR, textStatus, errorThrown) {
            params.onerror(errorThrown)
        }
        request.success = function (data, textStatus, jqXHR) {
            if (data.length == 0) params.onsuccess();
            else {
                var o = Mi.JSON.deserialize(data);
                if ($.isPlainObject(o)) if (o.type) if (o.type == 'EXCEPTION') {
                    params.onerror(o.mensajeUsuario);
                    return;
                }
                params.onsuccess(o);
            }
        }
        $.ajax(params.url, request);
    }
}