WITH lifetime_days AS(

SELECT
s.customerkey,
max(s.orderdate) - min(s.orderdate)  AS lifetime_days
FROM sales s 
INNER JOIN customer c 
ON s.customerkey = c.customerkey
WHERE c.country ='NL'
GROUP BY s.customerkey
)

SELECT 
sum(ld.lifetime_days) AS total_lifetime_days,
count(ld.customerkey) AS total_number_of_customers,
percentile_cont(0.5) WITHIN GROUP (ORDER BY ld.lifetime_days) AS median_value,
(sum(ld.lifetime_days)/count(ld.customerkey)) AS mean
FROM 
lifetime_days ld
WHERE ld.lifetime_days>=1
