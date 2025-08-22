--1.Analyze Sales Performance Over Time.
--2.total sales by year

select
	extract (year
from
	s.order_date) as order_year,
	sum(s.sales_amount) as total_sales
from
	gold.sales s
where
	s.order_date is not null
group by
	order_year
order by
	total_sales desc
;
--3.total sales by month

select
	date_trunc('month', s.order_date) as order_month,
	sum(s.sales_amount) as total_sales
from
	gold.sales s
where
	s.order_date is not null
group by
	order_month
order by
	total_sales desc
;
--- Calculate the total sales per month and the running total of sales over time

select
	order_month,
	total_sales,
	sum(total_sales) over (
	order by order_month) as running_total
from
	(
	select
		to_char(s.order_date, 'yyyy,mmm') as order_month,
		sum(s.sales_amount) as total_sales
	from
		gold.sales s
	where
		s.order_date is not null
	group by
		order_month) t
;
--Calculate the total sales per year and the running total of sales over time

select
	order_year,
	total_sales,
	sum(total_sales) over (
	order by order_year) as Running_total
from
	(
	select
		extract (year
	from
		s.order_date) as order_year,
		sum(s.sales_amount) as total_sales
	from
		gold.sales s
	where
		s.order_date is not null
	group by
		order_year) t
;
--moving avarage of price by month

select
	order_month,
	avg_price,
	round(avg(avg_price) over (order by order_month), 2) as moving_avg_price
from
	(
	select
		date_trunc('month', s.order_date) as order_month ,
		round(avg(s.price), 2) as avg_price
	from
		gold.sales s
	where
		s.order_date is not null
	group by
		order_month
) t
;
--Write a query to calculate 3-month moving average of price by month.

select
	order_month,
	avg_price,
	round(avg(avg_price) over (order by order_month rows between 2 preceding and current row), 2) as moving_avg_3m
from
	(
	select
		date_trunc('month', s.order_date) as order_month ,
		round(avg(s.price), 2) as avg_price
	from
		gold.sales s
	where
		s.order_date is not null
	group by
		order_month
) t
;

/*Analyze the yearly performance of products
  by comparing each product's sales to both its
  average sales performance and the previous year's sales. */

;

with yearly_product_sales as(
select 
extract (year from s.order_date) as order_year,
p.product_name,
sum(s.sales_amount) as total_sales
from gold.sales s 
left join 
gold.products p 
on s.product_key = p.product_key
where s.order_date is not null
group by extract (year from s.order_date),
p.product_name)

select
	order_year,
	product_name,
	total_sales,
	avg(total_sales) over (partition by product_name) as avg_sales,
	total_sales - avg(total_sales) over (partition by product_name) as diff_avg_sales,
	case
		when total_sales - avg(total_sales) over (partition by product_name) >0 then 'above_avg'
		when total_sales - avg(total_sales) over (partition by product_name) <0 then 'below_avg'
		else 'avg'
	end as change_avg,
	lag (total_sales) over (partition by product_name
order by
	order_year) as py_sales,
	total_sales - lag (total_sales) over (partition by product_name
order by
	order_year) as diff_py_sales,
	case
		when lag (total_sales) over (partition by product_name
	order by
		order_year) >0 then 'increse'
		when lag (total_sales) over (partition by product_name
	order by
		order_year) <0 then 'decrease'
		else 'no_change'
	end as py_change
from
	yearly_product_sales
;
--Which categories contribute the most to overall sales?

with category_sales as (
select
	p.category,
	sum(s.sales_amount) as total_sales
from
	gold.sales s
left join 
gold.products p 
on
	s.product_key = p.product_key
group by
	1)

select
	category,
	total_sales,
	sum(total_sales) over () as overall_sales,
	round((total_sales / sum(total_sales) over ())* 100, 2) || '%' as percentage_of_sales
from
	category_sales
order by
	total_sales desc
;

/* Segment products into cost ranges 
   and count how many products fall into each segment */

with cost_range as (
select
	p.product_key,
	p.product_name,
	p."cost",
	case
		when "cost" <100 then 'below_100'
		when cost between 100 and 500 then '100_500'
		when cost between 500 and 1000 then '500_1000'
		else 'above_1000'
	end as cost_range
from
	gold.products p )

select
	cost_range,
	count(distinct product_key) as total_product
from
	cost_range
group by
	1
order by
	total_product desc
;

