# Myntra MarketWatch — Business Recommendations

Every recommendation below is derived directly from a finding in `reports/business_insights.md`, which in turn is traced to specific SQL queries and Python charts. No recommendation here relies on external assumptions, industry benchmarks, or invented data.

**Scope reminder:** This dataset covers men's jeans/denim listings only, with no customer/transaction data. "Customer Engagement" recommendations below are based on review count and rating (customer *feedback* signals), not purchase behavior — see `sql/08_customer_analysis.sql` for why purchase-based recommendations are not made.

---

## 1. Pricing Strategy

**Based on:** Finding 5 (premium brand consistency) and the price-vs-rating relationship (Steps 10 & 12).

- **Lean into consistent premium positioning for luxury brands.** True Religion and Tramarossa price well above the fit-type average across *multiple* styles, not just one — this is a deliberate, catalog-wide strategy. Continue supporting this positioning rather than pressuring these brands toward mid-market pricing.
- **Reassess mid-range pricing.** Rating only shows a real upward association with price at the top end (4.0★ → ₹1,594 avg, 4.5★ → ₹1,831, 5.0★ → ₹2,096 — `sql/07_rating_analysis.sql` Q7). Below the 4.0 rating band, price shows little relationship to perceived quality, suggesting mid-tier pricing has room to be re-evaluated without an expected rating penalty.

## 2. Discount Strategy

**Based on:** Findings 3 and 4 (discount-rating threshold effect, and brands that discount heavily without losing ratings).

- **Treat ~60% discount as a soft ceiling.** Ratings hold steady up to roughly the 59th discount percentile, then decline notably beyond it (`sql/06_discount_analysis.sql` Q6). Deep discounting up to this point appears safe; beyond it, monitor for a quality-perception drop.
- **Study the 41 brands that buck this trend.** Brands like Red Tape (77.6% avg discount, 4.13 avg rating) show it's possible to discount deeply without a rating hit. A follow-up investigation (not possible with this dataset alone) into what these brands do differently — packaging, sizing accuracy, marketing — could turn into a playbook for others.
- **Apply lighter discounting to Slim Fit and Anti Fit.** These already carry the lowest average discounts (~49%) and are among the pricier fit types — no evidence in this data suggests they need deeper discounts to perform well.

## 3. Product Assortment

**Based on:** Finding 6 (low-demand fit types) and Finding 1 (catalog concentration).

- **Re-evaluate stocking levels for Loose Fit, Wide Leg, and Flared jeans.** These fit types are both the lowest-priced and most heavily discounted (58–59% avg), a pattern consistent with slower-moving inventory. Consider smaller batch sizes or bundling these styles with better-performing ones.
- **Audit the long tail of single/near-single-listing brands.** 109 of 417 brands have fewer than 5 listed products each. Determine whether these genuinely add customer choice or simply add catalog clutter — a smaller, better-curated brand list may improve navigability without reducing real variety (top 18 brands already cover 50%+ of listings).

## 4. Brand Strategy

**Based on:** Finding 7 (HIGHLANDER's outsized engagement) and brand-level rating leaders (Step 9).

- **Study HIGHLANDER as an internal benchmark.** With only 417 products but 779.4 average reviews per product (nearly triple most larger competitors), HIGHLANDER is generating disproportionate customer interest relative to catalog size. Understanding why — pricing, positioning, marketing — could inform strategy for similarly-sized brands.
- **Recognize Levis as a cross-tier performer.** Levis is the only brand to rank as a top performer in both the Mid-range and Luxury price bands (`sql/09_cte_analysis.sql` Q5) while also holding a strong 4.22 average rating across 566 products — a genuinely broad, consistent brand, not a one-segment specialist.

## 5. Category (Fit-Type) Strategy

**Based on:** Findings from Step 8 category analysis and Step 15 window function results.

- **Slim Fit is both the volume leader and a strong performer** (11,994 listings, 3.99 avg rating, 1.47M total reviews) — continue prioritizing catalog depth here, it is not over-saturated relative to its demonstrated demand.
- **Bootcut, despite being a small category (593 listings), shows the highest average price and strong per-product engagement (144.4 avg reviews/product)** — a candidate for selective expansion rather than treating it as a niche/legacy style.

## 6. Customer Engagement (Review-Based Signals Only)

**Based on:** Finding 2 (popularity ≠ quality) — no purchase/transaction data exists, so this section is intentionally limited to review-based signals.

- **Do not equate high review count with high satisfaction in merchandising decisions.** The two most-reviewed products in the entire catalog (30,700 reviews each) carry only a 3.50 rating, well under the 3.98 average. "Most popular" badges or default sort-by-popularity views may be surfacing mediocre products.
- **Consider a combined engagement+quality score for featured placement** (e.g., weighting both review_count and rating) rather than ranking by either metric alone, given the near-zero correlation between them (r = -0.0085).

---

## What This Project Cannot Recommend (and why)

Per the project's integrity rules, the following are explicitly NOT recommended, because the data does not support them:
- Any claim about actual sales lift, revenue impact, or ROI from a pricing/discount change (no transaction data)
- Customer retention or repeat-purchase strategies (no customer-level data)
- Claims that a discount or price change will *cause* a rating change (only association is demonstrated, not causation)
