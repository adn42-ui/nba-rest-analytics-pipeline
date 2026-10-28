-- A custom test: returns any (game, team) pair that appears more than once.
-- dbt passes the test when this query returns zero rows.

select game_id, team_id, count(*) as n
from {{ ref('stg_team_games') }}
group by game_id, team_id
having count(*) > 1
