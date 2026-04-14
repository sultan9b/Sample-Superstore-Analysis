-- СОЗДАНИЕ СТРУКТУРЫ ДЛЯ ВИНТРИНЫ ДАННЫХ
-- Создание базы данных
create database if not exists dwh;
use dwh;

-- Создание таблицы для витрины данных в Clickhouse
create table dwh.sales_fact (
	order_id 		String,
	row_id 			UInt16,
	order_date 		Date,
	customer_name 	String,
	segment			String,
	city            String,
    state           String,
    region          String,
    product_name    String,
    category        String,
    sub_category    String,
    ship_mode       String,
    ship_status     String,
    profit          UInt16,
    quantity        UInt16,
    discount        Float32,
    sales           UInt16,
    sales_forecast  UInt16
	) engine = MergeTree()
	order by (order_date, region, category);