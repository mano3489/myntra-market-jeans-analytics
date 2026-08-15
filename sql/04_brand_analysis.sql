-- =====================================================================
-- Myntra MarketWatch — 04_brand_analysis.sql
-- Brand-level performance analysis
-- =====================================================================
-- THRESHOLD NOTE: Brand product counts range from 1 to 3,300 (median
-- is only 15). 42 brands have just a single listing, and 109 have
-- fewer than 5. Using such brands in "top brand" rankings would let one
-- lucky 5-star review make an obscure brand look like a market leader.
-- We use a minimum of 30 products per brand for ranking queries — this
-- retains 162 of 417 brands (a meaningful, representative sample) while
-- excluding the long tail of near-single-listing brands.
-- =====================================================================


-- -----------------------------------------------------------------
-- Q1: Top 15 brands by product count (no threshold — this question
-- is explicitly about listing volume, so all brands are valid here)
-- -----------------------------------------------------------------
SELECT
    b.brand_name,
    COUNT(*) AS product_count
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
ORDER BY product_count DESC
LIMIT 15;


-- -----------------------------------------------------------------
-- Q2: Average price by brand (min 30 products)
-- -----------------------------------------------------------------
SELECT
    b.brand_name,
    COUNT(*) AS product_count,
    ROUND(AVG(p.price), 2) AS avg_price
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
HAVING COUNT(*) >= 30
ORDER BY avg_price DESC
LIMIT 15;


-- -----------------------------------------------------------------
-- Q3: Average rating by brand (min 30 products)
-- -----------------------------------------------------------------
SELECT
    b.brand_name,
    COUNT(*) AS product_count,
    ROUND(AVG(p.rating), 2) AS avg_rating
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
HAVING COUNT(*) >= 30
ORDER BY avg_rating DESC
LIMIT 15;


-- -----------------------------------------------------------------
-- Q4: Average discount by brand (min 30 products)
-- -----------------------------------------------------------------
SELECT
    b.brand_name,
    COUNT(*) AS product_count,
    ROUND(AVG(p.discount_percent), 2) AS avg_discount_percent
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
HAVING COUNT(*) >= 30
ORDER BY avg_discount_percent DESC
LIMIT 15;


-- -----------------------------------------------------------------
-- Q5: Review volume by brand (min 30 products) — total engagement
-- -----------------------------------------------------------------
SELECT
    b.brand_name,
    COUNT(*) AS product_count,
    SUM(p.review_count) AS total_reviews,
    ROUND(SUM(p.review_count)::NUMERIC / COUNT(*), 1) AS avg_reviews_per_product
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
HAVING COUNT(*) >= 30
ORDER BY total_reviews DESC
LIMIT 15;


-- -----------------------------------------------------------------
-- Q6: "Premium" brands — highest average price relative to overall
-- average, among brands with a meaningful listing count
-- -----------------------------------------------------------------
-- Uses a CROSS JOIN with the overall average price (computed once as
-- a subquery) so each brand's price can be compared against the whole
-- dataset's average in the same query.
SELECT
    b.brand_name,
    COUNT(*) AS product_count,
    ROUND(AVG(p.price), 2) AS brand_avg_price,
    overall.overall_avg_price,
    ROUND(AVG(p.price) - overall.overall_avg_price, 2) AS price_diff_from_overall
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
CROSS JOIN (SELECT ROUND(AVG(price), 2) AS overall_avg_price FROM products) overall
GROUP BY b.brand_name, overall.overall_avg_price
HAVING COUNT(*) >= 30 AND AVG(p.price) > overall.overall_avg_price
ORDER BY price_diff_from_overall DESC
LIMIT 15;


-- -----------------------------------------------------------------
-- Q7: "Budget" brands — lowest average price relative to overall
-- average, among brands with a meaningful listing count
-- -----------------------------------------------------------------
SELECT
    b.brand_name,
    COUNT(*) AS product_count,
    ROUND(AVG(p.price), 2) AS brand_avg_price,
    overall.overall_avg_price,
    ROUND(AVG(p.price) - overall.overall_avg_price, 2) AS price_diff_from_overall
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
CROSS JOIN (SELECT ROUND(AVG(price), 2) AS overall_avg_price FROM products) overall
GROUP BY b.brand_name, overall.overall_avg_price
HAVING COUNT(*) >= 30 AND AVG(p.price) < overall.overall_avg_price
ORDER BY price_diff_from_overall ASC
LIMIT 15;