-- СОЗДАНИЕ СТРУКТУРЫ ДЛЯ ПРЕОБРАЗОВАННЫХ ДАННЫХ

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

-- Таблица для хранения информации о геолокации (почтовый индекс, город)
create table if not exists stage.geolocation (
    geolocation_id int generated always as identity primary key,
    postal_code int,
    city_id int,
    foreign key (city_id) references stage.cities(city_id)
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
	geolocation_id int,
	ship_status_id int, 
	ship_mode_id int,
	ship_date date,
	days_to_ship_actual int,
	days_to_ship_scheduled int,
	foreign key (customer_id) references stage.customers(customer_id),
	foreign key (geolocation_id) references stage.geolocation(geolocation_id),
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

