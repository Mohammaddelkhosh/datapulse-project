-- ==========================================================
-- Datapulse Project - Session 3: Advanced SQL (Window Functions)
-- Author: MOHAMMAD ASGARI DELKHOSH
-- Description: Practice queries for ROW_NUMBER, RANK, DENSE_RANK,
--              LAG, and CTE in PostgreSQL
-- ==========================================================

-- 1. ROW_NUMBER(): شماره‌گذاری سفارش‌های هر مشتری از جدید به قدیم
SELECT
    order_id,
    customer_id,
    order_date,
    amount,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_date DESC, order_id DESC
    ) AS order_sequence
FROM orders
ORDER BY customer_id, order_sequence;


-- 2. RANK(): رتبه‌بندی تمام سفارش‌ها بر اساس مبلغ (بیشترین به کمترین)
SELECT
    order_id,
    customer_id,
    amount,
    RANK() OVER (
        ORDER BY amount DESC
    ) AS amount_rank
FROM orders
ORDER BY amount_rank, order_id;


-- 3. DENSE_RANK(): رتبه‌بندی مبالغ بدون پرش در اعداد رتبه
SELECT
    order_id,
    customer_id,
    amount,
    DENSE_RANK() OVER (
        ORDER BY amount DESC
    ) AS dense_amount_rank
FROM orders
ORDER BY dense_amount_rank, order_id;


-- 4. LAG(): مقایسه هر سفارش با سفارش قبلی همان مشتری (محاسبه اختلاف قیمت)
SELECT
    order_id,
    customer_id,
    order_date,
    amount,
    LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS previous_order_amount,
    amount - LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS difference_from_previous
FROM orders
ORDER BY customer_id, order_date, order_id;


-- 5. CTE + ROW_NUMBER(): استخراج آخرین سفارش ثبت شده برای هر مشتری
WITH latest_orders AS (
    SELECT
        order_id,
        customer_id,
        order_date,
        amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC, order_id DESC
        ) AS row_num
    FROM orders
)
SELECT
    order_id,
    customer_id,
    order_date,
    amount
FROM latest_orders
WHERE row_num = 1
ORDER BY customer_id;
