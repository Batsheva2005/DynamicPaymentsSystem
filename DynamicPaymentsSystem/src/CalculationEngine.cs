using System;
using System.Data;

namespace DynamicCalculator
{
    public class CalculationEngine
    {
        // מנוע חישוב אופטימלי (In-Memory Logic)
        // מבצע את החישוב ישירות על ה-DataTable המקורי ללא שכפול מיותר של נתונים
        public DataTable CalculateAll(DataTable sourceData, int targilId, string formula)
        {
            // הכנת מבנה טבלת התוצאות (Schema Only)
            DataTable resultsBuffer = new DataTable();
            resultsBuffer.Columns.Add("data_id", typeof(int));
            resultsBuffer.Columns.Add("targil_id", typeof(int));
            resultsBuffer.Columns.Add("method", typeof(string));
            resultsBuffer.Columns.Add("result", typeof(double));

            // --- מנוע תרגום נוסחאות (Transpiler) ---
            // המרה של סינטקס עסקי (Excel-like) לסינטקס נתמך של DataTable (SQL-like)
            string cleanFormula = formula;

            // 1. תרגום פונקציות ספציפיות (ABS)
            // המרת ABS ללוגיקה מותנית (מכיוון ש-Compute לא תומך ב-Math functions)
            if (cleanFormula.Contains("ABS(d - b)"))
            {
                cleanFormula = cleanFormula.Replace("ABS(d - b)", "IIF((d - b) < 0, (d - b) * -1, (d - b))");
            }

            // 2. תרגום ישיר של פקודות בסיסיות
            cleanFormula = cleanFormula.Replace("if(", "IIF(");

            // 3. תרגום אופרטורים
            cleanFormula = cleanFormula.Replace("==", "=");

            // ניקוי עמודות זמניות משאריות של ריצות קודמות (Cleanup)
            string tempColName = "tempResult";
            if (sourceData.Columns.Contains(tempColName))
                sourceData.Columns.Remove(tempColName);

            try
            {
                // הוספת העמודה המחושבת (Vector-based calculation)
                // פעולה זו מהירה משמעותית מלולאה רגילה (Iteration)
                sourceData.Columns.Add(tempColName, typeof(double), cleanFormula);
            }
            catch (Exception ex)
            {
                // טיפול בשגיאות תחביר בנוסחה ללא קריסת המערכת
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"Error inside C# calculation for Formula {targilId}: {ex.Message}");
                Console.WriteLine($"Original: {formula} -> Translated: {cleanFormula}");
                Console.ResetColor();
                return resultsBuffer;
            }

            // איסוף התוצאות לטבלת הפלט
            foreach (DataRow row in sourceData.Rows)
            {
                // טיפול בערכי NULL למניעת שגיאות המרה
                object rawValue = row[tempColName];
                double finalResult = (rawValue == DBNull.Value) ? 0.0 : Convert.ToDouble(rawValue);

                resultsBuffer.Rows.Add(
                    row["data_id"],
                    targilId,
                    "C# .NET Optimized",
                    finalResult
                );
            }

            // ניקוי סופי: החזרת הטבלה למצבה המקורי
            if (sourceData.Columns.Contains(tempColName))
                sourceData.Columns.Remove(tempColName);

            return resultsBuffer;
        }
    }
}