USE DynamicPaymentsDB;
GO

SET NOCOUNT ON; 

-- חלק א': יצירת מיליון רשומות נתונים
-- שימוש בטכניקת CROSS JOIN ליצירה מהירה של נתונים (הרבה יותר מהיר מלולאה רגילה)
DECLARE @TargetCount INT = 1000000;
DECLARE @BatchSize INT = 10000;
DECLARE @CurrentCount INT = 0;

-- בדיקה אם הנתונים כבר קיימים כדי למנוע כפילויות
IF (SELECT COUNT(*) FROM t_data) < @TargetCount
BEGIN
    PRINT 'Starting data generation...';

    WHILE @CurrentCount < @TargetCount
    BEGIN
        INSERT INTO t_data (a, b, c, d)
        SELECT TOP (@BatchSize)
            ABS(CHECKSUM(NEWID()) % 1000) * 1.0, 
            ABS(CHECKSUM(NEWID()) % 500) * 1.0,  
            ABS(CHECKSUM(NEWID()) % 100) * 1.0,  
            ABS(CHECKSUM(NEWID()) % 50) * 1.0    
        FROM sys.all_columns AS t1
        CROSS JOIN sys.all_columns AS t2;
        
        SET @CurrentCount = @CurrentCount + @BatchSize;
        RAISERROR('Inserted %d rows...', 0, 1, @CurrentCount) WITH NOWAIT;
    END
    PRINT 'Done! 1,000,000 rows inserted.';
END
ELSE
BEGIN
    PRINT 'Data already exists. Skipping generation.';
END
GO

-- חלק ב': אתחול טבלת הנוסחאות
-- מחיקת נתונים ישנים לפני טעינה מחדש
DELETE FROM t_targil;

-- 1. חיבור פשוט
INSERT INTO t_targil (targil_id, targil, tnai, targil_false) VALUES (1, 'a + b', NULL, NULL);

-- 2. כפל בקבוע
INSERT INTO t_targil (targil_id, targil, tnai, targil_false) VALUES (2, 'c * 2', NULL, NULL);

-- 3. חישוב מורכב (סדר פעולות חשבון)
INSERT INTO t_targil (targil_id, targil, tnai, targil_false) VALUES (3, '(a + b) * 8', NULL, NULL);

-- 4. פונקציית ערך מוחלט (ABS)
-- הערה: המערכת תומכת בפונקציה זו ע"י תרגום לוגי (Transpilation) בקוד
INSERT INTO t_targil (targil_id, targil, tnai, targil_false) VALUES (4, 'ABS(d - b)', NULL, NULL);

-- 5. סכום ריבועים
INSERT INTO t_targil (targil_id, targil, tnai, targil_false) VALUES (5, '(c * c) + (d * d)', NULL, NULL);

-- 6. תנאי לוגי: בונוס שכר
-- לוגיקה: אם שכר הבסיס (a) גבוה מ-500, הבונוס הוא 20%, אחרת 5%
INSERT INTO t_targil (targil_id, targil, tnai, targil_false) 
VALUES (6, 'if(a > 500, b * 1.20, b * 1.05)', 'a > 500', 'b * 1.05');

-- 7. תנאי לוגי: תמריץ נוכחות
-- לוגיקה: אם היו פחות מ-5 היעדרויות (c), קבל תוספת 200 לשכר
INSERT INTO t_targil (targil_id, targil, tnai, targil_false) 
VALUES (7, 'if(c < 5, a + 200, a)', 'c < 5', 'a');

-- 8. תנאי לוגי: בדיקת שוויון
-- תמיכה בתחביר השוואה כפול (==) בהתאם לדרישות המערכת
INSERT INTO t_targil (targil_id, targil, tnai, targil_false) 
VALUES (8, 'if(a == c, 1, 0)', 'a == c', '0');

GO