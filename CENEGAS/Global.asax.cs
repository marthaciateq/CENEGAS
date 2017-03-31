using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;
using System.IO;
using Mi.Control;
using Mi;
using System.Configuration;

namespace CENEGAS
{
    public class Global : System.Web.HttpApplication
    {

        protected void Application_Start(object sender, EventArgs e)
        {
            FileStream fileStream = null;
            byte[] connectionStrings = null;
            try
            {
                fileStream = File.OpenRead(HttpRuntime.AppDomainAppPath + "dbcs.png");
                connectionStrings = new byte[fileStream.Length];
                fileStream.Read(connectionStrings, 0, connectionStrings.Length);
                Config.Load(ConfigurationManager.AppSettings["DefaultErrorMessage"], HttpRuntime.AppDomainAppPath, Crypt.De(connectionStrings, ConfigurationManager.AppSettings["DBCS"]));
                Files.Path = ConfigurationManager.AppSettings["FilesPath"];
            }
            catch (Exception exception)
            {
                Config.ApplicationStartError = exception;
            }
            finally
            {
                if (fileStream != null) try { fileStream.Close(); }
                    catch { }
            }
        }

        protected void Session_Start(object sender, EventArgs e)
        {
            Config.WebHome = Request.Url.GetLeftPart(UriPartial.Authority);
        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {

        }

        protected void Application_AuthenticateRequest(object sender, EventArgs e)
        {
            if (Config.ApplicationStartError != null)
                Mi.Clases.Oops.Responder(Response, Config.ApplicationStartError);
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            Mi.Clases.Oops.Responder(Response, Server.GetLastError());
        }

        protected void Session_End(object sender, EventArgs e)
        {

        }

        protected void Application_End(object sender, EventArgs e)
        {

        }
    }
}