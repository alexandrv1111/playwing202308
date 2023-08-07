WITH
cteReports (
    t_id
    ,t_articleKey
    ,a_articleKey
    ,t_articleId
    ,a_articleId
    ,country_code
    ,country_name
    ,a_articleName
    ,a_price
    ,amount
    ,revenue
    ,creation_timestamp
    ,year
    ,quarter
	) 
	AS (
		SELECT
        t.[t_id] as t_id
        ,t.[article_key] as t_article_key
        ,a.[_key] as a_articlekey
        ,t.[article_id] as t_articleId
        ,a.[article_id] as a_articleId
        ,a.country_code
        ,a.country_name
        ,a.name as a_articleName
        ,a.price as a_price
        ,t.[amount]
        ,t.[amount] * a.price as revenue
        ,t.[creation_timestamp]
        ,t.year
        ,t.quarter
		FROM [test_tasks].[smpl].[transactions] t
		left join [test_tasks].[smpl].[articles] a
        on t.[article_key] = a._key
	)

SELECT
  count(t_id) #_of_transactions
  ,country_name
  ,sum(amount) as #_of_ordered_items
  ,sum(revenue) revenue_at_country
  FROM cteReports 
WHERE 
year=2023 and 
quarter=1
GROUP BY (country_name)
ORDER BY revenue_at_country desc
GO