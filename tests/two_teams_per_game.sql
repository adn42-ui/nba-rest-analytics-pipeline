-- The self-join must pair every game into exactly two rows, one per team.
-- More would mean a bad join; fewer would mean a team is missing a game.

select game_id, count(*) as n
from {{ ref('fct_team_games') }}
group by game_id
having count(*) <> 2
