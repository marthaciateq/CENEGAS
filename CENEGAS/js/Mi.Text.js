Mi.Text = {}
Mi.Text.inputCombo = function (element) {
	if (element.prop('selectedIndex') < 0) return '';
	else return element.children('option').eq(element.prop('selectedIndex')).prop('text');
}
Mi.Text.inputComboFilter = function (element) {
	return element.children('select').MiText();
}
Mi.Text.inputDatetime = function (element) {
	return element.val();
}
Mi.Text.inputNumber = function (element) {
	return element.val();
}
Mi.Text.inputText = function (element) {
	return element.val();
}
