Mi.Table = {}
Mi.form = function (params) {
	var e = $('<table/>');
	e.MiForm(params);
	return e;
}
Mi.table = function (params) {
	var e = $('<table/>');
	e.MiTable(params);
	return e;
}
Mi.Table.plugin = function ($) {
	$.fn.MiForm = function (params) {
		if (!$.isPlainObject(params)) params = {};
		if ($.type(params.title) != 'string') params.title = null;
		if (!$.isArray(params.fields)) params.fields = [];
		if (!(params.buttons instanceof $)) params.buttons = null;
		else params.buttons.MiButton();
		if ($.type(params.addCheckbox) != 'boolean') params.addCheckbox = false;
		this.each(function () {
			if ($(this).prop('nodeName') == 'TABLE') {
				$(this).addClass('MiForm');
				$(this).MiTable({
					head: {
						data: params.title != null ? [[params.title]] : null
					},
					body: {
						data: params.fields,
						cols: ['label', 'input']
					},
					foot: {
						data: params.buttons != null ? [[params.buttons]] : null
					},
					addCheckbox: params.addCheckbox,
					noClassNameOnlyOneSelect: true,
					format: function (element, type, section, row, col, value) {
						if (type == 'TABLE') {
							element.prop({
								align: 'center',
								cellspacing: Mi.height * 0.01,
								cellpadding: Mi.height * 0.005
							});
							element.css({
								'width': Mi.width * 0.45,
								'box-shadow': Mi.Template.value('boxShadow'),
								'border-radius': Mi.Template.value('borderRadius')
							});
						} else if (section == 'THEAD' && type == 'TD') {
							element.prop('colspan', params.addCheckbox ? 3 : 2);
							element.css({
								'text-align': 'left',
								'padding-left': Mi.width * 0.01
							});
						} else if (section == 'TBODY' && type == 'TD') {
							if (params.addCheckbox && col == 0) {
								element.css({
									'text-align': 'center',
									width: '2%',
									border: 'none',
									'border-radius': 0
								});
								element.parent().children('td').eq(2).find('*').prop('disabled', true);
								element.parent().children('td').eq(0).children().change(function () {
									$(this).parent().parent().children('td').eq(2).find('*').prop('disabled', !$(this).prop('checked'));
								});
								if (element.parent().data('row').checked) {
									element.parent().children('td').eq(0).children().prop('checked', true);
									element.parent().children('td').eq(0).children().change();
								}
							} else if ((!params.addCheckbox && col == 0) || (params.addCheckbox && col == 1)) element.css({
								'text-align': 'right',
								'color': 'black',
								'font-weight': 'bold',
								'font-size': Mi.Template.value('fontSizeNormal'),
								width: '30%',
								'padding-right': Mi.width * 0.01,
								'padding-top': Mi.height * 0.015,
								'padding-bottom': Mi.height * 0.015
							});
							else if ((!params.addCheckbox && col == 1) || (params.addCheckbox && col == 2)) element.css({
								'text-align': 'left',
								'color': 'black',
								'font-weight': 'bold',
								'font-size': Mi.Template.value('fontSizeNormal'),
								'padding-left': Mi.width * 0.01,
								'border-radius': 0,
								'border-bottom': 'none'
							});
						} else if (section == 'TFOOT' && type == 'TD') {
							element.prop('colspan', 3);
							element.css({
								'text-align': 'left',
								'padding-left': Mi.width * 0.01
							});
						}
					}
				});
			}
		});
	}
	$.fn.MiTable = function (params) {
		function fill(section, data, cols) {
			var tr, td
			for (var row in data) {
				tr = $('<tr/>')
				tr.appendTo(section)
				tr.data('row', data[row]);
				if (!cols) for (var col in data[row]) {
					td = $('<td/>')
					if (data[row][col] instanceof $) {
						if (data[row][col].length == 1) {
							if (data[row][col].eq(0).prop('nodeName') == 'TD') td = data[row][col];
							else data[row][col].appendTo(td);
						} else data[row][col].appendTo(td);
					}
					else if (data[row][col] == null);
					else $(document.createTextNode(data[row][col])).appendTo(td)
					td.appendTo(tr)
				} else for (var col in cols) {
					td = $('<td></td>')
					if (data[row][cols[col]] instanceof $) {
						if (data[row][cols[col]].length == 1) {
							if (data[row][cols[col]].eq(0).prop('nodeName') == 'TD') td = data[row][cols[col]];
							else data[row][cols[col]].appendTo(td);
						} else data[row][cols[col]].appendTo(td);
					}
					else if (data[row][cols[col]] == null);
					else $(document.createTextNode(data[row][cols[col]])).appendTo(td)
					td.appendTo(tr)
				}
			}
		}
		if (!$.isPlainObject(params)) params = {};
		if (!$.isPlainObject(params.head)) params.head = {};
		if (!$.isArray(params.head.data)) params.head.data = null;
		if (!$.isArray(params.head.cols)) params.head.cols = null;
		if (!$.isPlainObject(params.body)) params.body = {};
		if (!$.isArray(params.body.data)) params.body.data = null;
		if (!$.isArray(params.body.cols)) params.body.cols = null;
		if (!$.isPlainObject(params.foot)) params.foot = {};
		if (!$.isArray(params.foot.data)) params.foot.data = null;
		if (!$.isArray(params.foot.cols)) params.foot.cols = null;
		if ($.type(params.format) != 'function') params.format = null;
		if ($.type(params.noFormat) != 'boolean') params.noFormat = false;
		if ($.type(params.addCheckbox) != 'boolean') params.addCheckbox = false;
		if ($.type(params.noClassNameOnlyOneSelect) != 'boolean') params.noClassNameOnlyOneSelect = false;
		if (params.addCheckbox) {
			var tmp = [], row, colName, classNameOnlyOneSelect;
			if (!params.noClassNameOnlyOneSelect) classNameOnlyOneSelect = 'MiTable_classNameOnlyOneSelect' + (new Date()).getMilliseconds();
			for (var i = 0; i < params.body.data.length; i++) {
				if ($.isArray(params.body.data[i])) {
					colName = 0;
					row = [Mi.Input.checkbox({ classNameOnlyOneSelect: classNameOnlyOneSelect })]; tmp.push(row);
					for (var j = 0; j < params.body.data[i].length; j++)
						row.push(params.body.data[i][j]);
				} else if ($.isPlainObject(params.body.data[i])) {
					colName = 'MiTableCheckbox';
					row = { MiTableCheckbox: Mi.Input.checkbox({ classNameOnlyOneSelect: classNameOnlyOneSelect }) }; tmp.push(row);
					for (var j = 0 in params.body.data[i])
						row[j] = params.body.data[i][j];
				}
			}
			params.body.data = tmp;
			if ($.isArray(params.body.cols)) {
				tmp = [];
				tmp.push(colName);
				for (var i = 0; i < params.body.cols.length; i++)
					tmp.push(params.body.cols[i]);

				params.body.cols = tmp;
			}
		}
		this.each(function () {
			if ($(this).prop('nodeName') == 'TABLE') {
			    $(this).addClass('MiTable');
			    $(this).addClass('table table-striped');
				$(this).children().remove();
				$(this).append('<thead/><tbody/><tfoot/>');
				fill($(this).children().eq(0), params.head.data, params.head.cols);
				fill($(this).children().eq(1), params.body.data, params.body.cols);
				fill($(this).children().eq(2), params.foot.data, params.foot.cols);
				if (!params.noFormat) $(this).MiFormat(function (element, type, section, row, col, value) {
					if (type == 'TABLE') {
//						element.prop({
//							align: 'center',
//							cellspacing: Mi.height * 0.01,
//							cellpadding: Mi.height * 0.005
//						});
//						element.css({
//							'width': Mi.width * (Mi.Template.orientation == 'H' ? 0.65 : 0.9),
//							'box-shadow': Mi.Template.value('boxShadow'),
//							'border-radius': Mi.Template.value('borderRadius')
//						});
					} else if (type == 'TD' && section == 'THEAD') {
//						element.css(Mi.Template.value('header'));
//						element.css({
//							'border-bottom': 'solid 1px ' + Mi.Template.value('colorObscuro')
//						});
					} else if (section == 'TBODY' && type == 'TR') {
						if (element.data('row').deleted == 'S') element.css('opacity', 0.4);
					} else if (type == 'TD' && section == 'TBODY') {
//						element.css({
//							'border-radius': row < element.parent().parent().children().length - 1 ? Mi.Template.value('borderRadius') : 0,
//							'border-bottom': row < element.parent().parent().children().length - 1 ? 'solid 1px ' + Mi.Template.value('colorObscuro') : 'none',
//							'text-align': 'left',
//							'color': 'black'
//						});
						if (params.addCheckbox) if (col == 0) element.css({
							width: Mi.width * 0.03,
							'text-align': 'center'
						});
					} else if (type == 'TD' && section == 'TFOOT') {
						if (element.parent().children().length == 1) {
							var colsHeader = 0, colsBody = 0;
							if (element.parent().parent().parent().children('thead').length == 1)
								if (element.parent().parent().parent().children('thead').children().length > 0)
									colsHeader = element.parent().parent().parent().children('thead').children().eq(0).children().length;
							if (element.parent().parent().parent().children('tbody').length == 1)
								if (element.parent().parent().parent().children('tbody').children().length > 0)
									colsBody = element.parent().parent().parent().children('tbody').children().eq(0).children().length;
							if (colsHeader > 0 || colsBody > 0)
								if (colsHeader > colsBody) element.prop('colspan', colsHeader);
								else element.prop('colspan', colsBody);
						}
					}
				});
				if (params.format) $(this).MiFormat(params.format)
			}
		});
	}
}