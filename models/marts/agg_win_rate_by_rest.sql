-- Win rate and average margin by rest situation, per season and home/away.
-- Small, pre-aggregated table that answers "does rest win games?" directly.

with games as (

    select * from {{ ref('fct_team_games') }}

)

select
    season,
    case when is_home then 'Home' else 'Away' end   as venue,
    rest_advantage_bucket,
    back_to_back_matchup,
    count(*)                                        as games,
    sum(case when is_win then 1 else 0 end)         as wins,
    round(avg(case when is_win then 1.0 else 0.0 end), 4) as win_pct,
    round(avg(point_diff), 2)                       as avg_point_diff
from games
group by 1, 2, 3, 4
