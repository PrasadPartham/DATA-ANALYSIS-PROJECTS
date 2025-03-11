create database pizzaHut;

use pizzaHut;

create table orders
(order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id)
);

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id)
);

-- BASIC QUESTIONS
-- Q1 retrive the total number of orders placed
select count(*) as total_orders from orders;

-- Q2 calculate the total revenue generated from total sales
select round(sum(price*quantity),2) as total_revenue 
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id;

-- Q3 identify the highest price pizza
select * from pizzas
order by price desc
limit 1;
                -- or
select name , price 
from pizzas join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
order by price desc
Limit 1;

-- Q4 identify the most common pizza size ordered
select size , count(order_details_id) as order_count 
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by size
order by order_count desc
limit 1;

-- Q5 list the top 5 most ordered pizza types along with their quantity
select name,sum(quantity) as total_qunatity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by name
order by sum(quantity) desc
limit 5;

-- INTERMEDIATE QUESTIONS
-- Q1 join the nessasary tables to find the total quantity of each pizza category ordered
select category , count(quantity) as quantity_ordered 
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by category
order by count(quantity) desc;

-- Q2 determin the distribute of orders by hour of the day
select hour(order_time) as hours, count(order_id) as total_orders from orders
group by hour(order_time);

-- Q3 join the relevent tables to find category wise distribution of pizzas
select distinct(category), count(name) as name
 from pizza_types 
 group by category;
 
 -- Q4 group the orders by date and calculate the average number of pizzas order per date
 select round(avg(quant),0) as average_qunat from
 (select order_date , sum(quantity) as quant
 from orders join order_details
 on orders.order_id = order_details.order_id
 group by order_date) as order_quant;

-- Q5 Determine the most ordered pizzas types based on revenue
select pizza_type_id , sum(quantity*price) as revenue 
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_type_id
order by revenue desc
limit 3;

          -- or 
select name , sum(quantity * price) as revenue
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by name
order by revenue desc
limit 3;


-- ADVANCE QUERIES
-- Q1 calculate the percentage contribution of each pizza type to total revenue
select category , round(((sum(quantity* price))/ 
					(select sum(quantity*price) as total_revenue
					from pizzas join order_details on pizzas.pizza_id = order_details.pizza_id))*100,2) as revenue
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by category
order by revenue desc;

-- Q2 analyze the cumulative revenue generated over the time
select order_date ,sum(revenue) over (order by order_date) as Cum_revenue
from
(select order_date , round(sum(quantity*price),2) as revenue
from order_details join orders
on order_details.order_id = orders.order_id
join pizzas
on pizzas.pizza_id = order_details.pizza_id
group by order_date) as sales;


-- Q3 determine the top 3 most ordered pizza types based on revenue for each pizza category
select name , revenue 
from
(select category, name , revenue ,
rank() over(partition by category order by  revenue desc) as rn
from
(select category , name , round(sum(quantity*price)) as revenue 
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by category , name ) as a) as b
where rn <= 3;
