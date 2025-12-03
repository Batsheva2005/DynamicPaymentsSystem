using System;
using System.Data;
using System.Diagnostics;

namespace DynamicCalculator
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Starting C# Dynamic Calculation Engine (Architectured Version)...");

            SqlService db = new SqlService();
            CalculationEngine engine = new CalculationEngine();

            try
            {
                Console.WriteLine("Loading data from SQL...");
                DataTable dataTable = db.LoadData("SELECT data_id, a, b, c, d FROM t_data");
                Console.WriteLine($"Loaded {dataTable.Rows.Count} rows.");

                DataTable formulasTable = db.LoadData("SELECT targil_id, targil FROM t_targil");

                foreach (DataRow formulaRow in formulasTable.Rows)
                {
                    int targilId = (int)formulaRow["targil_id"];
                    string formula = formulaRow["targil"].ToString();

                    Console.WriteLine($"\nProcessing Formula ID: {targilId} ({formula})...");

                    Stopwatch sw = Stopwatch.StartNew();

                    // א. ביצוע החישוב (נטו)
                    DataTable results = engine.CalculateAll(dataTable, targilId, formula);

                    // מדידת זמן ביניים (רק החישוב)
                    double calcTime = sw.Elapsed.TotalSeconds;

                    // ב. שמירת התוצאות (DB)
                    db.SaveResultsBulk(results);

                    sw.Stop();
                    double totalTime = sw.Elapsed.TotalSeconds;

                    // ג. תיעוד לוג - נשמור את הזמן הכולל 
                    db.LogTime(targilId, "C# .NET Optimized", totalTime);

                  
                    Console.WriteLine($"Finished!");
                    Console.ForegroundColor = ConsoleColor.Green; 
                    Console.WriteLine($"   > Calculation Time (CPU): {calcTime:F3} sec");
                    Console.ResetColor();
                    Console.WriteLine($"   > Total Time (with DB Save): {totalTime:F3} sec");
                }

                Console.WriteLine("\nAll Done!");
            }
            catch (Exception ex)
            {
                Console.WriteLine("Critical Error: " + ex.Message);
            }
            Console.ReadLine();
        }
    }
}