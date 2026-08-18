-- =========================================================
-- DataPulse Project - Session 5
-- Sales Data Mart (Star Schema)
-- File: 01_create_sales_datamart.sql
-- =========================================================

-- ساخت Schema مجزا برای بخش تحلیلی (OLAP / Data Mart)
CREATE SCHEMA IF NOT EXISTS analytics;

-- =========================================================
-- 1) Customer Dimension
-- =========================================================
CREATE TABLE IF NOT EXISTS analytics.dim_customer (
    customer_key SERIAL PRIMARY KEY,          -- کلید جانشین در Data Mart
    customer_id INTEGER NOT NULL UNIQUE,      -- شناسه مشتری در سیستم عملیاتی

    full_name VARCHAR(200),
    email VARCHAR(255),
    city VARCHAR(100),
    registration_date DATE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 2) Product Dimension
-- =========================================================
CREATE TABLE IF NOT EXISTS analytics.dim_product (
    product_key SERIAL PRIMARY KEY,           -- کلید جانشین
    product_id INTEGER NOT NULL UNIQUE,       -- شناسه محصول در سیستم عملیاتی

    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(150),
    brand VARCHAR(150),
    unit_price NUMERIC(12, 2),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 3) Store Dimension
-- =========================================================
CREATE TABLE IF NOT EXISTS analytics.dim_store (
    store_key SERIAL PRIMARY KEY,             -- کلید جانشین
    store_id INTEGER NOT NULL UNIQUE,         -- شناسه فروشگاه در سیستم عملیاتی

    store_name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    registration_date DATE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 4) Date Dimension
-- =========================================================
CREATE TABLE IF NOT EXISTS analytics.dim_date (
    date_key INTEGER PRIMARY KEY,             -- مانند: 20260819
    full_date DATE NOT NULL UNIQUE,

    day_of_month SMALLINT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    day_of_week SMALLINT NOT NULL,

    month_number SMALLINT NOT NULL,
    month_name VARCHAR(20) NOT NULL,

    quarter_number SMALLINT NOT NULL,
    year_number SMALLINT NOT NULL,

    is_weekend BOOLEAN NOT NULL DEFAULT FALSE
);

-- =========================================================
-- 5) Sales Fact Table
-- سطح جزئیات: هر ردیف = یک فروش / یک سفارش
-- =========================================================
CREATE TABLE IF NOT EXISTS analytics.fact_sales (
    sales_key BIGSERIAL PRIMARY KEY,

    order_id INTEGER NOT NULL UNIQUE,         -- شناسه سفارش در OLTP

    customer_key INTEGER NOT NULL,
    product_key INTEGER,
    store_key INTEGER,
    date_key INTEGER NOT NULL,

    -- معیارهای تحلیلی (Measures)
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price NUMERIC(12, 2),
    discount_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    total_amount NUMERIC(12, 2) NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fact_sales_customer
        FOREIGN KEY (customer_key)
        REFERENCES analytics.dim_customer(customer_key),

    CONSTRAINT fk_fact_sales_product
        FOREIGN KEY (product_key)
        REFERENCES analytics.dim_product(product_key),

    CONSTRAINT fk_fact_sales_store
        FOREIGN KEY (store_key)
        REFERENCES analytics.dim_store(store_key),

    CONSTRAINT fk_fact_sales_date
        FOREIGN KEY (date_key)
        REFERENCES analytics.dim_date(date_key),

    CONSTRAINT chk_fact_sales_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_fact_sales_discount
        CHECK (discount_amount >= 0),

    CONSTRAINT chk_fact_sales_total_amount
        CHECK (total_amount >= 0)
);

-- =========================================================
-- ایندکس‌های لازم برای Joinها و Queryهای تحلیلی پرتکرار
-- =========================================================
CREATE INDEX IF NOT EXISTS idx_fact_sales_customer_key
    ON analytics.fact_sales(customer_key);

CREATE INDEX IF NOT EXISTS idx_fact_sales_product_key
    ON analytics.fact_sales(product_key);

CREATE INDEX IF NOT EXISTS idx_fact_sales_store_key
    ON analytics.fact_sales(store_key);

CREATE INDEX IF NOT EXISTS idx_fact_sales_date_key
    ON analytics.fact_sales(date_key);
