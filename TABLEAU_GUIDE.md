# Building the Tableau dashboard

Data source: `exports/fct_team_games.csv` (one row per team per game).

## 1. Set up (about 15 min)
1. Download **Tableau Public** (free) from public.tableau.com and create an account.
2. Open Tableau Public, choose **Connect → Text file**, and pick `exports/fct_team_games.csv`.
3. Check the column types at the top of each column: `season` should be a number, `game_date` a date, and `is_win` a boolean (T/F).

## 2. Create the calculated field you'll need
**Analysis → Create Calculated Field**, name it `Win %`:
```
AVG(IIF([Is Win], 1, 0))
```
Format it as a percentage: right-click it → **Default Properties → Number Format → Percentage**.

## 3. Build the sheets
| Sheet | Columns | Rows | Notes |
|---|---|---|---|
| **Win % by rest advantage** | `Rest Advantage Bucket` | `Win %` | Sort the buckets from Opponent +2 to Team +2; filter out "Season opener"; add a 50% reference line |
| **Back-to-back penalty** | `Is Home`, `Back To Back Matchup` | `Win %` | Color by `Back To Back Matchup`; exclude "Both on back-to-back" |
| **Win % by days of rest** | `Rest Bucket` | `Win %` | Add `Number of Records` to Label to show game counts |
| **Back-to-back penalty by season** | `Season` | `Win %` | Filter to "Only team on back-to-back"; line chart |

## 4. Assemble the dashboard
1. **New Dashboard**, size **Automatic**.
2. Drag the four sheets in a 2×2 grid. Add a title: "Does Rest Win NBA Games?"
3. Add **filters**: `Season` and `Team`. Right-click each filter → **Apply to Worksheets → All Using This Data Source**.
4. Add a one-line takeaway text box: "2+ days more rest than the opponent: 57% wins. Back-to-back vs a rested team: −6 points."

## 5. Publish
**File → Save to Tableau Public**. Copy the link, add it to the README (replace "in progress"), and add it to the resume project line.
