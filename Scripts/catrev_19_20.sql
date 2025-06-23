WITH customer_info2 AS(
SELECT
EXTRACT(YEAR FROM orderdate) AS order_year,
p.categoryname,
(CASE WHEN age<'35' THEN 'young adult'
WHEN age BETWEEN '35' AND '55' THEN 'middle-aged adult'
WHEN age>'55' THEN 'senior' END) AS age_category,
sum((s.quantity * s.netprice) / s.exchangerate) AS net_revenue
FROM sales s 
LEFT JOIN customer c
ON s.customerkey=c.customerkey
LEFT JOIN product p 
ON s.productkey = p.productkey
WHERE country ='NL'
GROUP BY order_year,age,age_category,p.categoryname
)

SELECT 
categoryname,
order_year,
sum(net_revenue) AS total_rev
FROM customer_info2 ci2
WHERE ci2.order_year BETWEEN '2019' AND '2020' AND  ci2.age_category='senior'
GROUP BY categoryname, order_year