/*Group customers into three segments based on their spending behavior:
VIP: Customers with at least 12 months of history and spending more than €5,000.
Regular: Customers with at least 12 months of history but spending €5,000 or less.
New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

with customer_spending as (
select
	c.customer_key,
	sum(s.sales_amount) as total_spending,
	min(s.order_date) as first_order,
	max(s.order_date) as last_order,
	(extract (year
from
	age(max(s.order_date), min(s.order_date)))* 12 
+ extract (month
from
	age(max(s.order_date), min(s.order_date)))) as lifespan
from
	gold.customers c
left join 
gold.sales s 
on
	s.customer_key = c.customer_key
where
	s.order_date is not null
group by
	1)

select
	customer_segment,
	count(customer_key) as total_customer
from
	(
	select
		customer_key,
		total_spending,
		lifespan,
		case
			when lifespan >= 12
				and total_spending > 5000 then 'VIP'
				when lifespan >= 12
				and total_spending < 5000 then 'Regular'
				else 'New'
			end as customer_segment
		from
			customer_spending) t
group by
	1
;

/*
 ======================================================================
Customer Report
=======================================================================
Purpose:
This report consolidates key customer metrics and behaviors

Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		-total orders
		-total sales
		-total quantity purchased
		-total products
		-lifespan (in months)
	4. Calculates valuable KPIs:
		-recency (months since last order)
		-average order value
		-average monthly spend */
create view gold.report_customer as 
select
	with base_query as (
	---------------------------------------------------------
	--1) Base Query: Retrieves core columns from tables
	---------------------------------------------------------

with base_query as (
	select
		s.order_number,
		s.product_key,
		s.sales_amount,
		s.quantity,
		s.order_date,
		c.customer_key,
		c.customer_number,
		concat(c.first_name, ' ' , c.last_name) as customer_name,
		extract (year
	from
		age(c.birthdate)) as customer_age
	from
		gold.sales s
	left join 
gold.customers c 
on
		s.customer_key = c.customer_key
	where
		s.order_date is not null)

,
	Aggregates_customer as (
	select
		customer_key,
		customer_number,
		customer_name,
		customer_age,
		count(order_number) as total_order,
		count(product_key) as total_product,
		sum(sales_amount) total_sales,
		sum(quantity) as total_quantity,
		max(order_date) as last_order_date,
		(extract (year
	from
		age(max(order_date), min(order_date)))* 12 
+ extract (month
	from
		age(max(order_date), min(order_date)))) as lifespan
	from
		base_query
	group by
		customer_key,
		customer_number,
		customer_name,
		customer_age)
	select
		customer_key,
		customer_number,
		customer_name,
		customer_age,
		case
			when customer_age < 20 then 'under_20'
			when customer_age between 20 and 29 then '20_29'
			when customer_age between 30 and 39 then '30_39'
			when customer_age between 40 and 49 then '40_49'
			else 'above_50'
		end as age_group,
		case
			when lifespan >= 12
			and total_sales > 5000 then 'VIP'
			when lifespan >= 12
			and total_sales < 5000 then 'Regular'
			else 'New'
		end as customer_segment,
		total_order,
		(extract (year
	from
		age(current_date, last_order_date))* 12 
+ extract (month
	from
		age(current_date, last_order_date))) as recency,
		case
			when total_sales = 0 then 0
			else total_sales / total_order
		end as avg_order_value,
		case
			when lifespan = 0 then total_sales
			else total_sales / lifespan
		end as avg_monthly_spen,
		total_product,
		total_sales,
		total_quantity,
		lifespan
	from
		Aggregates_customer




create view gold.report_customer as
with base_query as (
		select
			s.order_number,
			s.product_key,
			s.sales_amount,
			s.quantity,
			s.order_date,
			c.customer_key,
			c.customer_number,
			CONCAT(c.first_name, ' ', c.last_name) as customer_name,
			extract(year from age(c.birthdate)) as customer_age
		from
			gold.sales s
		left join gold.customers c 
        on
			s.customer_key = c.customer_key
		where
			s.order_date is not null
),
		Aggregates_customer as (
		select
			customer_key,
			customer_number,
			customer_name,
			customer_age,
			COUNT(order_number) as total_order,
			COUNT(product_key) as total_product,
			SUM(sales_amount) as total_sales,
			SUM(quantity) as total_quantity,
			MAX(order_date) as last_order_date,
			(extract(year from age(MAX(order_date), MIN(order_date))) * 12 
        + extract(month from age(MAX(order_date), MIN(order_date)))) as lifespan
		from
			base_query
		group by
			customer_key,
			customer_number,
			customer_name,
			customer_age
)
		select
			customer_key,
			customer_number,
			customer_name,
			customer_age,
			case
				when customer_age < 20 then 'under_20'
				when customer_age between 20 and 29 then '20_29'
				when customer_age between 30 and 39 then '30_39'
				when customer_age between 40 and 49 then '40_49'
				else 'above_50'
			end as age_group,
			case
				when lifespan >= 12
				and total_sales > 5000 then 'VIP'
				when lifespan >= 12
				and total_sales <= 5000 then 'Regular'
				else 'New'
			end as customer_segment,
			total_order,
			(extract(year from age(current_date, last_order_date)) * 12 
    + extract(month from age(current_date, last_order_date))) as recency,
			case
				when total_sales = 0 then 0
				else total_sales / total_order
			end as avg_order_value,
			case
				when lifespan = 0 then total_sales
				else total_sales / lifespan
			end as avg_monthly_spen,
			total_product,
			total_sales,
			total_quantity,
			lifespan
		from
			Aggregates_customer;
