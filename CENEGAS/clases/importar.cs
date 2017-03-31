using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


using System.IO;
using System.Data.OleDb;
using System.Data;
using System.Web.Configuration;

using System.Data.SqlClient;

using Mi.Control;



namespace cenegas.clases
{
    public class importar
    {
        private static Dictionary<string, System.Type> layoutFields = new Dictionary<string, Type>();
        private static string importsDirectory = WebConfigurationManager.AppSettings["importsDirectory"];

        // Inicia el proceso de importacion del archivo de mediciones
        public static void import(HttpPostedFile csvHours, HttpPostedFile csvSummary, DateTime initDate, DateTime finalDate, bool updateRecords, HttpResponse response)
        {
            Dictionary<string, object>  result = new Dictionary<string,object>();
            try {
                int taskTime;

                result.Add("success", true);

                DateTime start = DateTime.Now;

                importCSVFile(csvHours, csvSummary, initDate, finalDate, updateRecords);

                TimeSpan ts = DateTime.Now - start;

                int dif = ts.Seconds;

                response.Output.Write(JSON.Serialize(result));
            }
            catch (Exception e)
            {
                result.Add("success", false);

                response.Output.Write(JSON.Serialize(result));
            }
        
        }

        // Recibe un archivo CSV e importa sus registros a una tabla del servidor
        private static void importCSVFile(HttpPostedFile csvHours, HttpPostedFile csvSummary, DateTime initDate, DateTime finalDate, bool updateRecords)
        {
            const decimal _byte = 8; // bits
            const decimal KB = _byte * 1024;
            const decimal MB = KB * 1024;
            decimal FILE_MAX_LENGTH = MB * decimal.Parse(WebConfigurationManager.AppSettings["importsFILE_MAX_LENGTH"]);

            if (csvHours.ContentLength > FILE_MAX_LENGTH)
            {
                // Tamaño de archivo excedido
            }

            DataTable recordsByHour = new DataTable();
            DataTable summaryOfRecords = new DataTable();
            string hoursPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, importsDirectory);
            string summaryPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, importsDirectory);
            string hoursName = "";
            string summaryName = "";

            // Guardar el archivo de horarios
            saveFileInServer(ref csvHours, ref hoursPath);

            // Guardar el archivo de horarios
            saveFileInServer(ref csvSummary, ref summaryPath);

            hoursName = System.IO.Path.GetFileName(hoursPath);
            summaryName = System.IO.Path.GetFileName(summaryPath);

            // Se agrega un dia unicamente para hacer la comparación de registros < a fechaFinal
            finalDate = finalDate.AddDays(1);

            csvToDataTable(hoursPath, "SELECT * FROM " + hoursName + " WHERE   Fecha >= CDate('" + initDate.Year + "/0" + initDate.Month + "/0" + initDate.Day + "')   AND   fecha < CDate('" + finalDate.Year + "/0" + finalDate.Month + "/" + finalDate.Day + "') ", ref recordsByHour);
            csvToDataTable(summaryPath, "SELECT * FROM " + summaryName + " WHERE   Fecha >= CDate('" + initDate.Year + "/0" + initDate.Month + "/0" + initDate.Day + "')   AND   fecha < CDate('" + finalDate.Year + "/0" + finalDate.Month + "/" + finalDate.Day + "') ", ref summaryOfRecords);
            // Se restaura la fecha original
            finalDate = finalDate.AddDays(-1);

            // Eliminar las columas de más
            recordsByHour.Columns.RemoveAt(2); // Columna Descripcion del CSV
            //recordsByHour.Columns.RemoveAt(1); // Columna Nombre Alterno del CSV

            // Eliminar las columas de más
            summaryOfRecords.Columns.RemoveAt(2); // Columna Descripcion del CSV
            //summaryOfRecords.Columns.RemoveAt(1); // Columna Nombre Alterno del CSV

            recordsByHour.Columns[0].ColumnName = "punto";
            recordsByHour.Columns[1].ColumnName = "nombreAlterno";
            recordsByHour.Columns[2].ColumnName = "fecha";
            recordsByHour.Columns[3].ColumnName = "metano";
            recordsByHour.Columns[4].ColumnName = "bioxidoCarbono";

            recordsByHour.Columns[5].ColumnName = "nitrogeno";
            recordsByHour.Columns[6].ColumnName = "totalInertes";
            recordsByHour.Columns[7].ColumnName = "etano";
            recordsByHour.Columns[8].ColumnName = "tempRocio";
            recordsByHour.Columns[9].ColumnName = "humedad";

            recordsByHour.Columns[10].ColumnName = "poderCalorifico";
            recordsByHour.Columns[11].ColumnName = "indiceWoobe";
            recordsByHour.Columns[12].ColumnName = "acidoSulfhidrico";
            recordsByHour.Columns[13].ColumnName = "azufreTotal";
            recordsByHour.Columns[14].ColumnName = "oxigeno";


            summaryOfRecords.Columns[0].ColumnName = "punto";
            summaryOfRecords.Columns[1].ColumnName = "nombreAlterno";
            summaryOfRecords.Columns[2].ColumnName = "fecha";
            summaryOfRecords.Columns[3].ColumnName = "metano";
            summaryOfRecords.Columns[4].ColumnName = "bioxidoCarbono";

