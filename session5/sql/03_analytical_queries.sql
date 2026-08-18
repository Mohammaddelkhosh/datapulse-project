-- =========================================================
-- DataPulse Project - Session 5
-- Exercise 3: Analytical Queries on Sales Data Mart
-- Schema: analytics
-- =========================================================


-- ---------------------------------------------------------
-- Query 1: Total sales by year and month
-- هدف: تحلیل تعداد سفارش، فروش کل و میانگین مبلغ سفارش در هر ماه
-- ---------------------------------------------------------
SELECT
    d.year_number AS sales_year,
    d.month_number AS sales_month,
    TRIM(d.month_name) AS month_name,
    COUNT(f.sales_key) AS total_orders,
    SUM(f.total_amount) AS total_sales_amount,
    ROUND(AVG(f.total_amount), 2) AS avg_order_amount
FROM analytics.fact_sales AS f
JOIN analytics.dim_date AS d
    ON f.date_key = d.date_key
GROUP BY
    d.year_number,
    d.month_number,
    TRIM(d.month_name)
ORDER BY
    d.year_number,
    d.month_number;


-- ---------------------------------------------------------
-- Query 2: Top 10 customers by total purchase amount
-- هدف: شناسایی مشتریان برتر از نظر ارزش کل خرید
-- ---------------------------------------------------------
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    COUNT(f.sales_key) AS total_orders,
    SUM(f.total_amount) AS total_purchase_amount,
    ROUND(AVG(f.total_amount), 2) AS avg_purchase_amount
FROM analytics.fact_sales AS f
JOIN analytics.dim_customer AS c
    ON f.customer_key = c.customer_key
WHERE c.customer_id <> -1
GROUP BY
    c.customer_id,
    c.full_name,
    c.email
ORDER BY
    total_purchase_amount DESC
LIMIT 10;


-- ---------------------------------------------------------
-- Query 3: Sales analysis by day of week
-- هدف: بررسی میزان فروش و تعداد سفارش‌ها در روزهای هفته
-- ---------------------------------------------------------
SELECT
    d.day_of_week,
    TRIM(d.day_name) AS day_name,
    COUNT(f.sales_key) AS total_orders,
    SUM(f.total_amount) AS total_sales_amount,
    ROUND(AVG(f.total_amount), 2) AS avg_order_amount
FROM analytics.fact_sales AS f
JOIN analytics.dim_date AS d
    ON f.date_key = d.date_key
GROUP BY
    d.day_of_week,
    TRIM(d.day_name)
ORDER BY
    d.day_of_week;


-- ---------------------------------------------------------
-- Query 4: Customer ranking using Window Function
-- هدف: رتبه‌بندی مشتریان بر پایه مجموع مبلغ خرید
-- ---------------------------------------------------------
SELECT
    c.customer_id,
    c.full_name,
    COUNT(f.sales_key) AS total_orders,
    SUM(f.total_amount) AS total_purchase_amount,
    RANK() OVER (
        ORDER BY SUM(f.total_amount) DESC
    ) AS customer_rank
FROM analytics.fact_sales AS f
JOIN analytics.dim_customer AS c
    ON f.customer_key = c.customer_key
WHERE c.customer_id <> -1
GROUP BY
    c.customer_id,
    c.full_name
ORDER BY
    customer_rank;


-- ---------------------------------------------------------
-- Query 5: Multi-level sales aggregation using ROLLUP
-- هدف: فروش در سطح ماه، فصل، سال و جمع کل
-- ---------------------------------------------------------
SELECT
    d.year_number,
    d.quarter_number,
    d.month_number,
    SUM(f.total_amount) AS total_sales_amount,
    COUNT(f.sales_key) AS total_orders
FROM analytics.fact_sales AS f
JOIN analytics.dim_date AS d
    ON f.date_key = d.date_key
GROUP BY ROLLUP (
    d.year_number,
    d.quarter_number,
    d.month_number
)
ORDER BY
    d.year_number NULLS LAST,
    d.quarter_number NULLS LAST,
    d.month_number NULLS LAST;
