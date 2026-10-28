"""Load the raw NBA game log CSVs into DuckDB, untouched.

Creates nba.duckdb with two tables in the `raw` schema:
  raw.team_logs   - one row per team per game (2016-17 to 2025-26)
  raw.player_logs - one row per player per game

dbt reads from these tables and builds everything else. Raw data stays exactly
as downloaded, so any cleaning lives in SQL where you can see and test it.

Run from the project root:
    python load_raw.py
"""

from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parent
RAW_DIR = ROOT / "data" / "raw"

con = duckdb.connect(str(ROOT / "nba.duckdb"))
con.execute("CREATE SCHEMA IF NOT EXISTS raw")
for table, pattern in [("team_logs", "team_logs_*.csv"), ("player_logs", "player_logs_*.csv")]:
    files = (RAW_DIR / pattern).as_posix()
    con.execute(f"CREATE OR REPLACE TABLE raw.{table} AS SELECT * FROM read_csv_auto('{files}', union_by_name = true)")
    rows = con.execute(f"SELECT count(*) FROM raw.{table}").fetchone()[0]
    print(f"raw.{table}: {rows:,} rows")
con.close()
