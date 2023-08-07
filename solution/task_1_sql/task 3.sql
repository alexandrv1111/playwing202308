-- cte : each transaction consists from only 1 article (one with the highest price)

WITH cte_first_purchase (
	t_id, t_datetime, t_year, article_key, client_key, first_purchase, country_code, country_name, price)
	as (
	 SELECT 
	 	t_id
		,t.creation_timestamp
		,YEAR(t.creation_timestamp) as _year
		,t.article_key
		,t.client_key
		,t2.first_purchase 
		,a.country_code
		,a.country_name
		,a.price
	FROM [test_tasks].[smpl].transactions t
	INNER JOIN
		(SELECT
			client_key
			,min(creation_timestamp) as first_purchase
		FROM [test_tasks].[smpl].transactions
		GROUP BY client_key) t2
	ON t.client_key = t2.client_key AND t.creation_timestamp= t2.first_purchase
	LEFT JOIN smpl.articles a on t.article_key = a._key
	)

SELECT 
	t_year
	,avg(price) as avg_price
FROM cte_first_purchase
WHERE country_code='CA'
GROUP BY t_year
GO
