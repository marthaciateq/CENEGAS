Mi.Menu = {};
Mi.Menu.menu = { 'caption': '', 'url': null, 'servicios': [] }
Mi.Menu.menu.administracion = { 'caption': 'Análisis de Calidad del Gas', 'url': null, 'servicios': [] }
Mi.Menu.menu.administracion.usuarios = { 'caption': 'Usuarios', 'url': 'pages/usuarios.html', 'servicios': ['sps_usuarios_guardar','sps_usuarios_borrar'] }
Mi.Menu.menu.administracion.pmuestreo = { 'caption': 'Puntos de Muestreo', 'url': 'pages/pmuestreo.html', 'servicios': ['sps_pmuestreo_guardar','sps_pmuestreo_borrar'] }
Mi.Menu.menu.administracion.elementos = { 'caption': 'Elementos', 'url': 'pages/elementos.html', 'servicios': ['sps_elementos_guardar','sps_elementos_borrar'] }
Mi.Menu.menu.administracion.especificaciones = { 'caption': 'Especificaciones', 'url': 'pages/especificaciones.html', 'servicios': ['sps_especificaciones_guardar','sps_especificaciones_borrar'] }
Mi.Menu.menu.administracion.bdatos = { 'caption': 'Carga de Bases de Datos', 'url': 'pages/bdatos.html', 'servicios': [] }
Mi.Menu.menu.administracion.reportes = { 'caption': 'Reportes', 'url': 'pages/reportes.html', 'servicios': [] }
Mi.Menu.menu.administracion.salir = {
    'caption': 'Salir', 'url': function () {
        Mi.Modal.confirm('¿Esta usted seguro de cerrar su sesión?',
                function () {
                    Mi.Cookie.remove('SESIONCENEGAS');
                    window.location.href = Mi.webHome + 'index.html';
                }
            );
    }, 'servicios': []
}

Mi.Menu.servicios = {};

Mi.Menu.load = function () {
    filtrarMenu = function () {
        function validarServiciosRequeridos(menu) {
            if (menu.servicios.length == 0) return true
            for (var servicioRequerido in menu.servicios) {
                for (var servicio in Mi.Menu.servicios) {
                    if (menu.servicios[servicioRequerido] == servicio) {
                        return true
                    }
                }
            }
            return false
        }
        function filtrarMenuPorServiciosRequeridos(menu) {
            for (var p in menu) {
                if (p != 'caption' && p != 'url' && p != 'servicios') {
                    if (validarServiciosRequeridos(menu[p])) {
                        filtrarMenuPorServiciosRequeridos(menu[p])
                    }
                    else {
                        delete menu[p]
                    }
                }
            }

        }
        function validarRamasVacias(menu) {
            if (typeof (menu.url) == 'string') {
                if (menu.url.length > 0)
                    return true
            }
            if (typeof (menu.url) == 'function') {
                return true
            }
            delete menu.url

            var i = 0
            for (var p in menu)
                if (p != 'caption' && p != 'url' && p != 'servicios') i++
            if (i == 0) return false
            return true
        }
        function filtrarMenuPorRamasVacias(menu) {
            for (var p in menu)
                if (p != 'caption' && p != 'url' && p != 'servicios')
                    filtrarMenuPorRamasVacias(menu[p])

            for (var p in menu)
                if (p != 'caption' && p != 'url' && p != 'servicios')
                    if (!validarRamasVacias(menu[p])) delete menu[p]

                }
                Mi.Menu.servicios = Mi.Cookie.exist('SESIONCENEGAS') ? Mi.Cookie.get('SESIONCENEGAS').servicios : {};
                filtrarMenuPorServiciosRequeridos(Mi.Menu.menu)
                filtrarMenuPorRamasVacias(Mi.Menu.menu)
            }

            function recorreMenu(menu, ul, ul2) {
                var li
                for (var p in menu)
                    if (p != 'caption' && p != 'url' && p != 'servicios') {
                        if (!(typeof (menu[p].url) == 'string') && !(typeof (menu[p].url) == 'function')) {
                            li = $('<li></li>').append(
                        $('<a href="#finances-opts" class="transition" role="button" data-toggle="collapse" aria-expanded="false" aria-controls="finances-opts">' + menu[p].caption + '</a>').append(
                            $('<span class="glyphicon glyphicon-menu-left pull-right transition" aria-hidden="true"></span>')
                        )
                    );
                            ul2 = $('<ul class="collapse list-unstyled" id="finances-opts"></ul>');
                            li.append(ul2);
                        }
                        else {
                            if (typeof (menu[p].url) == 'function') {
                                li = $('<li><a onclick="' + menu[p].url + '" href="#">' + menu[p].caption + '</a></li>')
                                li.find('a').click(menu[p].url);
                            }
                            else {
                                li = $('<li><a href="' + Mi.webHome + menu[p].url + '" class="transition">' + menu[p].caption + '</a></li>')
                            }
                            if (ul2) ul2.append(li);
                        }
                        li.appendTo(ul)
                        if (!(typeof (menu[p].url) == 'string')) recorreMenu(menu[p], $(li).children()[1], ul2)
                    }
            }
            filtrarMenu();

            var ul = $('<ul id="ul_menu" class="nav nav-pills nav-stacked"></ul>');
            //$('#side-menu').append($('<div class="profile-block"><h2 class="profile-title">CIATEQ<small>@ciateq.mx</small></h2></div>'));
            recorreMenu(Mi.Menu.menu, ul);
            ul.appendTo($('#side-menu'));
        }



