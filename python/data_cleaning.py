"""
Myntra MarketJean — Data Cleaning Script
==========================================
Input:  data/raw/myntra_dataset_ByScraping.csv
Output: data/cleaned/myntra_jeans_cleaned.csv

IMPORTANT SCOPE NOTE (read this before using elsewhere):
This dataset contains JEANS/DENIM products only (Myntra men's jeans category,
scraped via Selenium/BeautifulSoup). It has no product_id, category,
subcategory, gender, review text, or date columns. Every cleaning decision
below works with what genuinely exists in the raw file — nothing is invented.

Each cleaning step below is documented as:
  PROBLEM  -> what was wrong
  REASON   -> why it's a problem for analysis
  SOLUTION -> what we did about it
  IMPACT   -> how many rows/values were affected (real counts, printed at runtime)
"""

import pandas as pd
import numpy as np
import re

RAW_PATH = "data/raw/myntra_dataset_ByScraping.csv"
CLEANED_PATH = "data/cleaned/myntra_jeans_cleaned.csv"
SAMPLE_PATH = "data/sample/myntra_jeans_sample.csv"


def load_raw(path: str) -> pd.DataFrame:
    df = pd.read_csv(path)
    print(f"[LOAD] Raw shape: {df.shape}")
    return df


def rename_columns(df: pd.DataFrame) -> pd.DataFrame:
    """
    PROBLEM: Raw column names are inconsistent in style (mixed case, a
             domain-specific name 'pants_description' instead of a generic
             'product_name'), which makes SQL/BI work later less readable.
    REASON:  Consistent, descriptive, lowercase snake_case names make SQL
             queries and dashboard fields easier to read and less error-prone.
    SOLUTION: Rename to a clean, standard schema.
    IMPACT:  Structural only — no data values change.
    """
    df = df.rename(columns={
        "brand_name": "brand",
        "pants_description": "product_name",
        "MRP": "mrp",
        "ratings": "rating",
        "number_of_ratings": "review_count",
    })
    return df


def add_product_id(df: pd.DataFrame) -> pd.DataFrame:
    """
    PROBLEM: The raw dataset has no product_id column at all.
    REASON:  A primary key is required for the database design (Step 5) and
             for any row-level referencing in SQL joins/window functions.
    SOLUTION: Generate a synthetic sequential ID (JN00001, JN00002, ...).
              This is standard practice for scraped datasets that lack a
              native key — it is NOT the same as inventing product data;
              it's just a row label.
    IMPACT:  Adds one new column, 52,120 IDs generated, no data values touched.
    """
    df = df.reset_index(drop=True)
    df.insert(0, "product_id", ["JN" + str(i + 1).zfill(5) for i in range(len(df))])
    return df


def remove_exact_duplicates(df: pd.DataFrame) -> pd.DataFrame:
    """
    PROBLEM: 17,047 fully duplicate rows exist (identical brand, product name,
             price, MRP, discount, rating, and review count).
    REASON:  Duplicate rows inflate counts in every downstream analysis —
             brand product counts, category counts, average calculations
             would all be biased by repeated listings likely caused by the
             scraper visiting the same product page more than once.
    SOLUTION: Drop exact duplicate rows, keeping the first occurrence.
    IMPACT:  Printed at runtime (row count before vs after).
    """
    before = len(df)
    subset_cols = ["brand", "product_name", "price", "mrp", "discount_percent", "rating", "review_count"]
    df = df.drop_duplicates(subset=subset_cols, keep="first").reset_index(drop=True)
    after = len(df)
    print(f"[DEDUP] Removed {before - after} exact duplicate rows ({before} -> {after})")
    return df


def fix_discount_percent(df: pd.DataFrame) -> pd.DataFrame:
    """
    PROBLEM: The raw discount_percent column is inconsistent — most values
             are proper decimals (0.02-0.99), but 4,000+ rows have values
             far outside the valid 0-1 range (up to 64.0), meaning some
             records were scraped/stored as whole percentages instead of
             fractions, and disagree with the price/MRP relationship.
    REASON:  An unreliable discount column would produce wrong "top discount"
             rankings and wrong discount-vs-rating analysis in later SQL/BI
             steps.
    SOLUTION: Recompute discount_percent directly and consistently from the
              two numbers we trust — price and MRP — using:
                  discount_percent = (mrp - price) / mrp
              This replaces the untrustworthy raw column with a verified,
              internally consistent one, expressed as a percentage
              (e.g. 45.0 meaning 45%) for easier reading in SQL/BI.
    IMPACT:  Printed at runtime — every row's discount_percent is recalculated.
    """
    calc = (df["mrp"] - df["price"]) / df["mrp"] * 100
    changed = (abs(calc - df["discount_percent"] * 100) > 1).sum()
    print(f"[DISCOUNT] Recalculated discount_percent for all rows; "
          f"{changed} rows differed from the raw stated value by more than 1 point")
    df["discount_percent"] = calc.round(2)
    return df


