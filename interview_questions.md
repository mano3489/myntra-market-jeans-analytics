\# Myntra WatchJeans — Interview Preparation



Each question includes a brief pointer to the real answer from this project — use these as prompts to practice explaining in your own words, not scripts to memorize.



\---



\## Section 1: Project Questions



\*\*1. Explain your project.\*\*

> An end-to-end data analyst project analyzing \~35,000 real Myntra men's jeans listings — cleaned with Python, stored in a normalized PostgreSQL database, analyzed with 9 SQL files (basic stats through CTEs and window functions), visualized with Python/matplotlib and a 3-page Power BI dashboard, and summarized into evidence-based business insights.



\*\*2. Why did you choose this project?\*\*

> To demonstrate the full realistic data analyst pipeline — not just a single notebook — including database design, SQL depth, and dashboarding, using real (not synthetic) scraped e-commerce data.



\*\*3. What was the business problem?\*\*

> Understanding how pricing, discounting, and branding relate to customer perception (rating) and engagement (review volume) in a real product catalog.



\*\*4. What dataset did you use?\*\*

> The "Myntra Sales Dataset" from Kaggle (`skmewati/myntra-sales-dataset`) — publicly available, scraped via Selenium/BeautifulSoup. Be ready to say clearly: \*\*this turned out to be jeans-only, not multi-category\*\* — a real discovery you made and adapted to, not the original plan.



\*\*5. How large was the dataset?\*\*

> Raw: 52,120 rows × 7 columns. After cleaning: 35,073 rows × 10 columns.



\*\*6. How did you clean the data?\*\*

> Renamed columns, removed 17,047 exact duplicates, recalculated discount\_percent from price/MRP (the raw column was wrong on 3,557+ rows), derived fit\_type and rise\_type from text, generated a synthetic product\_id, validated ranges.



\*\*7. How did you handle missing values?\*\*

> There were none in this dataset — but you should be ready to explain what you \*would\* do (mean/median imputation for numeric, mode or "Unknown" category for categorical, or row removal, depending on missingness pattern) since interviewers often probe this even if your specific dataset didn't need it.



\*\*8. How did you handle duplicates?\*\*

> Identified 17,047 exact duplicate rows (same brand, product name, price, MRP, discount, rating, review count) and dropped them, keeping the first occurrence — a 33% reduction from raw data.



\*\*9. Why PostgreSQL?\*\*

> Free, open-source, strong SQL standard compliance, supports window functions and CTEs natively, industry-relevant for analyst roles.



\*\*10. Why SQL?\*\*

> It's the standard language for querying relational data efficiently and is universally expected of data analysts; also lets the database engine (not application code) do heavy aggregation work.



\*\*11. Why Python?\*\*

> For data cleaning/transformation (pandas), loading into PostgreSQL (psycopg2/sqlalchemy), and exploratory visualization (matplotlib) — tasks that are awkward or impossible in pure SQL.



\*\*12. What CTEs did you use?\*\*

> See Section 2 below — five CTE-based queries in `sql/09\_cte\_analysis.sql`, including a 3-stage nested CTE for "best-rated brand within each price band."



\*\*13. What window functions did you use?\*\*

> `ROW\_NUMBER`, `RANK`, `DENSE\_RANK`, `LAG`, `LEAD`, `SUM() OVER()` (running total), `AVG() OVER()` with an explicit window frame (moving average). See Section 2.



\*\*14. What was your most difficult SQL query?\*\*

> Arguably the price-band CTE query (`09\_cte\_analysis.sql` Q5) — three dependent CTE stages (band assignment → brand+band aggregation → ranking), or the window-frame moving average (`10\_window\_functions.sql` Q4), since getting `ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING` right required understanding the difference between a running and a moving average.



\*\*15. How did you optimize SQL queries?\*\*

