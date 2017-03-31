<%@ Page Language="C#" AutoEventWireup="true" %><% 
	Dictionary<String, String> querys = new Dictionary<String, String>();
	Mi.Control.Reports.Dispatch(Request, Response, querys); 
%>
