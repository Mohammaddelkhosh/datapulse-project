-- =========================================================
-- DataPulse Project - Session 5
-- Exercise 2: ETL from OLTP to Sales Data Mart
-- Source: public.customers, public.orders
-- Target: analytics schema
-- =========================================================

BEGIN;

-- =========================================================
-- مرحله ۱: بارگذاری Customer Dimension
-- Source: public.customers
-- =========================================================

-- رکورد ناشناخته برای سفارش‌هایی که مشتری ندارند
-- این رکورد برای جلوگیری از شکست Foreign Key استفاده می‌شود.
INSERT INTO analytics.dim_customer (
    customer_id,
    full_name,
    email
)
VALUES (
    -1,
    'Unknown Customer',
    'unknown@datapulse.local'
)
ON CONFLICT (customer_id) DO NOTHING;

-- انتقال مشتریان واقعی از OLTP به Data Mart
INSERT INTO analytics.dim_customer (
    customer_id,
    full_name,
    email
)
SELECT
    c.customer_id,
    c.name,
    c.email
FROM public.customers AS c
ON CONFLICT (customer_id)
DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    updated_at = CURRENT_TIMESTAMP;

-- =========================================================
-- مرحله ۲: بارگذاری Date Dimension
-- Source: public.orders.order_date
-- =========================================================

INSERT INTO analytics.dim_date (
    date_key,
    full_date,
    day_of_month,
    day_name,
    day_of_week,
    month_number,
    month_name,
    quarter_number,
    year_number,
    is_weekend
)
SELECT DISTINCT
    TO_CHAR(o.order_date, 'YYYYMMDD')::INTEGER AS date_key,
    o.order_date AS full_date,
    EXTRACT(DAY FROM o.order_date)::SMALLINT AS day_of_month,
    TO_CHAR(o.order_date, 'Day') AS day_name,
    EXTRACT(ISODOW FROM o.order_date)::SMALLINT AS day_of_week,
    EXTRACT(MONTH FROM o.order_date)::SMALLINT AS month_number,
    TO_CHAR(o.order_date, 'Month') AS month_name,
    EXTRACT(QUARTER FROM o.order_date)::SMALLINT AS quarter_number,
    EXTRACT(YEAR FROM o.order_date)::SMALLINT AS year_number,
    EXTRACT(ISODOW FROM o.order_date) IN (6, 7) AS is_weekend
FROM public.orders AS o
WHERE o.order_date IS NOT NULL
ON CONFLICT (date_key)
DO UPDATE SET
    full_date = EXCLUDED.full_date,
    day_of_month = EXCLUDED.day_of_month,
    day_name = EXCLUDED.day_name,
    day_of_week = EXCLUDED.day_of_week,
    month_number = EXCLUDED.month_number,
    month_name = EXCLUDED.month_name,
    quarter_number = EXCLUDED.quarter_number,
    year_number = EXCLUDED.year_number,
    is_weekend = EXCLUDED.is_weekend;

-- =========================================================
-- مرحله ۳: بارگذاری Sales Fact
-- Source: public.orders + public.customers + analytics dimensions
-- =========================================================

INSERT INTO analytics.fact_sales (
    order_id,
    customer_key,
    product_key,
    store_key,
    date_key,
    quantity,
    unit_price,
    discount_amount,
    total_amount
)
SELECT
    o.order_id,

    -- اگر customer_id تهی یا نامعتبر باشد، Unknown Customer استفاده می‌شود
    COALESCE(dc.customer_key, unknown_customer.customer_key) AS customer_key,

    -- در OLTP فعلی جدول products وجود ندارد
    NULL AS product_key,

    -- در OLTP فعلی جدول stores وجود ندارد
    NULL AS store_key,

    TO_CHAR(o.order_date, 'YYYYMMDD')::INTEGER AS date_key,

    1 AS quantity,
    o.amount AS unit_price,
    0.00 AS discount_amount,
    o.amount AS total_amount

FROM public.orders AS o

LEFT JOIN analytics.dim_customer AS dc
    ON dc.customer_id = o.customer_id

CROSS JOIN (
    SELECT customer_key
    FROM analytics.dim_customer
    WHERE customer_id = -1
) AS unknown_customer

WHERE o.order_date IS NOT NULL
  AND o.amount IS NOT NULL
  AND o.amount >= 0

ON CONFLICT (order_id)
DO UPDATE SET
    customer_key = EXCLUDED.customer_key,
    product_key = EXCLUDED.product_key,
    store_key = EXCLUDED.store_key,
    date_key = EXCLUDED.date_key,
    quantity = EXCLUDED.quantity,
    unit_price = EXCLUDED.unit_price,
    discount_amount = EXCLUDED.discount_amount,
    total_amount = EXCLUDED.total_amount;

COMMIT;

-- =========================================================
-- گزارش نتیجه ETL
-- =========================================================

SELECT
    'dim_customer' AS table_name,
    COUNT(*) AS row_count
FROM analytics.dim_customer

UNION ALL

SELECT
    'dim_date' AS table_name,
    COUNT(*) AS row_count
FROM analytics.dim_date

UNION ALL

SELECT
    'dim_product' AS table_name,
    COUNT(*) AS row_count
FROM analytics.dim_product

UNION ALL

SELECT
    'dim_store' AS table_name,
    COUNT(*) AS row_count
FROM analytics.dim_store

UNION ALL

SELECT
    'fact_sales' AS table_name,
    COUNT(*) AS row_count
FROM analytics.fact_sales;
