Mi.Template = {
	id: 1,
	orientation: 'H'
}
Mi.Template.menuTop = function (opciones, titulo) {
    $('#opciones').append(
        $('<nav id="top-menu" class="navbar navbar-default" role="navigation"></nav>').append(
            $('<div class="navbar-header"><button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-ex1-collapse"><span class="sr-only">Desplegar navegación</span><span class="icon-bar"></span><span class="icon-bar"></span><span class="icon-bar"></span></button><a class="navbar-brand" href="#">' + titulo + '</a></div>')
        ).append(
            $('<div class="collapse navbar-collapse navbar-ex1-collapse"></div>').append(
                $('<ul class="nav navbar-nav navbar-right" id="menuTop"></ul>')
            )
        )
    );
//    $("#menuTop").append(
//            $('<form class="navbar-form navbar-left" role="search"><div class="form-group"><input id="txtbuscar" type="text" class="form-control" placeholder="Buscar"></div><button id="bbuscar" type="submit" class="btn btn-default">Enviar</button></form>')
//    );
    $.each(opciones, function (key, elemento) {
        href = $('<a href="#"><span class="glyphicon ' + elemento.img + ' aria-hidden="true"></span>' + elemento.label + '</a>');
        href.click(elemento.onclick);
        $('<li></li>').append(href).appendTo($("#menuTop"));
    });
}
Mi.Template.value = function (key) {
	switch (key) {
		case 'borderRadius':
			if (Mi.Template.id == 1 || Mi.Template.id == 2) return Mi.height * 0.01;
			break;
		case 'boxShadow':
			if (Mi.Template.id == 1 || Mi.Template.id == 2) return (Mi.height * 0.001) + 'px ' + (Mi.height * -0.001) + 'px ' + (Mi.height * 0.01) + 'px ' + (Mi.height * 0.0005) + 'px ' + Mi.Template.value('colorClaro');
			break;
		case 'boxShadowInput':
			if (Mi.Template.id == 1 || Mi.Template.id == 2) return (Mi.height * 0.001) + 'px ' + (Mi.height * -0.001) + 'px ' + (Mi.height * 0.01) + 'px ' + (Mi.height * 0.0005) + 'px ' + Mi.Template.value('colorClaro');
			break;
		case 'colorMuyObscuro':
			if (Mi.Template.id == 1 || Mi.Template.id == 2) return '#a50f0f';
			break;
		case 'colorObscuro':
			if (Mi.Template.id == 1 || Mi.Template.id == 2) return '#c80300';
			break;
		case 'colorClaro':
			if (Mi.Template.id == 1 || Mi.Template.id == 2) return '#aaa';
			break;
		case 'colorMuyClaro':
			if (Mi.Template.id == 1 || Mi.Template.id == 2) return '#f5f5f5';
			break;
		case 'colorInputMask':
			if (Mi.Template.id == 1 || Mi.Template.id == 2) return Mi.Template.value('colorClaro');
			break;
		case 'colorInput':
			if (Mi.Template.id == 1 || Mi.Template.id == 2) return 'black';
			break;
		case 'fontFamily':
			if (Mi.Template.id == 1 || Mi.Template.id == 2) return 'Arial, Verdana, Book Antiqua';
			break;
		case 'fontSizeGrande':
			if (Mi.Template.id == 1 || Mi.Template.id == 2) {
				if (Mi.Template.orientation == 'H') return Mi.height * 0.023;
				else return Mi.width * 0.052;
			}
			break;
		case 'fontSizeExtraGrande':
			if (Mi.Template.id == 1 || Mi.Template.id == 2) {
				if (Mi.Template.orientation == 'H') return Mi.height * 0.04;
				else return Mi.width * 0.055;
			}
			break;
		case 'fontSizeNormal':
			if (Mi.Template.id == 1 || Mi.Template.id == 2) {
				if (Mi.Template.orientation == 'H') return Mi.height * 0.017;
				else return Mi.width * 0.049;
			}
			break;
		case 'header':
			return {
				'border-radius': Mi.Template.value('borderRadius'),
				background: 'linear-gradient(' + Mi.Template.value('colorMuyObscuro') + ', ' + Mi.Template.value('colorObscuro') + ')',
				'color': 'white',
				'font-weight': 'bold',
				'font-size': Mi.Template.value('fontSizeGrande')
			}
			break;
		case 'iconSize':
			if (Mi.Template.orientation == 'H') return Mi.height * 0.035;
			else return Mi.height * 0.06;
			break;
		case 'textShadow':
			if (Mi.Template.id == 1 || Mi.Template.id == 2) return (Mi.height * -0.003) + 'px ' + (Mi.height * -0.002) + 'px ' + (Mi.height * 0.015) + 'px ' + (Mi.height * 0.0025) + 'px ' + Mi.Template.value('colorClaro');
			break;
	}
	return null;
}
Mi.Template.load = function (onload, id, noAutenticacion) {
	if ($.type(onload) != 'function') onload = function () { };
	if (noAutenticacion) Mi.Template.principal(onload);
	else {
	    if (Mi.Cookie.exist('SESIONCENEGAS')) Mi.Template.principal(onload);
		else Mi.Template.oneAutentication(onload);
	}
}
Mi.Template.principal = function (onload) {

    $("#formAutenticacion").remove();

    if (!$("#div_principal").length) {
        $(document.body).children().remove();
        $(document.body).append(
            $('<div id="div_principal" class="container-fluid"></div>').append(
                $('<div id="row_principal" class="row"></div>').append(
                    $('<div id="side-menu" class="col-sm-2 hidden-xs" data-spy="affix" data-offset-top="0"></div>')
               ).append(
                    $('<div id="opciones" class="col-sm-offset-2 col-sm-10"></div>')
               ).append(
                    $('<div id="main" class="col-sm-offset-2 col-sm-10"></>')
               )
            )
        )
    }
    Mi.Menu.load();

    $(document.body).css({
        "background-image": '',
        "background-size": ''
    });

    onload();
}
Mi.Template.oneAutentication = function (onload) {
    $("#div_principal").remove();
    var e = $('<div id="formAutenticacion">\
			<div id="TABLE1" />\
		</div>'); $(document.body).append(e);

    $(document.body).css({
        "background-image": "url(../imgs/cenagas-transporte.jpg)",
        "background-size": "cover"
    });

//    function teclaEnter(event) {
//        if (event.which == 13) buttons.click();
//    }
//    var usuario = Mi.Input.text(); usuario.keydown(teclaEnter);
//    var pwd = Mi.Input.text(); pwd.prop('type', 'password'); pwd.keydown(teclaEnter);
//    var buttons = $('<button>Entrar</button>'); buttons.MiButton();

    $('#TABLE1').append('<h2 class="text-center">Aplicación para la evaluación de la calidad del Gas</h2><hr>');
    $('#TABLE1').append(
        $('<div id="formAcceso"><form class="form-horizontal"><div class="form-group form-group-sm"><label class="col-sm-2 control-label" for="lg">Usuario</label><div class="col-sm-4"><input class="form-control MiInputText" type="text" id="login" placeholder="Email"></div></div><div class="form-group form-group-sm"><label class="col-sm-2 control-label" for="sm">Password</label><div class="col-sm-4"><input class="form-control MiInputText" type="password" id="password" placeholder="Password"></div></div><div class="form-group form-group-sm "><div class="col-xs-offset-3"><a class="btn btn-primary btn-lg MiButton" id="acceso" role="button">Entrar</a></div></div></form></div>')
    )

    $("#acceso").click(function () {
       $("#acceso").MiWait(true);
        Mi.AJAX.request({
            data: {
                NAME: 'spp_autenticar',
                login: $("#login").val(),
                password: $("#password").val(),
            },
            onsuccess: function (r) {
                var servicios = {}
                for (var i = 0; i < r[1].length; i++)
                    servicios[r[1][i].servicio] = true;
                Mi.Cookie.set('SESIONCENEGAS', {
                    idsesion: r[0][0].idsesion,
                    login: r[0][0].login,
                    servicios: servicios
                });
                Mi.Template.principal(onload);
            },
            onerror: function (r) {
                $("#acceso").MiWait(false);
                Mi.dialog({ content: r, modal: true });
            }
        });
    });
    $("#login").focus();
}