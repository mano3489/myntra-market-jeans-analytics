# Myntra MarketJeans: Unveiling E-commerce Trends

A denim-category deep-dive analytics project built on a real, publicly available Myntra product dataset — covering data cleaning, PostgreSQL database design, SQL analysis (basic queries through CTEs and window functions), Python EDA, and a 3-page Power BI dashboard.

---

## Overview

Myntra MarketWatch analyzes ~35,000 men's jeans/denim product listings scraped from Myntra (a major Indian e-commerce fashion platform) to uncover pricing, discounting, branding, and rating patterns. The project demonstrates a complete, real-world data analyst workflow: raw data → cleaning → database → SQL analysis → Python EDA → BI dashboard → business insights → recommendations.

**Important scope note:** The dataset used is a **publicly available, Myntra-style e-commerce product dataset** (sourced from Kaggle, originally scraped via Selenium/BeautifulSoup) — it is not official Myntra business data, and no claims in this project represent actual Myntra company results.

---

## Business Problem

E-commerce fashion retailers need to understand how pricing, discounting, and branding decisions relate to customer perception (ratings) and engagement (review volume) — but this relationship is often assumed rather than measured. This project investigates, using real product-level data: Which brands and product styles perform best? How does discount depth relate to customer ratings? Is popularity the same as quality? Where does the catalog concentrate, and does that concentration make sense?

---

## Objectives

- Clean and validate a real scraped e-commerce dataset without fabricating missing structure
- Design a normalized relational database to support efficient analysis
- Answer a structured series of business questions using SQL (basic aggregation through CTEs and window functions)
- Visualize distributions and relationships using Python
- Build an interactive, filterable Power BI dashboard
- Produce evidence-based business insights and recommendations, explicitly distinguishing correlation from causation

---

## Dataset

- **Source:** Kaggle — `skmewati/myntra-sales-dataset` ("Myntra Sales Dataset")
- **Scope:** Men's jeans/denim products only (not multi-category, despite the project's original broader ambition — see `data/raw/` and cleaning notes below for why)
- **Raw size:** 52,120 rows, 7 columns (`brand_name`, `pants_description`, `price`, `MRP`, `discount_percent`, `ratings`, `number_of_ratings`)
- **Cleaned size:** 35,073 rows, 10 columns, after removing 17,047 exact duplicate listings and enriching with derived fields
- **No customer/transaction data exists in this dataset** — see `sql/08_customer_analysis.sql` for the explicit, documented reason customer-behavior analysis was not attempted

---

## Technologies Used

| Layer | Tools |
|---|---|
| Data processing | Python 3.13, pandas, numpy |
| Database | PostgreSQL 18.4 |
| SQL | Joins, CTEs, window functions, aggregate functions, CASE-based binning |
| Visualization (Python) | matplotlib |
| Visualization (Dashboard) | Power BI Desktop |
| IDE | VS Code |
| Version control | Git |

---

## Architecture

```
Raw CSV (Kaggle)
   ↓
Python data cleaning (dedup, derive fit_type/rise_type, validate ranges)
   ↓
PostgreSQL (normalized: products, brands, fit_types, rise_types)
   ↓
SQL analysis (9 files: basic → category → brand → pricing → discount → rating → CTEs → window functions)
   ↓
Python EDA (8 matplotlib charts)
   ↓
Power BI dashboard (3 pages)
   ↓
Business insights & recommendations (evidence-based, correlation not causation)
```

---

## Data Cleaning

Performed in `python/data_cleaning.py`. Key decisions:

- **Renamed columns** to a consistent schema (`brand`, `product_name`, `mrp`, `rating`, `review_count`)
- **Removed 17,047 exact duplicate rows** (33% of raw data) — likely repeated scraper visits to the same listing
- **Recalculated `discount_percent`** from `(mrp - price) / mrp`, since the raw column disagreed with the price/MRP math on 3,557+ rows
- **Derived `fit_type`** (Slim, Skinny, Relaxed, etc.) and **`rise_type`** (Mid/High/Low-Rise) from free-text product descriptions via keyword pattern matching — unmatched rows are honestly labeled "Other/Unspecified," not guessed
- **Generated a synthetic `product_id`** (no natural key existed in the raw data)
- **Validated** price/MRP/rating ranges — zero violations found after deduplication
- **Kept legitimate price outliers** (₹54,000 luxury jeans from Jacob Cohen, Tramarossa) after verifying they were real premium brands, not data errors

---

## Database Design

PostgreSQL schema: 1 fact table (`products`) + 3 normalized lookup tables (`brands`, `fit_types`, `rise_types`), connected via foreign keys with `CHECK` constraints enforcing business rules (`price > 0`, `price <= mrp`, `rating BETWEEN 0 AND 5`, etc.) and indexes on frequently-filtered columns. Full rationale in `database/schema.sql`; DDL in `database/create_tables.sql`.

