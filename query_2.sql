create table customer_orders (
order_id integer,
customer_id integer,
order_date date,
order_amount integer
);

insert into customer_orders values(1,100,cast('2022-01-01' as date),2000),(2,200,cast('2022-01-01' as date),2500),(3,300,cast('2022-01-01' as date),2100)
,(4,100,cast('2022-01-02' as date),2000),(5,400,cast('2022-01-02' as date),2200),(6,500,cast('2022-01-02' as date),2700)
,(7,100,cast('2022-01-03' as date),3000),(8,400,cast('2022-01-03' as date),1000),(9,600,cast('2022-01-03' as date),3000)
;


--For every date, determine the number of new customers and the number of repeated visits.

--select * from customer_orders


with repeated_customers as (
select co1.customer_id, co1.order_date
from customer_orders co1
inner join customer_orders co2 on co1.order_date != co2.order_date and co1.customer_id = co2.customer_id
group by co1.customer_id, co1.order_date)
, order_flag as (
select *,
rank() over(partition by customer_id order by order_date) as date_order_flag
from repeated_customers)
, ready_to_join as (
select customer_id, order_date
from order_flag
where date_order_flag != 1)
, joined as (
select co.order_date as date_1, r.order_date as date_2
from customer_orders co
left join ready_to_join r on r.customer_id = co.customer_id and r.order_date = co.order_date)
, new_or_old as (
select *, 
case when date_2 is not null then 1 else 0 end as old_ones, 
case when date_2 is null then 1 else 0 end as new_ones
from joined)

select date_1 as date, sum(new_ones) as first_visit, sum(old_ones) as repeated_visit
from new_or_old
group by date_1
order by date_1