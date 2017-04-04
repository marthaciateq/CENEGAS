using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


using System.IO;

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



        
    }
}