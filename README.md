## REVENUE ANALYSIS AND CUSTOMER BEHAVIOR
### OVERVIEW
The primary aim of every retail business is to improve revenue and optimize profits and this is majorly dependent on customer behavior and product performance in terms of profits and revenue. Considering a retail store whose customer base cuts across 8 countries and I investigated the profit and revenue generated from Netherlands’ customers, product performance from patronage of Netherlands customers and the overall behavior of Netherlands’ customers in their various segments. The Contoso demo datasets from Microsoft was utilized because it is a typical retail store datasets that creates the opportunity to explore data warehousing and business intelligence tools in real world scenario.<br>

**OBJECTIVE:** Carry out profit and revenue analysis, investigate product performance and understand customer behavior through segmentation for all sales from Netherlands.    

**Business Questions**
1)	Which year generates the most profit alongside the percentage profit change per year 
2)	Which quarter of the year and weekday generate the most revenue per year
3)	Which product category generates the most profit per year and what is the average order value (AOV) by product category 
4)	Which customer age group produces the most revenue
5)	What percentage of customers are repeat buyers
6)	What is the average churn rate of customers


### ANALYSIS APPROACH
In this part of the project, we intend to answer all the business questions in line with meeting the set objectives. We will show the various queries done on the dataset which are needed to investigate the profit revenue and behavior of Dutch customers.

*(1)* We investigated each year to find out the year with the most noticeable percentage profit change alongside their total yearly revenue.


**STEPS:** <br>
Created a common table expression (CTE) that;
* Joined the sales table and the customer table using the common customerkey column, Extracted the year from orderdate column,
* Calculated the total net profit for each year.

Finally, used a lag function to get the percentage yearly change of total net profit for each year. 

```
WITH category_profit_nl AS(
SELECT 
EXTRACT(YEAR FROM orderdate) AS order_year,
SUM(((netprice-unitcost)*quantity)/s.exchangerate) AS total_net_profit
FROM sales s
LEFT JOIN product p ON s.productkey = p.productkey
LEFT JOIN customer c ON s.customerkey = c.customerkey
WHERE country = 'NL'
GROUP BY order_year
)

SELECT
	cp.order_year,
	cp.total_net_profit,
	lag(cp.total_net_profit) over(ORDER BY cp.order_year) AS previous_year_profit,
	100*(cp.total_net_profit - lag(cp.total_net_profit) over(ORDER BY cp.order_year))/
	(lag(cp.total_net_profit) over(ORDER BY cp.order_year)) AS profit_change_percent
FROM
	category_profit_nl cp
```
<img src="latest\T1.jpg">

*Table 1.0: Table Showing Percentage Profit Change and Total Net profit by Order Year*

#### Key Findings:
Order year 2018 and 2022 show the highest increase in percentage change in profit <br>
Order year 2020 and 2024 show the lowest decrease in percentage change in profit <br>
Order Year 2020 and 2024 experience yearly profit dip.<br>
There is continuous increase in yearly profit from 2020 peaking at 2022 <br>
The highest profit years are 2022 and 2023

#### Business Insights:
* After year 2022 there is a reduction of percentage profit change up to the negative, denoting an end to the era of buying out of excitement and re-stocking after covid.
* The covid-19 lockdown hampered sales and hence the profit dip in 2020, while the major profit dip observed in 2024 is because the provided data only coveres for the first four months of the year 2024.
* The rise in profit after year 2020 shows increase in sales due to customers excitement and need to restock after the covid-19 lockdown.

*(2)* Which quarter and weekday of the year generated the most revenue per year <br>
We considered the quarters and the weekdays of each year to find out which quarter and year generated the highest revenue.

**STEPS:**  Maximum Quarter Revenue in Percent by Order Year <br>
Created two CTEs, the first contains 
* Yearly quarter column and quarter revenue.

Second CTE contains 
* The sum of quarter revenue partitioned by the order year using a windows function and the percent revenue per quarter also partitioned by order year.

