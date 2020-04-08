using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Security.Cryptography;
using System.Xml;
using System.Xml.Xsl;
using System.IO;
using System.Threading;
using CsvHelper;
using System.Globalization;
using Npgsql;




namespace C_Sharp_Sample {
    class Program {
        static void Main(string[] args) {
            String key = "";

            // XML login string
            String loginCommand = createLoginXml(); //commented out for security
            Console.Write("Client Started... \n");
            ConnectionObject connectionObject = new ConnectionObject();
            
            //Send Login Command once to get fishbowl server to recognize the connection attempt
            //or pull the key off the line if already connected
            key = pullKey(connectionObject.sendCommand(loginCommand));
            if (key == "null")
            {
                Console.Write("Please accept the connection attempt on the fishbowl server and press return");
                Console.ReadLine();
                key = pullKey(connectionObject.sendCommand(loginCommand));
            }
            Console.WriteLine($"{key}");


            // Perform in a loop to constantly refresh.
            // TODO: see what happens when connection is broken, how to have it automatically retry?


            do {
                //Now create the query to pull data out of fishbowl using the key
                String inventory = connectionObject.sendCommand(inventoryQuery(key));

                // Add rows to csv file or to a database for easy querying.

                XmlDocument inventoryXML = new XmlDocument();
                //inventoryXML.LoadXml(inventory);

                string[] invArray = new string[] { inventory };


                

                System.IO.File.WriteAllLines(@"C:\FastInv\inv.xml", invArray);

                XslCompiledTransform xslt = new XslCompiledTransform();
                xslt.Load("C:\\FastInv\\XmlToCSV.xslt");
                xslt.Transform("C:\\FastInv\\inv.xml", "C:\\FastInv\\OutputFileWithHeader.csv");


                // Remove unwanted 2 first lines from csv file
                List<String> linesList = File.ReadAllLines("C:\\FastInv\\OutputFileWithHeader.csv").ToList();
                linesList.RemoveRange(0,2);
                File.WriteAllLines("C:\\FastInv\\OutputFile.csv", linesList.ToArray());

                Console.WriteLine($"Data has been output to C:\\FastInv\\OutputFile.csv at {DateTime.Now.ToString()}");

                // Run Python script 

                System.Diagnostics.Process process = new System.Diagnostics.Process();
                System.Diagnostics.ProcessStartInfo startInfo = new System.Diagnostics.ProcessStartInfo();
                startInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Normal;
                startInfo.FileName = "Python.exe";
                startInfo.Arguments = "C:\\FastInv\\DataUpdates.py";
                process.StartInfo = startInfo;
                process.Start();
                process.WaitForExit();


                System.Threading.Thread.Sleep(500000);
                

            } while (1 == 1);

            

            //Added to keep the cmd screen open
            Console.ReadLine();


        }

        private static String createLoginXml(string username, string password) {
            System.Text.StringBuilder buffer = new System.Text.StringBuilder("<FbiXml><Ticket/><FbiMsgsRq><LoginRq><IAID>");
            buffer.Append("222");
            buffer.Append("</IAID><IAName>");
            buffer.Append("C Sharp Sample");
            buffer.Append("</IAName><IADescription>");
            buffer.Append("Sample Coding for C Sharp");
            buffer.Append("</IADescription><UserName>");
            buffer.Append(username);
            buffer.Append("</UserName><UserPassword>");

            MD5 md5 = MD5CryptoServiceProvider.Create();
            byte[] encoded = md5.ComputeHash(System.Text.Encoding.ASCII.GetBytes(password));
            string encrypted = Convert.ToBase64String(encoded, 0, 16);
            buffer.Append(encrypted);
            buffer.Append("</UserPassword></LoginRq></FbiMsgsRq></FbiXml>");

            return buffer.ToString();
        }

        //Pull the session Key out of the server response string
        private static String pullKey(String connection){
            String key = "";
            using (XmlReader reader = XmlReader.Create(new StringReader(connection)))
            {
                while (reader.Read())
                {
                    //if (reader.NodeType == XmlNodeType.Element && reader.Name.Equals("Key"))
                    if (reader.Name.Equals("Key") && reader.Read())
                    {
                        return reader.Value.ToString();
                    }
                }
            }
            return key;
        }

        
        // The following generates different queries 
        private static string inventoryQuery(string key)
        {
            return "<FbiXml><Ticket><Key>" + key + "</Key></Ticket><FbiMsgsRq><ExecuteQueryRq><Name>straitswebtools</Name></ExecuteQueryRq></FbiMsgsRq></FbiXml>";
        }

   

    }
}
