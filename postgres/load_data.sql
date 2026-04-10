-- Создание схемы для этапа загрузки сырых данных
create schema if not exists raw;
-- Создание схемы для этапа трансформации данных
create schema if not exists stage;


-- Создание таблицы источника данных
create table if not exists raw.raw_superstore (
	category varchar(15),
	city varchar(30),
	customer_id varchar(8),
	customer_name varchar(30),
	order_date date,
	order_id varchar(14),
	postal_code int,
	product_id varchar(15),
	product_name varchar(127),
	region varchar(7),
	row_id int,
	segment varchar(12),
	ship_date date,
	ship_mode varchar(15),
	ship_status varchar(16),
	state varchar(21),
	sub_category varchar(12),
	days_to_ship_actual int,
	days_to_ship_scheduled int,
	discount decimal(3,2),
	profit int,
	quantity int,
	sales int,
	sales_forecast int
);

-- Загрузка данных из csv в таблицу raw.raw_superstore
copy raw.raw_superstore(category, city, customer_id, customer_name, order_date,	order_id, postal_code, product_id, product_name, region, row_id,segment, ship_date, ship_mode, ship_status, state, sub_category, days_to_ship_actual, days_to_ship_scheduled, discount, profit, quantity, sales, sales_forecast)
from '/var/lib/postgresql/raw-data/Sample_Superstore_Orders.csv'
delimiter ','
csv header;