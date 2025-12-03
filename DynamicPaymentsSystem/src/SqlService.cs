using System;
using System.Data;
using System.Data.SqlClient;

namespace DynamicCalculator
{
    // שכבת גישה לנתונים (Data Access Layer)
    // מרכזת את כל הפעולות מול SQL Server
    public class SqlService
    {
        // הערה: בסביבת ייצור (Production), מחרוזת החיבור תישמר בקובץ קונפיגורציה (appsettings.json) ולא בקוד
        private string _connectionString = "Server=BATSHEVA-2024\\SQLEXPRESS;Database=DynamicPaymentsDB;Trusted_Connection=True;";

        // שליפת נתונים לזיכרון
        public DataTable LoadData(string query)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                using (SqlDataAdapter adapter = new SqlDataAdapter(query, conn))
                {
                    adapter.Fill(dt);
                }
            }
            return dt;
        }

        // ביצוע שמירה המונית (Bulk Insert)
        // שימוש ב-SqlBulkCopy במקום Insert רגיל משפר את הביצועים באלפי אחוזים
        public void SaveResultsBulk(DataTable resultsTable)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                using (SqlBulkCopy bulkCopy = new SqlBulkCopy(conn))
                {
                    bulkCopy.DestinationTableName = "results";

                    // מיפוי בין עמודות הזיכרון לעמודות בבסיס הנתונים
                    bulkCopy.ColumnMappings.Add("data_id", "data_id");
                    bulkCopy.ColumnMappings.Add("targil_id", "targil_id");
                    bulkCopy.ColumnMappings.Add("method", "method");
                    bulkCopy.ColumnMappings.Add("result", "result");

                    try
                    {
                        bulkCopy.WriteToServer(resultsTable);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("DB Error: " + ex.Message);
                    }
                }
            }
        }

        // תיעוד זמני ריצה לטבלת הלוג
        public void LogTime(int targilId, string method, double seconds)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                string query = "INSERT INTO t_log (targil_id, method, run_time) VALUES (@tid, @method, @time)";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@tid", targilId);
                    cmd.Parameters.AddWithValue("@method", method);
                    cmd.Parameters.AddWithValue("@time", seconds);
                    cmd.ExecuteNonQuery();
                }
            }
        }
    }
}