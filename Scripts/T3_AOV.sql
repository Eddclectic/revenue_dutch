WITH customer_net_revenue_year AS(
SELECT 
COUNT(orderkey)AS number_of_orders,
p.categoryname,
EXTRACT(YEAR FROM orderdate) AS order_year,
SUM((s.quantity * s.netprice) / s.exchangerate) AS total_net_revenue
FROM sales s 
LEFT JOIN product p 
ON s.productkey = p.productkey
LEFT JOIN customer c 
ON s.customerkey=c.customerkey
WHERE c.country='NL' 
GROUP BY p.categoryname,order_year
)
 SELECT 
 cr.order_year,
 cr.categoryname,
 cr.number_of_orders,
 cr.total_net_revenue,
 SUM(total_net_revenue/number_of_orders) AS average_order_value
 FROM 
 customer_net_revenue_year cr
 GROUP BY cr.order_year,
 cr.categoryname,
 cr.number_of_orders,
 cr.total_net_revenue

