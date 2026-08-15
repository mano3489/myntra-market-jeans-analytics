-- =====================================================================
-- Myntra MarketJean — 05_pricing_analysis.sql
-- Pricing distribution, price bands, and price-vs-rating relationship
-- =====================================================================
-- PRICE BAND THRESHOLDS — chosen from the ACTUAL price distribution
-- (computed via Python quantiles on the cleaned dataset), not arbitrary
-- round numbers:
--   25th percentile = 899   |  median = 1418  |  75th percentile = 1829
--   95th percentile = 3149
--
-- Bands used below:
--   Budget      : price <  899   (bottom 25%)
--   Mid-range   : 899 <= price < 1829   (the middle 50% of listings)
--   Premium     : 1829 <= price < 3149  (75th-95th percentile)
--   Luxury      : price >= 3149  (top 5%)
-- =====================================================================


-- -----------------------------------------------------------------
-- Q1: Overall price distribution stats
-- -----------------------------------------------------------------
SELECT
    MIN(price) AS min_price,
    ROUND(AVG(price), 2) AS avg_price,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) AS median_price,
    MAX(price) AS max_price,
    ROUND(STDDEV(price), 2) AS price_std_dev
FROM products;


-- -----------------------------------------------------------------
-- Q2: Product count and share by price band
-- -----------------------------------------------------------------
SELECT
    CASE
        WHEN price < 899 THEN '1. Budget (< ₹899)'
        WHEN price < 1829 THEN '2. Mid-range (₹899 - ₹1828)'
        WHEN price < 3149 THEN '3. Premium (₹1829 - ₹3148)'
        ELSE '4. Luxury (₹3149+)'
    END AS price_band,
    COUNT(*) AS product_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM products
GROUP BY price_band
ORDER BY price_band;


-- -----------------------------------------------------------------
-- Q3: Average price by fit type (repeated here with price-band lens)
-- -----------------------------------------------------------------
SELECT
    ft.fit_type_name,
    ROUND(AVG(p.price), 2) AS avg_price,
    MIN(p.price) AS min_price,
    MAX(p.price) AS max_price
FROM products p
JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
GROUP BY ft.fit_type_name
ORDER BY avg_price DESC;


-- -----------------------------------------------------------------
-- Q4: Average price by brand — already covered in 04_brand_analysis.sql
-- (Q2, Q6, Q7). Not repeated here to avoid duplicate queries; see that
-- file for premium/budget brand rankings.
-- -----------------------------------------------------------------


-- -----------------------------------------------------------------
-- Q5: Rating by price band — does higher price associate with
-- higher perceived quality (rating)?
-- -----------------------------------------------------------------
-- IMPORTANT: this shows association only, not causation — we cannot
-- claim higher price "causes" higher ratings from this data alone.
SELECT
    CASE
        WHEN price < 899 THEN '1. Budget (< ₹899)'
        WHEN price < 1829 THEN '2. Mid-range (₹899 - ₹1828)'
        WHEN price < 3149 THEN '3. Premium (₹1829 - ₹3148)'
        ELSE '4. Luxury (₹3149+)'
    END AS price_band,
    COUNT(*) AS product_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(discount_percent), 2) AS avg_discount_percent
FROM products
GROUP BY price_band
ORDER BY price_band;


-- -----------------------------------------------------------------
-- Q6: Discounted vs heavily-discounted comparison
-- -----------------------------------------------------------------
-- Splits products into below-median-discount vs above-median-discount
-- groups (all products in this dataset carry some discount — there is
-- no "0% discount" group in this data, so we compare degree of
-- discount rather than discounted vs non-discounted).
SELECT
    CASE
        WHEN discount_percent < (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY discount_percent) FROM products)
            THEN 'Below-median discount'
        ELSE 'Above-median discount'
    END AS discount_group,
    COUNT(*) AS product_count,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(review_count), 1) AS avg_review_count
FROM products
GROUP BY discount_group;


-- -----------------------------------------------------------------
-- Q7: Correlation between price and rating (Pearson correlation
-- coefficient, native PostgreSQL function)
-- -----------------------------------------------------------------
-- Returns a value between -1 and 1. Close to 0 = no linear relationship;
-- close to 1 or -1 = strong positive/negative linear relationship.
SELECT
    ROUND(CORR(price, rating)::NUMERIC, 4) AS price_rating_correlation,
    ROUND(CORR(price, discount_percent)::NUMERIC, 4) AS price_discount_correlation,
    ROUND(CORR(discount_percent, rating)::NUMERIC, 4) AS discount_rating_correlation
FROM products;