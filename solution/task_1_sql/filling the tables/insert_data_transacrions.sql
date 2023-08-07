--transactions

use test_tasks;
go


BEGIN TRY
    BEGIN TRAN
If(OBJECT_ID('tempdb..#Temp_smpl_transactions') Is Not Null)
DROP TABLE #Temp_smpl_transactions

CREATE TABLE #Temp_smpl_transactions (
    id INTEGER, 
    t_datetime DATETIME NOT NULL, 
    client_id INTEGER, 
    client_key INTEGER, 
    article_id INTEGER, 
    article_key INTEGER, 
    amount INTEGER
)
DECLARE @path varchar(MAX) = PATH_TO_GENERATED_TRANSACTIONS_CSV
DECLARE @SQL_BULK VARCHAR(MAX)
SET @SQL_BULK = 'BULK INSERT #Temp_smpl_transactions FROM ''' + @path + ''' WITH
        (
        FIRSTROW = 2,
        FIELDTERMINATOR = ''\t'',
        KEEPNULLS
        )'
EXEC (@SQL_BULK)

INSERT INTO smpl.transactions(
	t_id,
	creation_timestamp,
	client_id,
	client_key,
	article_id,
	article_key,
	amount
	) 
SELECT
	id,
	t_datetime,
	client_id,
	client_key,
	article_id,
	article_key,
	amount
FROM #Temp_smpl_transactions


If(OBJECT_ID('tempdb..#Temp_smpl_transactions') Is Not Null)
DROP TABLE #Temp_smpl_transactions

    COMMIT TRAN
    END TRY
BEGIN CATCH
    ROLLBACK TRAN
END CATCH
