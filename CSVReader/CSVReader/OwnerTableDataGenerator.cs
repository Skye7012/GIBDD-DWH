using Microsoft.VisualBasic.FileIO;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CSVReader
{
    class OwnerTableDataGenerator
    {
        static Random rnd = new Random();
        static void Main(string[] args)
        {
           using(StreamWriter sw = new StreamWriter("..\\..\\data.txt",false,Encoding.GetEncoding(1251)))
            {
                List<string> rows = GetData("..\\..\\data.csv");
                foreach (string row in rows)
                    sw.WriteLine(row);
                Console.WriteLine("Write Done");
            }
            
        }
        static List<string> GetData(string path)
        {
            using (TextFieldParser parser = new TextFieldParser(path))
            {
                parser.TextFieldType = FieldType.Delimited;
                parser.SetDelimiters(",");
                List<string[]> rows = new List<string[]>();
                List<string> res = new List<string>();
                while (!parser.EndOfData)
                {
                    rows.Add(parser.ReadFields());
                }
                int size = rows.Count;
                for (int i = 0; i < 1000; i++)
                {
                    int q = rnd.Next(0, size);
                    string[] row = rows[q];
                    for (int j = 0; j < 3; j++)
                    {
                        row[j] = row[j][0] + row[j].Substring(1).ToLower();
                    }
                    if (row[0] == "-" || row[1] == "-" || row[2] == "-")
                    {
                        i--;
                        continue;
                    }
                    res.Add(i + ";" + row[0] + " " + row[1] + " " + row[2] + ";" + Passposrt());
                }
                return res;
            }
        }
        static string Passposrt()
        {
            int[] i = new int[3];
            string res;
            i[0] = rnd.Next(100);
            i[1] = rnd.Next(100);
            i[2] = rnd.Next(1000000);
            res = String.Format("{0:d2} {1:d2} {2:d6}", i[0], i[1], i[2]);
            return res;
        }
    }
}

