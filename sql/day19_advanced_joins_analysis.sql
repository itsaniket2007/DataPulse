-- ============================================
-- DataPulse — Day 19
-- Advanced SQL JOIN Analysis & Data Validation
-- ============================================
-- Uses the Day 18 customer_summary and product_summary tables.
-- Each summary is joined at its natural grain to avoid duplicate rows.


-- 1. Inspect the row count at each table grain before joining.
SELECT 'sales_transactions' AS dataset, COUNT(*) AS row_count FROM sales
UNION ALL
SELECT 'customer_summary', COUNT(*) FROM customer_summary
UNION ALL
SELECT 'product_summary', COUNT(*) FROM product_summary;


-- 2. INNER JOIN: transactions with a matching customer summary.
SELECT
    s.order_id,
    s.customer_id,
    s.product,
    s.category,
    s.net_sales,
    c.total_orders AS customer_total_orders,
    c.total_revenue AS customer_lifetime_revenue
FROM sales AS s
INNER JOIN customer_summary AS c
    ON s.customer_id = c.customer_id
LIMIT 10;


-- 3. LEFT JOIN: retain every transaction while checking for customer matches.
SELECT
    s.order_id,
    s.customer_id,
    s.product,
    s.net_sales,
    c.total_revenue AS customer_lifetime_revenue
FROM sales AS s
LEFT JOIN customer_summary AS c
    ON s.customer_id = c.customer_id
LIMIT 10;


-- 4. Compare row counts before and after customer joins.
SELECT 'sales_before_join' AS check_name, COUNT(*) AS row_count FROM sales
UNION ALL
SELECT 'inner_join_customer_summary', COUNT(*)
FROM sales AS s
INNER JOIN customer_summary AS c ON s.customer_id = c.customer_id
UNION ALL
SELECT 'left_join_customer_summary', COUNT(*)
FROM sales AS s
LEFT JOIN customer_summary AS c ON s.customer_id = c.customer_id;


-- 5. Data quality: sales transactions without a customer-summary match.
SELECT
    s.customer_id,
    COUNT(*) AS unmatched_transaction_rows,
    ROUND(SUM(s.net_sales), 2) AS unmatched_revenue
FROM sales AS s
LEFT JOIN customer_summary AS c
    ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL
GROUP BY s.customer_id
ORDER BY unmatched_transaction_rows DESC;


-- 6. Three-table join at the correct grain.
-- Product and category are both used because product_summary is summarized by both fields.
SELECT
    s.order_id,
    s.customer_id,
    s.product,
    s.category,
    s.region,
    s.net_sales,
    c.total_revenue AS customer_lifetime_revenue,
    p.total_revenue AS product_lifetime_revenue
FROM sales AS s
INNER JOIN customer_summary AS c
    ON s.customer_id = c.customer_id
INNER JOIN product_summary AS p
    ON s.product = p.product
   AND s.category = p.category
LIMIT 10;


-- 7. Validate that the three-table join did not duplicate transaction rows.
SELECT 'sales_before_three_table_join' AS check_name, COUNT(*) AS row_count FROM sales
UNION ALL
SELECT 'three_table_join_rows', COUNT(*)
FROM sales AS s
INNER JOIN customer_summary AS c ON s.customer_id = c.customer_id
INNER JOIN product_summary AS p ON s.product = p.product AND s.category = p.category
UNION ALL
SELECT 'distinct_order_ids_after_join', COUNT(DISTINCT s.order_id)
FROM sales AS s
INNER JOIN customer_summary AS c ON s.customer_id = c.customer_id
INNER JOIN product_summary AS p ON s.product = p.product AND s.category = p.category;


-- 8. Revenue and product performance by customer and category.
-- MAX(customer_total_revenue) preserves the customer-level metric without summing it per transaction.
SELECT
    s.customer_id,
    s.category,
    COUNT(DISTINCT s.order_id) AS transaction_count,
    SUM(s.quantity) AS units_sold,
    ROUND(SUM(s.net_sales), 2) AS category_revenue,
    ROUND(MAX(c.total_revenue), 2) AS customer_lifetime_revenue
FROM sales AS s
INNER JOIN customer_summary AS c
    ON s.customer_id = c.customer_id
INNER JOIN product_summary AS p
    ON s.product = p.product
   AND s.category = p.category
GROUP BY s.customer_id, s.category
ORDER BY category_revenue DESC;


-- 9. Revenue by customer, category, and product.
SELECT
    s.customer_id,
    s.category,
    s.product,
    COUNT(DISTINCT s.order_id) AS transaction_count,
    SUM(s.quantity) AS units_sold,
    ROUND(SUM(s.net_sales), 2) AS product_revenue
FROM sales AS s
INNER JOIN customer_summary AS c
    ON s.customer_id = c.customer_id
INNER JOIN product_summary AS p
    ON s.product = p.product
   AND s.category = p.category
GROUP BY s.customer_id, s.category, s.product
ORDER BY product_revenue DESC;


-- 10. Product/category detail for Day 18 high-value customers (lifetime revenue > 50,000).
-- The notebook selects each customer's largest revenue category and product from this result.
SELECT
    s.customer_id,
    s.category,
    s.product,
    COUNT(DISTINCT s.order_id) AS transaction_count,
    SUM(s.quantity) AS units_sold,
    ROUND(SUM(s.net_sales), 2) AS product_revenue,
    ROUND(MAX(c.total_revenue), 2) AS customer_lifetime_revenue
FROM sales AS s
INNER JOIN customer_summary AS c
    ON s.customer_id = c.customer_id
INNER JOIN product_summary AS p
    ON s.product = p.product
   AND s.category = p.category
WHERE c.total_revenue > 50000
GROUP BY s.customer_id, s.category, s.product
ORDER BY s.customer_id, product_revenue DESC;


-- 11. JOIN-based validation summary: unmatched customer and product records.
SELECT
    COUNT(*) AS sales_rows,
    SUM(CASE WHEN c.customer_id IS NULL THEN 1 ELSE 0 END) AS unmatched_customer_rows,
    SUM(CASE WHEN p.product IS NULL THEN 1 ELSE 0 END) AS unmatched_product_rows,
    SUM(CASE WHEN c.customer_id IS NOT NULL AND p.product IS NOT NULL THEN 1 ELSE 0 END) AS fully_matched_rows
FROM sales AS s
LEFT JOIN customer_summary AS c
    ON s.customer_id = c.customer_id
LEFT JOIN product_summary AS p
    ON s.product = p.product
   AND s.category = p.category;
