
WITH category_profit_nl AS(
SELECT 
p.categoryname,
c.country,
EXTRACT(YEAR FROM orderdate) AS order_year,
SUM(((netprice-unitcost)*quantity)/s.exchangerate) AS total_net_profit
FROM sales s
LEFT JOIN product p ON s.productkey = p.productkey
LEFT JOIN customer c ON s.customerkey = c.customerkey
WHERE country = 'NL'
GROUP BY categoryname, country, order_year
)

SELECT
	categoryname,
	sum(CASE WHEN order_year = '2015' THEN (cp.total_net_profit)END) AS total_profit_revenue_2015,
	sum(CASE WHEN order_year = '2016' THEN (cp.total_net_profit)END) AS total_profit_revenue_2016,
	sum(CASE WHEN order_year = '2017' THEN (cp.total_net_profit)END) AS total_profit_revenue_2017,
	sum(CASE WHEN order_year = '2018' THEN (cp.total_net_profit)END) AS total_profit_revenue_2018,
	sum(CASE WHEN order_year = '2019' THEN (cp.total_net_profit)END) AS total_profit_revenue_2019,
	sum(CASE WHEN order_year = '2020' THEN (cp.total_net_profit)END) AS total_profit_revenue_2020,
	sum(CASE WHEN order_year = '2021' THEN (cp.total_net_profit)END) AS total_profit_revenue_2021,
	sum(CASE WHEN order_year = '2022' THEN (cp.total_net_profit)END) AS total_profit_revenue_2022,
	sum(CASE WHEN order_year = '2023' THEN (cp.total_net_profit)END) AS total_profit_revenue_2023,
	sum(CASE WHEN order_year = '2024' THEN (cp.total_net_profit)END) AS total_profit_revenue_2024
FROM
	category_profit_nl cp
GROUP BY
	categoryname