**No customer/transaction tables exist** — deliberately, since no such data was available (see Step 13 in the project's analysis log / `sql/08_customer_analysis.sql`).

---

## SQL Analysis

9 SQL files in `sql/`, run against the live PostgreSQL database:

1. `02_basic_analysis.sql` — counts, average/median price, cheapest/priciest/highest-rated/most-reviewed products
2. `03_category_analysis.sql` — fit-type-level product count, pricing, discount, rating, review volume
3. `04_brand_analysis.sql` — top brands, premium/budget brand identification (min. 30-product threshold to avoid small-sample distortion)
4. `05_pricing_analysis.sql` — data-driven price bands (percentile-based, not arbitrary), price-rating/price-discount correlation
5. `06_discount_analysis.sql` — discount deciles vs. rating and review count, brands combining high discount with high rating
6. `07_rating_analysis.sql` — rating distribution, rating vs. price/discount from the opposite axis
7. `08_customer_analysis.sql` — explicitly documented as **Not Applicable** (no transaction data)
8. `09_cte_analysis.sql` — multi-step business questions using Common Table Expressions
9. `10_window_functions.sql` — `RANK`, `DENSE_RANK`, `LAG`, `LEAD`, running totals, and moving averages with explicit window frames

All queries were run against real data; results and interpretation are documented throughout the project's development log.

---

## Python Analysis

`python/exploratory_analysis.py` generates 8 matplotlib charts (saved to `reports/charts/`), each tied to a specific business question already validated in SQL — cross-checking that both tools agree:

1. Product count by fit type
2. Average price by fit type
3. Rating distribution (reveals heavy clustering at 4.0/4.5)
4. Discount distribution
5. Top 15 brands by product count
6. Price distribution (log scale, showing the long luxury tail)
7. Rating vs. price (scatter + trend line)
8. Average rating by discount decile (shows the non-linear discount-rating relationship)

---

## Dashboard

3-page Power BI dashboard connected directly to the PostgreSQL database:

- **Page 1 — Executive Overview:** 6 KPI cards (Total Products, Brands, Fit Types, Avg Price, Avg Discount %, Avg Rating) + 4 charts (fit-type distribution, top brands, price distribution, discount distribution)
- **Page 2 — Product & Pricing Analysis:** Avg price/discount by fit type and brand, rating-vs-price scatter, data-driven price bands, top-rated products table, with slicers for fit type, brand, price range, and rating range
- **Page 3 — Business Insights:** Key findings and recommendations, summarized from `reports/business_insights.md` and `reports/recommendations.md`

---

## Key Insights

(Full detail with evidence in `reports/business_insights.md`)

1. Just 18 of 417 brands account for over 50% of all listings
2. Review volume and rating are essentially uncorrelated (r = -0.0085) — popularity ≠ quality
3. Discounts up to ~60% show no rating penalty; beyond that, ratings decline measurably
4. A subset of 41 brands successfully combine deep discounting with above-average ratings
5. Premium brands (True Religion, Tramarossa) price consistently above category norms across multiple fit types, not just once
6. Lower-priced, less-common fit types (Loose Fit, Wide Leg, Flared) rely more heavily on discounting
7. HIGHLANDER, a mid-sized brand, shows disproportionately high per-product engagement
8. 76% of all products cluster at just two rating values (4.0 and 4.5), suggesting a display/rounding artifact rather than genuine uniformity

---

## Business Recommendations

(Full detail in `reports/recommendations.md`) — organized by Pricing, Discount Strategy, Product Assortment, Brand Strategy, Category Strategy, and Customer Engagement, each tied directly to a specific finding above.

---

## Project Structure

```
myntra-marketwatch/
├── data/
│   ├── raw/                  # Original Kaggle CSV
│   ├── cleaned/               # Cleaned dataset (35,073 rows)
│   └── sample/                 # 200-row sample for quick preview
├── database/
│   ├── schema.sql              # Design rationale
│   └── create_tables.sql       # Runnable DDL
├── sql/                        # 9 analysis files (see above)
├── python/
│   ├── data_cleaning.py
│   ├── load_to_db.py
│   └── exploratory_analysis.py
├── dashboard/                   # Power BI .pbip project
├── reports/
│   ├── charts/                  # 8 matplotlib PNGs
│   ├── business_insights.md
│   └── recommendations.md
├── requirements.txt
└── README.md
```

---

## How to Run

1. **Environment:** Install Python 3.13+, PostgreSQL, and the packages in `requirements.txt` (`pip install -r requirements.txt`)
2. **Clean the data:** `python python/data_cleaning.py`
3. **Create the database:** `psql -U postgres -c "CREATE DATABASE myntra_marketwatch;"` then `psql -U postgres -d myntra_marketwatch -f database/create_tables.sql`
4. **Load the data:** `python python/load_to_db.py`
5. **Run SQL analysis:** `psql -U postgres -d myntra_marketwatch -f sql/02_basic_analysis.sql` (repeat for each file in `sql/`)
6. **Generate EDA charts:** `python python/exploratory_analysis.py`
7. **Open the dashboard:** Open `dashboard/*.pbip` in Power BI Desktop, connect to your local `myntra_marketwatch` database

---

## Future Enhancements

- If genuine transaction/customer data becomes available, extend the schema to support actual customer purchase-behavior and revenue analysis (explicitly not possible with the current product-level-only dataset)
- Expand beyond jeans to a genuinely multi-category Myntra dataset, if one with reliable category/gender columns is found
- Investigate causally (e.g., via controlled A/B testing data, if available) whether deep discounting actually influences ratings, rather than being merely associated with them
- Add time-series data if historical pricing/rating snapshots become available, to study trends rather than a single point-in-time snapshot

---

## Author

Manojprabakaran — built as a portfolio project demonstrating end-to-end data analyst skills (Python, SQL, PostgreSQL, Power BI) for college/GitHub/interview use.
