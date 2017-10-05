using System;
using System.IO;
using System.Text;
using System.Web.Script.Serialization;
using System.Collections;
using System.Collections.Generic;

namespace Mi
{
	public class Configuracion
	{
		private String path = null;
		private String json = null;
		private Object data = null;

		public string Path { get => path; }
		public string JSON { get => json; }
		public object Data { get => data;}

		private Configuracion() { }
		public Configuracion (String path){
			this.path = path;
			StreamReader streamReader = null;
			try
			{
				streamReader = new StreamReader(File.Open(this.path, FileMode.OpenOrCreate, FileAccess.Read), UTF8Encoding.UTF8);
				this.json = streamReader.ReadToEnd();
				this.data = (new JavaScriptSerializer()).Deserialize(json, Type.GetType("System.Object"));
			}
			finally
			{
				if (streamReader != null) try { streamReader.Close(); } catch { }
			}
		}
		public void Write(String json){
			StreamWriter streamWriter = null;
			try
			{
				this.data = (new JavaScriptSerializer()).Deserialize(json, data.GetType());
				this.json = json;
				streamWriter = new StreamWriter(File.Open(this.path, FileMode.Create, FileAccess.Write), UTF8Encoding.UTF8);
				streamWriter.Write(this.json);
			}
			finally
			{
				if (streamWriter != null) try { streamWriter.Close(); } catch { }
			}
		}
	}
}
