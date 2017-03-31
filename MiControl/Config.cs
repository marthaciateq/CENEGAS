using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mi
{
	namespace Control
	{
		public class Config
		{
			private static Exception applicationStartError = null;
			private static String appPath = null;
			private static String defaultErrorMessage = null;
			private static String webHome = null;
			private static Dictionary<String, ConnectionString> connectionStrings = new Dictionary<String, ConnectionString>();
			public enum ConnectionStringType { MSSQL, MYSQL, ORCL, SMTP }
			public struct ConnectionString
			{
				private ConnectionStringType type;
				private String value;
				public ConnectionString(ConnectionStringType type, String value)
				{
					this.type = type;
					this.value = value;
				}
				public ConnectionStringType Type
				{
					get { return this.type; }
					set { this.type = value; }
				}
				public String Value
				{
					get { return this.value; }
					set { this.value = value; }
				}
			}
			public static Exception ApplicationStartError
			{
				get { return Config.applicationStartError; }
				set { Config.applicationStartError = value; }
			}
			public static String AppPath
			{
				get { return Config.appPath; }
			}
			public static String DefaultErrorMessage
			{
				get { return Config.defaultErrorMessage; }
			}
			public static String WebHome
			{
				get { return Config.webHome; }
				set { Config.webHome = value; }
			}
			public static void Load(String defaultErrorMessage, String appPath, String connectionStrings)
			{
				Config.defaultErrorMessage = defaultErrorMessage;
				Config.appPath = appPath;
				if (connectionStrings == null) throw new Exception("Error al cargar las cadenas de conexión.");
				String[] lineas = connectionStrings.Split(new String[] { "\n" }, StringSplitOptions.RemoveEmptyEntries); ;
				if (lineas.Length < 2) throw new Exception("Cadenas de conexión cargadas: " + lineas.Length);
				int indexIgual, indexComa;
				String key, stype, value;
				ConnectionStringType type;
				for (int i = 0; i < lineas.Length; i++)
				{
					indexIgual = lineas[i].IndexOf('=');
					indexComa = lineas[i].IndexOf(',');
					if (indexIgual < 0 || indexComa < 0 || indexIgual > indexComa) throw new Exception("La cadena de conexión en la línea " + (i + 1) + " es incorrecta.");
					key = lineas[i].Substring(0, indexIgual);
					stype = lineas[i].Substring(indexIgual + 1, indexComa - indexIgual - 1);
					value = lineas[i].Substring(indexComa + 1);
					if (key.Length == 0) throw new Exception("La llave de la cadena de conexión en la línea " + (i + 1) + " es incorrecta.");
					if (stype == "MSSQL") type = ConnectionStringType.MSSQL;
					else if (stype == "MYSQL") type = ConnectionStringType.MYSQL;
					else if (stype == "ORCL") type = ConnectionStringType.ORCL;
					else if (stype == "SMTP") type = ConnectionStringType.SMTP;
					else throw new Exception("El tipo [" + stype + "] de la cadena de conexión en la línea " + (i + 1) + " es incorrecto."); ;
					if (value.Length == 0) throw new Exception("El valor de la cadena de conexión en la línea " + (i + 1) + " es incorrecto.");
					Config.connectionStrings.Add(key, new ConnectionString(type, value));
				}
			}
			public static ConnectionString GetConnectionString(String key)
			{
				if (!Config.connectionStrings.ContainsKey(key)) throw new Exception("La cadena de conexión " + key + " no existe.");

				return Config.connectionStrings[key];
			}
		}
	}
}