Did a row_number rank to rank and order the percent revenue of quarter for each order year.<br>
Returned the quarter with maximum percentage revenue for each order year.  
```

WITH quarter_revenue AS (

SELECT 
EXTRACT(YEAR FROM orderdate) AS order_year,
EXTRACT(QUARTER FROM orderdate) AS quarter,
SUM((s.quantity * s.netprice) / s.exchangerate) AS total_quarter_revenue


FROM sales s 
LEFT JOIN customer c 
ON s.customerkey =c.customerkey
WHERE country ='NL'
GROUP BY order_year, quarter
),

check1 AS (

SELECT 
qr.order_year,
qr.quarter, 
qr.total_quarter_revenue,
sum(total_quarter_revenue) OVER (PARTITION BY order_year) AS total_quarter_revenue_per_year,
((total_quarter_revenue)/(sum(total_quarter_revenue) OVER (PARTITION BY order_year))*100) AS percent_revenue_per_quarter

FROM quarter_revenue qr
)

SELECT 
order_year,
quarter, 
percent_revenue_per_quarter


FROM
    (
	SELECT
	c.order_year,
	c.quarter, 
	c.percent_revenue_per_quarter,
	row_number() over(PARTITION BY c.order_year ORDER BY c.percent_revenue_per_quarter DESC) AS max_quarter_rank 
	
	FROM check1 c
	) 
	
WHERE max_quarter_rank = 1
```

 STEPS: Maximum Weekday Revenue in Percent by Order Year<br>
Created two CTEs, the first contains 
* Weekday column and net revenue per weekday. 

The second CTE contains
* The sum of net revenue per weekday partitioned by the order year using a windows function, and showed the percent revenue for each weekday partitioned by order year.

Ranked the percent revenue of weekday for each order year.<br>
Returned the weekday with maximum percent revenue for each order year.

```
WITH rev_day AS (
SELECT 
EXTRACT(YEAR FROM orderdate) AS order_year,
TO_CHAR(orderdate, 'day') AS weekday,
SUM((s.quantity * s.netprice) / s.exchangerate) AS total_net_revenue_day
FROM sales s 
LEFT JOIN customer c 
ON s.customerkey =c.customerkey
WHERE country ='NL'
GROUP BY weekday, order_year
),

revenue_per_weekday AS(

SELECT 
rd.order_year,
rd.weekday,
total_net_revenue_day,
SUM(rd.total_net_revenue_day ) OVER(PARTITION BY order_year) AS total_net_revenue_per_year,
((rd.total_net_revenue_day )/(SUM(rd.total_net_revenue_day ) OVER(PARTITION BY order_year))*100) AS percent_revenue_per_weekday

FROM rev_day rd

GROUP BY 
rd.weekday, rd.order_year, rd.total_net_revenue_day
)

SELECT 
order_year,
weekday,
percent_revenue_per_weekday

FROM 
 (SELECT 
	rwd.ORDER_year,
	rwd.weekday,
	rwd.percent_revenue_per_weekday,
	row_number() over(PARTITION BY rwd.order_year ORDER BY rwd.percent_revenue_per_weekday DESC) AS weekday_percent_revenue_rank 
	FROM revenue_per_weekday rwd
 )
WHERE weekday_percent_revenue_rank = 1

```

<img src="latest\T2.jpg">

*Table 1.1: Table Showing the Maximum Quarter Revenue and Maximum Weekday Revenue per Order Year*

#### Key Findings:
Quarter 1 and 4 generated the maximum percentage revenue in majority of the order years.<br>
Quarter 1 in year 2024 has the highest revenue in percentage compared to other maximum quarter revenues.<br>
Maximum revenue is generated on Saturdays in most of the order years.<br>
Saturday in 2017 generated the highest revenue in percentage compared to other maximum weekday revenues.

#### Business Insights:     
* The maximum percentage revenue generated in quarter 1 is attributed to the beginning of the year shopping done by customers to carry them mostly through the year while that of quarter 4 is attributed to holiday shopping mode coming from the euphoria of the festive season and also the availability of holiday bonuses and other incentives given to customers in their various workplaces.

*(3)* Which product category generates the most profit per year and what is the average order value (AOV) by product category <br> 
The various profits from each product category were investigated and also with their average order value.<br>

**STEPS:** profit per year for each category <br>
Created a CTE that contains;
* The extracted order year and the calculated total net profit for each category name. 
* Use Join functions on the sales table, product table and customer table.

A case statement was done to filter out the profits of product category base on the order year.
```

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

```

**STEPS**: AOV per year for each category<br>
Created a CTE that includes 
* the number of orders, 
* order year and the sum of net revenue per order year.<br>

