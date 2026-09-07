-- 1. North Region Revenue

SELECT
    SUM(net_sales) AS north_revenue
FROM sales
WHERE region = 'North';


-- 2. North + South Revenue

SELECT
    region,
    SUM(net_sales) AS revenue
FROM sales
WHERE region IN ('North', 'South')
GROUP BY region
ORDER BY revenue DESC;


-- 3. Q1 Revenue

SELECT
    SUM(net_sales) AS q1_revenue
FROM sales
WHERE order_date BETWEEN '2025-01-01'
                      AND '2025-03-31';


-- 4. Products Above Median / Threshold

SELECT
    product,
    SUM(net_sales) AS revenue
FROM sales
GROUP BY product
HAVING SUM(net_sales) > 50000
ORDER BY revenue DESC;


-- 5. Product Return Analysis

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


-- 6. North High-Value Products

SELECT
    product,
    SUM(net_sales) AS revenue,
    AVG(discount) AS average_discount,
    COUNT(DISTINCT order_id) AS orders
FROM sales
WHERE region = 'North'
GROUP BY product
HAVING AVG(discount) > 5
ORDER BY revenue DESC;