WITH cat_age AS(
SELECT
EXTRACT(YEAR FROM orderdate) AS order_year,
p.categoryname,
concat(givenname, ' ', middleinitial, ' ', surname) AS name,
(CASE WHEN age<'35' THEN 'young adult'
WHEN age BETWEEN '35' AND '55' THEN 'middle-aged adult'
WHEN age>'55' THEN 'senior' END) AS age_category,
sum((s.quantity * s.netprice) / s.exchangerate) AS net_revenue
FROM sales s 
LEFT JOIN customer c
ON s.customerkey=c.customerkey
LEFT JOIN product p 
ON s.productkey=p.productkey
WHERE country ='NL'
GROUP BY order_year,name,age,age_category,categoryname
)

SELECT 
ca.categoryname,
sum(ca.net_revenue) AS total_revenue_category

FROM cat_age ca
WHERE age_category='senior' AND order_year='2018'
GROUP BY ca.categoryname