Calculated the average order year by dividing the total net revenue by the number of orders.
```
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

```
 <img src="latest\T3.png">

*Table 1.2: Table Showing Total Profit Revenue for each Product Category by Order Year*

#### Key Findings:
The computers category has the overall maximum profit revenue in all order years with its peak at 2022 while Games and Toys, and Audio category have the least.<br>
There is increase in profit revenue for all product categories as seen in year 2019 and 2022 but this is most noticeable in categories like Computers, Home Appliances, TV and Videos, and Cell phones.<br>
There is a decrease in profit revenue for all categories in year 2020 and 2024, this decrease is majorly visible in categories like Computers, Home Appliances, TV and Videos, and Cell phones.<br>
```
```


 <img src="latest\T4.jpg">

*Table 1.3: Table Showing the Average Order Value by Order Year*

#### Key Findings:
Computers have the highest AOV compared to other categories for each order year.<br>
The AOV for computers shows a gradual decrease over the years.<br>
Games and Toys, Audio, and Music, Movies and Audio books categories are at the lowest bottom due to their low AOVs.

#### Business Insights:
* The gradual decrease in AOV for computers even with increase in profit revenue and number of items sold.
* indicate that there was a major drop in the price of computers.
* The decrease in AOV of computers is because most customers were not working and so computer usage and sales dropped.
* There was a bit of increase in the AOV of Home appliances, and TV & Video, this is attributed to the fact that customers increased their spendings on items much relevant to their lock-down situation.

*(4)* Which customer age group produces the most revenue<br>
The customer age column was used for segmentation into various age groups,
* Senior = age > ’55’
* Middle-aged Adult = age between ‘35’ and ‘55’
* Young Adult = age < ’35’

**STEPS:**
Created a CTE that contains;<br>
* Extracted order year from order date column,
* Case statement to categorize the age column,
* Sum of the net revenue for each category.

Use a Case statement to get the sum of the age category revenue for the different order years.

```
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

```
<img src="latest\T5.png">

*Table 5: Table Showing Age Category Revenue by Order Year*

#### Key Findings:
The Senior category generated the highest revenue in almost all the order years.<br>
Over the years the graph showing revenue from all categories have shown similar movement in increase and decrease.<br>
The Senior category is below the middle-aged category only in year 2017.

#### Business Insights:
* The high revenue generated by the senior category is due to the high patronage of the computer, Home Appliances and Cellphones by this category.
* The drop in the senior category in year 2017 is due to the drop in revenue from Home Appliances, and Cameras & Camcorders in this year.

*(5)* What percentage of customers are repeat buyers<br>
The total number of customers and the percentage of repeat customers were considered for different order years.<br>

**STEPS:**<br>
Created four CTEs,
* Customer_first_purchase: containing order year and the first purchase
* Customer_cat: containing Case statement to categorize the customers purchase into first or repeat purchase.
* Customer_total: containing the total number of customers per year.
* Repeat_customers: containing the number of customers per year with repeat purchase.

Compute the percentage of repeat customers for each order year.
```
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
```
<img src="latest\T6.jpg"> 

*Table 6: Table Showing Percentage of Repeat Customers and Total Number of Customer by Order Year*

#### Key Findings:
There is a slow upward trend in the percentage of repeat customers over the years.<br>
There is a major dip in the total number of customers in 2020 and 2024.<br>
Percentage of repeat customers is highest in year 2024 with less than 60% and lowest in year 2016

#### Business Insights:
* The slow upward trend is an indication that there is increase in customer retention over the years even in years which showing decline in customer numbers.
* The dip in 2020 is attributed to the drop in patronage as a result of covid-19 breakout.
* The dip in 2024 is due to incomplete data as only data for the first four months was provided.

*(6)* What is the average churn rate of customers<br>
Customers whose last purchase was done in year 2022 and below are churned out while those with last purchase dates higher than 2022 are considered active. This categorization was done for customers whose first purchase date was below 2022.

**STEPS:**<br>
Created a CTE containing 
* First order date,
* Customer status resulting from a case statement categorizing customers into active and churn status.

Extract year from order date.
Use Count function to get the number of customers.
Sum the number of customers, partitioned this result by year using windows function.
Get the percentage of each customer status by dividing the number of customers in each status by total number of customers, partitioned by the year using a windows function.

```
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

```

