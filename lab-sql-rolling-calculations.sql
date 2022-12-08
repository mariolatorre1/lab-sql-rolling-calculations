use sakila;

-- Get number of monthly active customers.
create or replace view customer_activity as
select customer_id, convert(rental_date, date) as activity_date,
	date_format(convert(rental_date,date), '%m') as activity_month,
	date_format(convert(rental_date,date), '%Y') as activity_year
from rental;

create or replace view monthly_active_customers as
select activity_year, activity_Month, count(distinct customer_id) as active_customers
from customer_activity
group by activity_year, activity_month;

select * from monthly_active_customers;


-- Active users in the previous month.
select 
   activity_year, 
   activity_month,
   active_customers, 
   lag(active_customers) over (order by activity_year, activity_month) as last_month  
from monthly_active_customers;


-- Percentage change in the number of active customers.
create or replace view change_monthly_active_customers as
with cte_user_activity as 
(
   select 
   activity_year, 
   activity_month,
   active_customers, 
   lag(active_customers) over (order by activity_year, activity_month) as last_month  
from monthly_active_customers
)
select 
   activity_year, 
   activity_month,
   active_customers, 
   last_month, 
   round(((active_customers - last_month) / last_month * 100), 2) as '%_difference' 
from cte_user_activity;

select * from change_monthly_active_customers;


-- Retained customers every month.
create or replace view retained_monthly_active_customers as
with cte_user_activity as 
(
   select 
   activity_year, 
   activity_month,
   active_customers, 
   lag(active_customers) over (order by activity_year, activity_month) as last_month  
from monthly_active_customers
)
select 
   activity_year, 
   activity_month,
   active_customers, 
   last_month, 
   round(((active_customers - (last_month - active_customers)) / last_month * 100), 2) as '%_retained_customers'
from cte_user_activity;

select * from retained_monthly_active_customers;
















select * from rental;