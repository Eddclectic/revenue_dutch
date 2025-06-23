
WITH quarter_revenue AS (

SELECT 
EXTRACT(YEAR FROM orderdate) AS order_year,
EXTRACT(QUARTER FROM orderdate) AS quarter,
SUM((s.quantity * s.netprice) / s.exchangerate) AS total_quarter_revenue


FROM sales s 
LEFT JOIN customer c 
ON s.customerkey =c.customerkey
WHERE country ='NL'
GROUP BY order_year, quarter
),

check1 AS (

SELECT 
qr.order_year,
qr.quarter, 
qr.total_quarter_revenue,
sum(total_quarter_revenue) OVER (PARTITION BY order_year) AS total_quarter_revenue_per_year,
((total_quarter_revenue)/(sum(total_quarter_revenue) OVER (PARTITION BY order_year))*100) AS percent_revenue_per_quarter

FROM quarter_revenue qr
)

SELECT 
order_year,
quarter, 
percent_revenue_per_quarter


FROM
    (
	SELECT
	c.order_year,
	c.quarter, 
	c.percent_revenue_per_quarter,
	row_number() over(PARTITION BY c.order_year ORDER BY c.percent_revenue_per_quarter DESC) AS max_quarter_rank 
	
	FROM check1 c
	) 
	
WHERE max_quarter_rank = 1