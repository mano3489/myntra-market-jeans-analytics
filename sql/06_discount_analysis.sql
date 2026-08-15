-- =====================================================================
-- Myntra MarketWatch — 06_discount_analysis.sql
-- Deep-dive into discount patterns
-- =====================================================================
-- REMINDER (per project integrity rules): this data shows ASSOCIATION
-- only. We cannot claim a discount level "causes" a change in rating,
-- reviews, or sales, since no controlled experiment or time-series
-- sales data exists here. All findings are phrased as "associated with".
-- =====================================================================


-- -----------------------------------------------------------------
-- Q1: Overall discount summary stats
-- -----------------------------------------------------------------
SELECT
    ROUND(AVG(discount_percent), 2) AS avg_discount,
    MIN(discount_percent) AS min_discount,
    MAX(discount_percent) AS max_discount,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY discount_percent) AS median_discount
FROM products;


-- -----------------------------------------------------------------
-- Q2: Top 10 highest-discounted products
-- -----------------------------------------------------------------
SELECT
    p.product_id,
    b.brand_name,
    p.product_name,
    p.price,
    p.mrp,
    p.discount_percent,
    p.rating
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
ORDER BY p.discount_percent DESC
LIMIT 10;


-- -----------------------------------------------------------------
-- Q3: Top 10 lowest-discounted products
-- -----------------------------------------------------------------
SELECT
    p.product_id,
    b.brand_name,
    p.product_name,
    p.price,
    p.mrp,
    p.discount_percent,
    p.rating
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
ORDER BY p.discount_percent ASC
LIMIT 10;


-- -----------------------------------------------------------------
-- Q4: Discount by fit type — cross-reference to 03_category_analysis.sql
-- Repeated here, sorted by discount specifically, for a discount-first view
-- -----------------------------------------------------------------
SELECT
    ft.fit_type_name,
    COUNT(*) AS product_count,
    ROUND(AVG(p.discount_percent), 2) AS avg_discount_percent,
    ROUND(AVG(p.rating), 2) AS avg_rating
FROM products p
JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
GROUP BY ft.fit_type_name
ORDER BY avg_discount_percent DESC;


-- -----------------------------------------------------------------
-- Q5: Discount by brand — top 10 highest & lowest (min 30 products)
-- Cross-reference to 04_brand_analysis.sql Q4 (highest only); here we
-- add the lowest-discount brands too, for a fuller picture.
-- -----------------------------------------------------------------
(
    SELECT b.brand_name, COUNT(*) AS product_count,
           ROUND(AVG(p.discount_percent), 2) AS avg_discount_percent,
           'Highest' AS discount_rank_group
    FROM products p
    JOIN brands b ON p.brand_id = b.brand_id
    GROUP BY b.brand_name
    HAVING COUNT(*) >= 30
    ORDER BY avg_discount_percent DESC
    LIMIT 10
)
UNION ALL
(
    SELECT b.brand_name, COUNT(*) AS product_count,
           ROUND(AVG(p.discount_percent), 2) AS avg_discount_percent,
           'Lowest' AS discount_rank_group
    FROM products p
    JOIN brands b ON p.brand_id = b.brand_id
    GROUP BY b.brand_name
    HAVING COUNT(*) >= 30
    ORDER BY avg_discount_percent ASC
    LIMIT 10
)
ORDER BY discount_rank_group, avg_discount_percent DESC;


-- -----------------------------------------------------------------
-- Q6: Discount vs rating — decile-level view
-- -----------------------------------------------------------------
-- Splits products into 10 equal-sized groups (deciles) by discount
-- level using NTILE(), then shows avg rating per decile. This gives a
-- more granular picture than a single correlation number (which we
-- already computed as -0.0975 in Step 10 — a very weak relationship).
SELECT
    discount_decile,
    COUNT(*) AS product_count,
    ROUND(MIN(discount_percent), 2) AS min_discount_in_decile,
    ROUND(MAX(discount_percent), 2) AS max_discount_in_decile,
    ROUND(AVG(rating), 2) AS avg_rating
FROM (
    SELECT
        discount_percent,
        rating,
        NTILE(10) OVER (ORDER BY discount_percent) AS discount_decile
    FROM products
) sub
GROUP BY discount_decile
ORDER BY discount_decile;


-- -----------------------------------------------------------------
-- Q7: Discount vs review count — decile-level view
-- -----------------------------------------------------------------
SELECT
    discount_decile,
    COUNT(*) AS product_count,
    ROUND(MIN(discount_percent), 2) AS min_discount_in_decile,
    ROUND(MAX(discount_percent), 2) AS max_discount_in_decile,
    ROUND(AVG(review_count), 1) AS avg_review_count
FROM (
    SELECT
        discount_percent,
        review_count,
        NTILE(10) OVER (ORDER BY discount_percent) AS discount_decile
    FROM products
) sub
GROUP BY discount_decile
ORDER BY discount_decile;


-- -----------------------------------------------------------------
-- Q8: Brands that combine high discount AND high rating (a genuinely
-- useful business signal — the promo is working without hurting
-- perceived quality). Min 30 products for reliability.
-- -----------------------------------------------------------------
SELECT
    b.brand_name,
    COUNT(*) AS product_count,
    ROUND(AVG(p.discount_percent), 2) AS avg_discount_percent,
    ROUND(AVG(p.rating), 2) AS avg_rating
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
HAVING COUNT(*) >= 30
    AND AVG(p.discount_percent) > (SELECT AVG(discount_percent) FROM products)
    AND AVG(p.rating) > (SELECT AVG(rating) FROM products)
ORDER BY avg_discount_percent DESC, avg_rating DESC;
