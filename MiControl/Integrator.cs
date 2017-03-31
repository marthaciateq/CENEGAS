using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using System.Data.Common;

namespace Mi.Control
{
	public class Integrator
	{
		private static void CreateTablaDestino(SqlConnection destino, String tablaDestino, DataTable metadata)
		{
			StringBuilder sql = new StringBuilder();
			String columnName = null;
			String dataType = null;
			String columnSize = null;
			int numericPrecision = -1;
			int numericScale = -1;
			int columnId = 0;
			SqlCommand sqlCommand = null;
			bool closeDestino = false;
			try
			{
				if (destino == null)
				{
					closeDestino = true;
					destino = BD.Connection("Admin");
				}
				sql.AppendLine("CREATE TABLE " + tablaDestino + " (");
				sql.AppendLine("idintegracion int");

				foreach (DataRow row in metadata.Rows)
				{
					columnName = row["ColumnName"].ToString();
					dataType = row["DataType"].ToString();
					columnSize = row["ColumnSize"].ToString();
					try
					{
						numericPrecision = Int32.Parse(row["NumericPrecision"].ToString());
					}
					catch
					{
						numericPrecision = -1;
					}
					try
					{
						numericScale = Int32.Parse(row["NumericScale"].ToString());
					}
					catch
					{
						numericScale = -1;
					}

					sql.Append(",");
					sql.Append(columnName);


					switch (dataType)
					{
						case "System.String":
							sql.AppendLine(" varchar(max) ");
							break;

						case "System.Int16":
						case "System.Int32":
						case "System.UInt32":
						case "System.Byte":
						case "System.Int64":
						case "System.UInt64":
							sql.AppendLine(" bigint ");
							break;
						case "System.Decimal":
						case "System.Double":
							sql.AppendLine(" float ");
							break;
						case "System.DateTime":
							sql.AppendLine(" datetime ");
							break;
						case "System.Byte[]":
							sql.AppendLine(" varbinary(max) ");
							break;
						default:
							sql.AppendLine(" varchar(max) ");
							break;

					}
					columnId++;
				}
				sql.AppendLine(")");
				sqlCommand = new SqlCommand(sql.ToString(), destino);
				sqlCommand.ExecuteNonQuery();
			}
			finally
			{
				if (closeDestino) try { destino.Close(); }
					catch { }
			}

		}
		private static DataTable CreateDataTable(DataTable metadata)
		{
			DataTable dataTable = new DataTable();
			dataTable.Columns.Add();
			foreach (DataRow dataRow in metadata.Rows)
			{
				dataTable.Columns.Add();
			}
			return dataTable;
		}
		public static int Copy(String origen, String query, SqlConnection destino, String tablaDestino)
		{
			bool createTablaDestino = false;
			int idintegracion = -1, idlog = -1;
			DbConnection dbConnectionOrigen = null;
			DbCommand dbCommand = null;
			DbDataReader dbDataReader = null;

			SqlCommand sqlCommand = null, sqlCommandLog = null;
			SqlDataReader sqlDataReader = null;

			SqlTransaction sqlTransaction = null;
			SqlBulkCopy sqlBulkCopy = null;
			DataTable dataTable = null;
			object[] row, completeRow;

			bool closeDestino = false;
			try
			{
				if (destino == null)
				{
					closeDestino = true;
					destino = BD.Connection("Admin");
				}
				sqlCommandLog = new SqlCommand(query);
				sqlCommandLog.Parameters.Add("origen", SqlDbType.VarChar).Value = origen;
				sqlCommandLog.Parameters.Add("tablaDestino", SqlDbType.VarChar).Value = tablaDestino;
				idlog=BD.LogInit(sqlCommandLog, destino);
				dbConnectionOrigen = BD.DBConnection(origen);
				dbCommand = dbConnectionOrigen.CreateCommand();
				dbCommand.CommandText = query;
				dbDataReader = dbCommand.ExecuteReader();

				sqlCommand = new SqlCommand("select count(*) from sys.tables where name='" + tablaDestino + "'", destino);
				sqlDataReader = sqlCommand.ExecuteReader();
				sqlDataReader.Read();
				if (sqlDataReader.GetInt32(0) == 0) createTablaDestino = true;
				sqlDataReader.Close();

				idintegracion = BD.KeysNext("integraciones.idintegracion", null);

				sqlCommand = new SqlCommand("insert into integraciones values(@idintegracion, @origen, @destino, @query, getutcdate(), null, null)", destino);
				sqlCommand.Parameters.Add("@idintegracion", SqlDbType.Int).Value = idintegracion;
				sqlCommand.Parameters.Add("@origen", SqlDbType.VarChar).Value = dbConnectionOrigen.DataSource + "(" + dbConnectionOrigen.Database + ")";
				sqlCommand.Parameters.Add("@destino", SqlDbType.VarChar).Value = destino.DataSource + "(" + destino.Database + "." + tablaDestino + ")";
				sqlCommand.Parameters.Add("@query", SqlDbType.VarChar).Value = query;
				sqlCommand.ExecuteNonQuery();

				if (createTablaDestino) CreateTablaDestino(destino, tablaDestino, dbDataReader.GetSchemaTable());

				sqlTransaction = destino.BeginTransaction();
				sqlBulkCopy = new SqlBulkCopy(destino, SqlBulkCopyOptions.Default, sqlTransaction);
				sqlBulkCopy.BatchSize = 100;
				sqlBulkCopy.DestinationTableName = tablaDestino;
				dataTable = CreateDataTable(dbDataReader.GetSchemaTable());
				while (dbDataReader.Read())
				{
					row = new object[dbDataReader.GetSchemaTable().Rows.Count];
					dbDataReader.GetValues(row);
					completeRow = new object[dbDataReader.GetSchemaTable().Rows.Count + 1];
					completeRow[0] = idintegracion;
					row.CopyTo(completeRow, 1);
					dataTable.Rows.Add(completeRow);
					if (dataTable.Rows.Count == sqlBulkCopy.BatchSize)
					{
						sqlBulkCopy.WriteToServer(dataTable);
						dataTable = dataTable = CreateDataTable(dbDataReader.GetSchemaTable());
					}
				}
				if (dataTable.Rows.Count > 0)
				{
					sqlBulkCopy.BatchSize = dataTable.Rows.Count;
					sqlBulkCopy.WriteToServer(dataTable);
				}
				sqlTransaction.Commit();

				sqlCommand = new SqlCommand("update integraciones set ffinal=getutcdate() where idintegracion=@idintegracion", destino);
				sqlCommand.Parameters.Add("@idintegracion", SqlDbType.Int).Value = idintegracion;
				sqlCommand.ExecuteNonQuery();
				BD.LogOk(idlog, destino);
				return idintegracion;
			}
			catch (Exception ex)
			{
				BD.LogException(idlog, ex, destino);
				if (sqlTransaction != null) try { sqlTransaction.Rollback(); }
					catch { }
				try
				{
					sqlCommand = new SqlCommand("update integraciones set ffinal=getdate(), error=@error where idintegracion=@idintegracion", destino);
					sqlCommand.Parameters.Add("@idintegracion", SqlDbType.Int).Value = idintegracion;
					sqlCommand.Parameters.Add("@error", SqlDbType.VarChar).Value = ex.Message;
					sqlCommand.ExecuteNonQuery();
				}
				catch { }
				throw ex;
			}
			finally
			{
				if (sqlDataReader != null) try { sqlDataReader.Close(); }
					catch { }
				if (dbDataReader != null) try { dbDataReader.Close(); }
					catch { }
				if (dbConnectionOrigen != null) try { dbConnectionOrigen.Close(); }
					catch { }
				if (closeDestino) try { destino.Close(); }
					catch { }
			}
		}
		public static int Integrar(String origen, String query, String tablaDestino, String serviceName, SqlConnection sqlConnectionAdmin, SqlConnection sqlConnection)
		{
			int idintegracion = -1;
			Dictionary<String, Object> storeProcedure = null;
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
				idintegracion = Mi.Control.Integrator.Copy(origen, query, sqlConnectionAdmin, tablaDestino);
				storeProcedure = new Dictionary<String, Object>();
				storeProcedure.Add("NAME", serviceName);
				storeProcedure.Add("idintegracion", idintegracion);
				BD.ExecuteService(storeProcedure, null, sqlConnectionAdmin, sqlConnection);
				return idintegracion;
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
