-- Days of rest before every team game.
--
-- lag() is a window function: it reads a value from the previous row. The
-- window is each team's season (partition by) in date order (order by), so the
-- previous row is that team's previous game, and a season opener has none.

with games as (

    select * from {{ ref('stg_team_games') }}

),

with_previous as (

    select
        *,
        lag(game_date) over (partition by team_id, season order by game_date) as previous_game_date
    from games

),

final as (

    select
        *,
        -- days between games minus 1 = full days off (back-to-back = 0)
        date_diff('day', previous_game_date, game_date) - 1 as days_rest,
        date_diff('day', previous_game_date, game_date) - 1 = 0 as is_back_to_back
    from with_previous

)

select * from final
