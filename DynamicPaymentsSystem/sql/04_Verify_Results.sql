-- 1. בדיקת אימות נתונים (Data Integrity)
-- מטרה: לוודא ששתי שיטות החישוב (SQL ו-C#) הפיקו תוצאות זהות לחלוטין.
-- תוצאה צפויה: טבלה ריקה (0 שורות), המעידה על 0 פערים.

SELECT 
    T1.data_id,
    T1.targil_id,
    T1.result AS SQL_Result,
    T2.result AS CSharp_Result,
    (T1.result - T2.result) AS Diff 
FROM results T1
JOIN results T2 ON T1.data_id = T2.data_id AND T1.targil_id = T2.targil_id
WHERE 
    T1.method = 'SQL'           
    AND T2.method = 'C# .NET Optimized' 
    AND ABS(T1.result - T2.result) > 0.001; -- סובלנות לסטייה מזערית בנקודה צפה (Floating Point)


-- 2. דוח ביצועים והשוואה (Performance Report)
-- מטרה: השוואת זמני הריצה הממוצעים בין השיטות.

SELECT 
    method AS 'Calculation Method',
    COUNT(*) AS 'Formulas Processed',
    SUM(run_time) AS 'Total Time (Seconds)',
    AVG(run_time) AS 'Avg Time Per Formula'
FROM t_log
GROUP BY method
ORDER BY AVG(run_time) ASC;