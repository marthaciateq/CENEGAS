Mi.Val = {}
Mi.Val.inputCombo = function (element, value) {
	if ($.type(value) == 'undefined') {
		if (element.prop('selectedIndex') < 0) return null;
		else return element.children('option').eq(element.prop('selectedIndex')).data('MiVal');
	} else {
		var params = element.data('params');
		element.prop('selectedIndex', -1);
		if ($.isArray(value)) {
			element.children('option').each(function () {
				if ($(this).data('MiVal') == value[0]) $(this).prop('selected', true);
			});
			if (element.prop('selectedIndex') == -1) {
				var option = $('<option/>'); option.addClass('MiInputComboOption');
				Mi.css(option);
				option.text(value[1]);
				option.data('MiVal', value[0]);
				option.prop('selected', true);
				element.append(option);
			}
		} else element.children('option').each(function () {
			if ($(this).data('MiVal') == value) $(this).prop('selected', true);
		});
		if (element.prop('selectedIndex') == -1 && params.mask != null) element.prop('selectedIndex', 0);
	}
}
Mi.Val.inputComboFilter = function (element, value) {
	if ($.type(value) == 'undefined')
		return element.children('select').MiVal();
	else element.children('select').MiVal(value);
}
Mi.Val.inputDatetime = function (element, value) {
	if ($.type(value) == 'undefined') {
		if (element.val().trim() == '') return null;
		if (element.prop('type') == 'text') {
			var a, b, c;
			if (element.data('params').type == 'datetime') {
				a = element.val().trim().split(' ');
				b = a[0].split('/');
				c = a[1].split(':');
				return new Date(parseInt(b[2]), parseInt(b[1]) - 1, parseInt(b[0]), parseInt(c[0]), parseInt(c[1]));
			}
			if (element.data('params').type == 'date') {
				b = element.val().trim().split('/');
				return new Date(parseInt(b[2]), parseInt(b[1]) - 1, parseInt(b[0]));
			}
			if (element.data('params').type == 'time') {
				c = element.val().trim().split(':');
				return new Date(2000, 0, 1, parseInt(c[0]), parseInt(c[1]));
			}
		} else {
			var a,b,c;
			if (element.data('params').type == 'datetime') a = (element.val()).split('T');
			if (element.data('params').type == 'date') a = (element.val() + 'T00:00').split('T');
			if (element.data('params').type == 'time') a = ('2000-01-01T' + element.val()).split('T');
			b = a[0].split('-');
			c = a[1].split(':');
			return new Date(parseInt(b[0]), parseInt(b[1]) - 1, parseInt(b[2]), parseInt(c[0]), parseInt(c[1]));
		}
	} else {
		if ($.type(value) != 'date') element.val('');
		else {
			if (element.prop('type') == 'text') {
				if (element.data('params').type == 'datetime')
					element.val(Mi.Convert.dateToString(value, '%dd/%mm/%a %hh:%ii'));
				else if (element.data('params').type == 'date')
					element.val(Mi.Convert.dateToString(value, '%dd/%mm/%a'));
				else if (element.data('params').type == 'time')
					element.val(Mi.Convert.dateToString(value, '%hh:%ii'));
			} else {
				if (element.data('params').type == 'datetime')
					element.val(Mi.Convert.dateToString(value, '%a-%mm-%ddT%hh:%ii'));
				else if (element.data('params').type == 'date')
					element.val(Mi.Convert.dateToString(value, '%a-%mm-%dd'));
				else if (element.data('params').type == 'time')
					element.val(Mi.Convert.dateToString(value, '%hh:%ii'));
			}

		}
	}
}
Mi.Val.inputMultiple = function (element, value) {
	if ($.type(value) == 'undefined') {
		var r = [];
		element.children('div').children('.MiInputMultipleSpan').each(function () {
			if ($(this).data('MiVal') != null) r.push($(this).data('MiVal'));
		});
		if (r.length > 0) return r;
		else return element.children().eq(0).MiVal();
	}
}
Mi.Val.inputNumber = function (element, value) {
	if ($.type(value) == 'undefined') {
		if (element.val().trim() == '') return null;
		else return Mi.Convert.stringToNumber(element.val());
	} else {
		if (!$.isNumeric(parseFloat(value))) element.val('')
		else element.val(Mi.Convert.numberToString(value, element.data('params').decimales, element.data('params').separador))
	}
}
Mi.Val.inputText = function (element, value) {
	if ($.type(value) == 'undefined') {
		if (element.val().trim() == '') return null;
		else return element.val().trim();
	} else element.val(value == null ? '' : value);
}