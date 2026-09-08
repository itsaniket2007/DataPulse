-- ============================================
-- DataPulse — Day 18
-- SQL JOIN & Customer Analysis
-- ============================================


-- 1. Create Customer Summary

CREATE TABLE IF NOT EXISTS customer_summary AS

SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units,
    SUM(net_sales) AS total_revenue,
    AVG(net_sales) AS average_transaction_value,
    AVG(discount) AS average_discount,
    MIN(order_date) AS first_purchase_date,
    MAX(order_date) AS last_purchase_date

FROM sales

GROUP BY customer_id;


-- 2. Top Customers

SELECT
    customer_id,
    total_orders,
    total_revenue

FROM customer_summary

ORDER BY total_revenue DESC

LIMIT 10;


-- 3. High-Value Customers

SELECT
    customer_id,
    total_orders,
    total_revenue

FROM customer_summary

WHERE total_revenue > 50000

ORDER BY total_revenue DESC;


-- 4. Repeat Customers

SELECT
    COUNT(*) AS repeat_customers

FROM customer_summary

WHERE total_orders > 1;


-- 5. Create Product Summary

CREATE TABLE IF NOT EXISTS product_summary AS

SELECT
    product,
    category,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units,
    SUM(net_sales) AS total_revenue,
    AVG(unit_price) AS average_unit_price,
    AVG(discount) AS average_discount

FROM sales

GROUP BY
    product,
    category;


-- 6. Customer + Sales JOIN

SELECT
    s.order_id,
    s.customer_id,
    s.product,
    s.net_sales,
    c.total_orders,
    c.total_revenue

FROM sales AS s

INNER JOIN customer_summary AS c
    ON s.customer_id = c.customer_id;


-- 7. Three-Table JOIN

SELECT
    s.order_id,
    s.customer_id,
    s.product,
    p.category,
    s.region,
    s.net_sales,
    c.total_orders,
    c.total_revenue

FROM sales AS s

INNER JOIN customer_summary AS c
    ON s.customer_id = c.customer_id

INNER JOIN product_summary AS p
    ON s.product = p.product;


-- 8. LEFT JOIN Data Quality Check

SELECT
    COUNT(*) AS unmatched_records

FROM sales AS s

LEFT JOIN customer_summary AS c
    ON s.customer_id = c.customer_id

WHERE c.customer_id IS NULL;