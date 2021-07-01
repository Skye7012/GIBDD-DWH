using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net.Http;
using System.IO;
using System.Web;

namespace Parser
{
    class Parser
    {
        static Random rnd = new Random(); 
        static int numOfCameras = 10;
        static void Main(string[] args)
        {
            WriteCarModelParsingData();
            WriteSubjectParsingData();
            WriteCameraParsingData();
        }
        #region Writing
        static void WriteCarModelParsingData()
        {
            using (StreamWriter sw = new StreamWriter("..\\..\\CarModels.txt", false, Encoding.GetEncoding(1251)))
            {
                var res = CarModelParsing();
                foreach (string row in res)
                    sw.WriteLine(row);
                Console.WriteLine("Write Done");
            }
        }
        static void WriteCameraParsingData()
        {
            List<int> subjectCodes = new List<int>();
            List<string> locations = new List<string>();
            List<string> cameras = new List<string>();
            int id = 0;
            using (StreamReader sr = new StreamReader("..\\..\\Subjects.txt"))
            {
                string line;
                while ((line = sr.ReadLine()) != null)
                {
                    subjectCodes.Add(int.Parse(line.Split(';')[0]));
                }
            }
            for (int i = 0; i < subjectCodes.Count; i++)
            {
                var parsedCameras = CameraParsing(subjectCodes[i]);
                if (parsedCameras is null)
                    continue;
                locations.AddRange(parsedCameras);
                for (int j = 0; j < numOfCameras; j++)
                {
                    string res = id + 1 + "||" + locations[id] + "||" + subjectCodes[i];
                    Console.WriteLine(res);
                    cameras.Add(res);
                    id++;
                }
            }
            using (StreamWriter sw = new StreamWriter("..\\..\\Cameras.txt", false, Encoding.GetEncoding(1251)))
            {
                foreach (var camera in cameras)
                    sw.WriteLine(camera);
                Console.WriteLine("Write Done");
            }
        }
        static void WriteSubjectParsingData()
        {
            using (StreamWriter sw = new StreamWriter("..\\..\\Subjects.txt", false, Encoding.GetEncoding(1251)))
            {
                List<string> res = SubjectParing("https://xn--90adear.xn--p1ai/r/01/milestones");
                foreach (string row in res)
                    sw.WriteLine(row);
                Console.WriteLine("Write Done");
            }
        }
        #endregion
        #region Parsing
        static List<string> CameraParsing(int subject_code)
        {
            string url = "https://xn--90adear.xn--p1ai/r/" + string.Format("{0:d2}", subject_code) + "/milestones";
            try
            {
                using (HttpClientHandler hdl = new HttpClientHandler { AllowAutoRedirect = false, AutomaticDecompression = System.Net.DecompressionMethods.GZip | System.Net.DecompressionMethods.Deflate | System.Net.DecompressionMethods.None })
                {
                    using (var clnt = new HttpClient(hdl))
                    {
                        using (HttpResponseMessage resp = clnt.GetAsync(url).Result)
                        {
                            if (resp.IsSuccessStatusCode)
                            {
                                var html = resp.Content.ReadAsStringAsync().Result;
                                if (!string.IsNullOrEmpty(html))
                                {
                                    HtmlAgilityPack.HtmlDocument doc = new HtmlAgilityPack.HtmlDocument();
                                    doc.LoadHtml(html);
                                    var records = doc.DocumentNode.SelectNodes(".//div[@class='section-list type-4 type-4a margin2']//div[@class='clearfix']//div[@class='sl-item']"); ////div[@class='
                                    if (records != null && records.Count > 0 && records.Count > 9)
                                    {
                                        var result = new List<string>();
                                        int size = records.Count;
                                        for (int i = 0; i < numOfCameras; i++)
                                        {
                                            int n = rnd.Next(size);
                                            var row = records[n].SelectSingleNode(".//div[@class='sl-item-text']");
                                            if (row.InnerText.Trim() == "")
                                                row = records[n].SelectSingleNode(".//div[@class='sl-item-title']//a");
                                            string addRow = HttpUtility.HtmlDecode(row.InnerText);
                                            addRow = addRow.Trim();
                                            if (result.Any(x => x == addRow))
                                                i--;
                                            else
                                                result.Add(addRow);
                                        }
                                        return result;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex) { Console.WriteLine(ex.Message); }
            return null;
        }
        static List<string> CarModelParsing()
        {
            string url = "https://autorating.ru/news/2020-07-07-top25-samykh-populyarnykh-avtomobiley-v-rossii/";
            try
            {
                using (HttpClientHandler hdl = new HttpClientHandler { AllowAutoRedirect = false, AutomaticDecompression = System.Net.DecompressionMethods.GZip | System.Net.DecompressionMethods.Deflate | System.Net.DecompressionMethods.None })
                {
                    using (var clnt = new HttpClient(hdl))
                    {
                        using (HttpResponseMessage resp = clnt.GetAsync(url).Result)
                        {
                            if (resp.IsSuccessStatusCode)
                            {
                                var html = resp.Content.ReadAsStringAsync().Result;
                                if (!string.IsNullOrEmpty(html))
                                {
                                    HtmlAgilityPack.HtmlDocument doc = new HtmlAgilityPack.HtmlDocument();
                                    doc.LoadHtml(html);
                                    var tables = doc.DocumentNode.SelectNodes(".//div[@class='news-detail__text content']//table"); 
                                    var table = tables[1];
                                    if (table != null)
                                    {
                                        List<string> res = new List<string>();
                                        var rows = table.SelectNodes(".//tr");
                                        if(rows != null && rows.Count > 0)
                                        {
                                            for(int i = 1; i < rows.Count; i++)
                                            {
                                                var row = rows[i];
                                                var cells = row.SelectNodes(".//td");
                                                if (cells != null && cells.Count > 0)
                                                {
                                                    string addCell = HttpUtility.HtmlDecode(cells[0].InnerText);
                                                    addCell = addCell.Split('.')[1];
                                                    addCell = addCell.Trim();
                                                    addCell = i + ";" + addCell.Split(' ')[0] + ";" + addCell.Split(' ')[1];
                                                    
                                                    Console.WriteLine(addCell);
                                                    res.Add(addCell);
                                                }
                                            }                                 
                                        }
                                        return res;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex) { Console.WriteLine(ex.Message); }
            return null;
        }
        static List<string> SubjectParing(string url)
        {
            try
            {
                using (HttpClientHandler hdl = new HttpClientHandler { AllowAutoRedirect = false, AutomaticDecompression = System.Net.DecompressionMethods.GZip | System.Net.DecompressionMethods.Deflate | System.Net.DecompressionMethods.None })
                {
                    using (var clnt = new HttpClient(hdl))
                    {
                        using (HttpResponseMessage resp = clnt.GetAsync(url).Result)
                        {
                            if (resp.IsSuccessStatusCode)
                            {
                                var html = resp.Content.ReadAsStringAsync().Result;
                                if (!string.IsNullOrEmpty(html))
                                {
                                    HtmlAgilityPack.HtmlDocument doc = new HtmlAgilityPack.HtmlDocument();
                                    doc.LoadHtml(html);
                                    var record = doc.DocumentNode.SelectSingleNode(".//select[@class='select request-input regions']"); 
                                    if (record != null)
                                    {
                                        var result = new List<string>();
                                        for(int i = 1; i <= 95; i++)
                                        {
                                            string numPath = String.Format(".//option[@value='{0:d2}']", i);
                                            var row = record.SelectSingleNode(numPath);
                                            if(row != null)
                                                result.Add(row.InnerText.Replace("&quot;", "\""));
                                        }
                                        for(int z = 0;z < result.Count; z++)
                                        {
                                            result[z] = int.Parse(result[z].Substring(0, 2)).ToString() + ";" + result[z].Substring(3);
                                        }
                                        return result;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex) { Console.WriteLine(ex.Message); }
            return null;
        }
        #endregion
    }
}
