WITH category_nl AS(
SELECT 
p.categoryname,
c.country,
EXTRACT(YEAR FROM orderdate) AS order_year,
SUM((s.quantity * s.netprice) / s.exchangerate) AS total_net_revenue
FROM sales s
LEFT JOIN product p ON s.productkey = p.productkey
LEFT JOIN customer c ON s.customerkey = c.customerkey
WHERE country = 'NL'
GROUP BY categoryname, country, order_year
)

SELECT
	categoryname,
	sum(CASE WHEN order_year = '2015' THEN (f.total_net_revenue)END) AS total_product_revenue_2015,
	sum(CASE WHEN order_year = '2016' THEN (f.total_net_revenue)END) AS total_product_revenue_2016,
	sum(CASE WHEN order_year = '2017' THEN (f.total_net_revenue)END) AS total_product_revenue_2017,
	sum(CASE WHEN order_year = '2018' THEN (f.total_net_revenue)END) AS total_product_revenue_2018,
	sum(CASE WHEN order_year = '2019' THEN (f.total_net_revenue)END) AS total_product_revenue_2019,
	sum(CASE WHEN order_year = '2020' THEN (f.total_net_revenue)END) AS total_product_revenue_2020,
	sum(CASE WHEN order_year = '2021' THEN (f.total_net_revenue)END) AS total_product_revenue_2021,
	sum(CASE WHEN order_year = '2022' THEN (f.total_net_revenue)END) AS total_product_revenue_2022,
	sum(CASE WHEN order_year = '2023' THEN (f.total_net_revenue)END) AS total_product_revenue_2023,
	sum(CASE WHEN order_year = '2024' THEN (f.total_net_revenue)END) AS total_product_revenue_2024
FROM
	category_nl f
GROUP BY
	categoryname