> Added indexes on `brand\_id`, `fit\_type\_id`, `price`, and `rating` in `create\_tables.sql` since those columns are filtered/grouped/sorted constantly across almost every analysis file.



\*\*16. How did you validate your results?\*\*

> Cross-checked findings across tools — e.g., the discount-rating decile pattern found in SQL (`06\_discount\_analysis.sql`) was independently reproduced in the Python chart (`08\_discount\_vs\_rating.png`) and again from the opposite axis in `07\_rating\_analysis.sql`. Also ran explicit data-load verification (row counts, NULL checks, orphaned foreign key checks) after populating the database.



\*\*17. What was your most important finding?\*\*

> Popularity (review\_count) and quality (rating) are essentially uncorrelated (r = -0.0085) — the two most-reviewed products in the whole catalog (30,700 reviews each) only rate 3.50, well below the 3.98 average.



\*\*18. What business recommendation did you make?\*\*

> Among others: treat \~60% discount as a soft ceiling before ratings start declining, and don't use review volume alone as a proxy for product quality in merchandising decisions.



\*\*19. What are the limitations?\*\*

> No customer/transaction data (so no revenue, repeat-purchase, or true sales-impact claims are possible); single-category (jeans only, not the originally-planned multi-category dataset); all relationships are correlational, not causal; rating values show heavy clustering (76% at just two values), likely a platform display artifact limiting rating granularity.



\*\*20. What would you improve in the future?\*\*

> See `README.md` → Future Enhancements: genuine transaction data for revenue analysis, a true multi-category dataset, causal analysis with controlled data, and time-series data to study trends rather than a single snapshot.



\---



\## Section 2: SQL Questions (specific to this project's actual queries)



1\. Walk me through `sql/02\_basic\_analysis.sql` — how did you compute the median price in SQL, and why not just use AVG?

&#x20;  \*(`PERCENTILE\_CONT(0.5) WITHIN GROUP (ORDER BY price)` — median is robust to outliers like the ₹54,000 luxury jeans, unlike AVG.)\*



2\. In `03\_category\_analysis.sql`, why did you use `HAVING COUNT(\*) >= 100` in one query but not others?

&#x20;  \*(To prevent a fit type with very few listings from misleadingly topping a "best-rated" ranking by chance.)\*



3\. In `04\_brand\_analysis.sql`, how did you decide on a minimum-30-products threshold for brand rankings? What did you check before choosing it?

&#x20;  \*(Checked the real distribution — 42 brands had exactly 1 product, 109 had fewer than 5, median brand had 15. Thirty was chosen to retain a meaningful \~39% of brands while excluding the extreme long tail.)\*



4\. Explain the `CASE`-based price bands in `05\_pricing\_analysis.sql`. Why those specific cutoffs?

&#x20;  \*(Derived from actual price quantiles — 25th percentile ₹899, median ₹1,418, 75th percentile ₹1,829, 95th percentile ₹3,149 — not arbitrary round numbers.)\*



5\. What's the difference between `RANK()` and `DENSE\_RANK()`, and where did you demonstrate it?

&#x20;  \*(`10\_window\_functions.sql` Q1 — RANK leaves gaps after ties (1,1,3), DENSE\_RANK doesn't (1,1,2).)\*



6\. What's the difference between `LAG()`/`LEAD()` and a self-join? Why use the window function version?

&#x20;  \*(LAG/LEAD avoid the extra join and messy ON conditions — they directly reference the "previous"/"next" row within an ordered partition in one pass.)\*



7\. Explain the window frame in your moving-average query.

&#x20;  \*(`ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING` in `10\_window\_functions.sql` Q4 — restricts the AVG() to a 5-row local neighborhood, making it a true moving average rather than the default cumulative-from-start behavior.)\*



8\. Why did you use a CTE instead of a subquery in `09\_cte\_analysis.sql`?

&#x20;  \*(Multi-stage logic — e.g. Q5's three dependent stages (band assignment → per-band brand aggregation → ranking) are far more readable named step-by-step than nested inside one query.)\*



