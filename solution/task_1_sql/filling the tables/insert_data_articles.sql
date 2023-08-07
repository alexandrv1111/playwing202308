--articles

use test_tasks;
go

SET IDENTITY_INSERT smpl.articles ON;  
GO

BEGIN TRY
    BEGIN TRAN

    If(OBJECT_ID('tempdb..#Temp_smpl_articles') Is Not Null)
    DROP TABLE #Temp_smpl_articles

    CREATE TABLE #Temp_smpl_articles (
        _key INTEGER, 
        id INTEGER, 
        name VARCHAR(200) NOT NULL, 
        country_code CHAR(2),
        country_name VARCHAR(255),
        description TEXT,
        price FLOAT(2),
        valid_from DATETIME,
        valid_to DATETIME
    )

    DECLARE @path varchar(MAX) = PATH_TO_GENERATED_ARTICLES_CSV
    DECLARE @SQL_BULK VARCHAR(MAX)
    SET @SQL_BULK = 'BULK INSERT #Temp_smpl_articles FROM ''' + @path + ''' WITH
            (
            FIRSTROW = 2,
            FIELDTERMINATOR = ''\t'',
            KEEPNULLS
            )'
    EXEC (@SQL_BULK)


    INSERT INTO smpl.articles(
        _key,
        article_id,
        name,
        country_code,
        country_name,
        description,
        price,
        valid_from,
        valid_to) 
    SELECT _key,
        id,
        name,
        country_code,
        country_name,
        description,
        price,
        valid_from,
        valid_to
    FROM #Temp_smpl_articles


    If(OBJECT_ID('tempdb..#Temp_smpl_articles') Is Not Null)
    DROP TABLE #Temp_smpl_articles

    COMMIT TRAN

    END TRY
BEGIN CATCH
    ROLLBACK TRAN
END CATCH

SET IDENTITY_INSERT smpl.articles OFF;  
GO


