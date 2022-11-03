-- 1. What is the total amount each customer spent at the restaurant?
Select customer_id, sum(price) as total
from sales
join menu on sales.product_id=menu.product_id
group by customer_id;


-- 2. How many days has each customer visited the restaurant?
Select customer_id, count( distinct order_date) as Visits
from sales
group by customer_id;


-- 3. What was the first item from the menu purchased by each customer?
Select customer_id, order_date, product_name, rank() over(partition by customer_id order by order_date) as ranks
from sales
join menu on sales.product_id=menu.product_id
group by customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
Select product_name, count(*) as total
from sales
join menu on sales.product_id=menu.product_id
group by product_name
order by total desc
limit 1;

-- 5. Which item was the most popular for each customer?
Select customer_id, product_name, count(*) as total
from sales
join menu on sales.product_id=menu.product_id
group by customer_id, product_name
order by total desc
;

-- 6. Which item was purchased first by the customer after they became a member?
Select sales.customer_id,join_date, order_date, product_name
from sales
join menu on sales.product_id=menu.product_id
join members as m on m.customer_id=sales.customer_id
where order_date>=join_date
group by customer_id
order by sales.customer_id, order_date asc;

-- 7.Which item was purchased just before the customer became a member?
select *
from (
	Select sales.customer_id,join_date, order_date, product_name, rank() over(partition by sales.customer_id order by order_date desc) as ranks
	from sales
	join menu on sales.product_id=menu.product_id
	join members as m on m.customer_id=sales.customer_id
	where order_date<join_date
    ) as temp
    where ranks=1;
    
-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select t.customer_id, sum(points) as total
from(
select customer_id,sales.product_id,product_name,price,
case when sales.product_id=1 then (price*20) else (price*10) end as points
from sales 
join menu on sales.product_id=menu.product_id
) as t
group by t.customer_id;


-- Join All The Things
select sales.customer_id,order_date,menu.product_name,price,
case when (order_date<join_date or join_date is NULL) then 'N' else 'Y' end as IsMember
from sales 
left join menu on sales.product_id=menu.product_id
left join members as m on m.customer_id=sales.customer_id
order by sales.customer_id,order_date;

-- Rank All The Things
Select *, 
(Case when IsMember='N' then NUll else 1 end)*(dense_rank() over(partition by t.customer_id, IsMember order by order_date ))
from (
select sales.customer_id,order_date,menu.product_name,price,
case when (order_date<join_date or join_date is NULL) then 'N' else 'Y' end as IsMember
from sales 
left join menu on sales.product_id=menu.product_id
left join members as m on m.customer_id=sales.customer_id
order by sales.customer_id,order_date
) as t; 

