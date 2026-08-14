-- Query to join Customers and Orders
SELECT Customers.name, Orders.amount, Orders.order_date
FROM Customers
JOIN Orders ON Customers.customer_id = Orders.customer_id;

-- Check record counts
SELECT COUNT(*) FROM Customers;
SELECT COUNT(*) FROM Orders;
