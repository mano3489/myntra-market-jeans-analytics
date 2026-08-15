\# Myntra MarketJeans — Presentation Outline (10 Slides)





Each slide lists: what appears on it, what to say, key numbers to cite, and which chart/file to show. All numbers are real, calculated values from this project — nothing here is invented.



\---



\### Slide 1 — Title

\*\*On slide:\*\* Project title "Myntra MarketJeans: Denim E-commerce Trends Analysis," your name, and a one-line subtitle: "An end-to-end data analyst project — Python, SQL, PostgreSQL, Power BI."

\*\*Say:\*\* Briefly introduce yourself and the project in one sentence: "I built a complete analytics pipeline analyzing real Myntra jeans listing data, from raw scraped CSV all the way to an interactive dashboard."

\*\*Numbers:\*\* None needed here — keep it clean.

\*\*Show:\*\* Just the title slide, no chart.



\---



\### Slide 2 — Business Problem

\*\*On slide:\*\* The core question this project investigates.

\*\*Say:\*\* "E-commerce retailers assume pricing, discounting, and branding decisions affect customer perception — but this is rarely actually measured. I wanted to test that using real product-level data: does popularity mean quality? Does discounting hurt ratings? Where is the market concentrated?"

\*\*Numbers:\*\* None yet — this sets up the "why."

\*\*Show:\*\* No chart; optionally a simple text slide with the 2-3 core questions listed.



\---



\### Slide 3 — Project Objective \& Scope

\*\*On slide:\*\* Objectives list + an honest scope callout.

\*\*Say:\*\* "The dataset turned out to be jeans/denim-only, not the multi-category dataset I originally planned for — I want to be upfront about that. I adapted the project scope accordingly rather than forcing category claims the data couldn't support."

\*\*Numbers:\*\* None.

\*\*Show:\*\* No chart — this is a credibility-building slide, keep it text-only.



\---



\### Slide 4 — Dataset

\*\*On slide:\*\* Dataset source, size before/after cleaning.

\*\*Say:\*\* "I used the Myntra Sales Dataset from Kaggle — 52,120 raw rows, scraped via Selenium and BeautifulSoup. After cleaning, I was left with 35,073 genuine product listings across 417 brands."

\*\*Numbers:\*\* 52,120 raw rows → 35,073 cleaned rows; 417 brands; 12 fit types.

\*\*Show:\*\* No chart needed, or a simple before/after row-count graphic.



\---



\### Slide 5 — Data Cleaning

\*\*On slide:\*\* The 3 biggest cleaning decisions.

\*\*Say:\*\* "I removed 17,047 exact duplicate rows — a third of the raw data. I also found the discount\_percent column disagreed with the actual price/MRP math on over 3,500 rows, so I recalculated it directly. Finally, since there was no true category column, I extracted fit\_type and rise\_type from the product description text."

\*\*Numbers:\*\* 17,047 duplicates removed (33%); 3,557+ rows with inconsistent discount values fixed.

\*\*Show:\*\* No chart required — optionally a simple "before → after" table snippet.



\---



\### Slide 6 — Database \& SQL Analysis

\*\*On slide:\*\* Schema diagram (4 tables) + a short list of SQL techniques used.

\*\*Say:\*\* "I designed a normalized PostgreSQL schema — one products fact table with three lookup tables for brands, fit types, and rise types. I then wrote 9 SQL files covering everything from basic aggregation to CTEs and window functions like RANK, LAG/LEAD, and moving averages."

\*\*Numbers:\*\* 4 tables; 9 SQL analysis files; 35,073 rows loaded with 0 integrity violations.

\*\*Show:\*\* The ER-style diagram from Power BI's Model view (screenshot), or just describe the 4 tables verbally.



\---



\### Slide 7 — Python Analysis

\*\*On slide:\*\* 2-3 of the strongest EDA charts.

\*\*Say:\*\* "I built 8 matplotlib charts, each answering a specific business question already validated in SQL — this cross-checking between tools was intentional, to make sure both approaches agreed."

\*\*Numbers:\*\* 8 charts generated.

\*\*Show:\*\* `reports/charts/03\_rating\_distribution.png` (shows the striking clustering at 4.0/4.5) and `08\_discount\_vs\_rating.png` (shows the non-linear discount threshold effect) — these are your two most visually compelling findings.



\---



\### Slide 8 — Power BI Dashboard

\*\*On slide:\*\* Screenshot of Page 1 (Executive Overview).

\*\*Say:\*\* "The dashboard has 3 pages — an executive overview with KPIs, a detailed product and pricing analysis page with interactive filters, and a business insights page. I connected it directly to my live PostgreSQL database."

\*\*Numbers:\*\* 3 pages; 7 DAX measures; 4 interactive slicers on Page 2.

\*\*Show:\*\* Screenshot of your actual Page 1 dashboard.



\---



\### Slide 9 — Key Insights \& Recommendations

\*\*On slide:\*\* Your 3 strongest findings, condensed to one line each.

\*\*Say:\*\* "Three findings stood out. First, catalog concentration — just 18 of 417 brands account for over half of all listings. Second, popularity doesn't mean quality — review count and rating are essentially uncorrelated, r equals negative 0.0085. Third, discounting is safe up to about 60%, but ratings measurably decline beyond that threshold."

\*\*Numbers:\*\* 18/417 brands = 50%+ of listings; r = -0.0085; \~60% discount threshold.

\*\*Show:\*\* `reports/charts/08\_discount\_vs\_rating.png` again, or a simple 3-bullet insight slide.



\---



\### Slide 10 — Conclusion \& Future Scope

\*\*On slide:\*\* What was accomplished + honest limitations + what's next.

\*\*Say:\*\* "This project shows a complete pipeline from raw data to business recommendations, built entirely on evidence — every claim is traceable back to a specific SQL query or chart. Its main limitation is that there's no transaction data, so everything here is correlational, not causal, and I was careful to phrase every finding that way. With real transaction data, the natural next step would be genuine revenue and customer-retention analysis."

\*\*Numbers:\*\* Recap: 35,073 products analyzed, 9 SQL files, 8 charts, 3-page dashboard, 8 documented findings.

\*\*Show:\*\* No chart — end on the GitHub repo link for anyone who wants to explore further: github.com/mano3489/myntra-market-jeans-analytics

