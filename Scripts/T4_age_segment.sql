WITH customer_info AS(
SELECT
EXTRACT(YEAR FROM orderdate) AS order_year,
concat(givenname, ' ', middleinitial, ' ', surname) AS name,
(CASE WHEN age<'35' THEN 'young adult'
WHEN age BETWEEN '35' AND '55' THEN 'middle-aged adult'
WHEN age>'55' THEN 'senior' END) AS age_category,
sum((s.quantity * s.netprice) / s.exchangerate) AS net_revenue
FROM sales s 
LEFT JOIN customer c
ON s.customerkey=c.customerkey
WHERE country ='NL'
GROUP BY order_year,name,age,age_category
)

SELECT 
age_category,
sum(CASE WHEN order_year='2015' THEN (ci.net_revenue)END) AS age_category_revenue_2015,
sum(CASE WHEN order_year='2016' THEN (ci.net_revenue)END) AS age_category_revenue_2016,
sum(CASE WHEN order_year='2017' THEN (ci.net_revenue)END) AS age_category_revenue_2017,
sum(CASE WHEN order_year='2018' THEN (ci.net_revenue)END) AS age_category_revenue_2018,
sum(CASE WHEN order_year='2019' THEN (ci.net_revenue)END) AS age_category_revenue_2019,
sum(CASE WHEN order_year='2020' THEN (ci.net_revenue)END) AS age_category_revenue_2020,
sum(CASE WHEN order_year='2021' THEN (ci.net_revenue)END) AS age_category_revenue_2021,
sum(CASE WHEN order_year='2022' THEN (ci.net_revenue)END) AS age_category_revenue_2022,
sum(CASE WHEN order_year='2023' THEN (ci.net_revenue)END) AS age_category_revenue_2023,
sum(CASE WHEN order_year='2024' THEN (ci.net_revenue)END) AS age_category_revenue_2024
FROM customer_info ci

GROUP BY age_category
