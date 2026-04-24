# :memo: Sample Superstore Analysis

Тренировочный проект по известному датасету Sample-supersore
---

## Цель проекта
Выполнение разных видов аналитики в данном шаблоне. 

## Набор данных
**Источник:** [Kaggle - Superstore Dataset](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)

Таблица источник был разделен в полноценную схему таблиц в базе данных postgres

| Таблица | Описание | Записей |
|---------|----------|---------|
| Regions | Регионы  | 4       |
| States  | Штаты    | 49      |
| Cities  | Города   | 604     |
| Customers | Клиенты | 793    |
| Segments | Сегменты | 3      |
| Products | Продукты | 1 894  |
| Categories | Категории | 3   |
| Sub categories | Субкатегории | 17 |
| Ship modes | Способы доставки | 4 |
| Ship statuses | Статусы доставки | 3 |
| Orders | Заказы | 5 009 |
| Order items | Товары в заказе | 9 994 |

Итого 9 994 записей 

### ER-диаграмма базы данных

```
ship_ modes ─────┐┌─── ship_statuses
                 ||
order_items ─── orders  ──── cities ──── states ──── regions
     |           | 
     |           └───── customers  ───── segments
     |
     └────── products ────── sub_categories ────── categories
```
### Схемы (schemas)

- `raw` - postgres схема грязных данных с источника 
- `stage` - postgres схема обработки по таблицам справочникам и таблицам фактов
- `dwh` - clickhouse схема с колоночной структурой витрины данных для дальнейшей аналитики