            summaryOfRecords.Columns[5].ColumnName = "nitrogeno";
            summaryOfRecords.Columns[6].ColumnName = "totalInertes";
            summaryOfRecords.Columns[7].ColumnName = "etano";
            summaryOfRecords.Columns[8].ColumnName = "tempRocio";
            summaryOfRecords.Columns[9].ColumnName = "humedad";

            summaryOfRecords.Columns[10].ColumnName = "poderCalorifico";
            summaryOfRecords.Columns[11].ColumnName = "indiceWoobe";
            summaryOfRecords.Columns[12].ColumnName = "acidoSulfhidrico";
            summaryOfRecords.Columns[13].ColumnName = "azufreTotal";
            summaryOfRecords.Columns[14].ColumnName = "oxigeno";



            saveRecords(initDate, finalDate, updateRecords, "20160617194441460203936886013010", hoursName, csvHours.FileName, summaryName, csvSummary.FileName, ref recordsByHour, ref summaryOfRecords);
        }

        // Guarda el archivo recibido en la ruta especificada
        private static void saveFileInServer(ref HttpPostedFile csvFile, ref string destinyPath)
        {
            utils utils = new utils();

            destinyPath += utils.GUID() + ".csv";

            csvFile.SaveAs(destinyPath);
        }

        // Lee los datos de un archivo CSV y los vuelca en un DataTable
        private static void csvToDataTable(string pathFile, string query, ref DataTable dt)
        {
            ////// NOTAS IMPORTANTES: 
            //////- Para poder utilizar el driver Microsoft.Jet.OLEDB.4.0; o el Microsoft.ACE.OLEDB.12.0;
            //////- es necesario configurar el Pool de Aplicaciones de IIS para habilitar las aplicaciones de 32 bits, 
            //////- IIS > Application Pools > DefaultAppPool > Advanced Settings > Enable 32-Bit Applications 
            //////-      Cambiar el valor a TRUE


            string path = System.IO.Path.GetDirectoryName(pathFile);

            ////Guardamos el tiempo antes del proceso a cronometrar
            //DateTime tiempoinicial = DateTime.Now;

            using (OleDbConnection conn = new OleDbConnection("Provider=Microsoft.ACE.OLEDB.12.0;Data Source='" + path + "';Extended Properties='text;HDR=Yes;FMT=Delimited'"))
            {

                OleDbDataAdapter da = new OleDbDataAdapter(query, conn);
                da.Fill(dt);
            }

            ////Guardamos el tiempo al finalizar todas las instrucciones
            //DateTime tiempofinal = DateTime.Now;

            ////Creamos el intervalo de tiempo con una resta
            //TimeSpan total = new TimeSpan(tiempofinal.Ticks - tiempoinicial.Ticks);

            ////Mostramos por pantalla el tiempo que ha tardado el proceso
            //System.Console.WriteLine(total.ToString());
        }

        // Guarda mediante un SP los regitros de un DataTable en una tabla del Servidor
        private static void saveRecords(  DateTime      initDate     , DateTime      finalDate
                                        , bool          updateRecords, string        userId
                                        , string        hoursName    , string        originalHoursName
                                        , string        summaryName  , string        originalSummaryName
                                        , ref DataTable recordsByHour, ref DataTable summaryOfRecords)
        {
            SqlConnection cnn = new SqlConnection();
            SqlCommand cmd = new SqlCommand();

            try
            {

                cnn = BD.Connection();

                cmd.Parameters.Add("@initDate", SqlDbType.DateTime);
                cmd.Parameters.Add("@finalDate", SqlDbType.DateTime);

                cmd.Parameters.Add("@updateRecords", SqlDbType.Bit);
                cmd.Parameters.Add("@userId", SqlDbType.VarChar);

                cmd.Parameters.Add("@hoursName", SqlDbType.VarChar);
                cmd.Parameters.Add("@originalHoursName", SqlDbType.VarChar);

                cmd.Parameters.Add("@summaryName", SqlDbType.VarChar);
                cmd.Parameters.Add("@originalSummaryName", SqlDbType.VarChar);
                
                cmd.Parameters.Add("@recordsByHour", SqlDbType.Structured);
                cmd.Parameters.Add("@summaryOfRecords", SqlDbType.Structured);


                cmd.Parameters["@initDate"].Value = initDate;
                cmd.Parameters["@finalDate"].Value = finalDate;

                cmd.Parameters["@updateRecords"].Value = updateRecords;
                cmd.Parameters["@userId"].Value = userId;

                cmd.Parameters["@hoursName"].Value = hoursName;
                cmd.Parameters["@originalHoursName"].Value = originalHoursName;

                cmd.Parameters["@summaryName"].Value = summaryName;
                cmd.Parameters["@originalSummaryName"].Value = originalSummaryName;

                cmd.Parameters["@recordsByHour"].Value = recordsByHour;
                cmd.Parameters["@summaryOfRecords"].Value = summaryOfRecords;

                cmd.Connection = cnn;
                cmd.CommandTimeout = 180;
                cmd.CommandText = "sps_import";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.ExecuteNonQuery();

                
            }
            catch (Exception e)
            {
                throw(e);
            }
            finally {
                if (cnn != null){
                    if (cnn.State == ConnectionState.Open) {
                        cnn.Close();
                        cnn.Dispose();
                    }
                }
            }


        }


    }
}