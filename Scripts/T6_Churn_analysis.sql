WITH first_purchase AS(
SELECT 
s.customerkey,
s.orderdate,
min(orderdate) over(PARTITION BY s.customerkey) AS first_order_date,
(CASE WHEN max(orderdate)>= current_date - INTERVAL '3years' THEN 'active'
ELSE 'churned' END) AS customer_status

FROM sales s
INNER JOIN customer c 
ON s.customerkey = c.customerkey
WHERE country ='NL'
GROUP BY s.customerkey, s.orderdate
)

SELECT 
EXTRACT(YEAR FROM fp.first_order_date) AS year_date,
fp.customer_status,
count(fp.customerkey) AS num_customers,
sum(count(fp.customerkey)) OVER(PARTITION BY EXTRACT(YEAR FROM fp.first_order_date)) AS total_cust,
round(count(fp.customerkey)/ sum(count(fp.customerkey)) over(PARTITION BY EXTRACT(YEAR FROM fp.first_order_date)),2) AS percent_of_status

FROM first_purchase fp
WHERE fp.first_order_date<current_date - INTERVAL '3years'
GROUP BY fp.customer_status, year_date
