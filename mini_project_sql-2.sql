create database SQL_2_Mini_Project;

select*from cust_dimen;
select*from market_fact;
select*from orders_dimen;
select*from prod_dimen;
select*from shipping_dimen;

-- 1.	Join all the tables and create a new table called combined_table.
# (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)

create table combined as
(select Customer_Name,Province,Region,Customer_Segment,m.Cust_id,o.Ord_id,p.Prod_id,s.Ship_id,Sales,Discount,Order_Quantity,Profit,Shipping_Cost,
Product_Base_Margin,o.Order_ID,Order_Date,Order_Priority,Product_Category,Product_Sub_Category,Ship_Mode,Ship_Date
from cust_dimen c
join market_fact m
on c.Cust_id=m.Cust_id
join prod_dimen p
on m.Prod_id=p.Prod_id
join orders_dimen o
on m.Ord_id=o.Ord_id
join shipping_dimen s
on o.Order_ID=s.Order_ID);
select*from combined;


-- 2.	Find the top 3 customers who have the maximum number of orders
select* from
(select c.cust_id,customer_name,count(c.cust_id) as no_of_orders
from cust_dimen c
join market_fact m
on c.Cust_id=m.Cust_id
group by c.cust_id,customer_name
order by count(c.cust_id) desc limit 3)t;

-- 3.	Create a new column DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
select*from
(select order_date,ship_date,ship_date-Order_Date as daystakenfordelivery
from orders_dimen o
join shipping_dimen s
on s.Order_ID=o.Order_ID)t;

-- 4.	Find the customer whose order took the maximum time to get delivered.
select*from
(select cust_id,customer_name,max(ship_date-Order_Date) as maximum_time
from  combined)t;


-- 5.	Retrieve total sales made by each product from the data (use Windows function)

select m.prod_id,p.product_category,sum(sales) over(partition by m.prod_id)Total_sales from market_fact m,prod_dimen p 
where m.Prod_id=p.Prod_id
group by m.Prod_id;

-- 6.	Retrieve total profit made from each product from the data (use windows function)
select m.prod_id,p.product_category,sum(profit) over(partition by m.prod_id)Total_profit from market_fact m,prod_dimen p 
where m.Prod_id=p.Prod_id
group by m.Prod_id;


-- 7.	Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

select * from
(select cust_id,count(distinct month(str_to_date(order_date,'%d-%m-%Y'))) as count1 
from combined
where year(str_to_date(order_date,'%d-%m-%Y'))=2011
group by cust_id)t
where count1>11;

-- 8.	Retrieve month-by-month customer retention rate since the start of the business.(using views)

select *,case 
when retention_rate <=1 then 'Retained'
when retention_rate>1 then 'Irregular'
when retention_rate is Null then 'Churned'
end retained from 
(select cust_id,avg(month_diff) as retention_rate from
(select *,abs((month(ord_date)-month(prev_ord))) as month_diff from
(select cust_id,str_to_date(order_date,'%d-%m-%Y') as ord_date
,lag(str_to_date(order_date,'%d-%m-%Y'))over(partition by cust_id order by str_to_date(order_date,'%d-%m-%Y')) as prev_ord 
from combined)t)t1
group by cust_id)t2;








