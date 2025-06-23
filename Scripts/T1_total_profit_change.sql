

WITH category_profit_nl AS(
SELECT 
EXTRACT(YEAR FROM orderdate) AS order_year,
SUM(((netprice-unitcost)*quantity)/s.exchangerate) AS total_net_profit
FROM sales s
LEFT JOIN product p ON s.productkey = p.productkey
LEFT JOIN customer c ON s.customerkey = c.customerkey
WHERE country = 'NL'
GROUP BY order_year
)

SELECT
	cp.order_year,
	cp.total_net_profit,
	lag(cp.total_net_profit) over(ORDER BY cp.order_year) AS previous_year_profit,
	100*(cp.total_net_profit - lag(cp.total_net_profit) over(ORDER BY cp.order_year))/
	(lag(cp.total_net_profit) over(ORDER BY cp.order_year)) AS profit_change_percent
FROM
	category_profit_nl cp

