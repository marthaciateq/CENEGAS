Mi.Input = {}
Mi.Input.checkbox = function (params) {
	var e = $('<input/>');
	e.MiInputCheckbox(params);
	return e;
}
Mi.Input.combo = function (params) {
    var e = $('<select/>');
	e.MiInputCombo(params);
	return e;
}
Mi.Input.datetime = function (params) {
	var e = $('<input/>');
	e.MiInputDatetime(params);
	return e;
}
Mi.Input.multiple = function (params) {
	var e = $('<div/>');
	e.MiInputMultiple(params);
	return e;
}
Mi.Input.number = function (params) {
	var e = $('<input/>');
	e.MiInputNumber(params);
	return e;
}
Mi.Input.text = function (params) {
	var e = $('<input/>');
	if (params) if (params.multiline) e = $('<textarea/>');
	e.MiInputText(params);
	return e;
}
Mi.Input.plugin = function ($) {
    $.fn.MiInputCheckbox = function (params) {
        if (!$.isPlainObject(params)) params = {};
        if (params.classNameOnlyOneSelect) params.classNameOnlyOneSelect = params.classNameOnlyOneSelect.toString();
        else params.classNameOnlyOneSelect = null;
        if ($.type(params.onchange) != 'function') params.onchange = null;
        this.each(function () {
            if ($(this).prop('nodeName') == 'INPUT') {
                $(this).data('params', params);
                $(this).addClass('MiInputCheckbox'); Mi.css($(this));
                $(this).change(function () {
                    if (params.onchange) params.onchange();
                });
                $(this).prop('type', 'checkbox');
                if (params.classNameOnlyOneSelect) {
                    $(this).addClass(params.classNameOnlyOneSelect);
                    $(this).click(function () {
                        var e = $(this), dobleClick = false, timeout = 400;
                        if (!e.data('MiInputCheckbox.lastClickObject')) e.data('MiInputCheckbox.lastClickObject', { time: 0, handler: 0 });
                        if ((new Date()).getTime() - e.data('MiInputCheckbox.lastClickObject').time < timeout) dobleClick = true;
                        if (e.data('MiInputCheckbox.lastClickObject').handler) {
                            clearTimeout(e.data('MiInputCheckbox.lastClickObject').handler);
                            e.data('MiInputCheckbox.lastClickObject').handler = 0;
                        }
                        if (dobleClick) e.prop('checked', true);
                        else if (e.prop('checked')) e.data('MiInputCheckbox.lastClickObject').handler = setTimeout(function () {
                            $(document.body).find('.' + params.classNameOnlyOneSelect).each(function () {
                                if (!e.is($(this))) $(this).prop('checked', false);
                            });
                        }, timeout);
                        e.data('MiInputCheckbox.lastClickObject').time = (new Date()).getTime();
                    });
                }
            }
        });
    }
    $.fn.MiInputCombo = function (params) {
        if (!$.isPlainObject(params)) params = {};
        if ($.type(params.onchange) != 'function') params.onchange = null;
        if ($.type(params.mask) != 'string') params.mask = null;
        if (params.multiple == "true") {
            $(this).prop("multiple", "true");
        }
        this.each(function () {
            if ($(this).prop('nodeName') == 'SELECT') {
                $(this).data('params', params);
                $(this).addClass('MiInputCombo');
                $(this).addClass('form-control');
                $(this).data('MiVal', Mi.Val.inputCombo);
                $(this).data('MiText', Mi.Text.inputCombo);
                $(this).change(function () {
                    if (params.onchange) params.onchange();
                });
                if (params.mask != null) {
                    var option = $('<option/>');
                    option.addClass('MiInputComboOptionMask');
                    option.text(params.mask);
                    option.data('MiVal', null);
                    $(this).append(option);
                }
            }
        });
    }
    $.fn.MiInputComboFilter = function (params) {
        if (!$.isPlainObject(params)) params = {};
        if ($.type(params.onchange) != 'function') params.onchange = null;
        if (!$.isPlainObject(params.data)) throw 'params.data not found';
        if ($.type(params.data.NAME) != 'string') throw 'params.data.NAME not found';
        if ($.type(params.filter) != 'string') throw 'params.filter not found';
        if ($.type(params.value) != 'string') throw 'params.value not found';
        if ($.type(params.text) != 'string') throw 'params.text not found';
        if ($.type(params.vacio) != 'string') params.vacio = '-';
        if ($.type(params.mask) != 'string') params.mask = null;

        this.each(function () {
            if ($(this).prop('nodeName') == 'SPAN') {
                $(this).data('params', params);
                $(this).append($('<input/><span><img src="' + Mi.webHome + 'img/wait.gif"/></span><select/>'));
                $(this).addClass('MiInputComboFilter');
                $(this).data('MiVal', Mi.Val.inputComboFilter);
                $(this).data('MiText', Mi.Text.inputComboFilter);
                var input = $(this).children('input');
                var span = $(this).children('span');
                var img = span.children('img');
                var select = $(this).children('select');
                input.MiInputText({
                    onStartWrite: function () {
                        select.children().not('.MiInputComboOptionMask').remove();
                        select.MiOnchange();
                        select.css('visibility', 'hidden');
                        img.show();
                    },
                    onEndWrite: function () {
                        var data = {};
                        for (var i in params.data)
                            if (params.data[i] instanceof $) data[i] = params.data[i].MiVal();
                            else data[i] = params.data[i];
                        data[params.filter] = input.MiVal();
                        Mi.AJAX.request({
                            data: data,
                            onsuccess: function (r) {
                                select.css('visibility', 'visible');
                                img.hide();
                                if (r.length > 0) {
                                    select.MiFill(r, { value: params.value, text: params.text });
                                    select.MiVal(r[0][params.value]);
                                    select.MiOnchange();
                                } else select.MiFill([[null, params.vacio]]);
                            }, onerror: function (r) {
                                select.css('visibility', 'visible');
                                img.hide();
                            }
                        });
                    }
                });
                Mi.css($(this));
                span.css({
                    position: 'absolute'
                });
                img.hide();
                select.MiInputCombo({ mask: params.mask, onchange: params.onchange });
                select.MiFill([[null, params.vacio]]);
            }
        });
    }
    $.fn.MiInputDatetime = function (params) {
        if (!$.isPlainObject(params)) params = {};
        if (params.type != 'datetime' && params.type != 'time') params.type = 'date';
        if ($.type(params.onchange) != 'function') params.onchange = null;
        this.each(function () {
            if ($(this).prop('nodeName') == 'INPUT') {
                $(this).data('params', params);
                $(this).addClass('MiInputDatetime'); Mi.css($(this));
                $(this).data('MiVal', Mi.Val.inputDatetime);
                $(this).data('MiText', Mi.Text.inputDatetime);
                try {
                    $(this).prop('type', params.type == 'datetime' ? 'datetime-local' : params.type == 'date' ? 'date' : 'time');
                } catch (ex) {
                    $(this).prop('type', 'text');
                };
                if ($(this).prop('type') == 'text' && (params.type == 'datetime' || params.type == 'date')) {
                    $(this).focus(function (event) {
                        var input = $(this);
                        var calendario = $('#' + input.data('calendarioID'));
                        if (calendario.length == 0) {
                            input.data('calendarioID', (new Date()).getTime());
                            calendario = Mi.calendar({
                                date: input.MiVal(),
                                onchange: function (f) {
                                    input.MiVal(f);
                                    input.focus();
                                    input.select();
                                }
                            });
                            calendario.prop('id', input.data('calendarioID'));
                        }
                    });
                }
                $(this).change(function () {
                    if ($(this).prop('type') == 'text') {
                        if (params.type == 'datetime') {
                            if (!$(this).val().trim().match(/^\d+\x2F\d+\x2F\d+\x20\d+\x3A\d+$/gi)) $(this).val('');
                            else {
                                var a = $(this).val().trim().split(' ');
                                var b = a[0].split('/');
                                var c = a[1].split(':');
                                $(this).val(Mi.Convert.dateToString(new Date(parseInt(b[2]), parseInt(b[1]) - 1, parseInt(b[0]), parseInt(c[0]), parseInt(c[1])), '%dd/%mm/%a %hh:%ii'));
                            }
                        } else if (params.type == 'date') {
                            if (!$(this).val().trim().match(/^\d+\x2F\d+\x2F\d+$/gi)) $(this).val('');
                            else {
                                var b = $(this).val().trim().split('/');
                                $(this).val(Mi.Convert.dateToString(new Date(parseInt(b[2]), parseInt(b[1]) - 1, parseInt(b[0])), '%dd/%mm/%a'));
                            }
                        } else if (params.type == 'time') {
                            if (!$(this).val().trim().match(/^\d+\x3A\d+$/gi)) $(this).val('');
                            else {
                                var c = $(this).val().trim().split(':');
                                $(this).val(Mi.Convert.dateToString(new Date(2000, 0, 1, parseInt(c[0]), parseInt(c[1])), '%hh:%ii'));
                            }
                        }
                    }
                    if (params.onchange) params.onchange();
                });
            }
        });
    }
    $.fn.MiInputMultiple = function (params) {
        if (!$.isPlainObject(params)) params = {};
        if ($.type(params.onchange) != 'function') params.onchange = null;
        if (!params.input instanceof $) throw 'params.input not found';

        if (this.length > 0 && this.eq(0).prop('nodeName') == 'DIV') {
            this.eq(0).data('params', params);
            this.eq(0).addClass('MiInputMultiple');
            this.eq(0).data('MiVal', Mi.Val.inputMultiple);
            this.eq(0).append(params.input);
            var span0 = $('<span class="span0"><img src="' + Mi.webHome + 'img/arrow1.png"/></span>');
            var span1 = $('<span class="span1"/>');
            var div0 = $('<div class="div0"/>');
            this.eq(0).append(span0);
            this.eq(0).append(span1);
            this.eq(0).append(div0);
            var img = span0.children('img').eq(0);
            Mi.css($(this));
            img.click(function () {
                if (params.input.MiVal() == null) return;
                var yaExiste = false;
                div0.children('span').each(function () {
                    if ($(this).data('MiVal') == params.input.MiVal()) {
                        yaExiste = true;
                        return;
                    }
                });
                if (yaExiste) return;
                var span = $('<span><span/><img src="' + Mi.webHome + 'img/close2.png"/></span>'); div0.append(span);
                span.addClass('MiInputMultipleSpan'); Mi.css(span);
                span.children('span').text(params.input.MiText());
                span.data('MiVal', params.input.MiVal());
                span.children('img').click(function () {
                    $(this).parent().remove();
                    if (params.onchange) params.onchange();
                });
                div0.append($('<span> </span>'));
                if (params.onchange) params.onchange();
            });
        }
    }
    $.fn.MiInputNumber = function (params) {
        if (!$.isPlainObject(params)) params = {};
        if ($.type(params.onchange) != 'function') params.onchange = null;
        if ($.type(params.mask) != 'string') params.mask = null;
        if (!$.isNumeric(params.decimales)) params.decimales = null;
        if (params.separador) params.separador = true;
        if (Mi.Template.orientation != 'H') params.separador = false;
        this.each(function () {
            if ($(this).prop('nodeName') == 'INPUT') {
                $(this).data('params', params);
                $(this).addClass('MiInputNumber'); Mi.css($(this));
                $(this).data('MiVal', Mi.Val.inputNumber);
                $(this).data('MiText', Mi.Text.inputNumber);
                if (params.mask != null) $(this).prop('placeholder', params.mask);
                try {
                    $(this).prop('type', 'number');
                    params.separador = false;
                } catch (ex) { }


                $(this).change(function () {
                    $(this).val(Mi.Convert.numberToString(Mi.Convert.stringToNumber($(this).val()), params.decimales, params.separador));
                    if (params.onchange) params.onchange();
                });
            }
        });
    }
    $.fn.MiInputText = function (params) {
        if (!$.isPlainObject(params)) params = {};
        if ($.type(params.onchange) != 'function') params.onchange = null;
        if ($.type(params.onStartWrite) != 'function') params.onStartWrite = null;
        if ($.type(params.onEndWrite) != 'function') params.onEndWrite = null;
        if ($.type(params.textWriteTimeout) != 'number') params.textWriteTimeout = 1000;
        if (params.multiline) params.multiline = true;
        if ($.type(params.mask) != 'string') params.mask = null;
        this.each(function () {
            if ($(this).prop('nodeName') == 'INPUT' || $(this).prop('nodeName') == 'TEXTAREA') {
                $(this).data('params', params);
                $(this).addClass('MiInputText'); Mi.css($(this));
                $(this).data('MiVal', Mi.Val.inputText);
                $(this).data('MiText', Mi.Text.inputText);
                if (params.mask != null) $(this).prop('placeholder', params.mask);
                if (params.onStartWrite != null || params.onEndWrite != null) {
                    $(this).data('MiInputTextWriteStarted', false);
                    $(this).keyup(function (event) {
                        if (event.which == 9 || event.which == 16 || event.which == 17 || event.which == 27 || event.which == 37 || event.which == 39) return true;
                        var text = $(this);
                        if (params.onStartWrite && !text.data('MiInputTextWriteStarted')) {
                            text.data('MiInputTextWriteStarted', true);
                            params.onStartWrite();
                        }
                        if ($.type(text.data('MiInputTextHandler')) != 'undefined') clearTimeout(text.data('MiInputTextHandler'));
                        text.data('MiInputTextHandler', setTimeout(function () {
                            if (text.data('MiInputTextWriteStarted') && params.onEndWrite) {
                                text.data('MiInputTextWriteStarted', false);
                                params.onEndWrite();
                                if (params.onchange) params.onchange();
                            }
                        }, params.textWriteTimeout));
                    });
                } else $(this).change(function () {
                    if (params.onchange) params.onchange();
                });
            }
        });
    }
}