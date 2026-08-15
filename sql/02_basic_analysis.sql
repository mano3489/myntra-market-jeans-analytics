-- =====================================================================
-- Myntra MarketWatch — 02_basic_analysis.sql
-- Basic descriptive SQL analysis on the products table
-- =====================================================================

-- Q1: How many products are available?
SELECT COUNT(*) AS total_products
FROM products;

-- Q2: How many brands are represented?
SELECT COUNT(*) AS total_brands
FROM brands;

-- Q3: How many fit types (this dataset's category-equivalent)?
SELECT COUNT(*) AS total_fit_types
FROM fit_types;

-- Q4: What is the average product price?
SELECT ROUND(AVG(price), 2) AS avg_price
FROM products;

-- Q5: What is the median price?
SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) AS median_price
FROM products;

-- Q6: What are the 10 cheapest products?
SELECT
    p.product_id,
    b.brand_name,
    p.product_name,
    p.price,
    p.mrp,
    p.discount_percent
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
ORDER BY p.price ASC
LIMIT 10;

-- Q7: What are the 10 most expensive products?
SELECT
    p.product_id,
    b.brand_name,
    p.product_name,
    p.price,
    p.mrp,
    p.discount_percent
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
ORDER BY p.price DESC
LIMIT 10;

-- Q8: What are the highest-rated products? (min 50 reviews so a single
-- 5-star rating doesn't outrank genuinely popular, well-reviewed products)
SELECT
    p.product_id,
    b.brand_name,
    p.product_name,
    p.rating,
    p.review_count
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
WHERE p.review_count >= 50
ORDER BY p.rating DESC, p.review_count DESC
LIMIT 10;

-- Q9: Which products have the most reviews?
SELECT
    p.product_id,
    b.brand_name,
    p.product_name,
    p.review_count,
    p.rating
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
ORDER BY p.review_count DESC
LIMIT 10;