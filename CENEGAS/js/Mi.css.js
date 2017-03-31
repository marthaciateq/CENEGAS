Mi.css = function (element) {
	if (element.hasClass('MiButton')) {
		element.css({
			'box-shadow': Mi.Template.value('boxShadow'),
			'border-radius': Mi.Template.value('borderRadius'),
			'background-color': Mi.Template.value('colorObscuro'),
			'color': Mi.Template.value('colorMuyClaro'),
			'padding-left': Mi.width * (Mi.Template.orientation == 'H' ? 0.015 : 0.1),
			'padding-right': Mi.width * (Mi.Template.orientation == 'H' ? 0.015 : 0.1),
			'padding-top': Mi.height * (Mi.Template.orientation == 'H' ? 0.004 : 0.025),
			'padding-bottom': Mi.height * (Mi.Template.orientation == 'H' ? 0.004 : 0.025),
			'font-size': Mi.Template.value('fontSizeNormal'),
			'font-family': Mi.Template.value('fontFamily'),
			cursor: 'pointer',
			'margin-right': Mi.width * 0.01
		});
	} else if (element.hasClass('MiInputCheckbox')) {
		element.css({
			width: Mi.Template.orientation == 'H' ? Mi.height * 0.03 : Mi.width * 0.1,
			height: Mi.Template.orientation == 'H' ? Mi.height * 0.03 : Mi.width * 0.1
		});
	} else if (element.hasClass('MiDialog')) {
		element.css({
			'min-width': Mi.width * 0.25,
			'width': element.data('params').width,
			'box-shadow': Mi.Template.value('boxShadow'),
			'border-radius': Mi.Template.value('borderRadius'),
			'display': 'inline-block',
			'background-color': Mi.Template.value('colorMuyClaro')
		});
		if (element.data('params').modal instanceof $)
			element.css({
				position: 'absolute',
				left: (Mi.width * 0.5) - (element.width() * 0.5),
				top: Mi.height * 0.3,
				'z-index': 99999999
			});
	} else if (element.hasClass('MiDialogDivButtons')) {
		element.css({
			margin: Mi.height * 0.02,
			'text-align': 'center'
		});
	} else if (element.hasClass('MiDialogDivClose')) {
		element.css({
			'text-align': 'right'
		});
		element.children('span').eq(0).children('span').eq(0).css({
			position: 'absolute'
		});
		element.children('span').eq(0).children('span').eq(0).children('img').eq(0).css({
			width: Mi.Template.value('iconSize'),
			height: Mi.Template.value('iconSize'),
			position: 'absolute',
			left: Mi.Template.value('iconSize') * -0.5,
			top: Mi.Template.value('iconSize') * -0.5,
			cursor: 'pointer'
		});
	} else if (element.hasClass('MiDialogDivContent')) {
		element.css({
			margin: Mi.height * 0.02,
			'text-align': 'justify'
		});
	} else if (element.hasClass('MiDialogDivHeader')) {
		element.css(Mi.Template.value('header'));
		element.css({
			margin: Mi.height * 0.01,
			'text-align': 'left',
			'padding-left': Mi.width * 0.02
		});
	} else if (element.hasClass('MiDialogDivModal')) {
		element.css({
			position: 'absolute',
			left: 0,
			top: 0,
			width: Mi.width,
			height: Mi.height,
			'background-color': Mi.Template.value('colorClaro'),
			'opacity': 0.8,
			'z-index': 9999999
		});
	} else if (element.hasClass('MiInputCombo')) {
		element.css({
			'padding-left': Mi.width * 0.005,
			'padding-right': Mi.width * 0.005,
			'padding-top': Mi.height * 0.005,
			'padding-bottom': Mi.height * 0.005,
			'background-color': Mi.Template.value('colorMuyClaro'),
			color: Mi.Template.value('colorInput'),
			'font-size': Mi.Template.value('fontSizeNormal'),
			'font-family': Mi.Template.value('fontFamily'),
			'boxShadow': Mi.Template.value('boxShadowInput'),
			border: 'solid 1px ' + Mi.Template.value('colorClaro'),
			width: Mi.width * (Mi.Template.orientation == 'H' ? 0.1 : 0.5),
			'-webkit-appearance': 'menulist',
			'appearance': 'menu'
		});
	} else if (element.hasClass('MiInputComboFilter')) {
		element.children('input').css({
			width: Mi.height * (Mi.Template.orientation == 'H' ? 0.08 : 0.1)
		});
		element.children('span').children('img').css({
			width: Mi.height * (Mi.Template.orientation == 'H' ? 0.02 : 0.047),
			height: Mi.height * (Mi.Template.orientation == 'H' ? 0.02 : 0.047),
			'vertical-align': 'middle',
			position: 'absolute',
			top: Mi.height * (Mi.Template.orientation == 'H' ? 0.009 : 0.005),
			left: Mi.height * (Mi.Template.orientation == 'H' ? 0.01 : 0.02)
		});
	} else if (element.hasClass('MiInputComboOption')) {
		element.css({
			color: Mi.Template.value('colorInput')
		});
	} else if (element.hasClass('MiInputComboOptionMask')) {
		element.css({
			color: Mi.Template.value('colorInputMask')
		});
	} else if (element.hasClass('MiInputDatetime')) {
		element.css({
			'padding-left': Mi.width * 0.005,
			'padding-right': Mi.width * 0.005,
			'padding-top': Mi.height * 0.005,
			'padding-bottom': Mi.height * 0.005,
			'background-color': Mi.Template.value('colorMuyClaro'),
			'color': Mi.Template.value('colorInput'),
			'font-size': Mi.Template.value('fontSizeNormal'),
			'font-family': Mi.Template.value('fontFamily'),
			'boxShadow': Mi.Template.value('boxShadowInput'),
			border: 'solid 1px ' + Mi.Template.value('colorClaro'),
			'text-align': 'center'
		});
		if (element.data('params').type == 'datetime') element.width(Mi.width * (Mi.Template.orientation == 'H' ? 0.12 : 0.7));
		else if (element.data('params').type == 'date') element.width(Mi.width * (Mi.Template.orientation == 'H' ? 0.08 : 0.5));
		else if (element.data('params').type == 'time') element.width(Mi.width * (Mi.Template.orientation == 'H' ? 0.065 : 0.4));
	} else if (element.hasClass('MiInputMultiple')) {
		element.css({
			display: 'inline-block',
			width: Mi.width * 0.3,
			'vertical-align': 'top',
			'text-align': 'left'
		});
		element.children('.div0').eq(0).css({
			'padding-top': Mi.height * 0.01,
			'line-height': '150%',
			'word-spacing': Mi.height * 0.01,
			'text-align': 'left'
		});
		element.children('.span0').eq(0).css({
			position: 'absolute'
		});
		element.children('.span1').eq(0).css({
			display: 'inline-block',
			width: Mi.height * 0.06
		});
		element.children('.span0').eq(0).children('img').eq(0).css({
			cursor: 'pointer',
			width: Mi.height * 0.06,
			height: Mi.height * 0.06
		});
	} else if (element.hasClass('MiInputMultipleSpan')) {
		element.css({
			'background-color': Mi.Template.value('colorObscuro'),
			'border-radius': Mi.Template.value('borderRadius'),
			color: 'white',
			'padding-left': Mi.height * 0.01,
			'padding-right': Mi.height * 0.01
		});
		element.children('img').css({
			height: Mi.Template.value('fontSizeNormal'),
			cursor: 'pointer',
			'vertical-align': 'middle'
		});
	} else if (element.hasClass('MiInputNumber')) {
		element.css({
			'padding-left': Mi.width * 0.005,
			'padding-right': Mi.width * 0.005,
			'padding-top': Mi.height * 0.005,
			'padding-bottom': Mi.height * 0.005,
			'background-color': Mi.Template.value('colorMuyClaro'),
			'color': Mi.Template.value('colorInput'),
			'font-size': Mi.Template.value('fontSizeNormal'),
			'font-family': Mi.Template.value('fontFamily'),
			'boxShadow': Mi.Template.value('boxShadowInput'),
			border: 'solid 1px ' + Mi.Template.value('colorClaro'),
			width: Mi.width * (Mi.Template.orientation == 'H' ? 0.08 : 0.3),
			'text-align': 'right'
		});
	} else if (element.hasClass('MiInputText')) {
		element.css({
			'padding-left': Mi.width * 0.005,
			'padding-right': Mi.width * 0.005,
			'padding-top': Mi.height * 0.005,
			'padding-bottom': Mi.height * 0.005,
			'background-color': Mi.Template.value('colorMuyClaro'),
			'color': Mi.Template.value('colorInput'),
			'font-size': Mi.Template.value('fontSizeNormal'),
			'font-family': Mi.Template.value('fontFamily'),
			'boxShadow': Mi.Template.value('boxShadowInput'),
			border: 'solid 1px ' + Mi.Template.value('colorClaro'),
			width: Mi.width * (Mi.Template.orientation == 'H' ? 0.2 : 0.5)
		});
		if (element.data('params').multiline) element.css({
			height: Mi.height * 0.1,
			width: Mi.width * 0.3
		});
	} else if (element.hasClass('MiTreeNode')) {
		element.css({
			'text-align': 'left',
			'padding-top': Mi.height * 0.01
		});
		element.children('img').css({
			'vertical-align': 'middle',
			width: Mi.height * 0.025,
			height: Mi.height * 0.025
		});
	} else if (element.hasClass('MiTreeNodeContentDiv')) {
		element.css({
			display: 'inline-block',
			'min-width': Mi.width * 0.15,
			'vertical-align': 'middle',
			'text-align': 'left',
			'padding-left': Mi.height * 0.01,
			'padding-top': Mi.height * 0.005,
			'padding-bottom': Mi.height * 0.005,
			'border-radius': Mi.Template.value('borderRadius'),
			'box-shadow': Mi.Template.value('boxShadow')
		});

	} else if (element.hasClass('MiTreeNode1Div')) {
		element.css({
			'display': 'inline-block',
			'vertical-align': 'top'
		});
		element.eq(0).css({
			width: '90%'
		});
		element.eq(1).css({
			'text-align': 'right',
			width: '10%'
		});
	}
}