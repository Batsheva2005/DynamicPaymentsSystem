-- 1. יצירת מסד הנתונים (אם אינו קיים)
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DynamicPaymentsDB')
BEGIN
    CREATE DATABASE DynamicPaymentsDB;
END
GO

USE DynamicPaymentsDB;
GO

-- 2. טבלת הנתונים (t_data)
-- טבלה זו מכילה את הנתונים הגולמיים (מיליון רשומות) עליהם יתבצע החישוב.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 't_data')
BEGIN
    CREATE TABLE t_data (
        data_id INT IDENTITY(1,1) PRIMARY KEY, -- מזהה רץ אוטומטי
        a FLOAT NOT NULL,
        b FLOAT NOT NULL,
        c FLOAT NOT NULL,
        d FLOAT NOT NULL
    );
END
GO

-- 3. טבלת הנוסחאות (t_targil)
-- מכילה את החוקים העסקיים (Business Logic) כטקסט דינמי.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 't_targil')
BEGIN
    CREATE TABLE t_targil (
        targil_id INT PRIMARY KEY,
        targil VARCHAR(255) NOT NULL,     -- הנוסחה עצמה
        tnai VARCHAR(255) NULL,           -- תנאי לביצוע (אופציונלי)
        targil_false VARCHAR(255) NULL    -- ערך במידה והתנאי לא מתקיים
    );
END
GO

-- 4. טבלת התוצאות (results)
-- מרכזת את הפלט של כל מנועי החישוב (SQL ו-C#) לצורך השוואה.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'results')
BEGIN
    CREATE TABLE results (
        results_id INT IDENTITY(1,1) PRIMARY KEY,
        data_id INT NOT NULL,
        targil_id INT NOT NULL,
        method VARCHAR(50) NOT NULL, -- שם השיטה שביצעה את החישוב
        result FLOAT NULL,
        
        -- הגדרת מפתחות זרים לשמירה על שלמות הנתונים
        FOREIGN KEY (data_id) REFERENCES t_data(data_id),
        FOREIGN KEY (targil_id) REFERENCES t_targil(targil_id)
    );
END
GO

-- 5. טבלת לוגים (t_log)
-- משמשת לניטור ביצועים ומדידת זמני ריצה.
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 't_log')
BEGIN
    CREATE TABLE t_log (
        log_id INT IDENTITY(1,1) PRIMARY KEY,
        targil_id INT NOT NULL,
        method VARCHAR(50) NOT NULL,
        run_time FLOAT NULL, -- זמן הריצה בשניות
        
        FOREIGN KEY (targil_id) REFERENCES t_targil(targil_id)
    );
END
GO