# Myntra MarketWatch — Business Insights

**Dataset:** Myntra-style e-commerce product dataset (publicly available, scraped listing data), scoped to men's jeans/denim products only — 35,073 cleaned product listings across 417 brands.

**Scope note:** All findings below are PRODUCT-LEVEL (pricing, discounting, ratings, review counts). No customer/transaction data exists in this dataset, so no purchase-behavior or revenue claims are made anywhere in this report (see `sql/08_customer_analysis.sql` for why). All relationships described are correlational/associative, not causal, per this project's integrity rules.

---

### Finding 1: The catalog is highly concentrated in a small number of brands

**Evidence:** Just 18 of 417 brands (≈4.3% of all brands) account for over 50% of all product listings (`sql/10_window_functions.sql`, Q3 — running total crosses 50.90% at brand rank 18, led by United Colors of Benetton at 9.41% alone).

**Business Meaning:** Despite the appearance of a broad, diverse marketplace, the actual denim catalog is dominated by a handful of mass-market players (United Colors of Benetton, Flying Machine, Roadster, SPYKAR, WROGN).

**Recommendation:** A platform or retailer relying on this catalog should evaluate whether the long tail of 399 smaller brands is adding meaningful customer choice or simply diluting catalog navigability. Category managers could examine whether promoting mid-tier brands (100–500 listings) improves discovery without the noise of near-single-listing brands.

---

### Finding 2: Popularity (review volume) is not associated with quality (rating)

**Evidence:** The correlation between review_count and rating across all products is effectively zero (r = -0.0085, `sql/07_rating_analysis.sql` Q9). Concretely, the two most-reviewed products in the dataset (United Colors of Benetton and Roadster, each with 30,700 reviews) carry only a 3.50 rating — well below the dataset average of 3.98 (`sql/02_basic_analysis.sql` Q9).

**Business Meaning:** High sales/engagement volume does not guarantee high customer satisfaction in this catalog. A product being popular is not evidence that customers love it.

**Recommendation:** Avoid using review count alone as a proxy for product quality in merchandising decisions (e.g., "bestseller" badges). Pair volume metrics with rating thresholds before featuring a product as a top recommendation.

---

### Finding 3: Deeper discounts are associated with lower prices, and, past a threshold, with lower ratings

**Evidence:** Price and discount_percent show a moderate negative correlation (r = -0.3333, `sql/05_pricing_analysis.sql` Q7) — Luxury-band products average 34.63% discount vs 64.85% for Budget-band products. Separately, a decile breakdown of discount vs. rating (`sql/06_discount_analysis.sql` Q6) shows ratings stay flat (~4.00) through the first six discount deciles (2%–59%), then decline steadily to 3.87 in the top decile (70%–86% discount).

**Business Meaning:** Moderate discounting shows no clear association with perceived quality, but the steepest discounts (roughly the top 30% most-discounted listings) are associated with a modest but real drop in customer satisfaction.

**Recommendation:** Discounting up to roughly 60% appears "safe" with respect to customer perception in this dataset. Discounts beyond that range should be monitored for their association with declining ratings — this may reflect clearance/lower-quality inventory rather than the discount itself causing dissatisfaction, and would benefit from further investigation if transaction data becomes available.

---

### Finding 4: A small number of brands combine heavy discounting with above-average ratings

**Evidence:** 41 brands (min. 30 products each) show both above-average discount_percent AND above-average rating simultaneously (`sql/06_discount_analysis.sql` Q8) — led by Red Tape (77.60% avg discount, 4.13 avg rating).

**Business Meaning:** Finding 3 shows deep discounts are *generally* associated with lower ratings — but these 41 brands demonstrate that isn't a fixed rule. Some brands successfully discount heavily without a matching drop in customer satisfaction.

**Recommendation:** These 41 brands are worth studying as internal case studies — what these brands are doing differently (product quality, sizing accuracy, material) may be replicable playbook elements for other brands whose discounting is coinciding with lower ratings.

---

### Finding 5: Premium brand positioning is consistent across product styles, not a one-off

