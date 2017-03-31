using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;

namespace Mi.Control
{
	public class Files
	{
		public struct File
		{
			public String idfile;
			public String name;
			public long clength;
			public String ctype;
			public byte[] data;
			public File(String idfile, String name, long clength, String ctype, byte[] data)
			{
				this.idfile = idfile;
				this.name = name;
				this.clength = clength;
				this.ctype = ctype;
				this.data = data;
			}
		}
		private static String extension = ".dat";
		private static String path = null;
		public static String Path
		{
			get { return Files.path; }
			set { Files.path = value; }
		}
		public static Files.File Write(String idsesion, Files.File file, SqlConnection sqlConnectionAdmin, SqlConnection sqlConnection)
		{
			Dictionary<String, Object> storeProcedure = new Dictionary<string, object>();
			String tmpname = null;
			FileStream fileStream = null;
			bool closeAdminConnection = false;
			bool closeConnection = false;
			try
			{
				if (sqlConnectionAdmin == null)
				{
					closeAdminConnection = true;
					sqlConnectionAdmin = BD.Connection("Admin");
				}
				if (sqlConnection == null)
				{
					closeConnection = true;
					sqlConnection = BD.Connection();
				}
				if (Files.path != null)
				{
					if (!System.IO.Directory.Exists(Files.path)) throw new Exception("No existe la ruta para Files");
					tmpname = Files.path + "\\" + DateTime.Now.Ticks.ToString() + ".tmp";
					fileStream = System.IO.File.OpenWrite(tmpname);
					fileStream.Write(file.data, 0, file.data.Length);
					fileStream.Close();
					fileStream = null;
				}
				storeProcedure.Add("NAME", "sps_files_write");
				storeProcedure.Add("idsesion", idsesion);
				storeProcedure.Add("name", file.name);
				storeProcedure.Add("clength", file.clength);
				storeProcedure.Add("ctype", file.ctype);
				if (Files.path == null) storeProcedure.Add("data", file.data);
				file.idfile = (String)BD.ExecuteService(storeProcedure, null, sqlConnectionAdmin, sqlConnection).Tables[0].Rows[0].ItemArray[0];
				if (tmpname != null) System.IO.File.Move(tmpname, Files.path + "\\" + file.idfile + Files.extension);
				return file;
			}
			finally
			{
				if (fileStream != null) try { fileStream.Close(); }
					catch { }
				if (tmpname != null)
					if (System.IO.File.Exists(tmpname))
						try { System.IO.File.Delete(tmpname); }
						catch { }
				if (closeAdminConnection)
					try
					{
						sqlConnectionAdmin.Close();
					}
					catch { }
				if (closeConnection)
					try
					{
						sqlConnection.Close();
					}
					catch { }
			}
		}
		public static Files.File[] Read(String idsesion, String idfiles, SqlConnection sqlConnectionAdmin, SqlConnection sqlConnection)
		{
			Dictionary<String, Object> storeProcedure = new Dictionary<string, object>();
			DataSet dataSet = null;
			FileStream fileStream = null;
			Files.File[] files = null;
			bool closeAdminConnection = false;
			bool closeConnection = false;
			try
			{
				if (sqlConnectionAdmin == null)
				{
					closeAdminConnection = true;
					sqlConnectionAdmin = BD.Connection("Admin");
				}
				if (sqlConnection == null)
				{
					closeConnection = true;
					sqlConnection = BD.Connection();
				}
				storeProcedure.Add("NAME", "sps_files_read");
				storeProcedure.Add("idsesion", idsesion);
				storeProcedure.Add("idfiles", idfiles);
				dataSet = BD.ExecuteService(storeProcedure, null, sqlConnectionAdmin, sqlConnection);
				files = new Files.File[dataSet.Tables[0].Rows.Count];
				for (int i = 0; i < dataSet.Tables[0].Rows.Count; i++)
				{
					files[i].idfile = (String)dataSet.Tables[0].Rows[i].ItemArray[0];
					files[i].name = (String)dataSet.Tables[0].Rows[i].ItemArray[1];
					files[i].clength = (long)dataSet.Tables[0].Rows[i].ItemArray[2];
					files[i].ctype = (String)dataSet.Tables[0].Rows[i].ItemArray[3];
					if (Files.path == null) files[i].data = (byte[])dataSet.Tables[0].Rows[i].ItemArray[4];
					else
					{
						files[i].data = new byte[files[i].clength];
						fileStream = System.IO.File.OpenRead(Files.path + "\\" + files[i].idfile + Files.extension);
						for (int j = 0; j < files[i].clength; j++)
							files[i].data[j] = (byte)fileStream.ReadByte();
						fileStream.Close();
						fileStream = null;
					}
				}
				return files;
			}
			finally
			{
				if (fileStream != null) try { fileStream.Close(); }
					catch { }
				if (closeAdminConnection)
					try
					{
						sqlConnectionAdmin.Close();
					}
					catch { }
				if (closeConnection)
					try
					{
						sqlConnection.Close();
					}
					catch { }
			}
		}
	}
}