9\. How did you compute correlation directly in SQL?

&#x20;  \*(PostgreSQL's native `CORR()` aggregate function — e.g. `CORR(price, rating)` in `05\_pricing\_analysis.sql` Q7 — no need to export to Python for this.)\*



10\. Why is `sql/08\_customer\_analysis.sql` empty of queries?

&#x20;   \*(No transaction/customer data exists in this dataset — explicitly documented rather than fabricated, per the project's integrity rules.)\*



\---



\## Section 3: Power BI Questions (specific to this project's actual dashboard)



1\. How did you connect Power BI to your data source?

&#x20;  \*(Direct PostgreSQL connector, Import mode, localhost:5432, database `myntra\_marketwatch`.)\*



2\. Walk me through your data model — how many tables, and what are the relationships?

&#x20;  \*(4 tables: `products` as the central fact table, with foreign keys to 3 lookup tables — `brands`, `fit\_types`, `rise\_types` — all one-to-many relationships, auto-detected from the PostgreSQL foreign key constraints.)\*



3\. What DAX measures did you create, and why as measures rather than calculated columns?

&#x20;  \*(`Total Products`, `Total Brands`, `Total Fit Types`, `Avg Price`, `Avg Discount %`, `Avg Rating`, `Total Reviews` — all aggregations that should recalculate dynamically based on report filters/slicers, which is exactly what measures are for; a calculated column would compute once per row and wouldn't respond to slicer interaction the same way.)\*



4\. You also created a calculated \*column\* (Price Band) — why a column instead of a measure there?

&#x20;  \*(Price Band needs to exist as a categorical value on each row, usable as an axis/group-by field in visuals — that's what columns are for; measures can't be used as an axis field.)\*



5\. Describe a bug you ran into and how you fixed it.

&#x20;  \*(Good real example: the Price Band DAX formula initially threw "a single value for column price cannot be determined" — caused by accidentally creating it as a measure instead of a calculated column, since measures lack row context. Fixed by explicitly using "New column" and re-entering the formula.)\*



6\. Your scatter chart initially showed only one dot — what happened, and how did you fix it?

&#x20;  \*(Power BI defaulted to aggregating price and rating with SUM across the whole table, collapsing all \~35,000 products into a single point. Fixed by adding `product\_id` to the chart's Details field, forcing each product to render as its own point.)\*



7\. Your top-rated products table showed impossible values (a "rating" of 26.40). What caused that, and what does it teach you about Power BI table visuals?

&#x20;  \*(Multiple actual products shared identical product\_name + brand\_name text, so the table grouped and summed their ratings together. Fixed by adding the unique product\_id column and switching the aggregation from Sum to Average. Lesson: any table meant to show one row per real-world entity needs a genuine unique identifier field, or Power BI will silently group and aggregate rows that look identical on the displayed columns.)\*



8\. How do your slicers work, and what would happen if you didn't clear them before presenting?

&#x20;  \*(fit\_type\_name, brand\_name, price range, and rating range slicers filter every visual on the page simultaneously. If left set to a single value like "Loose Fit" while presenting, every chart on the page would misleadingly appear to only have one fit type's worth of data — a mistake made and caught during this project's build.)\*



9\. Why does Page 3 have no interactive charts, just text boxes?

&#x20;  \*(An insights/summary page is meant to be read, not explored — text boxes clearly presenting the 8 key findings and 6 recommendation themes are more appropriate than forcing extra charts where they don't add value, consistent with "don't overcrowd the dashboard.")\*



10\. How would you make this dashboard refresh automatically, or share it with others?

&#x20;   \*(Publish to Power BI Service, set up a scheduled refresh against the PostgreSQL source (would need a gateway for an on-premises database), and share via a workspace or published link — worth knowing conceptually even if not implemented in this local-only project.)\*

