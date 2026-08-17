-- session4/sql/02_performance_queries.sql

-- Query 1: customer-based lookup
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 10;

-- Query 2: customer + date filtering
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 10
  AND order_date >= '2024-01-01'
ORDER BY order_date;

-- Query 3: aggregation by customer
EXPLAIN ANALYZE
SELECT customer_id, COUNT(*) AS total_orders, SUM(amount) AS total_amount
FROM orders
GROUP BY customer_id
ORDER BY total_amount DESC;
