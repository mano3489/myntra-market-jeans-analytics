-- =====================================================================
-- Myntra MarketWatch — 10_window_functions.sql
-- Window functions: ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, SUM OVER,
-- AVG OVER, and an explicit window frame example
-- =====================================================================
-- CONCEPT NOTE:
-- PARTITION BY splits rows into groups (like a GROUP BY) but WITHOUT
-- collapsing rows into one row per group — every original row is kept,
-- with the window calculation attached alongside it.
-- ORDER BY (inside the OVER clause) decides the order used for ranking,
-- LAG/LEAD, and running-total calculations within each partition.
-- =====================================================================


-- -----------------------------------------------------------------
-- Q1: RANK() vs DENSE_RANK() — rank brands by average price WITHIN
-- each fit type (min 15 products per brand+fit_type for reliability)
-- -----------------------------------------------------------------
-- WHY BOTH FUNCTIONS SIDE BY SIDE: RANK() leaves gaps after ties
-- (e.g. 1,1,3), while DENSE_RANK() does not (1,1,2). Showing both
-- columns together makes the difference concrete rather than abstract.
WITH brand_fit_price AS (
    SELECT
        ft.fit_type_name,
        b.brand_name,
        AVG(p.price) AS avg_price,
        COUNT(*) AS product_count
    FROM products p
    JOIN brands b ON p.brand_id = b.brand_id
    JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
    GROUP BY ft.fit_type_name, b.brand_name
    HAVING COUNT(*) >= 15
)
SELECT
    fit_type_name,
    brand_name,
    product_count,
    ROUND(avg_price, 2) AS avg_price,
    RANK() OVER (PARTITION BY fit_type_name ORDER BY avg_price DESC) AS price_rank,
    DENSE_RANK() OVER (PARTITION BY fit_type_name ORDER BY avg_price DESC) AS price_dense_rank
FROM brand_fit_price
WHERE fit_type_name IN ('Slim Fit', 'Skinny Fit')  -- limited to 2 fit types to keep output readable
ORDER BY fit_type_name, price_rank
LIMIT 20;


-- -----------------------------------------------------------------
-- Q2: LAG() and LEAD() — compare each fit type's average price to
-- the fit type ranked just above and just below it
-- -----------------------------------------------------------------
-- WHY LAG/LEAD: after ordering fit types by average price, LAG() looks
-- backward (the next-cheaper fit type) and LEAD() looks forward (the
-- next-pricier fit type), letting us compute the price GAP between
-- consecutively-ranked fit types — impossible with a plain GROUP BY.
WITH fit_type_price AS (
    SELECT
        ft.fit_type_name,
        ROUND(AVG(p.price), 2) AS avg_price
    FROM products p
    JOIN fit_types ft ON p.fit_type_id = ft.fit_type_id
    GROUP BY ft.fit_type_name
)
SELECT
    fit_type_name,
    avg_price,
    LAG(avg_price) OVER (ORDER BY avg_price DESC) AS next_cheaper_fit_type_price,
    LEAD(avg_price) OVER (ORDER BY avg_price DESC) AS next_pricier_fit_type_price,
    ROUND(avg_price - LAG(avg_price) OVER (ORDER BY avg_price DESC), 2) AS gap_from_next_cheaper
FROM fit_type_price
ORDER BY avg_price DESC;


-- -----------------------------------------------------------------
-- Q3: SUM() OVER() — running (cumulative) total of product count by
-- brand, ordered by brand size, to answer: "how many top brands does
-- it take to cover half the catalog?"
-- -----------------------------------------------------------------
-- WHY A RUNNING TOTAL: a plain SUM() with GROUP BY gives each brand's
-- own count, but can't show CUMULATIVE coverage across ranked brands.
-- SUM() OVER (ORDER BY ...) keeps every row while adding a running
-- total column — the classic use case for this window function.
WITH brand_counts AS (
    SELECT
        b.brand_name,
        COUNT(*) AS product_count
    FROM products p
    JOIN brands b ON p.brand_id = b.brand_id
    GROUP BY b.brand_name
)
SELECT
    brand_name,
    product_count,
    SUM(product_count) OVER (ORDER BY product_count DESC) AS running_total_products,
    ROUND(
        100.0 * SUM(product_count) OVER (ORDER BY product_count DESC)
        / SUM(product_count) OVER (), 2
    ) AS running_pct_of_catalog
FROM brand_counts
ORDER BY product_count DESC
LIMIT 25;


-- -----------------------------------------------------------------
-- Q4: AVG() OVER() with an explicit window FRAME — a "local" moving
-- average of price among neighboring products (ordered by price),
-- showing each product's price against the average of the 5 nearest-
-- priced products (itself + 2 on each side)
-- -----------------------------------------------------------------
-- WHY A FRAME: by default, an OVER() with ORDER BY includes all rows
-- from the start of the partition up to the current row. Here we
-- explicitly restrict the frame to "2 rows before to 2 rows after"
-- using ROWS BETWEEN, which is what actually makes this a genuine
-- MOVING average rather than a running/cumulative one.
SELECT
    product_id,
    product_name,
    price,
    ROUND(
        AVG(price) OVER (
            ORDER BY price
            ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
        ), 2
    ) AS local_moving_avg_price
FROM products
ORDER BY price
LIMIT 15;


-- -----------------------------------------------------------------
-- Q5: Top-rated product per brand using RANK() (ties get the same
-- rank, unlike Step 14's ROW_NUMBER version, which always breaks ties)
-- -----------------------------------------------------------------
WITH brand_product_rank AS (
    SELECT
        b.brand_name,
        p.product_name,
        p.rating,
        p.review_count,
        RANK() OVER (
            PARTITION BY b.brand_name
            ORDER BY p.rating DESC, p.review_count DESC
        ) AS rank_in_brand
    FROM products p
    JOIN brands b ON p.brand_id = b.brand_id
    WHERE b.brand_id IN (
        SELECT brand_id FROM products GROUP BY brand_id HAVING COUNT(*) >= 500
    )
)
SELECT brand_name, product_name, rating, review_count, rank_in_brand
FROM brand_product_rank
WHERE rank_in_brand = 1
ORDER BY brand_name;