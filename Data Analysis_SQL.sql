create database ecommerce_analysis;
use ecommerce_analysis;
create table products(
product_id int,created_at datetime,product_name varchar(100));
 
create table website_sessions(
website_session_id int,
created_at datetime,
user_id int,
is_repeat_session int,
utm_source varchar(50),
utm_campaign varchar(50),
utm_content varchar(50),
device_type varchar(50),
http_referer varchar(255)
);
truncate table website_sessions;
set global local_infile =1;
show variables like "local_infile";
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/clean_website_sessions.csv'
INTO TABLE website_sessions
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
show variables like 'secure_file_priv';
select count(*) from website_sessions;

create table website_pageviews(
website_pageview_id int, created_at datetime,
website_sessions_id int ,
pageview_url varchar(255));
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/clean_website_pageviews.csv'
INTO TABLE website_pageviews
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

create table clean_orders(
order_id int,
created_at datetime,
website_session_id int,
user_id int,
primary_product_id int,
items_purchased int,
price_usd int,
congs_usd float);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/clean_orders.csv'
INTO TABLE clean_orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

create table order_items(
order_item_id int,
created_at datetime,
order_id int,
product_id int,
is_primary_items int,
price_usd decimal(10,2),
cogs_usd decimal(10,2));
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/clean_order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

create table order_item_refunds(
order_item_refund_id int,
created_at datetime,
order_item_id int,
order_id int,
refund_amount_usd float);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/clean_order_item_refunds.csv'
INTO TABLE order_item_refunds
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select sum(price_usd) as total_revenue from order_items; -- total revenue
select count(distinct order_id) as total_order from clean_orders;
select sum(price_usd)/count(distinct order_id) as ag_order_value from order_items;-- avg_order_value

describe products;
select*from products limit 5;
SELECT 
p.product_name,                               -- (revenue by product) 
SUM(oi.price_usd) AS total_revenue
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;

select sum(price_usd-cogs_usd) as total_profit from order_items;   -- total_profit

select device_type,count(distinct website_session_id) as sessions from website_sessions group by device_type; -- device traffic analysis 
describe order_items;

select date_format(created_at,'%Y-%m') as month
,sum(price_usd-cogs_usd) as monthly_profit from order_items -- (monthly trend) 
 group by month order by month;
 
 SELECT 
p.product_name,
SUM(oi.price_usd - oi.cogs_usd) / SUM(oi.price_usd) AS profit_margin
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_name;

