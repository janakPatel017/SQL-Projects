-- 1. Coffee Consumers Count
--    How many people in each city are estimated to consume coffee, given that 25% of the population does?
select
 city_name,
 round(
 (population*0.25)/1000000
 ,2)
 as coffee_consumers,
 city_rank
from city
order by 2 desc;

-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
select 
	c1.city_name,
	sum(s.total)as TOTAL_REVENUE 
	from sales as s
	join customers as c
	on s.customer_id=c.customer_id
	join city as c1
	on c1.city_id=c.city_id
	where Extract(YEAR from s.sale_date) =2023
	and 
	Extract(quarter from s.sale_date) =4
	group by c1.city_name
	order by 2 desc;

-- Sales Count for Each Product
-- How many units of each coffee product have been sold?
select
      p.product_name,
	  count(s.sale_id) as units
	  from
	  sales as s
	  JOIN
	  products as p 
	  ON
	  s.product_id=p.product_id
	  Group by
	  p.product_name
	  order by 2 Desc;

--Average Sales Amount per City
-- What is the average sales amount per customer in each city?
select 
	c1.city_name,
	sum(s.total)as TOTAL_REVENUE,
	count(distinct s.customer_id) as total_cx,
	ROUND(sum(s.total)/count(distinct s.customer_id)) as AVG_sales_per_customers
	from sales as s
	join customers as c
	on s.customer_id=c.customer_id
	join city as c1
	on c1.city_id=c.city_id
	group by c1.city_name
	order by 3 desc;
		
-- City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers
select 
	  c.city_name,
	  ROUND((c.population*0.25)/1000000,2) as population,
	  count(distinct s.customer_id)as EST_COFFEE_CONSUMERS
	  from city as c
	  join 
	  customers as c1
	  on 
	  c1.city_id=c.city_id
	  join 
	  sales as s
	  on 
	  c1.customer_id=s.customer_id
	  group by 1,2
	  order by 2 DESC;

-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
select *
from
(select
      c.city_name,
	  p.product_name as Products,
	  count(s.sale_id) as sales_volume,
	  dense_rank() Over(partition by c.city_name order by count(s.sale_id)desc) as rank
	  from products as p
	  join 
	  sales as s
	  on 
	  s.product_id=p.product_id
	  join 
	  customers as c1
	  on 
	  s.customer_id=c1.customer_id
	  join 
	  city as c
	  on 
	  c1.city_id=c.city_id
	  group by 1,2
)as t1
where rank<=3;

-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?
select 
	c1.city_name, 
	count(distinct s.customer_id) as unique_customer
	-- c.customer_name
	from sales as s
	join customers as c
	on s.customer_id=c.customer_id
	join city as c1
	on c1.city_id=c.city_id
	where
	s.product_id in (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
	group by 1;

-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer
select
	c1.city_name,
	sum(s.total)as TOTAL_REVENUE,
	c1.estimated_rent,
	count(distinct s.customer_id) as total_cx,
	ROUND(sum(s.total)/count(distinct s.customer_id)) as AVG_sales_per_customer,
	Round(c1.estimated_rent/count(distinct s.customer_id)) as AVG_rent_per_customer
	from sales as s
	join customers as c
	on s.customer_id=c.customer_id
	join city as c1
	on c1.city_id=c.city_id
	group by c1.city_name,c1.estimated_rent
	order by 6 desc;

-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
with 
monthly_sales
as
(select 
	c1.city_name, 
	EXTRACT(MONTH from s.sale_date) as sale_month,
	EXTRACT(YEAR from s.sale_date) as sale_year,
	sum(s.total) as Total_sales
	from sales as s
	join customers as c
	on s.customer_id=c.customer_id
	join city as c1
	on c1.city_id=c.city_id
	group by 1,2,3
	order by 1,3,2
),
current_last_month_sales
as
(
select
  	city_name,
	 sale_month,
	 sale_year,
	 total_sales as cr_month_sales,
	 LAG(total_sales,1) Over(partition by city_name order by sale_year,sale_month)as last_month_sales
from
monthly_sales
)
select
     city_name,
	 sale_month,
	 sale_year,
	 cr_month_sales,
	 last_month_sales,
	 ROUND((cr_month_sales-last_month_sales)::numeric/last_month_sales::numeric*100,2) as Growth_ratio
from
current_last_month_sales;

--Market Potential Analysis
--Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

with 
abcd
as
(
select
      c.city_name,
	  c.estimated_rent,
	  sum(s.total)as total_sale,
	  count(distinct s.customer_id) as total_customer,
	  round((c.population * 0.25)/1000000,2) as estimated_coffee_consumers_million 
	  from sales as s
	  join 
	  customers as cu
	  on 
	  cu.customer_id=s.customer_id
	  join 
	  city as c
	  on 
	  c.city_id=cu.city_id
	  group by 
	  c.city_name,c.estimated_rent,c.population
)
select
      city_name,
	  estimated_rent,
	  total_sale,
	  total_customer,
	  estimated_coffee_consumers_million,
	  round((total_sale/total_customer)::numeric,2) as Avg_sale_per_customers,
	  round((estimated_rent/total_customer)::numeric,2) as Avg_rent_per_customers
	  from
	  abcd;
/* 
Recommedations
City 1: Pune

1. Average rent per customer is very low.
2. Highest total revenue.
3. Average sales per customer is also high.

City 2: Delhi

1. Highest estimated coffee consumers at 7.7 million.
2. Highest total number of customers, which is 68.
3. Average rent per customer is 330 (still under 500).

City 3: Jaipur

1. Highest number of customers, which is 69.
2. Average rent per customer is very low at 156.
3. Average sales per customer is better at 11.6k.

*/