WITH customer_first_purchase AS (

SELECT
s.orderdate,
EXTRACT(YEAR FROM orderdate) AS order_year,
s.customerkey,
min(s.orderdate) OVER(PARTITION BY s.customerkey) AS first_purchase

FROM sales s 
INNER JOIN customer c 
ON s.customerkey = c.customerkey
WHERE country ='NL'
GROUP BY orderdate, order_year, s.customerkey
),

customer_cat AS(
SELECT
cfp.order_year,
cfp.customerkey,
(CASE WHEN cfp.orderdate > cfp.first_purchase THEN 'repeat purchase'
ELSE 'first purchase' END) AS customer_category

FROM customer_first_purchase cfp
GROUP BY cfp.customerkey, cfp.order_year, cfp.orderdate, cfp.first_purchase
),

customer_total AS(
SELECT 
 cc.order_year,
 count(DISTINCT customerkey) AS total_no_of_customers
 
 FROM customer_cat cc
 GROUP BY cc.order_year
),


repeat_customers AS (
SELECT 
 cc.order_year,
 count(DISTINCT customerkey) AS total_no_of_repeat_customers
 
 FROM customer_cat cc
 WHERE customer_category='repeat purchase'
 GROUP BY cc.order_year
 )
 
 SELECT 
 rc.order_year,
 total_no_of_repeat_customers,
 total_no_of_customers,
 (100*total_no_of_repeat_customers/total_no_of_customers) AS percent_of_repeat_customers
 
 FROM 
 repeat_customers rc
 LEFT JOIN customer_total ct
 ON rc.order_year=ct.order_year