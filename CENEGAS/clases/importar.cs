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

using System.Threading;


using LumenWorks.Framework.IO.Csv;

namespace cenegas.clases
{
    public static class importar
    {
        private static Dictionary<string, System.Type> layoutFields = new Dictionary<string, Type>();
        private static string importsDirectory = WebConfigurationManager.AppSettings["importsDirectory"];
        static DateTime? start ;
        static TimeSpan? ts;


        private static Random random = new Random();

        public static string RandomString(int length)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            return new string(Enumerable.Repeat(chars, length)
              .Select(s => s[random.Next(s.Length)]).ToArray());
        }

        // Inicia el proceso de importacion del archivo de mediciones
        public static void import(string idsesion, HttpPostedFile csvHours, HttpPostedFile csvSummary, bool useRange, bool viewHowChanges, DateTime initDate, DateTime finalDate, HttpResponse response)
        {
            Dictionary<string, object> result = new Dictionary<string, object>();
            //System.Globalization.CultureInfo beforeCulture = System.Threading.Thread.CurrentThread.CurrentCulture;
           
            try
            {
                //System.Threading.Thread.CurrentThread.CurrentCulture = new System.Globalization.CultureInfo("es-MX");

                result.Add("success", true);
                
                importCSVFile(idsesion, csvHours, csvSummary, useRange, viewHowChanges, initDate, finalDate);

                response.Output.Write(JSON.Serialize(result));
            }
            catch (Exception e)
            {
                //ts = DateTime.Now - start;
                //result.Add("elapsed", ts.ToString());

                result["success"] = false;

                result.Add("error", e.Message);

                response.Output.Write(JSON.Serialize(result));
            }
            //finally{
            //    System.Threading.Thread.CurrentThread.CurrentCulture = beforeCulture;
            //}
          

        }


        public static void Convert<T>(this DataColumn column, Func<object, T> conversion)
        {
            int index = 0;
            foreach (DataRow row in column.Table.Rows)
            {

                index++;
                if (row[column].ToString().Length > 0)
                {
                    row[column] = conversion(row[column]);


                }
            }
        }


        public static void Parse<T>(this DataColumn column) {
            foreach (DataRow row in column.Table.Rows) {
                row["fecha2"] = DateTime.Parse(row[column].ToString());
            }
        }

        // Recibe un archivo CSV e importa sus registros a una tabla del servidor *
        private static void importCSVFile(string idsesion, HttpPostedFile csvHours, HttpPostedFile csvSummary, bool useRange, bool viewHowChanges, DateTime? initDate, DateTime? finalDate)
        {
            //const decimal _byte = 8; // bits
            const double KB = 1024.0;
            const double MB = KB * 1024.0;
            double FILE_MAX_LENGTH = MB * double.Parse(WebConfigurationManager.AppSettings["importsFILE_MAX_LENGTH"]);
            int MAX_COLUMNS = 0;
            int index = 0;

            string hoursPath = "";
            string summaryPath  = "";


            DataRow[] afterRows;
            DataRow[] beforeRows;


            try
            {

                if (csvHours.ContentLength > FILE_MAX_LENGTH)
                {
                    // Tamaño de archivo excedido
                    Exception e = new Exception("No es posible realizar la importación, ya que el peso del archivo de horarios es de " + Math.Round((csvHours.ContentLength / MB), 2).ToString() + " MB, lo que excede el tamaño máximo permitido, que es de " + decimal.Parse(WebConfigurationManager.AppSettings["importsFILE_MAX_LENGTH"]).ToString() + " MB.");

                    throw (e);
                }

                if (csvSummary.ContentLength > FILE_MAX_LENGTH)
                {
                    // Tamaño de archivo excedido
                    Exception e = new Exception("No es posible realizar la importación, ya que el peso del archivo de promedios es de " + Math.Round((csvSummary.ContentLength / MB), 2).ToString() + " MB, lo que excede el tamaño permitido, que es de " + decimal.Parse(WebConfigurationManager.AppSettings["importsFILE_MAX_LENGTH"]).ToString() + " MB.");

                    throw (e);
                }

                DataTable recordsByHour = new DataTable();
                DataTable summaryOfRecords = new DataTable();
                hoursPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, importsDirectory);
                summaryPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, importsDirectory);
                string hoursName = "";
                string summaryName = "";

