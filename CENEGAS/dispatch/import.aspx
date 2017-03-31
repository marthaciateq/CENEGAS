<%@ Page Language="C#" AutoEventWireup="true" %><% 
                                                    
    HttpPostedFile csvHours = (HttpPostedFile)Request.Files["horarios"];
    HttpPostedFile csvSummary = (HttpPostedFile)Request.Files["promedios"];
    
    DateTime initDate = DateTime.Parse( Request.Params["initDate"]);
    DateTime finalDate = DateTime.Parse(Request.Params["finalDate"]);
    bool updateRecords = bool.Parse(Request.Params["updateRecords"]);

    if (csvHours != null && csvSummary != null)
        cenegas.clases.importar.import(csvHours, csvSummary, initDate, finalDate, updateRecords, Response);
                                                                                     
%>
