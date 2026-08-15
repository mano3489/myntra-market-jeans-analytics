-- =====================================================================
-- Myntra MarketJean — 03_category_analysis.sql
-- "Category" analysis using fit_type as our sub-category dimension
-- (this dataset has no true category column — see database/schema.sql
-- for why fit_type is the closest legitimate equivalent)
-- =====================================================================


-- -----------------------------------------------------------------
-- Q1: Product count by fit type
-- -----------------------------------------------------------------
SELECT
    ft.fit_type_name,
    COUNT(*) AS product_count
FROM products p
JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
GROUP BY ft.fit_type_name
ORDER BY product_count DESC;


-- -----------------------------------------------------------------
-- Q2: Average price by fit type
-- -----------------------------------------------------------------
SELECT
    ft.fit_type_name,
    COUNT(*) AS product_count,
    ROUND(AVG(p.price), 2) AS avg_price
FROM products p
JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
GROUP BY ft.fit_type_name
ORDER BY avg_price DESC;


-- -----------------------------------------------------------------
-- Q3: Average discount by fit type
-- -----------------------------------------------------------------
SELECT
    ft.fit_type_name,
    ROUND(AVG(p.discount_percent), 2) AS avg_discount_percent
FROM products p
JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
GROUP BY ft.fit_type_name
ORDER BY avg_discount_percent DESC;


-- -----------------------------------------------------------------
-- Q4: Average rating by fit type
-- -----------------------------------------------------------------
SELECT
    ft.fit_type_name,
    ROUND(AVG(p.rating), 2) AS avg_rating,
    COUNT(*) AS product_count
FROM products p
JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
GROUP BY ft.fit_type_name
ORDER BY avg_rating DESC;


-- -----------------------------------------------------------------
-- Q5: Total review volume by fit type
-- -----------------------------------------------------------------
-- Shows which fit types customers engage with most overall (sum of all
-- reviews across every product in that fit type) vs which are merely
-- common in listing count (Q1). These can tell different stories.
SELECT
    ft.fit_type_name,
    SUM(p.review_count) AS total_reviews,
    COUNT(*) AS product_count,
    ROUND(SUM(p.review_count)::NUMERIC / COUNT(*), 1) AS avg_reviews_per_product
FROM products p
JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
GROUP BY ft.fit_type_name
ORDER BY total_reviews DESC;


-- -----------------------------------------------------------------
-- Q6: Top-performing fit types — combined view
-- -----------------------------------------------------------------
-- "Top-performing" here is defined transparently as: highest average
-- rating AMONG fit types with at least 100 products (so a fit type
-- with only 5 listings can't top the list by chance). This threshold
-- choice is stated explicitly rather than silently applied.
SELECT
    ft.fit_type_name,
    COUNT(*) AS product_count,
    ROUND(AVG(p.price), 2) AS avg_price,
    ROUND(AVG(p.discount_percent), 2) AS avg_discount_percent,
    ROUND(AVG(p.rating), 2) AS avg_rating,
    SUM(p.review_count) AS total_reviews
FROM products p
JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
GROUP BY ft.fit_type_name
HAVING COUNT(*) >= 100
ORDER BY avg_rating DESC;
