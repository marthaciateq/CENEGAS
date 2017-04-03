using System;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using Microsoft.Reporting;
using System.Collections;
using System.IO.Compression;
using Microsoft.Reporting.WebForms;
using System.IO;

namespace Mi
{
	namespace Control
	{

		public class Reports
		{
			public static void Dispatch(HttpRequest request, HttpResponse response, Dictionary<String, String> querys)
			{
				String nombre = null;
				String format = null;
				DataSet[] dataSets = null;
				ReportViewer reportViewer = null;
				ReportDataSource reportDataSource = null;
				Warning[] warnings = null;
				string[] streams = null;
				string mimeType = null;
				string encoding = null;
				string fileNameExtension = null;
				byte[] bytes = null;
             
				try
				{
					if (request.Params["nombre"] == null) throw new ArgumentException("Se debe especificar el nombre del reporte");
					else nombre = request.Params["nombre"];

					if (request.Params["format"].Equals("EXCEL")) format = "EXCEL";
					else if (request.Params["format"].Equals("WORD")) format = "WORD";
					else format = "PDF";

					reportViewer = new ReportViewer();
					reportViewer.ProcessingMode = Microsoft.Reporting.WebForms.ProcessingMode.Local;
					reportViewer.LocalReport.ReportPath = "reports\\" + nombre + ".rdl";


					dataSets = AJAX.ExecuteStoreProcedures(request.Params["DATA"], querys, null, null);

					foreach (DataSet dataSet in dataSets)
						for (int i = 0; i < dataSet.Tables.Count; i++)
						{
							reportDataSource = new ReportDataSource();
							reportDataSource.Name = "DataSet" + (reportViewer.LocalReport.DataSources.Count + 1);
							reportDataSource.Value = dataSet.Tables[i];
							reportViewer.LocalReport.DataSources.Add(reportDataSource);

						}
					bytes = reportViewer.LocalReport.Render(format, null, out mimeType, out encoding, out fileNameExtension, out streams, out warnings);
					if (request.Params["toFile"] == "S")
						response.Output.Write(JSON.Serialize(Files.Write(request.Params["idsesion"], new Files.File(null, nombre + "." + fileNameExtension, bytes.Length, mimeType, bytes), null, null).idfile));
					else
					{
						response.ContentType = mimeType;
						response.AddHeader("Content-disposition", "attachment; filename=" + nombre + "." + fileNameExtension);
						response.OutputStream.Write(bytes, 0, bytes.Length);
					}
				}
				catch (Exception exception)
				{
					if (request.Params["toFile"] == "S")
						response.Output.Write(AJAX.Exception(exception));
					else
					{
						String msg;
						if (exception.Message.IndexOf("EXCEPCION USUARIO:") < 0) msg = Config.DefaultErrorMessage;
						else msg = exception.Message.Replace("EXCEPCION SISTEMA:", "").Replace("EXCEPCION USUARIO:", "");
						response.Output.Write("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\"><head><title>Error en reporte DIETECH</title></head><body><table ;\"><table style=\"width:40%;\" align=\"center\" border=\"1\"><tr><td style=\"text-align:left; background-color:#900; color:white; font-weight:bold;\">Error en reporte</td></tr><tr><td style=\"text-align:left; padding:1cm;\">" + msg + "</td></tr></table></td></tr></table></body></html><!-- " + exception.Message + " --><!-- " + exception.StackTrace + " -->");

					}
                    response.Flush();
                    response.Close();
				}
			}

            public static void generateZip(HttpRequest request, HttpResponse response)
            {
                
                try
                {
                    if (request.Params["files"]==null) throw new ArgumentException("Se debe especificar los identificadores de los archivos a generar");

                    string[] files = request.Params["files"].Split(',');

                    string nfile = "temp_"+ DateTime.Now.ToString().Replace("/","").Replace(".","").Replace(" ","").Replace(":","")+".zip";
                    using (var fileStream = new FileStream( Files.Path + "\\"+nfile, FileMode.Create))
                    {
                        using (var archive = new ZipArchive(fileStream, ZipArchiveMode.Create, true))
                        {
                            for(int i=0;i<files.Length;i++)
                            {
                                var fPath = Files.Path + "\\" + files[i]+ ".dat";
                                var zipArchiveEntry = archive.CreateEntryFromFile(fPath, files[++i] + ".pdf");
                            }
                        }
                    }
                    response.ContentType = "application/zip";
                    response.AddHeader("Content-disposition", "attachment; filename=" + nfile);
                    response.WriteFile(Files.Path + "\\" + nfile);
                }
                catch (Exception exception)
                {
                    response.Output.Write(AJAX.Exception(exception));
                }
            }
		}


	}
}