                string originalHoursName = "";
                string originalSummaryName = "";
                int charDirectory = 0;

         

                // Guardar el archivo de horarios
                saveFileInServer(ref csvHours, ref hoursPath);

                // Guardar el archivo de horarios
                saveFileInServer(ref csvSummary, ref summaryPath);

                hoursName = System.IO.Path.GetFileName(hoursPath);
                summaryName = System.IO.Path.GetFileName(summaryPath);


                recordsByHour.Columns.Add("punto");
                recordsByHour.Columns.Add("nombreAlterno");
                recordsByHour.Columns.Add("fecha");
                recordsByHour.Columns.Add("fecha2");
                recordsByHour.Columns["fecha2"].DataType = typeof(DateTime);
                recordsByHour.Columns.Add("metano");
                recordsByHour.Columns["metano"].DataType = typeof(double);

                recordsByHour.Columns.Add("bioxidoCarbono");
                recordsByHour.Columns["bioxidoCarbono"].DataType = typeof(double);
                recordsByHour.Columns.Add("nitrogeno");
                recordsByHour.Columns["nitrogeno"].DataType = typeof(double);
                recordsByHour.Columns.Add("totalInertes");
                recordsByHour.Columns["totalInertes"].DataType = typeof(double);
                recordsByHour.Columns.Add("etano");
                recordsByHour.Columns["etano"].DataType = typeof(double);

                recordsByHour.Columns.Add("tempRocio");
                recordsByHour.Columns["tempRocio"].DataType = typeof(double);
                recordsByHour.Columns.Add("humedad");
                recordsByHour.Columns["humedad"].DataType = typeof(double);
                recordsByHour.Columns.Add("poderCalorifico");
                recordsByHour.Columns["poderCalorifico"].DataType = typeof(double);
                recordsByHour.Columns.Add("indiceWoobe");
                recordsByHour.Columns["indiceWoobe"].DataType = typeof(double);

                recordsByHour.Columns.Add("acidoSulfhidrico");
                recordsByHour.Columns["acidoSulfhidrico"].DataType = typeof(double);

               



                summaryOfRecords.Columns.Add("punto");
                summaryOfRecords.Columns.Add("nombreAlterno");
                summaryOfRecords.Columns.Add("fecha");
                summaryOfRecords.Columns.Add("fecha2");
                summaryOfRecords.Columns["fecha2"].DataType = typeof(DateTime);
                summaryOfRecords.Columns.Add("metano");

                summaryOfRecords.Columns.Add("bioxidoCarbono");
                summaryOfRecords.Columns.Add("nitrogeno");
                summaryOfRecords.Columns.Add("totalInertes");
                summaryOfRecords.Columns.Add("etano");

                summaryOfRecords.Columns.Add("tempRocio");
                summaryOfRecords.Columns.Add("humedad");
                summaryOfRecords.Columns.Add("poderCalorifico");
                summaryOfRecords.Columns.Add("indiceWoobe");

                summaryOfRecords.Columns.Add("acidoSulfhidrico");
                


                

                readCSV(hoursPath, ref recordsByHour);

                readCSV(summaryPath, ref summaryOfRecords);

            

                foreach (DataRow row in recordsByHour.Rows)
                {
                    row["fecha2"] = DateTime.Parse(row["fecha"].ToString());
               
               }

                foreach (DataRow row in summaryOfRecords.Rows)
                {
                    row["fecha2"] = DateTime.Parse(row["fecha"].ToString());

                }


