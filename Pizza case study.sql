DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" datetime
);

INSERT INTO customer_orders
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" varchar(10)
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" varchar(10)
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" varchar(30)
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

  --------- Data Cleaning ---------

  select * from runners
  select * from customer_orders
  select * from runner_orders
  select * from pizza_names
  select * from pizza_toppings
  select * from pizza_recipes

  update customer_orders
  set exclusions = '' where exclusions is null or exclusions like '%NULL%'
  update customer_orders
  set extras = '' where extras is null or extras like '%null%'
  
  select * into dummy from ( 
  select  order_id,runner_id
,case when pickup_time = 'null' then ''
		when pickup_time is null then ''
		else pickup_time end as pickup_time
,case when distance = 'null' then ''
		when distance is null then ''
		when distance LIKE '%km' then trim('km' from distance)
		else distance end as distance
,case when duration = 'null' then ''
		when duration is null then ''
		when duration LIKE '%mins' then trim('mins' from duration)
		when duration LIKE '%minutes' then trim('minutes' from duration)
		when duration LIKE '%minute' then trim('minute' from duration)
		else duration end as duration
,case when cancellation like '%null%' then ''
		when cancellation is null then ''
		else cancellation end as cancellation
from runner_orders ) aa
where 1=1

drop table runner_orders
select * into runner_orders from dummy where 1=1
drop table dummy

-- Convert pizza_recipes table from string type to list type
select * into dummy from ( select pizza_id,value as toppings from pizza_recipes cross apply string_split(toppings,',')
where 1=1 )aa
drop table pizza_recipes
select * into pizza_recipes from dummy 
drop table dummy

------------------ Question set_1 -----------------------------

--How many pizzas were ordered?
select count(1) as total_pizza_ordered from customer_orders

--How many unique customer orders were made?
select count(distinct customer_id) as Unique_customer from customer_orders

--How many successful orders were delivered by each runner?
select runner_id,count(1) as order_delivered
from runner_orders
where pickup_time != ''
group by runner_id

--How many of each type of pizza was delivered?
select p.pizza_name,count(1) as no_of_pizza 
from customer_orders c join pizza_names p on p.pizza_id=c.pizza_id
join runner_orders r on r.order_id= c.order_id
where r.pickup_time != ''
group by p.pizza_name

--How many Vegetarian and Meatlovers were ordered by each customer?
select c.customer_id, p.pizza_name,count(1) as count_of_pizza
from customer_orders c join pizza_names p on p.pizza_id=c.pizza_id
group by c.customer_id,p.pizza_name
order by c.customer_id

--What was the maximum number of pizzas delivered in a single order?
select top 1 c.order_id, COUNT(1) as max_pizza
from customer_orders c join runner_orders r on r.order_id=c.order_id
where r.pickup_time != ''
group by c.order_id
order by max_pizza desc


--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select c.customer_id,sum( case when exclusions != '' or extras != '' then 1
				else 0 end) as count_of_atleast_one_changes
,sum( case when exclusions = '' and extras = '' then 1
				else 0 end) as count_of_no_changes
from customer_orders c join runner_orders r on r.order_id=c.order_id
where r.pickup_time != ''
group by c.customer_id

--How many pizzas were delivered that had both exclusions and extras?
select sum(case when exclusions != '' and extras != '' then 1
				else 0 end) as count_of_pizza_with_both_exclusions_extras
from customer_orders c join runner_orders r on r.order_id=c.order_id
where r.pickup_time != ''

--What was the total volume of pizzas ordered for each hour of the day?
select CAST(order_time as date) as Date,
datepart(hour,order_time) as hour, count(1) as count_per_hour
from customer_orders
group by CAST(order_time as date), datepart(hour,order_time)
order by 1,2

--What was the volume of orders for each day of the week?
select DATEPART(WEEKDAY,order_time) Day_of_week, count(1) as count
from customer_orders
group by DATEPART(WEEKDAY,order_time)

------------------Question Set_2------------------