def extract_fit_type(df: pd.DataFrame) -> pd.DataFrame:
    """
    PROBLEM: There is no category/subcategory column, but product_name text
             contains a recognizable fit style (Slim Fit, Loose Fit, Skinny
             Fit, Relaxed Fit, Straight Fit, Bootcut, Tapered, Anti Fit,
             Regular Fit, Wide Leg, Mid-Rise variants, etc.).
    REASON:  Since this is a single-category (jeans-only) dataset, fit_type
             is the most meaningful sub-grouping we can analyze — it stands
             in for what "subcategory" would normally provide, and it is
             genuinely present in the text, not invented.
    SOLUTION: Extract fit_type using pattern matching on known fit keywords.
              Rows that don't match any known keyword are labeled "Other/Unspecified"
              rather than guessed at.
    IMPACT:  Printed at runtime — shows how many rows matched vs fell to
             "Other/Unspecified".
    """
    fit_patterns = [
        ("Skinny Fit", r"skinny"),
        ("Slim Fit", r"slim"),
        ("Relaxed Fit", r"relax"),
        ("Regular Fit", r"regular"),
        ("Loose Fit", r"loose"),
        ("Straight Fit", r"straight"),
        ("Bootcut", r"bootcut|boot cut"),
        ("Wide Leg", r"wide leg|wide-leg"),
        ("Tapered Fit", r"taper"),
        ("Anti Fit", r"anti fit|anti-fit"),
        ("Flared", r"flare"),
    ]

    def match_fit(name: str) -> str:
        name_lower = name.lower()
        for label, pattern in fit_patterns:
            if re.search(pattern, name_lower):
                return label
        return "Other/Unspecified"

    df["fit_type"] = df["product_name"].apply(match_fit)
    matched = (df["fit_type"] != "Other/Unspecified").sum()
    print(f"[FIT_TYPE] Extracted fit_type for {matched}/{len(df)} rows "
          f"({len(df) - matched} labeled 'Other/Unspecified')")
    return df


def extract_rise_type(df: pd.DataFrame) -> pd.DataFrame:
    """
    PROBLEM: product_name also sometimes specifies rise (Mid-Rise, High-Rise,
             Low-Rise), a second genuine attribute buried in free text.
    REASON:  Rise is a real, commonly-used jeans attribute that adds another
             legitimate analysis dimension beyond fit_type.
    SOLUTION: Extract rise_type using keyword matching, same approach as
              fit_type. Rows without a specified rise are "Not Specified".
    IMPACT:  Printed at runtime.
    """
    def match_rise(name: str) -> str:
        name_lower = name.lower()
        if "mid-rise" in name_lower or "mid rise" in name_lower:
            return "Mid-Rise"
        if "high-rise" in name_lower or "high rise" in name_lower:
            return "High-Rise"
        if "low-rise" in name_lower or "low rise" in name_lower:
            return "Low-Rise"
        return "Not Specified"

    df["rise_type"] = df["product_name"].apply(match_rise)
    specified = (df["rise_type"] != "Not Specified").sum()
    print(f"[RISE_TYPE] Extracted rise_type for {specified}/{len(df)} rows")
    return df


def validate_ranges(df: pd.DataFrame) -> pd.DataFrame:
    """
    PROBLEM: Need to confirm price, mrp, rating, and discount all fall in
             plausible ranges before loading into the database.
    REASON:  Catching invalid values now (not during SQL analysis) prevents
             broken downstream queries and dashboard numbers.
    SOLUTION: Check — do not blindly drop — rows outside expected bounds:
                price > 0, mrp > 0, price <= mrp, 0 <= rating <= 5,
                0 <= discount_percent <= 100. Report counts; only remove
                rows that are logically impossible (e.g. price > mrp, which
                would mean a negative discount and likely a scraping error).
    IMPACT:  Printed at runtime.
    """
    invalid_price = (df["price"] <= 0).sum()
    invalid_mrp = (df["mrp"] <= 0).sum()
    price_over_mrp = (df["price"] > df["mrp"]).sum()
    invalid_rating = ((df["rating"] < 0) | (df["rating"] > 5)).sum()

    print(f"[VALIDATE] price<=0: {invalid_price} | mrp<=0: {invalid_mrp} | "
          f"price>mrp: {price_over_mrp} | rating out of [0,5]: {invalid_rating}")

    before = len(df)
    df = df[df["price"] <= df["mrp"]].reset_index(drop=True)
    after = len(df)
    if before != after:
        print(f"[VALIDATE] Removed {before - after} rows where price > mrp (impossible discount)")
    return df


def reorder_columns(df: pd.DataFrame) -> pd.DataFrame:
    ordered = [
        "product_id", "brand", "product_name", "fit_type", "rise_type",
        "price", "mrp", "discount_percent", "rating", "review_count",
    ]
    return df[ordered]


def run():
    df = load_raw(RAW_PATH)
    df = rename_columns(df)
    df = add_product_id(df)
    df = remove_exact_duplicates(df)
    df = fix_discount_percent(df)
    df = extract_fit_type(df)
    df = extract_rise_type(df)
    df = validate_ranges(df)
    df = reorder_columns(df)

    df.to_csv(CLEANED_PATH, index=False)
    df.head(200).to_csv(SAMPLE_PATH, index=False)

    print()
    print(f"[SAVE] Cleaned dataset saved to {CLEANED_PATH} — final shape: {df.shape}")
    print(f"[SAVE] Sample (first 200 rows) saved to {SAMPLE_PATH}")
    print()
    print("[SUMMARY] Cleaned dataset preview:")
    print(df.head(10).to_string())


if __name__ == "__main__":
    run()
