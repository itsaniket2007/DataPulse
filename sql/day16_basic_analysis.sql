-- ============================================
-- DataPulse — Day 16
-- Basic SQL Business Analysis
-- ============================================

SELECT
    order_id,
    customer_id,
    product,
    net_sales
FROM sales
ORDER BY net_sales DESC
LIMIT 10;


-- 2. Total Revenue

SELECT
    SUM(net_sales) AS total_revenue
FROM sales;


-- 3. Total Customers

SELECT
    COUNT(DISTINCT customer_id) AS total_customers
FROM sales;


-- 4. Total Orders

SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM sales;


-- 5. Revenue by Region

SELECT
    region,
    SUM(net_sales) AS revenue
FROM sales
GROUP BY region
ORDER BY revenue DESC;


-- 6. Revenue by Product

SELECT
    product,
    SUM(net_sales) AS revenue
FROM sales
GROUP BY product
ORDER BY revenue DESC;


-- 7. Revenue by Category

SELECT
    category,
    SUM(net_sales) AS revenue
FROM sales
GROUP BY category
ORDER BY revenue DESC;


-- 8. Average Discount by Product

SELECT
    product,
    AVG(discount) AS average_discount
FROM sales
GROUP BY product
ORDER BY average_discount DESC;


-- 9. Revenue by Month

SELECT
    year,
    month,
    SUM(net_sales) AS revenue
FROM sales
GROUP BY year, month
ORDER BY year, month;


-- 10. Return Analysis

SELECT
    product,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(
        DISTINCT CASE
            WHEN returned = 'Yes'
            THEN order_id
        END
    ) AS returned_orders
FROM sales
GROUP BY product;