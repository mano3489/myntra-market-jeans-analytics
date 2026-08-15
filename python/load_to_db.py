"""
Myntra MarketJean — Load Cleaned Data into PostgreSQL
========================================================
Reads data/cleaned/myntra_jeans_cleaned.csv and loads it into the
4 tables created by database/create_tables.sql (brands, fit_types,
rise_types, products), then runs verification checks.

USAGE (run from the project root folder):
    python python/load_to_db.py

You will be prompted for your PostgreSQL password (the one you set
during installation, for the 'postgres' user). Nothing is hardcoded
or stored, so this is safe to commit to GitHub.
"""

import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
import getpass

# ---------------------------------------------------------------------
# Connection settings — edit these if your setup differs
# ---------------------------------------------------------------------
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "myntra_marketwatch"
DB_USER = "postgres"

CLEANED_CSV = "data/cleaned/myntra_jeans_cleaned.csv"


def get_connection():
    password = getpass.getpass(f"Password for PostgreSQL user '{DB_USER}': ")
    conn = psycopg2.connect(
        host=DB_HOST, port=DB_PORT, dbname=DB_NAME, user=DB_USER, password=password
    )
    return conn


def load_lookup_table(cur, conn, table, id_col, name_col, values):
    """
    Inserts distinct values into a lookup table (brands / fit_types /
    rise_types) and returns a dict mapping value -> generated id.
    Uses ON CONFLICT DO NOTHING so re-running this script is safe
    (won't create duplicate brand rows if run twice).
    """
    rows = [(v,) for v in sorted(values)]
    execute_values(
        cur,
        f"INSERT INTO {table} ({name_col}) VALUES %s ON CONFLICT ({name_col}) DO NOTHING",
        rows,
    )
    conn.commit()

    cur.execute(f"SELECT {id_col}, {name_col} FROM {table}")
    mapping = {name: id_ for id_, name in cur.fetchall()}
    print(f"[LOOKUP] {table}: {len(mapping)} distinct values loaded")
    return mapping


def load_products(cur, conn, df, brand_map, fit_map, rise_map):
    rows = []
    for _, r in df.iterrows():
        rows.append((
            r["product_id"],
            r["product_name"],
            brand_map[r["brand"]],
            fit_map[r["fit_type"]],
            rise_map[r["rise_type"]],
            float(r["price"]),
            float(r["mrp"]),
            float(r["discount_percent"]),
            float(r["rating"]),
            int(r["review_count"]),
        ))

    execute_values(
        cur,
        """
        INSERT INTO products
            (product_id, product_name, brand_id, fit_type_id, rise_type_id,
             price, mrp, discount_percent, rating, review_count)
        VALUES %s
        ON CONFLICT (product_id) DO NOTHING
        """,
        rows,
    )
    conn.commit()
    print(f"[PRODUCTS] Attempted to insert {len(rows)} product rows")


def run_verification(cur):
    print("\n=== VERIFICATION ===")

    cur.execute("SELECT COUNT(*) FROM products")
    print("Row count in products:", cur.fetchone()[0])

    cur.execute("SELECT COUNT(*) FROM brands")
    print("Row count in brands:", cur.fetchone()[0])

    cur.execute("SELECT COUNT(*) FROM fit_types")
    print("Row count in fit_types:", cur.fetchone()[0])

    cur.execute("SELECT COUNT(*) FROM rise_types")
    print("Row count in rise_types:", cur.fetchone()[0])

    cur.execute("""
        SELECT COUNT(*) FROM products
        WHERE product_id IS NULL OR brand_id IS NULL
           OR fit_type_id IS NULL OR rise_type_id IS NULL
           OR price IS NULL OR mrp IS NULL
    """)
    print("Rows with NULLs in key columns:", cur.fetchone()[0])

    cur.execute("""
        SELECT product_id, COUNT(*) FROM products
        GROUP BY product_id HAVING COUNT(*) > 1
    """)
    dupes = cur.fetchall()
    print("Duplicate product_id values:", len(dupes))

    cur.execute("""
        SELECT COUNT(*) FROM products p
        LEFT JOIN brands b ON p.brand_id = b.brand_id
        WHERE b.brand_id IS NULL
    """)
    print("Products with orphaned brand_id (should be 0):", cur.fetchone()[0])


def run():
    df = pd.read_csv(CLEANED_CSV)
    print(f"[LOAD] Read {len(df)} rows from {CLEANED_CSV}")

    conn = get_connection()
    cur = conn.cursor()

    brand_map = load_lookup_table(cur, conn, "brands", "brand_id", "brand_name", df["brand"].unique())
    fit_map = load_lookup_table(cur, conn, "fit_types", "fit_type_id", "fit_type_name", df["fit_type"].unique())
    rise_map = load_lookup_table(cur, conn, "rise_types", "rise_type_id", "rise_type_name", df["rise_type"].unique())

    load_products(cur, conn, df, brand_map, fit_map, rise_map)

    run_verification(cur)

    cur.close()
    conn.close()
    print("\n[DONE] Load complete, connection closed.")


if __name__ == "__main__":
    run()