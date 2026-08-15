-- =====================================================================
-- Myntra MarketWatch — 09_cte_analysis.sql
-- Common Table Expressions (CTEs) for multi-step business questions
-- =====================================================================
-- WHY CTEs HERE: each query below genuinely needs an intermediate,
-- named result (e.g. "the average price per fit type") before the
-- final comparison can happen. Writing this as a single nested
-- subquery would work but becomes hard to read; a CTE lets us name
-- and reason about each step separately, top to bottom, the same way
-- you'd explain the logic out loud in an interview.
-- =====================================================================


-- -----------------------------------------------------------------
-- Q1: Top 3 highest-rated products within EACH fit type
-- -----------------------------------------------------------------
-- WHY A CTE: we need to rank products within each fit-type group
-- before we can filter down to "top 3 per group." Doing the ranking
-- and the filtering in one nested query would be hard to read; naming
-- the ranked result as `ranked_products` makes the final SELECT a
-- simple, obvious filter.
WITH ranked_products AS (
    SELECT
        ft.fit_type_name,
        b.brand_name,
        p.product_name,
        p.rating,
        p.review_count,
        ROW_NUMBER() OVER (
            PARTITION BY ft.fit_type_name
            ORDER BY p.rating DESC, p.review_count DESC
        ) AS rank_in_fit_type
    FROM products p
    JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
    JOIN brands b ON p.brand_id = b.brand_id
    WHERE p.review_count >= 30  -- reliability filter, consistent with earlier steps
)
SELECT fit_type_name, brand_name, product_name, rating, review_count, rank_in_fit_type
FROM ranked_products
WHERE rank_in_fit_type <= 3
ORDER BY fit_type_name, rank_in_fit_type;


-- -----------------------------------------------------------------
-- Q2: Brands whose average price EXCEEDS the average price of their
-- own fit type (i.e., brands pricing above the norm for the styles
-- they actually sell — a fairer premium-positioning check than
-- comparing to the overall dataset average, since fit types
-- themselves have different baseline prices, per Step 8)
-- -----------------------------------------------------------------
-- WHY CTEs (two of them): we need (1) each fit type's average price,
-- and (2) each brand-within-fit-type's average price, computed
-- separately before we can compare them. Naming both intermediate
-- results makes the final join self-explanatory.
WITH fit_type_avg AS (
    SELECT
        ft.fit_type_id,
        ft.fit_type_name,
        AVG(p.price) AS fit_type_avg_price
    FROM products p
    JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
    GROUP BY ft.fit_type_id, ft.fit_type_name
),
brand_fit_avg AS (
    SELECT
        b.brand_name,
        ft.fit_type_id,
        ft.fit_type_name,
        AVG(p.price) AS brand_avg_price,
        COUNT(*) AS product_count
    FROM products p
    JOIN brands b ON p.brand_id = b.brand_id
    JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
    GROUP BY b.brand_name, ft.fit_type_id, ft.fit_type_name
    HAVING COUNT(*) >= 10  -- avoid tiny brand+fit_type combos
)
SELECT
    bfa.brand_name,
    bfa.fit_type_name,
    bfa.product_count,
    ROUND(bfa.brand_avg_price, 2) AS brand_avg_price,
    ROUND(fta.fit_type_avg_price, 2) AS fit_type_avg_price,
    ROUND(bfa.brand_avg_price - fta.fit_type_avg_price, 2) AS price_premium
FROM brand_fit_avg bfa
JOIN fit_type_avg fta ON bfa.fit_type_id = fta.fit_type_id
WHERE bfa.brand_avg_price > fta.fit_type_avg_price
ORDER BY price_premium DESC
LIMIT 20;


-- -----------------------------------------------------------------
-- Q3: Fit types with above-average rating (compared to the overall
-- dataset average rating)
-- -----------------------------------------------------------------
-- WHY A CTE: the overall average rating needs to be computed once and
-- reused as a comparison benchmark; naming it `overall_avg` makes the
-- final filter read almost like plain English.
WITH overall_avg AS (
    SELECT AVG(rating) AS overall_avg_rating FROM products
),
fit_type_ratings AS (
    SELECT
        ft.fit_type_name,
        COUNT(*) AS product_count,
        AVG(p.rating) AS fit_type_avg_rating
    FROM products p
    JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
    GROUP BY ft.fit_type_name
)
SELECT
    ftr.fit_type_name,
    ftr.product_count,
    ROUND(ftr.fit_type_avg_rating, 2) AS fit_type_avg_rating,
    ROUND(oa.overall_avg_rating, 2) AS overall_avg_rating
FROM fit_type_ratings ftr
CROSS JOIN overall_avg oa
WHERE ftr.fit_type_avg_rating > oa.overall_avg_rating
ORDER BY ftr.fit_type_avg_rating DESC;


-- -----------------------------------------------------------------
-- Q4: Products with above-average review counts, showing how far
-- above average each one is
-- -----------------------------------------------------------------
WITH avg_reviews AS (
    SELECT AVG(review_count) AS overall_avg_reviews FROM products
)
SELECT
    p.product_id,
    b.brand_name,
    p.product_name,
    p.review_count,
    ROUND(ar.overall_avg_reviews, 1) AS overall_avg_reviews,
    ROUND(p.review_count - ar.overall_avg_reviews, 1) AS reviews_above_average
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
CROSS JOIN avg_reviews ar
WHERE p.review_count > ar.overall_avg_reviews
ORDER BY p.review_count DESC
LIMIT 20;


-- -----------------------------------------------------------------
-- Q5: Multi-step pricing analysis — for each price band, find the
-- single top-rated brand within that band (min 20 products in that
-- band for the brand, for reliability)
-- -----------------------------------------------------------------
-- WHY THREE CTEs: this is a genuinely multi-stage question —
-- (1) assign every product to a price band,
-- (2) aggregate rating by brand WITHIN each band,
-- (3) rank brands within each band and keep only the top one.
-- Each stage depends on the previous one, which is exactly the kind
-- of problem CTEs are designed to make readable step by step.
WITH banded_products AS (
    SELECT
        p.*,
        b.brand_name,
        CASE
            WHEN p.price < 899 THEN '1. Budget'
            WHEN p.price < 1829 THEN '2. Mid-range'
            WHEN p.price < 3149 THEN '3. Premium'
            ELSE '4. Luxury'
        END AS price_band
    FROM products p
    JOIN brands b ON p.brand_id = b.brand_id
),
brand_band_ratings AS (
    SELECT
        price_band,
        brand_name,
        COUNT(*) AS product_count,
        AVG(rating) AS avg_rating
    FROM banded_products
    GROUP BY price_band, brand_name
    HAVING COUNT(*) >= 20
),
ranked_brand_bands AS (
    SELECT
        price_band,
        brand_name,
        product_count,
        avg_rating,
        ROW_NUMBER() OVER (PARTITION BY price_band ORDER BY avg_rating DESC) AS rnk
    FROM brand_band_ratings
)
SELECT price_band, brand_name, product_count, ROUND(avg_rating, 2) AS avg_rating
FROM ranked_brand_bands
WHERE rnk = 1
ORDER BY price_band;