WITH rev_day AS (
SELECT 
EXTRACT(YEAR FROM orderdate) AS order_year,
TO_CHAR(orderdate, 'day') AS weekday,
SUM((s.quantity * s.netprice) / s.exchangerate) AS total_net_revenue_day
FROM sales s 
LEFT JOIN customer c 
ON s.customerkey =c.customerkey
WHERE country ='NL'
GROUP BY weekday, order_year
),

revenue_per_weekday AS(

SELECT 
rd.order_year,
rd.weekday,
total_net_revenue_day,
SUM(rd.total_net_revenue_day ) OVER(PARTITION BY order_year) AS total_net_revenue_per_year,
((rd.total_net_revenue_day )/(SUM(rd.total_net_revenue_day ) OVER(PARTITION BY order_year))*100) AS percent_revenue_per_weekday

FROM rev_day rd

GROUP BY 
rd.weekday, rd.order_year, rd.total_net_revenue_day
)

SELECT 
order_year,
weekday,
percent_revenue_per_weekday

FROM 
 (SELECT 
	rwd.ORDER_year,
	rwd.weekday,
	rwd.percent_revenue_per_weekday,
	row_number() over(PARTITION BY rwd.order_year ORDER BY rwd.percent_revenue_per_weekday DESC) AS weekday_percent_revenue_rank 
	FROM revenue_per_weekday rwd
 )
WHERE weekday_percent_revenue_rank = 1
