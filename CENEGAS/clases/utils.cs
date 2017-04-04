using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO.Compression;
using System.IO;
using Mi.Control;


namespace cenegas.clases
{
    public class utils
    {
        Random rnd = null;

        public string GUID()
        {
            rnd = new Random();

            return s4() + s4() + s4() + s4();
        }

        private string s4()
        {
            string HEXADECIMAL_FORMAT = "X";

            return ((int)Math.Floor(((double)(generateRandom())) * 0x10000)).ToString(HEXADECIMAL_FORMAT).Substring(1);
        }

        private int generateRandom()
        {
            int MIN = 1000;
            int MAX = 9999;

            return rnd.Next(MIN, MAX);
        }

        public static void generateZip(HttpRequest request, HttpResponse response)
        {

            try
            {
                if (request.Params["files"] == null) throw new ArgumentException("Se debe especificar los identificadores de los archivos a generar");

                string[] files = request.Params["files"].Split(',');

                string nfile = "temp_" + DateTime.Now.ToString().Replace("/", "").Replace(".", "").Replace(" ", "").Replace(":", "") + ".zip";
                using (var fileStream = new FileStream(Files.Path + "\\" + nfile, FileMode.Create))
                {
                    using (var archive = new ZipArchive(fileStream, ZipArchiveMode.Create, true))
                    {
                        for (int i = 0; i < files.Length; i++)
                        {
                            var fPath = Files.Path + "\\" + files[i] + ".dat";
                            var zipArchiveEntry = archive.CreateEntryFromFile(fPath, files[++i] + ".pdf");
                        }
                    }
                }
                response.ContentType = "application/zip";
                response.AddHeader("Content-disposition", "attachment; filename=" + nfile);
                response.WriteFile(Files.Path + "\\" + nfile);
            }
            catch (Exception exception)
            {
                response.Output.Write(AJAX.Exception(exception));
            }
        }

        
    }
}