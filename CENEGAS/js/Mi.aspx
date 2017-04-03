<%@ Page Language="C#" AutoEventWireup="true" %>
<%
	System.IO.StreamReader streamReader = null;
	String[] librerias = new String[]{
		"jquery-3.2.0.min.js",
		"bootstrap.min.js",        
        "chosen.jquery.min.js",    
        "bootstrap-datepicker.min.js",
        "bootstrap-datepicker.es.min.js",        
        "jszip.min.js",      
        "FileSaver.min.js",        
		"Mi.js",
		"Mi.css.js",
		"Mi.AJAX.js",
		"Mi.Cookie.js",
		"Mi.calendar.js",
		"Mi.Convert.js",
		"Mi.Input.js",
		"Mi.Input.combos.js",
		"Mi.JSON.js",
		"Mi.Menu.js",
		"Mi.Modal.js",        
		"Mi.Reports.js",
		"Mi.Table.js",
		"Mi.Template.js",
		"Mi.Text.js",
		"Mi.Util.js",
		"Mi.Val.js",
		"Mi.windows.js"
	};
	foreach (String libreria in librerias)
	{
		streamReader = new System.IO.StreamReader(System.IO.File.OpenRead(Mi.Control.Config.AppPath + "js\\" + libreria));
		Response.Output.WriteLine(streamReader.ReadToEnd());
		streamReader.Close();
	}
%>