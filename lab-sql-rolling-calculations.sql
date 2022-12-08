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
create or replace view distinct_customers as
select distinct 
	customer_id as active_id, 
	activity_year, 
	activity_month
from customer_activity
order by activity_year, activity_month, customer_id;

create or replace view recurrent_customers as
select d1.active_id, d1.activity_year, d1.activity_month, d2.activity_month as previous_month 
from distinct_customers d1
join distinct_customers d2
on d1.activity_year = d2.activity_year 
and d1.activity_month = d2.activity_month+1 
and d1.active_id = d2.active_id 
order by d1.active_id, d1.activity_year, d1.activity_month;

create or replace view total_recurrent_customers as
select activity_year, activity_month, count(active_id) as recurrent_customers from recurrent_customers
group by activity_year, activity_month;

select * from total_recurrent_customers;


-- OR (couldn't understand what the question was asking)


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



