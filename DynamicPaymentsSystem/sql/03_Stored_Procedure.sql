USE DynamicPaymentsDB;
GO

CREATE OR ALTER PROCEDURE sp_Calculate_Dynamic_SQL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TargilID INT;
    DECLARE @Formula VARCHAR(255);
    DECLARE @CleanFormula VARCHAR(255);
    DECLARE @StartTime DATETIME;
    DECLARE @EndTime DATETIME;
    DECLARE @DynamicSQL NVARCHAR(MAX);

    PRINT 'Starting calculation process (SQL Method with Transpilation)...';

    DECLARE cursor_formulas CURSOR FOR
    SELECT targil_id, targil
    FROM t_targil;

    OPEN cursor_formulas;
    FETCH NEXT FROM cursor_formulas INTO @TargilID, @Formula;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- שכבת תרגום (Transpilation Layer):
        -- התאמת הנוסחה מהפורמט העסקי (Excel-like) לפורמט של T-SQL
        SET @CleanFormula = @Formula;
        
        -- 1. המרת פקודת תנאי (if ל-IIF)
        SET @CleanFormula = REPLACE(@CleanFormula, 'if(', 'IIF(');
        
        -- 2. המרת אופרטור השוואה (== ל-=)
        SET @CleanFormula = REPLACE(@CleanFormula, '==', '=');

        
        PRINT 'Formula ID: ' + CAST(@TargilID AS VARCHAR) + 
              ' | Source: ' + @Formula + ' | Compiled: ' + @CleanFormula;

        SET @StartTime = GETDATE();

        -- בנייה והרצה של שאילתה דינמית (Dynamic SQL)
        SET @DynamicSQL = '
            INSERT INTO results (data_id, targil_id, method, result)
            SELECT data_id, ' + CAST(@TargilID AS VARCHAR) + ', ''SQL'', ' + @CleanFormula + '
            FROM t_data';

        BEGIN TRY
            EXEC sp_executesql @DynamicSQL;
        END TRY
        BEGIN CATCH
            PRINT 'Error in Formula ' + CAST(@TargilID AS VARCHAR) + ': ' + ERROR_MESSAGE();
        END CATCH

        SET @EndTime = GETDATE();

        -- תיעוד זמן הריצה
        INSERT INTO t_log (targil_id, method, run_time)
        VALUES (@TargilID, 'SQL', DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0);

        FETCH NEXT FROM cursor_formulas INTO @TargilID, @Formula;
    END;

    CLOSE cursor_formulas;
    DEALLOCATE cursor_formulas;
    PRINT 'Process Completed.';
END;
GO