**Evidence:** True Religion prices above its own fit-type's average price across three separate fit types simultaneously — Slim Fit (+₹9,976), Skinny Fit (+₹9,885), Straight Fit (+₹8,974) (`sql/09_cte_analysis.sql` Q2). Tramarossa shows the single largest premium of any brand, pricing ~19x above its fit-type's average.

**Business Meaning:** For these brands, premium pricing is a deliberate, catalog-wide strategy rather than an isolated expensive product.

**Recommendation:** Category strategy for luxury denim brands should lean into this consistent premium positioning (exclusivity, brand storytelling) rather than competing on price within any single fit-type segment.

---

### Finding 6: Certain fit types rely much more heavily on discounting than others

**Evidence:** Flared, Loose Fit, and Wide Leg jeans carry the highest average discounts (58–59%) and are also the lowest-priced fit types overall (`sql/03_category_analysis.sql` Q2, Q3). Slim Fit and Anti Fit carry the lowest average discounts (~49%) while being priced near the top of the range.

**Business Meaning:** Lower-priced, less mainstream fit types appear to depend more on promotional pricing to move inventory — consistent with these being slower-moving or less core styles.

**Recommendation:** Evaluate whether Loose Fit, Wide Leg, and Flared jeans should be stocked in smaller quantities, or whether their pricing (not just discount depth) should be reconsidered, since they may be structurally less in-demand rather than simply under-discounted.

---

### Finding 7: A small brand can achieve disproportionate customer engagement

**Evidence:** HIGHLANDER has only 417 total product listings (a mid-sized brand by catalog size) but averages 779.4 reviews per product — more than double the next-highest brand in the same comparison, and far above much larger brands like Roadster (296.0 avg reviews/product) or United Colors of Benetton (111.1) (`sql/04_brand_analysis.sql` Q5). This pattern is corroborated at the individual-product level too — HIGHLANDER appears 5 times in the top 20 most-reviewed individual products (`sql/09_cte_analysis.sql` Q4).

**Business Meaning:** Catalog size and customer engagement are not the same thing — a smaller, more focused brand can generate outsized customer interest per listing.

**Recommendation:** Investigate what specifically drives HIGHLANDER's high engagement (pricing, marketing, product-market fit) as a potential model for improving engagement on other similarly-sized brands.

---

### Finding 8: Ratings cluster heavily around two values, suggesting a display/rounding pattern rather than genuine rating diversity

**Evidence:** 54% of all products (19,024 of 35,073) carry a rating of exactly 4.0, and another 22% (7,868) carry exactly 4.5 — together over 76% of the entire catalog sits at just two rating values (`sql/07_rating_analysis.sql` Q2, visualized in `reports/charts/03_rating_distribution.png`).

**Business Meaning:** This level of clustering is unlikely to reflect genuinely uniform customer sentiment; it more plausibly reflects how Myntra rounds/displays star ratings, or an artifact of how ratings were captured during scraping.

**Recommendation:** Any rating-based analysis or ranking in this project (or by a future analyst using similar scraped data) should treat rating differences smaller than roughly 0.2–0.3 points as likely insignificant, given this clustering, rather than treating every decimal difference as meaningful.

---

## Summary Table

| # | Finding | Strength of Evidence |
|---|---|---|
| 1 | Catalog concentrated in ~18 brands | Strong (exact cumulative calculation) |
| 2 | Review volume ≠ rating quality | Strong (near-zero correlation, r=-0.0085) |
| 3 | Deep discounts associated with lower ratings, only past ~60% | Moderate (clear decile pattern, weak overall correlation) |
| 4 | Some brands discount heavily without losing ratings | Moderate (41 brands identified) |
| 5 | Premium brands price consistently high across styles | Strong (repeated pattern across 3+ fit types) |
| 6 | Less-common fit types discounted more heavily | Moderate (aggregate pattern, not row-level) |
| 7 | Small brand (HIGHLANDER) shows outsized engagement | Strong (confirmed at both brand and product level) |
| 8 | Rating values are heavily clustered | Strong (direct distribution count) |
