-- If one team has +2 rest advantage, its opponent must have -2 in the same game.

select a.game_id, a.team, a.rest_advantage, b.rest_advantage as opponent_rest_advantage
from {{ ref('fct_team_games') }} as a
join {{ ref('fct_team_games') }} as b
    on  a.game_id = b.game_id
    and a.team_id <> b.team_id
where a.rest_advantage <> -b.rest_advantage