--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select runner_id, avg(cast(datediff(minute,order_time,pickup_time) as decimal(5,2))) as time_take_in_minute
from customer_orders c join runner_orders r on r.order_id=c.order_id
where pickup_time !=''
group by runner_id

--Is there any relationship between the number of pizzas and how long the order takes to prepare?
select c.order_id,count(1) as pizza_count,max(datediff(minute,order_time,pickup_time)) as time_take_in_minute
from customer_orders c join runner_orders r on r.order_id=c.order_id
where pickup_time !=''
group by c.order_id

--What was the average distance travelled for each customer?
select c.customer_id,avg(cast(distance as decimal(6,2)))
from customer_orders c join runner_orders r on r.order_id=c.order_id
where pickup_time !=''
group by c.customer_id

--What was the difference between the longest and shortest delivery times for all orders?
select (max(datediff(minute,order_time,pickup_time) + duration) - 
min(datediff(minute,order_time,pickup_time) + duration)) as requird_time_in_min
from customer_orders c join runner_orders r on r.order_id=c.order_id
where pickup_time !=''

--What was the average speed for each runner for each delivery and do you notice any trend for these values?
select r.runner_id,r.order_id,avg(cast(distance as decimal)*60.00/cast(duration as int)) avg_speed_kmperhr
from runner_orders r
where pickup_time !=''
group by r.runner_id,r.order_id 

--What is the successful delivery percentage for each runner?
select runner_id,sum(case when pickup_time != '' then 1 else 0 end )*100/count(1) as success_pct
from runner_orders 
group by runner_id

-------------------------Question Set_3-------------------------

--What are the Common ingredients for each pizza?
select t.topping_name as Common_ingredients
from pizza_recipes r join pizza_toppings t on t.topping_id=r.toppings
group by t.topping_name 
having count(t.topping_name) > 1

--What are the standard ingredients for each pizza?
select n.pizza_name,STRING_AGG(t.topping_name,',') standard_ingredients
from pizza_recipes r join pizza_toppings t on t.topping_id=r.toppings
join pizza_names n on n.pizza_id = r.pizza_id
group by n.pizza_name

--What was the most commonly added extra?
select top 1 t.topping_name as commonly_added_extra
from customer_orders o 
cross apply string_split(extras,',') j
join pizza_toppings t on t.topping_id=j.value
group by t.topping_name
order by count(t.topping_name) desc

--What was the most common exclusion?
select top 1 t.topping_name as common_exclusion
from customer_orders o 
cross apply string_split([exclusions],',') j
join pizza_toppings t on t.topping_id=j.value
group by t.topping_name
order by count(t.topping_name) desc


--Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

with cte1 as (select * ,ROW_NUMBER()over(order by order_id,order_time) as rn
from customer_orders )
,cte2 as ( select max(order_id) as order_id, STRING_AGG(t2.topping_name,',') as extra , rn
from cte1 cross apply string_split(extras,',') k
left join pizza_toppings t2 on t2.topping_id=k.value
group by rn )
,cte3 as ( select max(pizza_id) as pizza_id, STRING_AGG(t2.topping_name,',') as exclude, rn
from cte1 cross apply string_split(exclusions,',') k
left join pizza_toppings t2 on t2.topping_id=k.value
group by rn )
select c2.order_id,
case when c2.extra is null and c3.exclude is null then n.pizza_name 
	when c2.extra is null and c3.exclude is not null then CONCAT(n.pizza_name,' - ','Exclude ',c3.exclude)
	when c2.extra is not null and c3.exclude is null then CONCAT(n.pizza_name,' - ','Extra ',c2.extra)
	when c2.extra is not null and c3.exclude is not null then CONCAT(n.pizza_name,' - ','Extra ',c2.extra,' - ','Exclude ',c3.exclude) end as order_item
from cte3 c3 join cte2 c2 on c2.rn=c3.rn
join pizza_names n on c3.pizza_id = n.pizza_id
order by c2.rn

--What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

