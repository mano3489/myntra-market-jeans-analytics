-- =====================================================================
-- Myntra MarketWatch — create_tables.sql
-- Run this against a PostgreSQL database, e.g.:
--   psql -U postgres -d myntra_marketwatch -f database/create_tables.sql
-- (see database/schema.sql for the full design rationale)
-- =====================================================================

DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS brands CASCADE;
DROP TABLE IF EXISTS fit_types CASCADE;
DROP TABLE IF EXISTS rise_types CASCADE;


-- ---------------------------------------------------------------------
-- Lookup table: brands
-- ---------------------------------------------------------------------
CREATE TABLE brands (
    brand_id    SERIAL PRIMARY KEY,
    brand_name  VARCHAR(100) NOT NULL UNIQUE
);


-- ---------------------------------------------------------------------
-- Lookup table: fit_types
-- ---------------------------------------------------------------------
CREATE TABLE fit_types (
    fit_type_id     SERIAL PRIMARY KEY,
    fit_type_name   VARCHAR(50) NOT NULL UNIQUE
);


-- ---------------------------------------------------------------------
-- Lookup table: rise_types
-- ---------------------------------------------------------------------
CREATE TABLE rise_types (
    rise_type_id    SERIAL PRIMARY KEY,
    rise_type_name  VARCHAR(50) NOT NULL UNIQUE
);


-- ---------------------------------------------------------------------
-- Fact table: products
-- ---------------------------------------------------------------------
CREATE TABLE products (
    product_id          VARCHAR(10) PRIMARY KEY,        -- e.g. 'JN00001'
    product_name         VARCHAR(255) NOT NULL,
    brand_id             INTEGER NOT NULL REFERENCES brands(brand_id),
    fit_type_id          INTEGER NOT NULL REFERENCES fit_types(fit_type_id),
    rise_type_id         INTEGER NOT NULL REFERENCES rise_types(rise_type_id),
    price                NUMERIC(10, 2) NOT NULL CHECK (price > 0),
    mrp                  NUMERIC(10, 2) NOT NULL CHECK (mrp > 0),
    discount_percent     NUMERIC(5, 2)  NOT NULL CHECK (discount_percent BETWEEN 0 AND 100),
    rating                NUMERIC(3, 2)  NOT NULL CHECK (rating BETWEEN 0 AND 5),
    review_count          INTEGER NOT NULL CHECK (review_count >= 0),

    CONSTRAINT chk_price_le_mrp CHECK (price <= mrp)
);


-- ---------------------------------------------------------------------
-- Indexes to speed up the SQL analysis steps that follow
-- ---------------------------------------------------------------------
CREATE INDEX idx_products_brand     ON products(brand_id);
CREATE INDEX idx_products_fit_type  ON products(fit_type_id);
CREATE INDEX idx_products_price     ON products(price);
CREATE INDEX idx_products_rating    ON products(rating);


-- ---------------------------------------------------------------------
-- Quick sanity check queries (run manually after loading data in Step 6)
-- ---------------------------------------------------------------------
-- SELECT COUNT(*) FROM products;
-- SELECT COUNT(*) FROM brands;
-- SELECT COUNT(*) FROM fit_types;
-- SELECT COUNT(*) FROM rise_types;
