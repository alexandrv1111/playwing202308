

use test_tasks;
go

SET IDENTITY_INSERT smpl.clients ON;  
GO

BEGIN TRY
    BEGIN TRAN

    If(OBJECT_ID('tempdb..#Temp_smpl_clients') Is Not Null)
    DROP TABLE #Temp_smpl_clients

    CREATE TABLE #Temp_smpl_clients
    (
        _key INTEGER, 
        client_id INTEGER, 
        fname VARCHAR(200), 
        lname VARCHAR(200), 
        country_code CHAR(2), 
        country_name VARCHAR(255), 
        city VARCHAR(255),
        address TEXT
    )

    DECLARE @path VARCHAR(MAX) = PATH_TO_GENERATED_CLIENTS_CSV
    DECLARE @SQL_BULK VARCHAR(MAX)
    SET @SQL_BULK = 'BULK INSERT #Temp_smpl_clients FROM ''' + @path + ''' WITH
            (
            FIRSTROW = 2,
            FIELDTERMINATOR = ''\t'',
            KEEPNULLS
            )'
    EXEC (@SQL_BULK)

    INSERT INTO smpl.clients(
        _key,
        client_id,
        first_name,
        last_name,
        country_code,
        country_name,
        city,
        address
        ) 
    SELECT
        _key,
        client_id,
        fname,
        lname,
        country_code,
        country_name,
        city,
        address
    FROM #Temp_smpl_clients

    If(OBJECT_ID('tempdb..#Temp_smpl_clients') Is Not Null)
    DROP TABLE #Temp_smpl_clients
    
    COMMIT TRAN
    END TRY
BEGIN CATCH
    ROLLBACK TRAN
END CATCH



SET IDENTITY_INSERT smpl.clients OFF;  
GO
