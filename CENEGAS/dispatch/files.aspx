<%@ Page Language="C#" AutoEventWireup="true" %><%
	if (Request.Params["idfile"] != null)
    {
        Mi.Control.Files.File[] files = Mi.Control.Files.Read(Request.Params["idsesion"], Request.Params["idfile"], null, null);
        if (files.Length == 1)
        {
            Response.ContentType = files[0].ctype;
            Response.AddHeader("Content-disposition", "filename=" + files[0].name);
            Response.OutputStream.Write(files[0].data, 0, (int)files[0].clength);
        }
    }
    else if (Request.QueryString["idDownload"] != null)
    {

        Mi.Control.Files.File file = cenegas.clases.importar.getFile(Request.QueryString["idDownload"], Request.QueryString["idsesion"]);

        Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        Response.AddHeader("Content-disposition", "filename=" + file.name);
        Response.OutputStream.Write(file.data, 0, (int)file.clength);
    }else if (Request.Params["idfile"] == null)
		Mi.Control.AJAX.UploadFile(Request, Response);
%>