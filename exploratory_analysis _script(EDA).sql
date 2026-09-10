select * from information_schema.tables

-- Retrieve a list of all tables in the database
SELECT 
    TABLE_CATALOG, 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES;

-- Retrieve all columns for a specific table (dim_customers)
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

select * from information_schema.columns
where table_name ='dim_customers'

/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/
-- Retrieve a list of unique countries from which customers originate
select distinct country from gold.dim_customers

-- Retrieve a list of unique categories, subcategories, and products
select 
distinct category, 
subcategory, 
product_name 
from gold.dim_products
order by 1,2,3

//*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/
-- Determine the first and last order date and the total duration in months
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- find the youngest and the oldest customer

select
min(birthdate) as oldest_birthdate,
datediff(year,min(birthdate),getdate()) oldest_age,
max(birthdate) youngest_birthdate,
datediff(year,max(birthdate),getdate()) youngest_age
from gold.dim_customers

/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/
-- find the total sales
 select sum(sales_amount) as total_sales from gold.fact_sales

-- find how many items are sold
select sum(quantity) as total_quantity from gold.fact_sales

-- find the average selling price
select avg(price) as avg_price from gold.fact_sales

-- find the total number of orders
select count(order_number) as total_orders from gold.fact_sales
select count(distinct order_number) as total_orders from gold.fact_sales

-- find the total number of products
select count(product_key) as total_products from gold.dim_products
select count(distinct product_key) as total_products from gold.dim_products

-- find the total number of customers
select count(customer_key) as total_customers from gold.dim_customers

-- find the total number of customers that has placed an order
select count(distinct customer_key) as total_customers from gold.fact_sales


--Generate  a Report that shows all key metrics of the business

select 'Total sales' as measure_name, sum(sales_amount) as measure_value from gold.fact_sales
union all
select  'Total Quantity' as measure_name, sum(quantity) as measure_value from gold.fact_sales
union all
select 'Avg Price' as measure_name, avg(price) as measure_value from gold.fact_sales
union all
select 'Total Nr. Orders', count(distinct order_number) from gold.fact_sales
union all
select 'Total Nr. Products' , count(product_name) from gold.dim_products
union all
select 'Total Nr. Customers', count(customer_key) from gold.dim_customers



/*
===============================================================================
Magnitude Analysis
===============================================================================
Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
===============================================================================
*/



-- find total customer by countries
select 
country,
count(customer_key) total_customers
from gold.dim_customers
group by country
order by total_customers desc

-- find total customers by gender
select 
gender,
count(customer_key) total_customers
from gold.dim_customers
group by gender 
order by total_customers desc

-- find total product by category
select 
category,
count(product_key) total_products
from gold.dim_products
group by category 
order by total_products desc

-- what is the average cost in each category?
select 
category,
avg(cost)  as avg_costs
from gold.dim_products
group by category
order by avg_costs desc

-- what is the total revenue generated for each category?
select 
p.category,
sum(f.sales_amount)as total_revenue
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.category
order by  total_revenue desc

-- find total revenue generayed by each customer
select 
c.customer_key,
c.first_name,
c.last_name,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
group by c.customer_key,
		 c.first_name,
		 c.last_name
order by total_revenue desc

-- what is the distribution of sold item across countries?
select 
country ,
sum(f.quantity) as total_sold_item
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
group by country
order by total_sold_item desc

/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- which 5 products generate the highest revenue?
select top 5
p.product_name ,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.product_name
order by total_revenue desc

select * from(
select 
p.product_name ,
sum(f.sales_amount) as total_revenue,
row_number() over(order by sum(f.sales_amount) desc) as rank_products
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.product_name) t
where  rank_products<=5;



-- what are the 5 worst- performing products in terms of sales?
select top 5
p.product_name ,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.product_name
order by total_revenue 


select * from (
select
p.product_name ,
sum(f.sales_amount) as total_revenue,
row_number() over(order by sum(f.sales_amount) asc) as rank_products
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.product_name
order by total_revenue ) t 
where rank_products <=5


--find top10 customers who have generated the highest revenue
select top 10
c.customer_key,
c.first_name,
c.last_name,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
group by c.customer_key,
		 c.first_name,
		 c.last_name
order by total_revenue desc


-- the 3 customers with the fewest orders placed
select top 3
c.customer_key,
c.first_name,
c.last_name,
count(distinct order_number) as total_revenue
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
group by c.customer_key,
		 c.first_name,
		 c.last_name
order by total_revenue desc
