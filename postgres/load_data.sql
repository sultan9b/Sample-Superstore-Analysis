-- Создание схемы для этапа загрузки сырых данных
create schema if not exists raw;


-- Создание таблицы источника данных
create table if not exists raw.raw_superstore (
	category text,
	city text,
	customer_id text,
	customer_name text,
	order_date date,
	order_id text,
	postal_code int,
	product_id text,
	product_name text,
	region text,
	row_id int,
	segment text,
	ship_date date,
	ship_mode text,
	ship_status text,
	state text,
	sub_category text,
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