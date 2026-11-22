-- ============================================================================
-- Project: Business Sales & Customer Performance Analysis (SQL)
-- File: 02_business_analysis_queries.sql
-- Description: Exploratory queries, aggregations, JOINs, and KPI metrics.
-- ============================================================================

USE business_sales_db;

-- ----------------------------------------------------------------------------
-- 1. Basic Filtering & Sorting (SELECT, WHERE, ORDER BY)
-- Retrieve all completed orders sorted by most recent order date
-- ----------------------------------------------------------------------------
SELECT
    order_id,
    customer_id,
    order_date,
    status
FROM orders
WHERE status = 'Completed'
ORDER BY order_date DESC;

-- ----------------------------------------------------------------------------
-- 2. Order Status Breakdown by Month (GROUP BY, COUNT)
-- Note: In SQL Server, replace DATE_FORMAT(order_date, '%Y-%m') with FORMAT(order_date, 'yyyy-MM')
-- ----------------------------------------------------------------------------
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m'), status
ORDER BY order_month ASC, status ASC;

-- ----------------------------------------------------------------------------
-- 3. Monthly Revenue Trend (JOINs + Aggregate Functions)
-- Calculates gross revenue, discount loss, and net revenue for completed orders
-- ----------------------------------------------------------------------------
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * p.unit_price), 2) AS gross_revenue,
    ROUND(SUM(oi.quantity * p.unit_price * (oi.discount_pct / 100.0)), 2) AS total_discounts,
    ROUND(SUM(oi.quantity * p.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS net_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month ASC;

-- ----------------------------------------------------------------------------
-- 4. Product Performance & Revenue Ranking
-- Identifies best-selling products by units sold and net revenue
-- ----------------------------------------------------------------------------
SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT(DISTINCT oi.order_id) AS order_appearances,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.quantity * p.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS net_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY net_revenue DESC;

-- ----------------------------------------------------------------------------
-- 5. Category Performance & Margin Impact
-- Compares category-level revenue and average discount percentage
-- ----------------------------------------------------------------------------
SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(AVG(oi.discount_pct), 2) AS avg_discount_pct,
    ROUND(SUM(oi.quantity * p.unit_price), 2) AS gross_sales,
    ROUND(SUM(oi.quantity * p.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS net_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.category
ORDER BY net_revenue DESC;

-- ----------------------------------------------------------------------------
-- 6. Customer Lifetime Spend & Average Order Value (LEFT JOIN)
-- Includes customers with zero completed orders to identify inactive/lost buyers
-- ----------------------------------------------------------------------------
SELECT
    c.customer_id,
    c.full_name,
    c.city,
    c.segment,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(COALESCE(SUM(oi.quantity * p.unit_price * (1 - oi.discount_pct / 100.0)), 0), 2) AS total_spend,
    ROUND(
        COALESCE(SUM(oi.quantity * p.unit_price * (1 - oi.discount_pct / 100.0)), 0)
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS avg_order_value
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
   AND o.status = 'Completed'
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN products p
    ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.full_name, c.city, c.segment
ORDER BY total_spend DESC;

-- ----------------------------------------------------------------------------
-- 7. Segment & City Revenue Breakdown
-- Evaluates which customer segments and cities drive the highest sales
-- ----------------------------------------------------------------------------
SELECT
    c.segment,
    c.city,
    COUNT(DISTINCT c.customer_id) AS active_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * p.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS net_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
GROUP BY c.segment, c.city
ORDER BY net_revenue DESC;
