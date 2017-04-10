Mi.MiTextVal = function (e, value) {
    if ($.type(value) == 'undefined') {
        if (e.val().trim() == '') return null
        else return e.val().trim()
    } else {
        if (value == null) e.val('')
        else e.val(value)
    }
}

Mi.MiNumberMiVal = function (e, value, decimales, separador) {
    if ($.type(value) == 'undefined') return Mi.Convert.stringToNumber(e.val())
    else {
        if (!$.isNumeric(parseFloat(value))) e.val('')
        else e.val(Mi.Convert.numberToString(value, decimales, separador))
    }
}