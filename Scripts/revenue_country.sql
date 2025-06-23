SELECT 
c.country,

SUM((s.quantity * s.netprice) / s.exchangerate) AS total_net_revenue
FROM sales s
LEFT JOIN customer c ON s.customerkey = c.customerkey
GROUP BY country

