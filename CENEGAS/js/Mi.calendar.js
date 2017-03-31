Mi.calendar = function (params) {
	function selectDate() {
		$(this).parent().parent().find('td').each(function () {
			Mi.calendarCSS('tbodytd', $(this))
		});
		Mi.calendarCSS('tbodytdselected', $(this))
		fechaSeleccionada = $(this).data('fecha');
	}
	function refreshTable(fecha) {
		fecha = new Date(fecha.getFullYear(), fecha.getMonth(), fecha.getDate());
		var f = new Date(fecha.getFullYear(), fecha.getMonth(), 1);
		while (f.getDay() != 1) f = new Date(f.getFullYear(), f.getMonth(), f.getDate() - 1);
		var anio = $('<input type="number"/>');
		Mi.calendarCSS('inputanio', anio);
		anio.val(fecha.getFullYear());
		anio.focus(function () { $(this).select() });
		anio.change(function () {
			anio.val(parseInt(anio.val()));
			refreshTable(new Date(anio.val(), fechaSeleccionada.getMonth(), fechaSeleccionada.getDate()));
		});
		var mes = $('<select><option value="0">Enero</option><option value="1">Febrero</option><option value="2">Marzo</option><option value="3">Abril</option><option value="4">Mayo</option><option value="5">Junio</option><option value="6">Julio</option><option value="7">Agosto</option><option value="8">Septiembre</option><option value="9">Octubre</option><option value="10">Noviembre</option><option value="11">Diciembre</option></select>');
		Mi.calendarCSS('selectmes', mes);
		mes.val(fecha.getMonth());
		mes.change(function () {
			refreshTable(new Date(fechaSeleccionada.getFullYear(), parseInt(mes.val()), fechaSeleccionada.getDate()));
		});
		var table = $('<table><thead/><tbody/><tfoot/></table>'), tr, td, tdselected;
		Mi.calendarCSS('table', table);
		tr = $('<tr><td colspan="3"/><td/><td colspan="3"/></tr>'); table.children('thead').append(tr);
		tr.children('td').eq(0).append(mes);
		tr.children('td').eq(2).append(anio);
		table.children('thead').append($('<tr><td>Lunes</td><td>Martes</td><td>Miércoles</td><td>Jueves</td><td>Viernes</td><td>Sábado</td><td>Domingo</td></tr>'));
		Mi.calendarCSS('thead', table.children('thead'));
		do {
			tr = $('<tr/>'); table.children('tbody').append(tr);
			for (i = 0; i < 7; i++) {
				td = $('<td>' + f.getDate() + '</td>');
				td.data('fecha', f);
				td.click(selectDate);
				tr.append(td);
				if (f.getTime() == fecha.getTime()) tdselected = td;
				f = new Date(f.getFullYear(), f.getMonth(), f.getDate() + 1);
			}
		} while (f.getMonth() == fecha.getMonth());
		tdselected.click();
		e.children().eq(1).remove();
		e.append(table);
	}
	if (!$.isPlainObject(params)) params = {};
	if ($.type(params.date) != 'date') params.date = new Date();
	if ($.type(params.onchange) != 'function') params.onchange = function (d) { }
	var fechaSeleccionada = null;
	var e = $('<div class="MiCalendar"/>'); e.appendTo(document.body);
	Mi.calendarCSS('MiCalendar', e);
	var divButtons = $('<div><button>Aceptar</button><button>Cancelar</button></div>');
	e.append(divButtons);
	Mi.calendarCSS('divButtons', divButtons);
	divButtons.children('button').eq(0).click(function () {
		params.onchange(fechaSeleccionada);
		e.hide();
		setTimeout(function () { e.remove(); }, 200);
	});
	divButtons.children('button').eq(1).click(function () {
		e.remove();
	});
	refreshTable(params.date);
	e.find('select').focus();
	return e;
}
Mi.calendarCSS = function (c, e) {
	if (c == 'divButtons') {
		e.css({
			position: 'absolute',
			left: Mi.width * 0.15,
			top: Mi.height * 0.87
		});
		e.children('button').MiButton();
		e.children('button').css({
			'font-size': Mi.height * 0.07
		});

	} else if (c == 'inputanio') e.css({
		'font-size': Mi.height * 0.05,
		'font-family': Mi.Template.value('fontFamily'),
		'text-align': 'center',
		width: Mi.height * 0.3,
		border: 'none'
	});
	else if (c == 'MiCalendar') e.css({
		position: 'absolute',
		left: 0,
		top: 0,
		width: Mi.width,
		height: Mi.height,
		'background-color': Mi.Template.value('colorClaro'),
		'z-index': 99999999
	});
	else if (c == 'selectmes') {
		e.css({
			'font-size': Mi.height * 0.05,
			'font-family': Mi.Template.value('fontFamily')
		});
		e.children('option').css({
			'font-size': Mi.height * 0.03,
			'font-family': Mi.Template.value('fontFamily')
		});
	} else if (c == 'table') {
		e.prop({
			'cellspacing': Mi.height * 0.01,
			'cellpadding': 0
		});
		e.css({
			position: 'absolute',
			top: Mi.height * 0.05,
			left: Mi.width * 0.15,
			height: Mi.height * 0.6
		});
	}
	else if (c == 'tbodytd') {
		e.css('background', 'none');
		e.css({
			'border-radius': Mi.Template.value('borderRadius'),
			'font-size': Mi.height * 0.03,
			'font-family': Mi.Template.value('fontFamily'),
			'background-color': 'white',
			color: 'black',
			cursor: 'pointer',
			'text-align': 'center',
			height: Mi.height * 0.09,
			width: Mi.width * 0.1
		});
	} else if (c == 'tbodytdselected') e.css({
		'font-size': Mi.height * 0.07,
		'background-color': '#F77',
		background: 'linear-gradient(' + Mi.Template.value('colorMuyObscuro') + ', ' + Mi.Template.value('colorObscuro') + ')',
		color: 'white'
	});
	else if (c == 'thead') {
		e.find('td').css({
			'border-radius': Mi.Template.value('borderRadius'),
			'font-size': Mi.height * 0.03,
			'font-family': Mi.Template.value('fontFamily'),
			'background-color': 'white',
			'text-align': 'center',
			height: Mi.height * 0.09,
			width: Mi.width * 0.1
		});
		e.children('tr').eq(1).find('td').css(Mi.Template.value('header'));
	}
}