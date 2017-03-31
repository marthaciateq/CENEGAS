using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace Mi
{
	namespace Control
	{
		public class HTTP
		{
			public static void GetStringParam(HttpRequest Request, HttpResponse Response, String paramName)
			{
				if (Request[paramName] == null) Response.Write("null");
				else Response.Write("'" + Request[paramName] + "'");
			}
			public static void GetIntParam(HttpRequest Request, HttpResponse Response, String paramName)
			{
				if (Request[paramName] == null) Response.Write("null");
				else Response.Write(Request[paramName]);
			}
		}
	}
}
