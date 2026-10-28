"""Export the dbt marts to CSV for Tableau, and draw preview charts for the README.

Tableau Public can't connect to DuckDB, so it reads these CSVs instead:
  exports/fct_team_games.csv        - one row per team per game (main dashboard source)
  exports/agg_win_rate_by_rest.csv  - pre-aggregated win rates

Run from the project root, after `.\\dbt build`:
    python export.py
"""

from pathlib import Path

import duckdb
import matplotlib.pyplot as plt
import seaborn as sns

ROOT = Path(__file__).resolve().parent
EXPORTS = ROOT / "exports"
FIGURES = ROOT / "figures"
TEAM, OPP, NEUTRAL = "#1D428A", "#C8102E", "#9AA5B1"

con = duckdb.connect(str(ROOT / "nba.duckdb"), read_only=True)
EXPORTS.mkdir(exist_ok=True)
FIGURES.mkdir(exist_ok=True)

for table in ["fct_team_games", "agg_win_rate_by_rest"]:
    df = con.sql(f"select * from main_marts.{table}").df()
    df.to_csv(EXPORTS / f"{table}.csv", index=False)
    print(f"exports/{table}.csv: {len(df):,} rows")

# Chart 1: win % by rest advantage
order = ["Opponent +2 or more", "Opponent +1", "Even rest", "Team +1", "Team +2 or more"]
adv = con.sql("""
    select rest_advantage_bucket as bucket, avg(is_win::int) * 100 as win_pct, count(*) as games
    from main_marts.fct_team_games
    where rest_advantage_bucket <> 'Season opener'
    group by 1
""").df().set_index("bucket").loc[order].reset_index()

fig, ax = plt.subplots(figsize=(9, 5))
colors = [OPP, OPP, NEUTRAL, TEAM, TEAM]
bars = ax.bar(adv.bucket, adv.win_pct, color=colors)
ax.bar_label(bars, labels=[f"{w:.1f}%" for w in adv.win_pct], padding=3)
ax.axhline(50, color="black", lw=0.8, ls="--")
ax.set_ylim(35, 62)
ax.set_ylabel("Win %")
ax.set_xlabel("Days of rest compared with the opponent")
ax.set_title("More rest than the opponent = more wins (2016-17 to 2025-26)", loc="left", fontweight="bold")
sns.despine()
fig.tight_layout()
fig.savefig(FIGURES / "win_pct_by_rest_advantage.png", dpi=200)
plt.close(fig)

# Chart 2: back-to-back penalty, holding home/away constant
b2b = con.sql("""
    select case when is_home then 'Home' else 'Away' end as venue,
           back_to_back_matchup as matchup,
           avg(is_win::int) * 100 as win_pct
    from main_marts.fct_team_games
    where back_to_back_matchup <> 'Both on back-to-back'
    group by 1, 2
""").df()
fig, ax = plt.subplots(figsize=(9, 5))
sns.barplot(data=b2b, x="venue", y="win_pct", hue="matchup", ax=ax, order=["Home", "Away"],
            hue_order=["Only team on back-to-back", "Neither on back-to-back", "Only opponent on back-to-back"],
            palette=[OPP, NEUTRAL, TEAM])
for c in ax.containers:
    ax.bar_label(c, fmt="%.1f%%", padding=3)
ax.set_ylim(30, 68)
ax.set_xlabel("")
ax.set_ylabel("Win %")
ax.legend(frameon=False, title="")
ax.set_title("A back-to-back costs about 6 points of win % at home or away", loc="left", fontweight="bold")
sns.despine()
fig.tight_layout()
fig.savefig(FIGURES / "back_to_back_by_venue.png", dpi=200)
plt.close(fig)
print("figures written")
