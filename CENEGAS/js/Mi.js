Mi = {
	webHome: '/',
	width:640,
	height:480
}
Mi.onload = function () {
	Mi.width = $(window).width();
	Mi.height = $(window).height();
	Mi.Template.orientation = Mi.width > Mi.height ? 'H' : 'V';
	Mi.plugin(jQuery);
	Mi.Input.plugin(jQuery);
	Mi.Table.plugin(jQuery);
	if (jQuery.when.all === undefined) {
	    jQuery.when.all = function (deferreds) {
	        var deferred = new jQuery.Deferred();
	        $.when.apply(jQuery, deferreds).then(
                function () {
                    deferred.resolve(Array.prototype.slice.call(arguments));
                },
                function () {
                    deferred.fail(Array.prototype.slice.call(arguments));
                });

	        return deferred;
	    }
	}
	_onload();
}
Mi.button = function (params, text) {
	var e = $('<button/>');
	e.text(text);
	e.MiButton(params);
	return e;
}
Mi.dialog = function (params) {
	var e = $('<div/>');
	e.MiDialog(params);
	return e;
}
Mi.parrafo = function (s) {
	if ($.type(s) != 'string') return s;
	s = s.split('\n');
	var e = $('<span/>'), p;
	for (var i = 0; i < s.length; i++) {
		p = $('<p/>');
		p.text(s[i]);
		e.append(p);
	}
	return e;
}
Mi.programacion = function (params) {
	var e = $('<div/>');
	e.MiProgramacion(params);
	return e;
}
Mi.treeNode = function (params, content) {
	var e = $('<div/>');
	if ($.type(content) == 'string') e.text(content);
	else if (content instanceof $) e.append(content);
	e.MiTreeNode(params);
	return e;
}
Mi.treeNode1 = function (params, content) {
	var div = $('<div class="MiTreeNode1Div"/><div></div>');
	div.eq(1).append(Mi.Input.checkbox({ classNameOnlyOneSelect: params.classNameOnlyOneSelect }));
	if (content instanceof $) div.eq(0).append(content);
	else div.eq(0).text(content);
	Mi.css(div);
	return Mi.treeNode(params, div);
}
Mi.plugin = function ($) {
	$.fn.MiButton = function (params) {
		if (!$.isPlainObject(params)) params = {};
		for (var i = 0; i < this.length; i++) {
			if (this.eq(i).prop('nodeName') == 'BUTTON') {
				this.eq(i).addClass('MiButton');
				//Mi.css(this.eq(i));
			}
		};
	}
	$.fn.MiClear = function () {
		this.each(function () {
			if ($(this).hasClass('MiInputCombo')) {
				$(this).children().not('.MiInputComboOptionMask').remove();
			}
		});
	}
	$.fn.MiDialog = function (params) {
		if (params == 'close') {
			$(this).children('div').eq(0).children('span').eq(0).children('span').eq(0).children('img').eq(0).click();
			return;
		}
		if (!$.isPlainObject(params)) params = {};

		if ($.type(params.header) == 'string') {
			var tmp = $('<div/>');
			tmp.text(params.header);
			params.header = tmp;
		}
		if (!(params.header instanceof $)) params.header = null;

		if ($.type(params.content) == 'string') {
			var tmp = $('<div/>');
			tmp.text(params.content);
			params.content = tmp;
		}
		if (!(params.content instanceof $)) params.content = null;

		if (!(params.buttons instanceof $)) params.buttons = null;
		else params.buttons.MiButton();

		if (!$.isNumeric(params.width)) params.width = Mi.Template.orientation == 'H' ? 'auto' : Mi.width * 0.85;
		if (params.modal) {
			params.modal = $('<div class="MiDialogDivModal"/>');
			params.modal.appendTo(document.body);
			Mi.css(params.modal);
		}

		this.each(function () {
			if ($(this).prop('nodeName') == 'DIV') {
				$(this).addClass('MiDialog');
				$(this).data('params', params);
				var divClose = null, divHeader = null, divContent = null, divFooter = null;
				divClose = $('<div class="MiDialogDivClose"><span><span><img src="' + Mi.webHome + 'imgs/close.png" /></span></span></div>');
				Mi.css(divClose);
				divClose.children('span').eq(0).children('span').eq(0).children('img').eq(0).click(function () {
					var e = $(this).parent().parent().parent().parent();
					$(this).remove();
					if (params.modal instanceof $)
						e.slideUp({
							duration: 300,
							complete: function () {
								e.remove();
								params.modal.remove();
							}
						});
					else e.remove();
				});
				$(this).append(divClose);
				if (params.header instanceof $) if (params.header.length >= 1) {
					if (params.header.length == 1 && params.header.get(0).nodeName == 'DIV') divHeader = params.header.eq(0);
					else {
						divHeader = $('<div/>');
						divHeader.append(params.header);
					}
					divHeader.addClass('MiDialogDivHeader');
					Mi.css(divHeader);
					$(this).append(divHeader);
				}
				if (params.content instanceof $) if (params.content.length >= 1) {
					if (params.content.length == 1 && params.content.get(0).nodeName == 'DIV') divContent = params.content.eq(0);
					else {
						divContent = $('<div/>');
						divContent.append(params.content);
					}
					divContent.addClass('MiDialogDivContent');
					Mi.css(divContent);
					$(this).append(divContent);
				}
				if (params.buttons instanceof $) if (params.buttons.length >= 1) {
					divButtons = $('<div class="MiDialogDivButtons" />');
					divButtons.append(params.buttons);
					Mi.css(divButtons);
					$(this).append(divButtons);
				}
				if (params.modal instanceof $) {
					$(this).appendTo(document.body);
					$(this).focus();
					$(this).keypress(function (event) {
						if (event.which == 27) {
							params.modal.remove();
							$(this).remove();
						}
					});
				}
				Mi.css($(this));
			}
		});
	}
	$.fn.MiFill = function (data, params) {
		var option, keyValue = 0, keyText = 1;
		if ($.isPlainObject(params)) {
			if (params.value || params.value == 0) keyValue = params.value;
			if (params.text || params.text == 0) keyText = params.text;
		}
		this.each(function () {
			if ($(this).hasClass('MiInputCombo')) {
				for (var i = 0; i < data.length; i++) {
				    option = $('<option value=' + data[i][keyValue] + ' />'); option.addClass('MiInputComboOption');
					$(this).append(option);
					if ($.type(data[i]) == 'string' || $.isNumeric(data[i])) {
						option.text(data[i]);
						option.data('MiVal', data[i]);
					} else if ($.isPlainObject(data[i]) || $.isArray(data[i])) {
						option.text(data[i][keyText]);
						option.data('MiVal', data[i][keyValue]);
					}
				}
			}
		});
	}
	$.fn.MiFormat = function (formatFunction) {
		//function(element, type, section, row, col, value)
		function formatSection(section) {
			var trs, tds, value
			formatFunction(section, section.prop('nodeName'));
			trs = section.children('tr');
			for (var i = 0; i < trs.length; i++) {
				formatFunction(trs.eq(i), trs.eq(i).prop('nodeName'), section.prop('nodeName'), i);
				tds = trs.eq(i).children('td');
				for (var j = 0; j < tds.length; j++) {
					value = null;
					if (tds.get(j).childNodes.length == 1) if (tds.get(j).childNodes[0].nodeName == '#text') value = tds.get(j).childNodes[0].data
					formatFunction(tds.eq(j), tds.eq(j).prop('nodeName'), section.prop('nodeName'), i, j, value);
				}
			}
		}
		if ($.type(formatFunction) != 'function') return;
		this.each(function () {
			if ($(this).hasClass('MiTable')) {
				formatFunction($(this), $(this).prop('nodeName'));
				$(this).children().each(function () {
					formatSection($(this));
				});
			}
		});
	}
	$.fn.MiOnchange = function () {
		this.each(function () {
			if ($(this).data('params'))
				if ($.type($(this).data('params').onchange) == 'function')
					$(this).data('params').onchange();
		});
	}
	$.fn.MiProgramacion = function (params) {
		if (!$.isPlainObject(params)) params = {};
		if ($.type(params.onsuccess) != 'function') params.onsuccess = null;
		this.each(function () {
			if ($(this).prop('nodeName') == 'DIV') {
				var onsuccessResponse = null;
				var dialog = $(this);
				dialog.MiDialog({ modal: params.modal });
				dialog.addClass('MiProgramacion');
				dialog.width(Mi.width * 0.2);
				function fechasRefresh() {
					ul.parent().parent().hide();
					var checkBox = null;
					if (repetir.children('input').eq(0).prop('checked')) checkBox = 'REPETICIONES';
					else if (repetir.children('input').eq(1).prop('checked')) checkBox = 'FECHA';
					if (checkBox == null || incremento.MiVal() == null) return;
					if (checkBox == 'REPETICIONES' && repeticiones.MiVal() == null) return;
					buttons.hide();
					Mi.AJAX.request({
						data: {
							NAME: 'spp_programacion',
							inicio: Mi.Convert.dateToString(inicio.MiVal(), '%dd/%mm/%a'),
							fin: checkBox == 'REPETICIONES' ? null : Mi.Convert.dateToString(fin.MiVal(), '%dd/%mm/%a'),
							tipo: tipo.MiVal(),
							incremento: incremento.MiVal(),
							repeticiones: checkBox == 'FECHA' ? null : repeticiones.MiVal()
						},
						onsuccess: function (r) {
							onsuccessResponse = r;
							ul.children().remove();
							var li;
							for (var i = 0; i < r.length; i++) {
								li = $('<li/>'); li.appendTo(ul);
								li.text(r[i].fechaS);
							}
							if (r.length > 0) ul.parent().parent().show();
							buttons.show();
						}
					});
				}
				var inicio = Mi.Input.datetime({ onchange: fechasRefresh });
				var fin = Mi.Input.datetime({ onchange: fechasRefresh });
				var repeticiones = Mi.Input.number(); repeticiones.width(Mi.height * 0.05); repeticiones.change(fechasRefresh);
				var repetir = $('<span><input type="checkbox"/> n número de veces&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox"/> hasta determinada fecha</span>');
				var repetirVeces = repetir.children('input').eq(0); repetirVeces.data('cual', 'veces');
				var repetirHasta = repetir.children('input').eq(1); repetirHasta.data('cual', 'hasta');
				repetir.children('input').click(function () {
					if ($(this).data('cual') == 'veces') repetirHasta.prop('checked', false);
					else repetirVeces.prop('checked', false);

					if (repetirVeces.prop('checked')) {
						cada.parent().parent().show();
						repeticiones.parent().parent().show();
						fin.parent().parent().hide();
					} else if (repetirHasta.prop('checked')) {
						cada.parent().parent().show();
						repeticiones.parent().parent().hide();
						fin.parent().parent().show();
					} else {
						cada.parent().parent().hide();
						repeticiones.parent().parent().hide();
						fin.parent().parent().hide();
					}
					fechasRefresh();
				});

				var cada = $('<input/> <select/>'); cada.change(fechasRefresh);
				var incremento = cada.eq(0); incremento.MiInputNumber({ decimales: 0 }); incremento.width(Mi.height * 0.05); incremento.change(fechasRefresh);
				var tipo = cada.eq(2); tipo.MiInputCombo(); tipo.MiFill([['DIARIO', 'Días'], ['SEMANAL', 'Semanas'], ['MENSUAL', 'Meses'], ['ANUAL', 'Años'], ['PRIMER_DIA_MES', 'Meses (primero de cada mes)']], { value: 0, text: 1 }); tipo.change(fechasRefresh);
				var ul = $('<ul/>');
				ul.css({
					'max-height': Mi.height * 0.2,
					overflow: 'auto'
				});
				var buttons = $('<button>Aceptar</button><button>Cancelar</button>');
				buttons.MiButton();
				buttons.eq(0).click(function () {
					dialog.MiDialog('close');
					if (params.onsuccess != null) params.onsuccess(onsuccessResponse);
				});
				buttons.eq(1).click(function () {
					dialog.MiDialog('close');
				});
				var table = $('<table/>'); table.appendTo(dialog);
				table.MiTable({
					body: {
						data: [
							['Inicio', inicio],
							['Repetir', repetir],
							['Cada', cada],
							['Número de repeticiones', repeticiones],
							['Repetir hasta', fin],
							['Fechas programadas', ul]
						]
					},
					foot: {
						data: params.modal ? [[buttons]] : null
					},
					format: function (element, type, section, row, col, value) {
						if (type == 'TABLE') element.width('100%');
						else if (type == 'TR' && row > 1) element.hide();
						else if (type == 'TD' && col == 0) element.width('30%');
					}
				});
			}
		})
	}
	$.fn.MiText = function () {
		var returnValue = [];
		this.each(function () {
			if ($.type($(this).data('MiText')) == 'function')
				returnValue.push($(this).data('MiText')($(this)));
		});
		if (returnValue.length == 0) return null
		else if (returnValue.length == 1) return returnValue[0]
		else return returnValue;
	}
	$.fn.MiTreeNode = function (params, element) {
		if (params == 'expand') {
			this.each(function () {
				if ($(this).hasClass('MiTreeNode')) {
					$(this).data('MiTreeNode_estado', 'expand');
					$(this).MiTreeNode('refresh');
				}
			});
		} else if (params == 'expandAll') {
			this.each(function () {
				if ($(this).hasClass('MiTreeNode')) {
					$(this).find('.MiTreeNode').MiTreeNode('expand');
				}
			});
		} else if (params == 'collapse') {
			this.each(function () {
				if ($(this).hasClass('MiTreeNode')) {
					$(this).data('MiTreeNode_estado', 'collapse');
					$(this).MiTreeNode('refresh');
				}
			});
		} else if (params == 'collapseAll') {
			this.each(function () {
				if ($(this).hasClass('MiTreeNode')) {
					$(this).find('.MiTreeNode').MiTreeNode('collapse');
				}
			});
		} else if (params == 'append') {
			this.each(function () {
				if ($(this).hasClass('MiTreeNode')) {
					$(this).children('div').eq(1).append(element);
					$(this).MiTreeNode('refresh');
				}
			});
		} else if (params == 'remove') {
			this.each(function () {
				if ($(this).hasClass('MiTreeNode')) {
					var nodoPadre = $(this).MiTreeNode('parent');
					$(this).remove();
					nodoPadre.MiTreeNode('refresh');
				}
			});
		} else if (params == 'refresh') {
			this.each(function () {
				if ($(this).hasClass('MiTreeNode')) {
					if ($(this).children('div').eq(1).children().length == 0) {
						$(this).children('img').eq(0).hide();
						$(this).children('img').eq(1).hide();
						$(this).children('img').eq(2).show();
						$(this).children('div').eq(1).hide();
					} else if ($(this).data('MiTreeNode_estado') == 'collapse') {
						$(this).children('img').eq(0).hide();
						$(this).children('img').eq(1).show();
						$(this).children('img').eq(2).hide();
						$(this).children('div').eq(1).hide();
					}
					else {
						$(this).children('img').eq(0).show();
						$(this).children('img').eq(1).hide();
						$(this).children('img').eq(2).hide();
						$(this).children('div').eq(1).show();

					}
				}
			});
		} else if (params == 'parent') {
			var result = $(document.body).children('#wertyuidfghjk23456');
			this.each(function () {
				if ($(this).hasClass('MiTreeNode')) {
					result = $(this).parent().parent('.MiTreeNode');
				}
			});
			return result;
		} else if (params == 'children') {
			var result = $(document.body).children('#wertyuidfghjk23456');
			this.each(function () {
				if ($(this).hasClass('MiTreeNode')) {
					result = $(this).children('div').eq(1).children('.MiTreeNode');
				}
			});
			return result;
		} else {
			if (!$.isPlainObject(params)) params = {};
			if ($.type(params.imgSize) != 'string' && $.type(params.imgSize) != 'number') params.imgSize = Mi.height * 0.03;
			if ($.type(params.imgSize) != 'string' && $.type(params.imgSize) != 'number') params.imgSize = Mi.height * 0.03;
			if (params.initialStatus != 'collapse') params.initialStatus = 'expand';
			this.each(function () {
				if ($(this).prop('nodeName') == 'DIV') {
					$(this).addClass('MiTreeNode');
					var content = $('<div/>'), tmp = [];
					for (var i = 0; i < this.childNodes.length; i++) tmp.push(this.childNodes[i]);
					for (var i = 0; i < tmp.length; i++) content.append(tmp[i]);
					content.addClass('MiTreeNodeContentDiv');
					Mi.css(content);
					$(this).append($('<img src="' + Mi.webHome + 'imgs/collapse.png"/>\
							<img src="' + Mi.webHome + 'imgs/expand.png"/>\
							<img src="' + Mi.webHome + 'imgs/transparent.png"/>\
							<div/>\
							<div/>'));
					var imgCollapse = $(this).children('img').eq(0);
					var imgExpand = $(this).children('img').eq(1);
					var imgNothing = $(this).children('img').eq(2);
					var div1 = $(this).children('div').eq(0);
					div1.append(content);
					var div2 = $(this).children('div').eq(1);
					Mi.css($(this));
					imgCollapse.css({
						cursor: 'pointer'
					});
					imgCollapse.click(function () { $(this).parent().MiTreeNode('collapse'); });
					imgExpand.css({
						cursor: 'pointer'
					});
					imgExpand.click(function () { $(this).parent().MiTreeNode('expand'); });
					div1.css({
						display: 'inline-block',
						'padding-left': Mi.width * 0,
						'vertical-align': 'middle'
					});
					div2.css({
						'padding-left': Mi.width * 0.02
					});
					$(this).MiTreeNode(params.initialStatus);
				}
			});
		}
	}
	$.fn.MiVal = function (value) {
		var returnValue = [];
		this.each(function () {
			if ($.type($(this).data('MiVal')) == 'function')
				if ($.type(value) == 'undefined')
					returnValue.push($(this).data('MiVal')($(this)));
				else $(this).data('MiVal')($(this), value);
		});
		if ($.type(value) == 'undefined') {
			if (returnValue.length == 0) return null
			else if (returnValue.length == 1) return returnValue[0]
			else return returnValue;
		}
	}
	$.fn.MiWait = function (iniciar) {
		this.each(function () {
			if ($(this).hasClass('MiButton')) {
				if (iniciar) {
					$(this).prop('disabled', true);
					$(this).css({
						'opacity': .5
					});
				} else {
					$(this).prop('disabled', false);
					$(this).css({
						'opacity': 1
					});
				}
			}
		});

	}
}