<img src="latest\T7.jpg">

*Table 7: Table Showing Percentage of Customer Status by Order Year*

#### Key Insights:
There is a gradual increase in the percentage of active customers and gradual decrease in churned customers over the years.<br>
The highest percentage of active customers making about 34% was recorded in year 2022 and the least percent of about 18% was recorded in year 2015 and 2016.<br>
The minimum churn rate in all the order years is 65% and it went as high as 82%. 

#### Business Insights:
* The minimum churn rate of about 65% percentage is very far from the acceptable churn rate which is between 2 – 10%.
* The gradual decrease in churn rate is important as it shows the possibility to hit the acceptable churn rate of at most 10%. So clearly there is an increase in customers tendency to repeat buy after the first purchase.
* It is encouraging that customers activities gradually increase with the order years


### STRATEGIC RECOMMENDATIONS
From the insights from analysis and visualizations done we provide recommendations on how to increase daily and quarterly product revenue, and reduce churned and inactive customers in the Netherlands.

**Churned Customers**

These are recommended for aggressive improvement of the slow increase in customers activities seen over the years.

* Reward long-term customers (customers for more than 2years) with exclusive benefits, discounts, or early access to new features.
* Provide discounts or promotions tailored to individual customer purchase history or behavior.
* Target the large pool of churned customers with special offers or new features to encourage possible return.
* Be honest about changes, price adjustments, or any issues.
* Showcase how other customers are successfully using your product, inspiring others.
* Use the information from customer survey to enhance products and improve service. 

**Repeat Buyers**

Customers repeat buy increases very slowly and these are the recommendations for drastic improvement. 

* Provide exceptional post-purchase experience through timely order updates, fast and reliable delivery, and easy returns and purchases.
* Tailor product recommendations based on past purchases, browse history, or stated preferences.
* Send relevant emails (e.g., reorder reminders, abandoned cart follow-ups, birthday discounts)
* Reward customers with points for every purchase, which can be redeemed for discounts or exclusive items.
* Offer increasing benefits as customers reach higher spending tiers
* Provide excellent Customer Service
* Build community and engagement where customers can share their experience with the brand

**Product Category** <br>
These are the recommendations to improve profit for the low revenue middle-aged and youth product category.
* Increase sales campaign on Uptodate and exciting features on Middle-Aged and Youth friendly product categories like Audio, Games and Toys, Movies, Music and Audio books, and Cameras and Camcorders.
* Encourage Cross-Selling and Up-Selling by promoting buying of low AOV products at a discount price in addition to high AOV categories at a higher price so as to increase the sales of both products. The low AOV products are the more middle-aged and youth type of items.
* Set up a minimum order value for free shipping and discounts for the low AOV product category.

**Quarter Revenue** <br>
These are the recommendations for increasing revenue for low revenue quarters Q2 and Q3
* Use clearance Sales on Q2 and Q3 to clear out old inventory and freeing up capital for new stock. 
* Introduce new seasonal products suitable for the Middle-aged and Youths in Q2 and Q3.
* Generate urgency for customers to shop in Q2 and Q3 by creating limited time offer through time-sensitive sales events within this period.
* Optimize inventory to avoid overstocking in Q2 and Q3, reducing holding costs.
* Reduce operational costs in Q2 and Q3 without sacrificing quality or customer experience.

**Daily Revenue**
* Offer specific discounts and flash sales separately for weekdays and weekends.
* Run digital ad campaigns specifically scheduled to promote offers on weekdays and send out reminders on these offers.
* Encourage loyalty program redemptions or point accumulation separately on weekdays and weekends shopping.
* Use the weekdays to give customers a unique look at the new or upcoming exciting features of all items on sale.

### LIMITATION
The given sales data for order year 2024 only captures the first four months of the year, causing a major decline in profits and revenue in that year.
### TECHNICAL DETAILS:
* Programming language: SQL was used to manipulate and manage the database 
* Databases: PostgreSQL is the relational database management system that was used in storing and querying the structured data 
* Analysis Tools used: PostgreSQL, DBeaver and PgAdmin
* Code Editors: VScode and DBeaver code editors were used in executing the Sql queries and managing the database. 
* Version Control: Git and Github were used in version control and sharing of the Sql scripts and analysis, creating room for collaboration and project tracking.
* Visualization: Power BI Desktop and Gemini.


