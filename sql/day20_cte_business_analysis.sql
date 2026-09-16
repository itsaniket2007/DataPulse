-- ============================================
-- DataPulse — Day 20
-- SQL Common Table Expressions (CTEs)
-- ============================================
-- Each WITH clause names an intermediate result that is used by the final query.
-- CTEs make a multi-step business question easier to read, test, and maintain.


-- 1. Basic WITH syntax: name the transaction fields needed downstream.
WITH sales_base AS (
    SELECT order_id, order_date, customer_id, product, category,
           region, quantity, net_sales
    FROM sales
)
SELECT *
FROM sales_base
LIMIT 10;


-- 2. Monthly revenue and order analysis.
WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(quantity) AS units_sold,
        ROUND(SUM(net_sales), 2) AS revenue
    FROM sales
    GROUP BY strftime('%Y-%m', order_date)
),
monthly_metrics AS (
    SELECT
        month,
        order_count,
        units_sold,
        revenue,
        ROUND(revenue / NULLIF(order_count, 0), 2) AS average_order_value
    FROM monthly_sales
)
SELECT *
FROM monthly_metrics
ORDER BY month;


-- 3. Reusable customer-level metrics.
WITH customer_metrics AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(quantity) AS units_sold,
        ROUND(SUM(net_sales), 2) AS revenue,
        ROUND(AVG(net_sales), 2) AS average_transaction_value
    FROM sales
    GROUP BY customer_id
),
customer_average AS (
    SELECT ROUND(AVG(revenue), 2) AS average_customer_revenue
    FROM customer_metrics
)
SELECT
    cm.customer_id,
    cm.order_count,
    cm.units_sold,
    cm.revenue,
    cm.average_transaction_value,
    ca.average_customer_revenue,
    ROUND(cm.revenue - ca.average_customer_revenue, 2) AS revenue_vs_customer_average
FROM customer_metrics AS cm
CROSS JOIN customer_average AS ca
ORDER BY cm.revenue DESC;


-- 4. Product and category performance built from a reusable product CTE.
WITH product_metrics AS (
    SELECT
        category,
        product,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(quantity) AS units_sold,
        ROUND(SUM(net_sales), 2) AS revenue
    FROM sales
    GROUP BY category, product
),
category_metrics AS (
    SELECT
        category,
        SUM(order_count) AS order_count,
        SUM(units_sold) AS units_sold,
        ROUND(SUM(revenue), 2) AS category_revenue
    FROM product_metrics
    GROUP BY category
)
SELECT
    pm.category,
    pm.product,
    pm.order_count,
    pm.units_sold,
    pm.revenue AS product_revenue,
    cm.category_revenue,
    ROUND(100.0 * pm.revenue / NULLIF(cm.category_revenue, 0), 2) AS category_revenue_share_pct
FROM product_metrics AS pm
INNER JOIN category_metrics AS cm
    ON pm.category = cm.category
ORDER BY product_revenue DESC;


-- 5. Combine CTEs: compare every region's revenue with its category revenue.
WITH region_category_metrics AS (
    SELECT
        region,
        category,
        COUNT(DISTINCT order_id) AS order_count,
        ROUND(SUM(net_sales), 2) AS region_category_revenue
    FROM sales
    GROUP BY region, category
),
category_totals AS (
    SELECT
        category,
        ROUND(SUM(region_category_revenue), 2) AS category_revenue
    FROM region_category_metrics
    GROUP BY category
),
category_region_average AS (
    SELECT
        category,
        ROUND(AVG(region_category_revenue), 2) AS average_region_category_revenue
    FROM region_category_metrics
    GROUP BY category
)
SELECT
    rcm.region,
    rcm.category,
    rcm.order_count,
    rcm.region_category_revenue,
    ct.category_revenue,
    cra.average_region_category_revenue,
    ROUND(rcm.region_category_revenue - cra.average_region_category_revenue, 2)
        AS revenue_vs_category_region_average,
    ROUND(100.0 * rcm.region_category_revenue / NULLIF(ct.category_revenue, 0), 2)
        AS category_revenue_share_pct
FROM region_category_metrics AS rcm
INNER JOIN category_totals AS ct
    ON rcm.category = ct.category
INNER JOIN category_region_average AS cra
    ON rcm.category = cra.category
ORDER BY rcm.category, rcm.region_category_revenue DESC;


-- 6. Compare customer segments using calculated customer revenue.
WITH customer_metrics AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count,
        ROUND(SUM(net_sales), 2) AS revenue
    FROM sales
    GROUP BY customer_id
),
customer_average AS (
    SELECT AVG(revenue) AS average_customer_revenue
    FROM customer_metrics
),
customer_segments AS (
    SELECT
        cm.customer_id,
        cm.order_count,
        cm.revenue,
        CASE
            WHEN cm.revenue >= ca.average_customer_revenue THEN 'At or above average revenue'
            ELSE 'Below average revenue'
        END AS revenue_segment
    FROM customer_metrics AS cm
    CROSS JOIN customer_average AS ca
)
SELECT
    revenue_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(order_count), 2) AS average_orders_per_customer,
    ROUND(AVG(revenue), 2) AS average_customer_revenue,
    ROUND(SUM(revenue), 2) AS segment_revenue
FROM customer_segments
GROUP BY revenue_segment
ORDER BY segment_revenue DESC;
