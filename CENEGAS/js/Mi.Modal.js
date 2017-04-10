Mi.Modal = {}
Mi.Modal.modal = function (params) {
	if (!$.isPlainObject(params)) params = {}
	if ($.type(params.dialogType) != 'string') params.dialogType = 'alert'; //alert, error, confirm
	if ($.type(params.title) != 'string') {
	    if (params.dialogType == 'alert') params.title = 'Alerta';
	    else if (params.dialogType == 'error') params.title = 'Error';
	    else if (params.dialogType == 'confirm') params.title = 'Confirmar';
	}
	if ($.type(params.content) == 'string') {
		var tmp = $('<span/>');
		tmp.text(params.content);
		params.content = tmp;
	} else if (!(params.content instanceof jQuery)) params.content = $('<span/>');

	if (!(params.buttons instanceof jQuery)) {
	    if (params.dialogType == 'alert' || params.dialogType == 'error') {
	        params.buttons = $('<button type="button" class="btn btn-default" data-dismiss="modal">Aceptar</button>');
	    } else if (params.dialogType == 'confirm') {
	        params.buttons = $('<button type="button" class="btn btn-default" data-dismiss="modal">Si</button><button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>');
	        params.buttons.eq(0).click(function () {
	            if ($.type(params.onsi) == 'function') params.onsi();
	            e.modal('hide');
	        });
	    }
	}
    var e=$('<div id="deleteModal" class="modal fade" role="dialog"></div>').append(
            $('<div class="modal-dialog"></div>').append(
                $('<div class="modal-content">').append(
                    $('<div class="modal-header"></div>').append(
                        $('<button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>')
                    ).append(
                      $('<h4 class="modal-title">'+params.title+'</h4>')
                    )
                ).append(
                    $('<div class="modal-body"></div>').append(
                        params.content
                    )
                ).append(
                    $('<div class="modal-footer"></div>').append(
                        params.buttons
                    )
                )
            )
        )
    e.appendTo(document.body);
    e.modal();
	return e;
}
Mi.Modal.alert = function (content, onaceptar, params) {
	if (!$.isPlainObject(params)) params = {}
	params.dialogType = 'alert';
	params.content = content;
	params.onaceptar = onaceptar;
	Mi.Modal.modal(params);
}
Mi.Modal.error = function (error, onaceptar, params) {
	if (!$.isPlainObject(params)) params = {}
	params.dialogType = 'error';
	params.content = error;
	params.onaceptar = onaceptar;
	Mi.Modal.modal(params);
}
Mi.Modal.confirm = function (content, onsi,params) {
    if (!$.isPlainObject(params)) params = {}
    params.dialogType = 'confirm';
    params.content = content;
    params.onsi = onsi;
    Mi.Modal.modal(params);
}

Mi.Modal.showPleaseWait=function() {
    var modalLoading = '<div class="modal" id="pleaseWaitDialog" data-backdrop="static" data-keyboard="false role="dialog">\
        <div class="modal-dialog">\
            <div class="modal-content">\
                <div class="modal-header">\
                    <h4 class="modal-title">Por favor espere ...</h4>\
                </div>\
                <div class="modal-body">\
                    <div class="progress">\
                      <div class="progress-bar progress-bar-success progress-bar-striped active" role="progressbar"\
                      aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width:100%; height: 40px">\
                      </div>\
                    </div>\
                </div>\
            </div>\
        </div>\
    </div>';
    $(document.body).append(modalLoading);
    $("#pleaseWaitDialog").modal("show");
};

Mi.Modal.hidePleaseWait=function(){
    $("#pleaseWaitDialog").modal("hide");
}