-- session4/sql/01_create_indexes.sql

-- Index on customer_id for fast lookups by customer
CREATE INDEX IF NOT EXISTS idx_orders_customer_id
ON orders (customer_id);

-- Composite index for queries filtering by customer_id and order_date
CREATE INDEX IF NOT EXISTS idx_orders_customer_date
ON orders (customer_id, order_date);

-- Optional: analyze table so planner updates statistics
ANALYZE orders;
