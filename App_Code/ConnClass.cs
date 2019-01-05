using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace SignalRChat
{
    public class ConnClass
    {
        public SqlCommand cmd = new SqlCommand();
        public SqlDataAdapter sda;
        public SqlDataReader sdr;
        public DataSet ds = new DataSet();
        public SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["conStr"].ToString());

        public bool IsExist(string Query)
        {
            bool check = false;
            using (cmd = new SqlCommand(Query, con))
            {
                con.Open();
                sdr = cmd.ExecuteReader();
                if (sdr.HasRows)
                    check = true;
                sdr.Close();
                con.Close();
            }
            return check;

        }

        public int ExecuteNonQuery(string Query)
        {
            int j = 0;
            using (cmd = new SqlCommand(Query, con))
            {
                con.Open();
                j = cmd.ExecuteNonQuery();
                con.Close();
            }

            return j;

        }

        public List<string> ExecuteQuery(string Query, int numberOfColumns)
        {
            List<string> result = new List<string>();
            using (cmd = new SqlCommand(Query, con))
            {
                con.Open();
                sdr = cmd.ExecuteReader();
                while (sdr.Read())
                {
                    for(int i = 0; i< numberOfColumns; i++)
                    {
                        result.Add(sdr.GetValue(i).ToString());
                    }
                }
                sdr.Close();
                con.Close();
            }
            return result;
        }

        public string GetColumnVal(string Query, string ColumnName)
        {
            string RetVal = "";
            using (cmd = new SqlCommand(Query, con))
            {
                con.Open();
                sdr = cmd.ExecuteReader();
                while (sdr.Read())
                {
                    RetVal = sdr[ColumnName].ToString();
                    break;
                }
                sdr.Close();
                con.Close();
            }

            return RetVal;


        }

    }
}