with
cte1 as ( select t2.topping_name as extra,COUNT(1) as extra_count
from customer_orders c cross apply string_split(extras,',') k
left join pizza_toppings t2 on t2.topping_id=k.value
join runner_orders r on r.order_id=c.order_id
where t2.topping_name is not null and r.cancellation =''
group by t2.topping_name )
,cte2 as ( select t2.topping_name as exclude,COUNT(1) as exclude_count
from customer_orders c cross apply string_split(exclusions,',') k
left join pizza_toppings t2 on t2.topping_id=k.value
join runner_orders r on r.order_id=c.order_id
where t2.topping_name is not null and r.cancellation =''
group by t2.topping_name )
,cte3 as ( select t.topping_name,COUNT(1) as regualr_count
from customer_orders c join runner_orders r on c.order_id = r.order_id
join pizza_recipes p on p.pizza_id = c.pizza_id
join pizza_toppings t on t.topping_id=p.toppings
where r.cancellation=''
group by t.topping_name
)
select c3.topping_name , regualr_count-ISNULL(exclude_count,0)+isnull(extra_count,0) as total_quantity_used
from cte3 c3
left join cte2 c2 on c3.topping_name=c2.exclude
left join cte1 c1 on c3.topping_name=c1.extra
order by total_quantity_used desc

-------------------------Question Set_4-------------------------

--If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

-- adding cost column to pizza_name table
alter table pizza_names
Add  cost int 
update pizza_names set cost = 12 where pizza_name = 'Meatlovers';
update pizza_names set cost = 10 where pizza_name = 'Vegetarian';

select  SUM(cost) as Pizza_Runner_income
from customer_orders c join runner_orders r on c.order_id=r.order_id
join pizza_names p on p.pizza_id = c.pizza_id
where r.cancellation ='';

--What if there was an additional $1 charge for any pizza extras?
with cte1 as (
select  SUM(cost) as Pizza_Runner_income
from customer_orders c join runner_orders r on c.order_id=r.order_id
join pizza_names p on p.pizza_id = c.pizza_id
where r.cancellation ='')
,cte2 as (select COUNT(1) as extra_earning
from customer_orders c cross apply string_split(extras,',') k
join runner_orders r on r.order_id=c.order_id
where r.cancellation ='' and value != '')
select Pizza_Runner_income+extra_earning as Total_earning
from cte2,cte1

--The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

create table order_rating (order_id int, rating int );
insert into order_rating
values (1,5),(2,4),(3,4),(4,3),(5,5),(6,5),(7,3),(8,4),(9,4),(10,5)
select * from order_rating;

--Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
--customer_id
--order_id
--runner_id
--rating
--order_time
--pickup_time
--Time between order and pickup
--Delivery duration
--Average speed
--Total number of pizzas

select max(c.customer_id) customer_id,c.order_id order_id ,max(r.runner_id) runner_id,max(rat.rating) rating
,max(c.order_time) order_time ,max(r.pickup_time) pickup_time
,max(datediff(minute,c.order_time,r.pickup_time)) as time_between_order_n_pickup,max(r.duration) Delivery_duration
,round(avg(r.distance*60.00/r.duration),2) as Avg_speed
from customer_orders c
join runner_orders r on c.order_id=r.order_id
join order_rating rat on rat.order_id=c.order_id
where r.cancellation = '' 
group by c.order_id

--If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

select sum(cost - (30.00*r.distance/100.00)) as Total_Profit
from customer_orders c join runner_orders r on c.order_id=r.order_id
join pizza_names p on p.pizza_id = c.pizza_id
where r.cancellation ='';

--------- Bonus_Question ---------

--If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

select * into 
pizza_name_new from pizza_names
insert into pizza_name_new
values (3,'Supreme',17)

select * into 
pizza_recipes_new from pizza_recipes
insert into pizza_recipes_new
values (3,1),(3,2),(3,3),(3,4),(3,5),(3,6),(3,7),(3,8),(3,9),(3,10),(3,11),(3,12);

