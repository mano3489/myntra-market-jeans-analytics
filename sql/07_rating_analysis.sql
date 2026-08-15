-- =====================================================================
-- Myntra MarketJean — 07_rating_analysis.sql
-- Rating distribution and its relationship to other attributes
-- =====================================================================


-- -----------------------------------------------------------------
-- Q1: Overall rating distribution
-- -----------------------------------------------------------------
SELECT
    ROUND(AVG(rating), 2) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rating) AS median_rating,
    ROUND(STDDEV(rating), 2) AS rating_std_dev
FROM products;


-- -----------------------------------------------------------------
-- Q2: Rating value distribution (how many products at each rounded
-- rating value — shows if ratings cluster at certain points)
-- -----------------------------------------------------------------
SELECT
    ROUND(rating * 2) / 2 AS rating_bucket,  -- rounds to nearest 0.5
    COUNT(*) AS product_count
FROM products
GROUP BY rating_bucket
ORDER BY rating_bucket;


-- -----------------------------------------------------------------
-- Q3: Average rating by fit type — cross-reference to Step 8
-- -----------------------------------------------------------------
SELECT
    ft.fit_type_name,
    COUNT(*) AS product_count,
    ROUND(AVG(p.rating), 2) AS avg_rating
FROM products p
JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
GROUP BY ft.fit_type_name
ORDER BY avg_rating DESC;


-- -----------------------------------------------------------------
-- Q4: Average rating by brand — cross-reference to Step 9 (min 30 products)
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
-- Q5: Highly-rated products (rating >= 4.5, min 50 reviews for reliability)
-- -----------------------------------------------------------------
SELECT
    p.product_id,
    b.brand_name,
    p.product_name,
    p.rating,
    p.review_count,
    p.price
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
WHERE p.rating >= 4.5 AND p.review_count >= 50
ORDER BY p.rating DESC, p.review_count DESC
LIMIT 15;


-- -----------------------------------------------------------------
-- Q6: Low-rated products (rating <= 3.5, min 50 reviews so this
-- reflects genuine dissatisfaction, not a fluke single review)
-- -----------------------------------------------------------------
SELECT
    p.product_id,
    b.brand_name,
    p.product_name,
    p.rating,
    p.review_count,
    p.price
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
WHERE p.rating <= 3.5 AND p.review_count >= 50
ORDER BY p.rating ASC, p.review_count DESC
LIMIT 15;


-- -----------------------------------------------------------------
-- Q7: Rating vs price — already computed as correlation in Step 10
-- (price_rating_correlation = 0.0868, essentially no linear relationship).
-- Here we look at it from the rating side: average price at each
-- rating bucket, to see if the (weak) trend is visible directly.
-- -----------------------------------------------------------------
SELECT
    ROUND(rating * 2) / 2 AS rating_bucket,
    COUNT(*) AS product_count,
    ROUND(AVG(price), 2) AS avg_price
FROM products
GROUP BY rating_bucket
ORDER BY rating_bucket;


-- -----------------------------------------------------------------
-- Q8: Rating vs discount — already computed as correlation in Step 10
-- (-0.0975) and explored via decile in Step 11 (Q6, showing the drop
-- only appears in the top discount deciles). Here: avg discount at
-- each rating bucket, the mirror image of that same relationship.
-- -----------------------------------------------------------------
SELECT
    ROUND(rating * 2) / 2 AS rating_bucket,
    COUNT(*) AS product_count,
    ROUND(AVG(discount_percent), 2) AS avg_discount_percent
FROM products
GROUP BY rating_bucket
ORDER BY rating_bucket;


-- -----------------------------------------------------------------
-- Q9: Rating vs review count — do more-reviewed products tend to
-- have higher or lower ratings? (Correlation, using native CORR())
-- -----------------------------------------------------------------
SELECT
    ROUND(CORR(review_count, rating)::NUMERIC, 4) AS review_count_rating_correlation
FROM products;