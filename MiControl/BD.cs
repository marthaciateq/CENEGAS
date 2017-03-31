using System;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace Mi
{
	namespace Control
	{
		public class BD
		{
			private static Dictionary<String, MiDBConnection> miDBConnections = new Dictionary<String, MiDBConnection>();
			private static String LogName(String commandText)
			{
				Match match = null;
				Regex regex = new Regex(@"^ *execute *\w*", RegexOptions.IgnoreCase);
				match = regex.Match(commandText);
				if (match.Success)
				{
					commandText = match.Value;
					regex = new Regex(@"^ *execute *", RegexOptions.IgnoreCase);
					match = regex.Match(commandText);
					commandText = commandText.Substring(match.Index + match.Length);
				}
				return commandText;
			}
			private static DataSet Execute(SqlCommand sqlCommand, SqlConnection sqlConnectionAdmin, SqlConnection sqlConnection)
			{
				SqlDataAdapter sqlDataAdapter = null;
				DataSet dataSet = new DataSet();
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
					sqlCommand.CommandTimeout = 300;
					sqlCommand.Connection = sqlConnection;
					sqlDataAdapter = new SqlDataAdapter(sqlCommand);
					sqlDataAdapter.Fill(dataSet);
					return dataSet;
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
			private static SqlCommand GetSqlCommandFromStoreProcedure(String storeProcedureName, Dictionary<string, object> parameters, SqlConnection sqlConnectionAdmin)
			{
				SqlCommand sqlCommand = null;
				SqlDataReader sqlDataReader = null;
				SqlParameter sqlParameter = null;
				bool closeConnectionAdmin = false;
				try
				{
					if (sqlConnectionAdmin == null)
					{
						closeConnectionAdmin = true;
						sqlConnectionAdmin = BD.Connection("Admin");
					}
					sqlCommand = new SqlCommand("select b.name parameterName, c.name typeName from sys.procedures a inner join sys.parameters b on a.object_id=b.object_id inner join sys.types c on b.system_type_id=c.system_type_id where a.name=@storeProcedureName order by b.parameter_id", sqlConnectionAdmin);
					sqlCommand.Parameters.Add("@storeProcedureName", SqlDbType.VarChar).Value = storeProcedureName;
					sqlDataReader = sqlCommand.ExecuteReader();
					sqlCommand = new SqlCommand();
					sqlCommand.CommandText = "execute " + storeProcedureName + " ";
					while (sqlDataReader.Read())
					{
						sqlParameter = new SqlParameter();
						sqlCommand.Parameters.Add(sqlParameter);
						sqlParameter.ParameterName = sqlDataReader.GetString(0);

						if (!parameters.ContainsKey(sqlParameter.ParameterName.Substring(1))) sqlParameter.Value = System.DBNull.Value;
						else if (parameters[sqlParameter.ParameterName.Substring(1)] == null) sqlParameter.Value = System.DBNull.Value;
						else if (sqlDataReader.GetString(1) == "varchar" && parameters[sqlParameter.ParameterName.Substring(1)].GetType().IsArray) sqlParameter.Value = BD.TableToString((Array)parameters[sqlParameter.ParameterName.Substring(1)]);
						else sqlParameter.Value = parameters[sqlParameter.ParameterName.Substring(1)];

						switch (sqlDataReader.GetString(1))
						{
							case "bigint": sqlParameter.SqlDbType = SqlDbType.BigInt; break;
							case "binary": sqlParameter.SqlDbType = SqlDbType.Binary; break;
							case "bit": sqlParameter.SqlDbType = SqlDbType.Bit; break;
							case "char": sqlParameter.SqlDbType = SqlDbType.Char; break;
							case "date": sqlParameter.SqlDbType = SqlDbType.Date; break;
							case "datetime": sqlParameter.SqlDbType = SqlDbType.DateTime; break;
							case "decimal": sqlParameter.SqlDbType = SqlDbType.Decimal; break;
							case "float": sqlParameter.SqlDbType = SqlDbType.Float; break;
							case "image": sqlParameter.SqlDbType = SqlDbType.Image; break;
							case "int": sqlParameter.SqlDbType = SqlDbType.Int; break;
							case "money": sqlParameter.SqlDbType = SqlDbType.Money; break;
							case "nchar": sqlParameter.SqlDbType = SqlDbType.NChar; break;
							case "ntext": sqlParameter.SqlDbType = SqlDbType.NText; break;
							case "numeric": sqlParameter.SqlDbType = SqlDbType.Decimal; break;
							case "nvarchar": sqlParameter.SqlDbType = SqlDbType.NVarChar; break;
							case "real": sqlParameter.SqlDbType = SqlDbType.Real; break;
							case "smalldatetime": sqlParameter.SqlDbType = SqlDbType.SmallDateTime; break;
							case "smallint": sqlParameter.SqlDbType = SqlDbType.SmallInt; break;
							case "smallmoney": sqlParameter.SqlDbType = SqlDbType.SmallMoney; break;
							case "text": sqlParameter.SqlDbType = SqlDbType.Text; break;
							case "timestamp": sqlParameter.SqlDbType = SqlDbType.Timestamp; break;
							case "tinyint": sqlParameter.SqlDbType = SqlDbType.TinyInt; break;
							case "uniqueidentifier": sqlParameter.SqlDbType = SqlDbType.UniqueIdentifier; break;
							case "varbinary": sqlParameter.SqlDbType = SqlDbType.VarBinary; break;
							case "varchar": sqlParameter.SqlDbType = SqlDbType.VarChar; break;
							case "xml": sqlParameter.SqlDbType = SqlDbType.Xml; break;
						}
						sqlCommand.CommandText = sqlCommand.CommandText + sqlParameter.ParameterName + ",";
					}
					sqlDataReader.Close();
					if (sqlCommand.CommandText.Substring(sqlCommand.CommandText.Length - 1, 1).Equals(","))
						sqlCommand.CommandText = sqlCommand.CommandText.Substring(0, sqlCommand.CommandText.Length - 1);
					return sqlCommand;
				}
				finally
				{
					if (sqlDataReader != null)
						try
						{
							sqlDataReader.Close();
						}
						catch { }
					if (closeConnectionAdmin) try { sqlConnectionAdmin.Close(); }
						catch { }
				}
			}
			private static String TableToString(Array table)
			{
				if (table.Length > 0) if (table.GetValue(0) == null || !table.GetValue(0).GetType().IsArray)
					{
						Object[] tmp = new Object[] { table };
						table = (Array)tmp;
					}

				StringBuilder s = new StringBuilder();
				for (int i = 0; i < table.Length; i++)
				{
					Array row = (Array)table.GetValue(i);
					for (int j = 0; j < row.Length; j++)
						if (row.GetValue(j) == null) s.Append("|");
						else if (row.GetValue(j).GetType().Namespace + "." + row.GetValue(j).GetType().Name == "System.DateTime")
							s.Append(JSON.Serialize(row.GetValue(j)).Replace("\"", "") + "|");
						else s.Append(row.GetValue(j).ToString().Replace("<PIPE>", "<PIPE2>").Replace("|", "<PIPE>") + "|");
				}
				return s.ToString();
			}
			public interface MiDBConnection
			{
				DbConnection Get();
			}
			public static void AddDBConnection(String key, MiDBConnection miDBConnection)
			{
				BD.miDBConnections.Add(key, miDBConnection);
			}
			public static int KeysNext(String key, SqlConnection sqlConnectionAdmin)
			{
				SqlCommand sqlCommand = null;
				bool closeConnectionAdmin = false;
				try
				{
					if (sqlConnectionAdmin == null)
					{
						closeConnectionAdmin = true;
						sqlConnectionAdmin = BD.Connection("Admin");
					}
					sqlCommand = new SqlCommand("execute sp_keys_next @key, 'S'", sqlConnectionAdmin);
					sqlCommand.Parameters.Add("@key", SqlDbType.VarChar).Value = key;
					return (int)sqlCommand.ExecuteScalar();
				}
				finally
				{
					if (closeConnectionAdmin) try { sqlConnectionAdmin.Close(); }
						catch { }
				}
			}
			public static DbConnection DBConnection(String key)
			{
				if (!miDBConnections.ContainsKey(key)) throw new Exception("No existe la DBConnection: " + key);
				DbConnection dbCoonection = BD.miDBConnections[key].Get();
				dbCoonection.Open();
				return dbCoonection;
			}
			public static SqlConnection Connection(String key)
			{
				SqlConnection sqlConnection = null;
				Config.ConnectionString connectionString = Config.GetConnectionString(key);
				if (connectionString.Type == Config.ConnectionStringType.MSSQL)
					sqlConnection = new SqlConnection(connectionString.Value);
				sqlConnection.Open();
				return sqlConnection;
			}
			public static SqlConnection Connection()
			{
				return BD.Connection("Default");
			}
			public static int LogInit(SqlCommand sqlCommand, SqlConnection sqlConnectionAdmin)
			{
				int idlog = -1;
				SqlCommand cmd = new SqlCommand("execute sp_log_begin @name, @parameters", sqlConnectionAdmin);
				ArrayList table = new ArrayList();

				for (int i = 0; i < sqlCommand.Parameters.Count; i++)
					table.Add(new Object[] { sqlCommand.Parameters[i].ParameterName, sqlCommand.Parameters[i].Value });

				cmd.Parameters.Add("@name", SqlDbType.VarChar).Value = BD.LogName(sqlCommand.CommandText);
				cmd.Parameters.Add("@parameters", SqlDbType.VarChar).Value = BD.TableToString(table.ToArray());
				idlog = (int)cmd.ExecuteScalar();
				return idlog;
			}
			public static void LogOk(int idlog, SqlConnection sqlConnectionAdmin)
			{
				SqlCommand cmd = new SqlCommand("execute sp_log_ok @idlog", sqlConnectionAdmin);
				cmd.Parameters.Add("@idlog", SqlDbType.Int).Value = idlog;
				cmd.ExecuteNonQuery();
			}
			public static void LogException(int idlog, Exception exception, SqlConnection sqlConnectionAdmin)
			{
				SqlCommand cmd = new SqlCommand("execute sp_log_exception @idlog, @exception", sqlConnectionAdmin);
				cmd.Parameters.Add("@idlog", SqlDbType.Int).Value = idlog;
				cmd.Parameters.Add("@exception", SqlDbType.VarChar).Value = exception.Message;
				cmd.ExecuteNonQuery();
			}
			public static DataSet ExecuteService(Dictionary<String, Object> storeProcedure, Dictionary<String, String> querys, SqlConnection sqlConnectionAdmin, SqlConnection sqlConnection)
			{
				String query;
				SqlCommand sqlCommand = null;
				DataSet dataSet = new DataSet();
				String[] rowSpecifications;
				int tableIndex;
				String fromColumn, fromColumnValue, toColumn, idsesionColumnValue;
				DataColumn dataFromColumn, dataToColumn, dataIdsesionColumn;
				Files.File[] files = null;
				int idlog = -1;
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
					sqlCommand = BD.GetSqlCommandFromStoreProcedure(storeProcedure["NAME"].ToString(), storeProcedure, sqlConnectionAdmin);
					idlog = BD.LogInit(sqlCommand, sqlConnectionAdmin);
					//	Integra datos de otra fuente y pasa como 
					//	parámetro el @idintegracion al SP
					if (storeProcedure.ContainsKey("INTEGRARorigen") && storeProcedure.ContainsKey("INTEGRARquery") && storeProcedure.ContainsKey("INTEGRARtablaDestino"))
					{
						if (querys == null || !querys.ContainsKey((String)storeProcedure["INTEGRARquery"])) throw new Exception("No existe el query.");
						query = querys[(String)storeProcedure["INTEGRARquery"]];
						foreach (String key in storeProcedure.Keys)
							if (key.Length >= 8 && key.Substring(0, 8) == "INTEGRAR")
								query = query.Replace(key, (String)storeProcedure[key]);
						sqlCommand.Parameters["@idintegracion"].Value = Mi.Control.Integrator.Copy((String)storeProcedure["INTEGRARorigen"], query, sqlConnectionAdmin, (String)storeProcedure["INTEGRARtablaDestino"]);
					}

					//	Ejecuta el SP
					dataSet = BD.Execute(sqlCommand, sqlConnectionAdmin, sqlConnection);

					//	Agrega al DataSet en la tabla especificada por el primer caracter
					//	del dato obtenido por el segundo caracter
					//	a la columna definida por el tercer carcater
					//	el código de barras en el formato especificado por el cuarto caracter
					foreach (String key in storeProcedure.Keys)
					{
						if (key.Length >= 7 && key.Substring(0, 7) == "BARCODE")
							if (storeProcedure[key].ToString() != null)
							{
								rowSpecifications = storeProcedure[key].ToString().Split(new char[] { ',' });
								if (rowSpecifications.Length == 4)
								{
									tableIndex = int.Parse(rowSpecifications[0]);
									fromColumn = rowSpecifications[1];
									toColumn = rowSpecifications[2];
									if (tableIndex < dataSet.Tables.Count)
										if (dataSet.Tables[tableIndex].Columns.Contains(fromColumn) && dataSet.Tables[tableIndex].Columns.Contains(toColumn))
										{
											dataFromColumn = dataSet.Tables[tableIndex].Columns[fromColumn];
											dataToColumn = dataSet.Tables[tableIndex].Columns[toColumn];
											for (int i = 0; i < dataSet.Tables[tableIndex].Rows.Count; i++)
												if (!dataSet.Tables[tableIndex].Rows[i].IsNull(dataFromColumn))
												{
													fromColumnValue = (String)dataSet.Tables[tableIndex].Rows[i].ItemArray[dataFromColumn.Ordinal];
													if (rowSpecifications[3] == "Code39") dataSet.Tables[tableIndex].Rows[i].SetField(dataToColumn, BarCode.Code39(fromColumnValue));
													else if (rowSpecifications[3] == "Pdf417") dataSet.Tables[tableIndex].Rows[i].SetField(dataToColumn, BarCode.Pdf417(fromColumnValue));
												}
										}
								}
							}

						if (key.Length >= 4 && key.Substring(0, 4) == "FILE")
							if (storeProcedure[key].ToString() != null)
							{
								rowSpecifications = storeProcedure[key].ToString().Split(new char[] { ',' });
								if (rowSpecifications.Length == 3)
								{
									tableIndex = int.Parse(rowSpecifications[0]);
									fromColumn = rowSpecifications[1];
									toColumn = rowSpecifications[2];
									if (tableIndex < dataSet.Tables.Count)
										if (dataSet.Tables[tableIndex].Columns.Contains(fromColumn) && dataSet.Tables[tableIndex].Columns.Contains(toColumn) && dataSet.Tables[tableIndex].Columns.Contains("idsesion"))
										{
											dataFromColumn = dataSet.Tables[tableIndex].Columns[fromColumn];
											dataToColumn = dataSet.Tables[tableIndex].Columns[toColumn];
											dataIdsesionColumn = dataSet.Tables[tableIndex].Columns["idsesion"];
											for (int i = 0; i < dataSet.Tables[tableIndex].Rows.Count; i++)
												if (!dataSet.Tables[tableIndex].Rows[i].IsNull(dataFromColumn) && !dataSet.Tables[tableIndex].Rows[i].IsNull(dataIdsesionColumn))
												{
													fromColumnValue = (String)dataSet.Tables[tableIndex].Rows[i].ItemArray[dataFromColumn.Ordinal];
													idsesionColumnValue = (String)dataSet.Tables[tableIndex].Rows[i].ItemArray[dataIdsesionColumn.Ordinal];
													files = Files.Read(idsesionColumnValue, fromColumnValue, sqlConnectionAdmin, sqlConnection);
													if (files.Length == 1)
														dataSet.Tables[tableIndex].Rows[i].SetField(dataToColumn, files[0].data);
												}
										}
								}
							}
					}
					//	Envía un correo por cada registro devuelto en el DataSet
					//	que tenga definidas las columnas MailTo, 
					//	MailSubject y (MailBody o MailTemplate)
					SMTP.Send(dataSet);
					BD.LogOk(idlog, sqlConnectionAdmin);
					return dataSet;
				}
				catch (Exception exception)
				{
					BD.LogException(idlog, exception, sqlConnectionAdmin);
					throw exception;
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
		}
	}
}