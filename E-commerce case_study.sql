-- Goal:- The goal was to analyze customer behavior, product performance, and sales patterns , with the intent of providing actionable insights to
--  improve customer retention, inventory planning, and marketing efficiency.

-- Task: Describe the Tables:
describe customers;
describe orderdetail;
describe orders;
describe products;

select * from customers;
select * from orderdetail;
select * from orders;
select * from products;

-- Market Segmentation Analysis
-- Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.
select location, count(customer_id) as number_of_customers
from customers
group by location
order by number_of_customers desc
limit 3;
 
with cte as( 
select location, count(customer_id) as number_of_customers,
dense_rank() over(order by count(customer_id) desc) as rn 
from customers group by location)
select location, number_of_customers
from cte
where rn<=3;
-- insights - we should focus in three major cities delhi,chennai,jaipur

-- Determine the distribution of customers by the number of orders placed. 
-- This insight will help in segmenting customers into one-time buyers, occasional shoppers,
--  and regular customers for tailored marketing strategies.
with cte as(
select customer_id, count(*) as numberoforders
from orders
group by customer_id 
)
select numberoforders,count(numberoforders) as customercount
from cte
group by numberoforders
order by numberoforders;
-- as the number of orders increases the customer count decreases.
-- - Retention Issue: Majority of customers don’t place repeat orders beyond 2 or 3 purchases.
-- - Loyalty Focus Needed: A loyalty program, discounts, or personalized engagement might boost repeat purchases.

with cte as(
select customer_id, count(*) as numberoforders,
case when count(*)=1 then 'One-time buyer'
when count(*)>4 then 'Regular Customers'
else 'Occasional Shoppers'
end as Customer_bucket
from orders
group by customer_id
) 
select Customer_bucket,count(*) as customer_count
from cte 
group by Customer_bucket;
-- insights:- High number of occaional shoppers so we should focus on coverting this customers into regular customers by providing personalized recommendation
--  and we can sent reminders through emails and sms.
-- Very low regular customers so we should have to work on  customers retention need improvment


-- identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.
SELECT p.name, 
       AVG(quantity) AS avg_quantity, 
       SUM(price_per_unit * quantity) AS total_revenue
FROM OrderDetail od 
join products p on od.product_id = p.product_id
GROUP BY p.name
HAVING AVG(quantity) = 2
ORDER BY total_revenue Desc 
limit 1;

-- insights:- smartphone 6 high revenue and preminum product target customers and advertise them the premium feature and emi support  

-- For each product category, calculate the unique number of customers purchasing from it. 
-- This will help understand which categories have wider appeal across the customer base.
select p.category, count(distinct o.customer_id) as unique_customers
from products p
join orderdetail od on  p.product_id = od.product_id
join orders o on o.order_id= od.order_id
group by p.category
order by unique_customers desc;
-- insights:-  Electronics category needs more focus as it is in high demand among the customers follwed by Wearable Tech

-- Analyze the month-on-month percentage change in total sales to identify growth trends.
with cte as
(select date_format(order_date,'%Y-%m') as month_year,sum(total_amount) as total_revenue
from orders
group by date_format(order_date,'%Y-%m')
),
cte2 as
(select month_year,total_revenue, lag(total_revenue) over(order by month_year) as prev_month_revenue
from cte )
select month_year,total_revenue, prev_month_revenue,round((total_revenue-prev_month_revenue)/prev_month_revenue*100,2) as PercentChange
from cte2;
-- insights:-  (Strong Growth) → April (+115.97), July (+146.92), December (+141.01) → These months saw high growth,strong demand or seasonal impact.
--  (Major Drop) →- May (-7.16), June (-34.26), August (-29.91), October (-48.86), February (-74.53) → These months faced significant declines, suggesting low demand
-- June, October, and February are weak, introduce discounts, promotions, or customer retention strategies during those times.


-- Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.
 with cte as(
 select date_format(order_date,'%Y-%m') as Month , avg(total_amount)as AvgOrderValue 
 from orders 
 group by date_format(order_date,'%Y-%m')
 ),
 cte2 as
 (select Month,AvgOrderValue,lag(avgordervalue) over(order by Month) as prev_amount
 from cte)
 select Month,AvgOrderValue,round(avgOrdervalue-prev_amount) as ChangeinValue
 from cte2
 order by month;
--  insights-- Major Growth :-- April , June , August , November , December (36,179)  December has the highest spike,
--  Sharp Declines  →July, October (-38,792), January, February (-85,583) - October and February show drastic drops,

-- Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.
select p.product_id,p.name, count(order_id) as Salesfrequency 
from orderdetail od
join products p on od.product_id = p.product_id
group by p.name,p.product_id
order by salesfrequency desc
limit 5;
-- insights:-product_id 7 has the highest turnover rates and needs to be restocked frequently followed by 3,4,2,8 also

-- List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.
select count(*) as customer_base from customers;

SELECT od.product_id, p.name, COUNT(DISTINCT o.customer_id) AS customer_count
FROM orders o
JOIN orderdetail od ON o.order_id = od.order_id
JOIN products p ON p.product_id = od.product_id
GROUP BY od.product_id, p.name
HAVING COUNT(DISTINCT o.customer_id) < (SELECT COUNT(*) * 0.4 FROM customers);
-- insights :- implement of target marketing campaign to raise awareness and interest

-- Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.
-- the count of the number of customers who made the first purchase on monthly basis.
with cte as(
select customer_id, date_format(min(order_date),'%Y-%m') as first_purchase
from orders
group by customer_id
)
select First_purchase as firstPurchaseMonth, count(distinct customer_id) as TotalNewCustomers
from cte
group by First_purchase
order by first_purchase;
-- insights:- overeall there is a downward trend that means compaign are not much effective 

-- Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.
select date_format(order_Date,'%Y-%m') as Month, sum(total_amount) TotalSales
from orders
group by date_format(order_Date,'%Y-%m')
order by TotalSales desc
limit 3;
-- insights:- sep and december are the  months of major restocking of product and increased staffs



















































