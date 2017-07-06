<%@ Page Language="C#" AutoEventWireup="true" %><%
    if (Request.Params["action"] != null && Request.Params["action"].Equals("eliminar"))
    {
        cenegas.clases.utils.borrarArchivos(Request, Response);
    }
    else
    {
        cenegas.clases.utils.generateZip(Request, Response);
    }
%>