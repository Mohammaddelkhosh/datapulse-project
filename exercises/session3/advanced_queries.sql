-- ==========================================
-- Exercise 3: Advanced SQL Queries
-- Project: DataPulse Behavior Analytics
-- Author: MOHAMMAD ASGARI DELKHOSH
-- ==========================================

-- 1. Common Table Expressions (CTE) 
-- Goal: Categorizing customers into spending tiers
WITH customer_totals AS (
    SELECT 
        customer_id, 
        SUM(amount) as total_spent,
        COUNT(*) as order_count
    FROM orders
    GROUP BY customer_id
)
SELECT 
    customer_id, 
    total_spent,
    CASE 
        WHEN total_spent >= 300 THEN 'High'
        WHEN total_spent >= 100 THEN 'Medium'
        ELSE 'Low' 
    END as spending_tier
FROM customer_totals
ORDER BY total_spent DESC;

-- 2. Analytical Query (GROUP BY ROLLUP)
-- Goal: Multi-level aggregation of sales by Year and Month
SELECT
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    COUNT(*) AS total_orders,
    SUM(amount) AS total_sales
FROM orders
GROUP BY ROLLUP (
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date)
)
ORDER BY order_year, order_month;

-- 3. Optimization and Explain Analyze
-- Task: Create an index and measure performance improvement

-- Step A: Create index (Already executed in psql)
-- CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- Step B: Measurement Query
-- Execution with Seq Scan forced OFF to see Index usage:
-- SET enable_seqscan = off;
-- EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 5;
-- SET enable_seqscan = on;

/* 
   RESULTS SUMMARY:
   - Before Index: Sequential Scan was used due to small table size.
   - After Index & SET: Index Scan using idx_orders_customer_id.
   - Planning Time: ~0.903 ms
   - Execution Time: ~0.090 ms
*/