                recordsByHour.Columns.Remove(recordsByHour.Columns["fecha"]);
                summaryOfRecords.Columns.Remove(summaryOfRecords.Columns["fecha"]);

                recordsByHour.Columns["fecha2"].ColumnName = "fecha";
                summaryOfRecords.Columns["fecha2"].ColumnName = "fecha";




                if (recordsByHour.Columns.Count > 12)
                {

                    MAX_COLUMNS = recordsByHour.Columns.Count - 1;
                    index = MAX_COLUMNS;

                    for (index = MAX_COLUMNS; index > 12; index--)
                    {
                        recordsByHour.Columns.Remove(recordsByHour.Columns[index]);
                    }
                }


                if (summaryOfRecords.Columns.Count > 12)
                {

                    MAX_COLUMNS = summaryOfRecords.Columns.Count - 1;
                    index = MAX_COLUMNS;

                    for (index = MAX_COLUMNS; index > 12; index--)
                    {
                        summaryOfRecords.Columns.Remove(summaryOfRecords.Columns[index]);
                    }
                }


                // Filtrar por rango de fechas


                if (useRange) {
                    // Se agrega un dia unicamente para hacer la comparación de registros < a fechaFinal
                    finalDate = ((DateTime)finalDate).AddDays(1);

                    beforeRows = recordsByHour.Select("fecha < '" + initDate + "'");

                    foreach (DataRow row in beforeRows)
                        row.Delete();


                    afterRows = recordsByHour.Select("fecha >= '" + finalDate + "'");

                    foreach (DataRow row in afterRows)
                        row.Delete();




                    beforeRows = summaryOfRecords.Select("fecha < '" + initDate + "'");

                    foreach (DataRow row in beforeRows)
                        row.Delete();


                    afterRows = summaryOfRecords.Select("fecha >= '" + finalDate + "'");

                    foreach (DataRow row in afterRows)
                        row.Delete();

                    // se reestablece la fecha original
                    finalDate = ((DateTime)finalDate).AddDays(-1);


                }


                originalHoursName = csvHours.FileName;
                originalSummaryName = csvSummary.FileName;


                charDirectory = originalHoursName.LastIndexOf("\\");
                if (charDirectory > 0)
                    originalHoursName = originalHoursName.Substring(charDirectory + 1, (originalHoursName.Length - 1) - charDirectory);

                charDirectory = originalSummaryName.LastIndexOf("\\");
                if (charDirectory > 0)
                    originalSummaryName = originalSummaryName.Substring(charDirectory + 1, (originalSummaryName.Length - 1) - charDirectory);

