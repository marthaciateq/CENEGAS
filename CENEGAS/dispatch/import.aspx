<%@ Page Language="C#" AutoEventWireup="true" %><% 
                                                    
    HttpPostedFile csvHours = (HttpPostedFile)Request.Files["horarios"];
    HttpPostedFile csvSummary = (HttpPostedFile)Request.Files["promedios"];

    string idsesion = Request.Params["idsesion"];

    bool updateRecords = bool.Parse(Request.Params["updateRecords"]);
    bool useRange = bool.Parse(Request.Params["useRange"]);
    
    string actionForNewPoints = Request.Params["actionForNewPoints"];
    
    DateTime initDate = DateTime.Now;
    DateTime finalDate = initDate;

    if (useRange)
    {
        initDate = DateTime.Parse(Request.Params["initDate"]);
        finalDate = DateTime.Parse(Request.Params["finalDate"]);
    }
    

    if (csvHours != null && csvSummary != null)
        cenegas.clases.importar.import(idsesion, csvHours, csvSummary, updateRecords, useRange, actionForNewPoints, initDate, finalDate, Response);
                                                                                     
%>
