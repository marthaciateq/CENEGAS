using System;
using System.Data.Common;
using MySql.Data.MySqlClient;
using Mi.Control;

namespace Mi.Clases
{
	public class MiMySQLConnection :BD.MiDBConnection
	{
		private String connectionString = null;
		private MiMySQLConnection() { }
		public MiMySQLConnection(String key)
		{
			if (Config.GetConnectionString(key).Type != Config.ConnectionStringType.MYSQL) throw new Exception("No es una conexión MySQL.");
			this.connectionString = Config.GetConnectionString(key).Value;
		}
		public DbConnection Get()
		{
			return new MySqlConnection(this.connectionString);
		}
	}
}