                saveRecords(idsesion, useRange, viewHowChanges, hoursName, originalHoursName, summaryName, originalSummaryName, ref recordsByHour, ref summaryOfRecords, initDate, finalDate);
            }
            catch (Exception e)
            {
                throw (e);
            }
            finally {
       
                if (viewHowChanges) {
                    if (summaryPath.Length > 0) {
                        if (File.Exists(summaryPath))
                            File.Delete(summaryPath);
                    }


                    if (hoursPath.Length > 0)
                    {
                        if (File.Exists(hoursPath))
                            File.Delete(hoursPath);
                    }
                }
            }

        }

        // Guarda el archivo recibido en la ruta especificada
        private static void saveFileInServer(ref HttpPostedFile csvFile, ref string destinyPath)
        {
            try
            {
                utils utils = new utils();

                double mileseconds = DateTime.Now.ToUniversalTime().Subtract(new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc)).TotalMilliseconds;

                destinyPath += RandomString(6) + mileseconds.ToString().Replace(".", "") + ".csv";

                csvFile.SaveAs(destinyPath);
            }
            catch (Exception e)
            {

                throw (e);
            }
        }

        private static object evalNull(string value) {
            object response = DBNull.Value;

            if (value.Length > 0)
                response = double.Parse(value);

            return response;
        }


        private static void readCSV(string pathFile, ref DataTable dt){
            DateTime hoy = DateTime.Now;

            try
            {
                // open the file "data.csv" which is a CSV file with headers
                using (CsvReader csv =
                       new CsvReader(new StreamReader(pathFile), true))
                {
                    int fieldCount = csv.FieldCount;

                    string[] headers = csv.GetFieldHeaders();
                    while (csv.ReadNextRecord())
                    {

                        dt.Rows.Add(csv[0], csv[1], csv[3], hoy
                            , evalNull(csv[4])
                            , evalNull(csv[5])
                            , evalNull(csv[6])
                            , evalNull(csv[7])
                            , evalNull(csv[8])
                            , evalNull(csv[9])
                            , evalNull(csv[10])
                            , evalNull(csv[11])
                            , evalNull(csv[12]));


                    }
                }
            }catch( Exception e){
                throw(e);
            }
        }

        // Lee los datos de un archivo CSV y los vuelca en un DataTable
        private static void csvToDataTable(string pathFile, string query, ref DataTable dt)
        {
            ////// NOTAS IMPORTANTES: 
            //////- Para poder utilizar el driver Microsoft.Jet.OLEDB.4.0; o el Microsoft.ACE.OLEDB.12.0;
            //////- es necesario configurar el Pool de Aplicaciones de IIS para habilitar las aplicaciones de 32 bits, 
            //////- IIS > Application Pools > DefaultAppPool > Advanced Settings > Enable 32-Bit Applications 
            //////-      Cambiar el valor a TRUE

            //System.Globalization.CultureInfo beforeCulture = System.Threading.Thread.CurrentThread.CurrentCulture;

            try
            {
                string path = System.IO.Path.GetDirectoryName(pathFile);

                ////Guardamos el tiempo antes del proceso a cronometrar
                //DateTime tiempoinicial = DateTime.Now;



                //System.Threading.Thread.CurrentThread.CurrentCulture = new System.Globalization.CultureInfo("es-MX");

                using (OleDbConnection conn = new OleDbConnection("Provider=Microsoft.Jet.OLEDB.4.0;Data Source='" + path + "';Extended Properties='text;HDR=No;IMEX=1;FMT=Delimited'"))
                {

                    OleDbDataAdapter da = new OleDbDataAdapter(query, conn);
                    da.Fill(dt);
                }

                //System.Threading.Thread.CurrentThread.CurrentCulture = beforeCulture;

                ////Guardamos el tiempo al finalizar todas las instrucciones
                //DateTime tiempofinal = DateTime.Now;

                ////Creamos el intervalo de tiempo con una resta
                //TimeSpan total = new TimeSpan(tiempofinal.Ticks - tiempoinicial.Ticks);

                ////Mostramos por pantalla el tiempo que ha tardado el proceso
                //System.Console.WriteLine(total.ToString());
            }
            catch (Exception e)
            {

                throw (e);
            }
            //finally
            //{
            //    System.Threading.Thread.CurrentThread.CurrentCulture = beforeCulture;
            //}
        }

        // Guarda mediante un SP los regitros de un DataTable en una tabla del Servidor
        private static void saveRecords(string idsesion, bool useRange, bool viewHowChanges
                                        , string hoursName, string originalHoursName
                                        , string summaryName, string originalSummaryName
                                        , ref DataTable recordsByHour, ref DataTable summaryOfRecords
                                        , DateTime? initDate, DateTime? finalDate
                                        )
        {


            SqlConnection adminConnection = BD.Connection("Admin");

            SqlConnection cnn = new SqlConnection();
            SqlCommand cmd = new SqlCommand();

            int idlog = -1;

            try
            {

                cnn = BD.Connection();

                if (useRange)
                {
                    cmd.Parameters.Add("@initDate", SqlDbType.DateTime);
                    cmd.Parameters.Add("@finalDate", SqlDbType.DateTime);

                    cmd.Parameters["@initDate"].Value = initDate;
                    cmd.Parameters["@finalDate"].Value = finalDate;
                }


                cmd.Parameters.Add("@viewHowChanges", SqlDbType.Bit);

                cmd.Parameters.Add("@idsesion", SqlDbType.VarChar);

                cmd.Parameters.Add("@hoursName", SqlDbType.VarChar);
                cmd.Parameters.Add("@originalHoursName", SqlDbType.VarChar);

                cmd.Parameters.Add("@summaryName", SqlDbType.VarChar);
                cmd.Parameters.Add("@originalSummaryName", SqlDbType.VarChar);

                cmd.Parameters.Add("@recordsByHour", SqlDbType.Structured);
                cmd.Parameters.Add("@summaryOfRecords", SqlDbType.Structured);


                cmd.Parameters["@viewHowChanges"].Value = viewHowChanges;

                cmd.Parameters["@idsesion"].Value = idsesion;

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

                idlog = BD.LogInit(cmd, adminConnection);
                cmd.ExecuteNonQuery();

                BD.LogOk(idlog, adminConnection);
            }
            catch (Exception e)
            {
                BD.LogException(idlog, e, adminConnection);
                throw (e);
            }
            finally
            {
                if (cnn != null)
                {
                    if (cnn.State == ConnectionState.Open)
                    {
                        cnn.Close();
                        cnn.Dispose();
                    }
                }

                if (adminConnection != null)
                {
                    if (adminConnection.State == ConnectionState.Open)
                    {
                        adminConnection.Close();
                        adminConnection.Dispose();
                    }
                }
            }


        }

        public static Mi.Control.Files.File getFile(string idDownload, string idsesion)
        {
            try
            {
                string importsDirectory = WebConfigurationManager.AppSettings["importsDirectory"];

                Mi.Control.Files.File file = new Files.File();


                string path = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, importsDirectory);
                string fileName = getFileName(idDownload, idsesion);

                byte[] bytesFile = fileToBytes(path + fileName);

                file.clength = bytesFile.Length;
                file.ctype = "csv";
                file.data = bytesFile;
                file.name = fileName;

                return file;
            }
            catch (Exception e)
            {

                throw (e);
            }
        }



        public static byte[] fileToBytes(String path)
        {
            try
            {
                MemoryStream destination = new MemoryStream();

                FileStream source = new FileStream(path, FileMode.Open);

                // Copy source to destination.

                source.CopyTo(destination);

                source.Close();
                source.Dispose();

                return destination.ToArray();
            }
            catch (Exception e)
            {

                throw (e);
            }

        }


        // Guarda mediante un SP los regitros de un DataTable en una tabla del Servidor
        public static string getFileName(string idbdatos, string idsesion)
        {


            SqlConnection cnn = new SqlConnection();
            SqlCommand cmd = new SqlCommand();
            SqlDataReader dr = null;

            try
            {

                cnn = BD.Connection();

                cmd.Parameters.Add("@idbdatos", SqlDbType.VarChar);
                cmd.Parameters.Add("@idsesion", SqlDbType.VarChar);


                cmd.Parameters["@idbdatos"].Value = idbdatos;
                cmd.Parameters["@idsesion"].Value = idsesion;

                cmd.Connection = cnn;
                cmd.CommandTimeout = 180;
                cmd.CommandText = "sps_getFileName";
                cmd.CommandType = CommandType.StoredProcedure;

                dr = cmd.ExecuteReader();

                dr.Read();

                string narchivo = (string)dr["narchivo"];

                return narchivo;

            }
            catch (Exception e)
            {
                throw (e);
            }
            finally
            {
                if (cnn != null)
                {
                    if (cnn.State == ConnectionState.Open)
                    {
                        cnn.Close();
                        cnn.Dispose();
                    }
                }

            }


        }


    }


}