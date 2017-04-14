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
        public static void import(string idsesion, HttpPostedFile csvHours, HttpPostedFile csvSummary, bool updateRecords, bool useRange, bool viewHowChanges, string actionForNewPoints, DateTime initDate, DateTime finalDate, HttpResponse response)
        {
            Dictionary<string, object> result = new Dictionary<string, object>();
            try
            {
                int taskTime;
                string filter = "";


                result.Add("success", true);

                DateTime start = DateTime.Now;

                // Se agrega un dia unicamente para hacer la comparación de registros < a fechaFinal
                finalDate = finalDate.AddDays(1);


                filter = useRange ? " WHERE   Fecha >= CDate('" + initDate.Year + (initDate.Month < 10 ? "/0" : "/") + initDate.Month + (initDate.Day < 10 ? "/0" : "/") + initDate.Day + "')   AND   fecha < CDate('" + finalDate.Year + (finalDate.Month < 10 ? "/0" : "/") + finalDate.Month + (finalDate.Day < 10 ? "/0" : "/") + finalDate.Day + "') " : "";

                // Se reestablece la fecha original
                finalDate = finalDate.AddDays(-1);


                importCSVFile(idsesion, csvHours, csvSummary, updateRecords, useRange, viewHowChanges, actionForNewPoints, initDate, finalDate, filter);

                TimeSpan ts = DateTime.Now - start;

                int dif = ts.Seconds;

                response.Output.Write(JSON.Serialize(result));
            }
            catch (Exception e)
            {
                result["success"] = false;

                result.Add("error", e.Message);

                response.Output.Write(JSON.Serialize(result));
            }

        }




        // Recibe un archivo CSV e importa sus registros a una tabla del servidor *
        private static void importCSVFile(string idsesion, HttpPostedFile csvHours, HttpPostedFile csvSummary, bool updateRecords, bool useRange, bool viewHowChanges, string actionForNewPoints, DateTime? initDate, DateTime? finalDate, string filter)
        {
            //const decimal _byte = 8; // bits
            const double KB = 1024.0;
            const double MB = KB * 1024.0;
            double FILE_MAX_LENGTH = MB * double.Parse(WebConfigurationManager.AppSettings["importsFILE_MAX_LENGTH"]);
            int MAX_COLUMNS = 0;
            int index = 0;

            string hoursPath = "";
            string summaryPath  = "";

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


                csvToDataTable(hoursPath, "SELECT * FROM " + hoursName + filter, ref recordsByHour);
                csvToDataTable(summaryPath, "SELECT * FROM " + summaryName + filter, ref summaryOfRecords);

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
                //recordsByHour.Columns[13].ColumnName = "azufreTotal";
                //recordsByHour.Columns[14].ColumnName = "oxigeno";


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
                //summaryOfRecords.Columns[13].ColumnName = "azufreTotal";
                //summaryOfRecords.Columns[14].ColumnName = "oxigeno";


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

                originalHoursName = csvHours.FileName;
                originalSummaryName = csvSummary.FileName;


                charDirectory = originalHoursName.LastIndexOf("\\");
                if (charDirectory > 0)
                    originalHoursName = originalHoursName.Substring(charDirectory + 1, (originalHoursName.Length - 1) - charDirectory);

                charDirectory = originalSummaryName.LastIndexOf("\\");
                if (charDirectory > 0)
                    originalSummaryName = originalSummaryName.Substring(charDirectory + 1, (originalSummaryName.Length - 1) - charDirectory);

                saveRecords(idsesion, updateRecords, useRange, viewHowChanges, actionForNewPoints, hoursName, originalHoursName, summaryName, originalSummaryName, ref recordsByHour, ref summaryOfRecords, initDate, finalDate);
            }
            catch (Exception e)
            {
                throw (e);
            }
            finally {
                if (viewHowChanges || actionForNewPoints == "V") {
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

                destinyPath += mileseconds.ToString().Replace(".", "") + ".csv";

                csvFile.SaveAs(destinyPath);
            }
            catch (Exception e)
            {

                throw (e);
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

            try
            {
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
            catch (Exception e)
            {

                throw (e);
            }
        }

        // Guarda mediante un SP los regitros de un DataTable en una tabla del Servidor
        private static void saveRecords(string idsesion, bool updateRecords, bool useRange, bool viewHowChanges, string actionForNewPoints
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

                cmd.Parameters.Add("@updateRecords", SqlDbType.Bit);
                cmd.Parameters.Add("@idsesion", SqlDbType.VarChar);

                cmd.Parameters.Add("@hoursName", SqlDbType.VarChar);
                cmd.Parameters.Add("@originalHoursName", SqlDbType.VarChar);

                cmd.Parameters.Add("@summaryName", SqlDbType.VarChar);
                cmd.Parameters.Add("@originalSummaryName", SqlDbType.VarChar);

                cmd.Parameters.Add("@actionForNewPoints", SqlDbType.VarChar);

                cmd.Parameters.Add("@recordsByHour", SqlDbType.Structured);
                cmd.Parameters.Add("@summaryOfRecords", SqlDbType.Structured);


                cmd.Parameters["@viewHowChanges"].Value = viewHowChanges;

                cmd.Parameters["@updateRecords"].Value = updateRecords;
                cmd.Parameters["@idsesion"].Value = idsesion;

                cmd.Parameters["@hoursName"].Value = hoursName;
                cmd.Parameters["@originalHoursName"].Value = originalHoursName;

                cmd.Parameters["@summaryName"].Value = summaryName;
                cmd.Parameters["@originalSummaryName"].Value = originalSummaryName;

                cmd.Parameters["@actionForNewPoints"].Value = actionForNewPoints;

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

        public static Mi.Control.Files.File getFile(string idDownload)
        {
            try
            {
                string importsDirectory = WebConfigurationManager.AppSettings["importsDirectory"];

                Mi.Control.Files.File file = new Files.File();


                string path = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, importsDirectory);
                string fileName = getFileName(idDownload);

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
        public static string getFileName(string idbdatos)
        {


            SqlConnection cnn = new SqlConnection();
            SqlCommand cmd = new SqlCommand();
            SqlDataReader dr = null;

            try
            {

                cnn = BD.Connection();

                cmd.Parameters.Add("@idbdatos", SqlDbType.VarChar);


                cmd.Parameters["@idbdatos"].Value = idbdatos;

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