using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Threading;
namespace Mi
{
	namespace Control
	{
		public class AJAX
		{
			public static String Exception(Exception exception)
			{
				bool excepcionUsuario = false;
				String mensajeUsuario = null, mensajeSistema = null;
				if (exception.Message.IndexOf("EXCEPCION USUARIO:") >= 0) excepcionUsuario = true;
				mensajeSistema = exception.Message.Replace("EXCEPCION SISTEMA:", "").Replace("EXCEPCION USUARIO:", "");
				if (excepcionUsuario) mensajeUsuario = mensajeSistema;
				else mensajeUsuario = Config.DefaultErrorMessage;

				Dictionary<String, Object> error = new Dictionary<String, Object>();
				error.Add("type", "EXCEPTION");
				error.Add("mensajeUsuario", mensajeUsuario);
				error.Add("mensajeSistema", mensajeSistema);
				return JSON.Serialize(error);
			}
			public static Dictionary<String, Object>[] DecodeStoreProcedures(String paramDATA)
			{
				Object DATA = null;
				ArrayList storeProcedures = null;

				if (paramDATA == null) throw new Exception("Param DATA nulo.");
				DATA = JSON.Deserialize(paramDATA);
				storeProcedures = new ArrayList();
				if (DATA.GetType().Namespace + "." + DATA.GetType().Name == "System.Collections.Generic.Dictionary`2")
					storeProcedures.Add(DATA);
				else if (DATA.GetType().IsArray)
				{
					Array array = (Array)DATA;
					for (int i = 0; i < array.Length; i++)
					{
						if (array.GetValue(i).GetType().Namespace + "." + array.GetValue(i).GetType().Name != "System.Collections.Generic.Dictionary`2")
							throw new Exception("El Store Procedure no es un objeto System.Collections.Generic.Dictionary`2.");
						storeProcedures.Add(array.GetValue(i));
					}
				}
				Dictionary<String, Object>[] storeProceduresArray = new Dictionary<String, Object>[storeProcedures.Count];
				for (int i = 0; i < storeProcedures.Count; i++)
					storeProceduresArray[i] = (Dictionary<String, Object>)storeProcedures[i];
				return storeProceduresArray;
			}
			public static DataSet[] ExecuteStoreProcedures(String DATA, Dictionary<String, String> querys, SqlConnection sqlConnectionAdmin, SqlConnection sqlConnection)
			{
				Dictionary<String, Object>[] storeProcedures = null;
				DataSet dataSet = null;
				ArrayList dataSets = null;
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
					storeProcedures = AJAX.DecodeStoreProcedures(DATA);
					dataSets = new ArrayList();
					foreach (Dictionary<String, Object> storeProcedure in storeProcedures)
					{
						dataSet = BD.ExecuteService(storeProcedure, querys, sqlConnectionAdmin, sqlConnection);
						dataSets.Add(dataSet);
					}
					DataSet[] dataSetsArray = new DataSet[dataSets.Count];
					for (int i = 0; i < dataSets.Count; i++)
						dataSetsArray[i] = (DataSet)dataSets[i];
					return dataSetsArray;
				}
				finally
				{
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
			public static void Dispatch(HttpRequest request, HttpResponse response, Dictionary<String, String> querys)
			{
				DataSet[] dataSets = null;
				ArrayList resultTables = new ArrayList(), resultTable = null;
				Dictionary<String, Object> resultRow = null;
				try
				{
					dataSets = AJAX.ExecuteStoreProcedures(request.Params["DATA"], querys, null, null);
					
					foreach (DataSet dataSet in dataSets)
					{
						foreach (DataTable table in dataSet.Tables)
						{
							resultTable = new ArrayList();
							foreach (DataRow row in table.Rows)
							{
								resultRow = new Dictionary<String, Object>();
								foreach (DataColumn col in table.Columns)
									resultRow.Add(col.ColumnName, row.ItemArray[col.Ordinal]);
								resultTable.Add(resultRow);
							}
							resultTables.Add(resultTable.ToArray());
						}
					}
					if (resultTables.Count == 1) response.Output.Write(JSON.Serialize(resultTables[0]));
					else if (resultTables.Count > 1) response.Output.Write(JSON.Serialize(resultTables.ToArray()));
				}
				catch (Exception exception)
				{
					response.Output.Write(AJAX.Exception(exception));
				}
			}
			public static void UploadFile(HttpRequest request, HttpResponse response)
			{
				ArrayList idfiles = new ArrayList();
				SqlConnection sqlConnection = null;
				SqlConnection sqlConnectionAdmin = null;
				Files.File file;
				try
				{
					sqlConnection = BD.Connection();
					sqlConnectionAdmin = BD.Connection("Admin");
					foreach (String key in request.Files)
					{
						file = new Files.File(null, request.Files[key].FileName, request.Files[key].ContentLength, request.Files[key].ContentType, new byte[request.Files[key].ContentLength]);
						if (file.name.LastIndexOf('\\') > 0)
							file.name = file.name.Substring(file.name.LastIndexOf('\\') + 1);
						for (int i = 0; i < file.clength; i++)
							file.data[i] = (byte)request.Files[key].InputStream.ReadByte();
						idfiles.Add(Files.Write(request.Params["idsesion"], file, sqlConnectionAdmin, sqlConnection).idfile);
					}
					if (idfiles.Count == 1) response.Output.Write(JSON.Serialize(idfiles[0]));
					else if (idfiles.Count > 1) response.Output.Write(JSON.Serialize(idfiles.ToArray()));
				}
				catch (Exception exception)
				{
					response.Output.Write(AJAX.Exception(exception));
				}
				finally
				{
					if (sqlConnection != null) try { sqlConnection.Close(); }
						catch { }
					if (sqlConnectionAdmin != null) try { sqlConnectionAdmin.Close(); }
						catch { }
				}
			}
		}
	}
}