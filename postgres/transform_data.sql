-- СОЗДАНИЕ СТРУКТУРЫ ДЛЯ ПРЕОБРАЗОВАННЫХ ДАННЫХ
-- Схема этапа трансформации данных
create schema if not exists stage;


-- ТАБЛИЦЫ СПРАВОЧНИКИ
-- Таблицы для хранения категорий товаров
create table if not exists stage.categories (
    category_id int generated always as identity primary key,
    category text
);

-- Таблицы для хранения подкатегорий товаров
create table if not exists stage.sub_categories (
	sub_category_id int generated always as identity primary key,
	sub_category text,
	category_id int,
	foreign key (category_id) references stage.categories(category_id)
);

-- Таблица для хранения информации о продуктах
create table if not exists stage.products (
	product_id text primary key,
	product_name text,
	sub_category_id int,
	foreign key (sub_category_id) references stage.sub_categories(sub_category_id)
);

-- Таблицы для хранения информации о регионах
create table if not exists stage.regions (
    region_id int generated always as identity primary key,
    region text
);

-- Таблицы для хранения информации о штатах
create table if not exists stage.states (
    state_id int generated always as identity primary key,
    state text,
    region_id int,
    foreign key (region_id) references stage.regions(region_id)
);

-- Таблицы для хранения информации о городах
create table if not exists stage.cities (
    city_id int generated always as identity primary key,
    city text,
    state_id int,
    foreign key (state_id) references stage.states(state_id)
);

-- Таблица для хранения информации о сегментах клиентов
create table if not exists stage.segments (
    segment_id int generated always as identity primary key,
    segment text
);

-- Таблица для хранения информации о клиентах
create table if not exists stage.customers (
    customer_id text primary key,
    customer_name text,
    segment_id int,
    foreign key (segment_id) references stage.segments(segment_id)
);

-- Таблица для хранения информации о статусах доставки
create table if not exists stage.ship_statuses (
    ship_status_id int generated always as identity primary key,
    ship_status text
);

-- Таблица для хранения информации о способах доставки
create table if not exists stage.ship_modes (
	ship_mode_id int generated always as identity primary key,
	ship_mode text
);

-- ТАБЛИЦЫ ФАКТОВ
-- Таблица для хранения информации о заказах
create table if not exists stage.orders (
	order_id text primary key,
	order_date date,
	customer_id text,
	city_id int,
	ship_status_id int, 
	ship_mode_id int,
	ship_date date,
	days_to_ship_actual int,
	days_to_ship_scheduled int,
	foreign key (customer_id) references stage.customers(customer_id),
	foreign key (city_id) references stage.cities(city_id),
	foreign key (ship_status_id) references stage.ship_statuses(ship_status_id),
	foreign key (ship_mode_id) references stage.ship_modes(ship_mode_id)
);

-- Таблица для хранения информации о позициях в заказах	
create table if not exists stage.order_items (
	order_id text,
	row_id int,
	product_id text,
	discount decimal(3,2),
	profit int,
	quantity int,
	sales int,
	sales_forecast int,
	primary key (order_id, row_id),
	foreign key (order_id) references stage.orders(order_id),
	foreign key (product_id) references stage.products(product_id)
	);



-- ЗАПОЛНЕНИЕ СПРАВОЧНИКОВ ДАННЫМИ ИЗ ТАБЛИЦЫ ИСТОЧНИКА
-- Заполнение таблицы категорий товаров
insert into stage.categories (category)
select distinct category from raw.raw_superstore;

-- Заполнение таблицы подкатегорий товаров
insert into stage.sub_categories (sub_category, category_id)
select distinct sub_category, c.category_id
from raw.raw_superstore r
join stage.categories c on r.category = c.category;

-- Заполнение таблицы товаров
-- Имеются товары с одинаковыми идентификатороми, нужно их разделить
select product_id, product_name,
	product_id || ' - ' ||  row_number() over (partition by product_id order by product_id) as new_id
from raw.raw_superstore
where product_id in (
	select product_id from raw.raw_superstore
	group by product_id
	having count(distinct product_name) > 1)
group by 1, 2; 

-- Изменение значения product_id
update raw.raw_superstore rs
set product_id = product_id || '-B'
where product_name in (
	select product_name from (
		select product_id, product_name,
			product_id || ' - ' ||  row_number() over (partition by product_id order by product_id) as new_id
		from raw.raw_superstore
		where product_id in (
			select product_id from raw.raw_superstore
			group by product_id
			having count(distinct product_name) > 1)
		group by 1, 2) query
	where new_id like '%- 2'
);

-- Проверка на дублирование product_id, результат пустой -> нету дублей
select product_id, count(distinct product_name) counts from raw.raw_superstore rs group by 1 having count(distinct product_name) > 1;


-- Теперь заполняем данные по товарам
insert into stage.products (product_id, product_name, sub_category_id)
select distinct product_id, product_name, sc.sub_category_id
from raw.raw_superstore r
join stage.sub_categories sc on r.sub_category = sc.sub_category;

-- Заполнение таблицы регионов
insert into stage.regions (region)
select distinct region
from raw.raw_superstore r;

-- Заполнение таблицы штатов
insert into stage.states (state, region_id)
select distinct state, r2.region_id
from raw.raw_superstore r
join stage.regions r2 on r.region = r2.region;

-- Заполнение таблицы городов
insert into stage.cities (city, state_id)
select distinct city, s.state_id
from raw.raw_superstore r
join stage.states s on r.state = s.state;

-- Заполнение таблицы сегментов клиентов
insert into stage.segments (segment)
select distinct segment
from raw.raw_superstore r;

-- Заполнение таблицы клиентов
insert into stage.customers (customer_id, customer_name, segment_id)
select distinct customer_id, customer_name, s.segment_id
from raw.raw_superstore r
join stage.segments s on r.segment = s.segment;

-- Заполнение таблицы способов доставки
insert into stage.ship_modes (ship_mode)
select distinct ship_mode
from raw.raw_superstore r;

-- Заполнение таблицы статусов доставки
insert into stage.ship_statuses (ship_status)
select distinct ship_status
from raw.raw_superstore r;

-- Заполнение таблицы заказов
insert into stage.orders (order_id, order_date, customer_id, city_id, ship_mode_id, ship_status_id, ship_date, days_to_ship_actual, days_to_ship_scheduled)
select distinct order_id, order_date, c.customer_id, c2.city_id,
		sm.ship_mode_id, ss.ship_status_id, ship_date,
		days_to_ship_actual, days_to_ship_scheduled 
from raw.raw_superstore r
join stage.customers c on r.customer_id = c.customer_id
join stage.cities c2 on r.city = c2.city
join stage.states s on r.state = s.state and c2.state_id = s.state_id 
join stage.ship_modes sm on r.ship_mode = sm.ship_mode
join stage.ship_statuses ss on r.ship_status = ss.ship_status;

-- Заполнение таблицы о позициях в заказе
insert into stage.order_items (order_id, row_id, product_id, discount, profit, quantity, sales, sales_forecast)
select distinct order_id, row_id, p.product_id,
		discount, profit, quantity, sales, sales_forecast
from raw.raw_superstore r
join stage.products p on r.product_id = p.product_id;