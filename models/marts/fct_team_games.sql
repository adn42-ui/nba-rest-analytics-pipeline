-- One row per team per game, with the team's rest AND its opponent's rest.
--
-- Every game has two rows in int_team_rest (one per team). Joining the table
-- to itself on game_id, while requiring a different team_id, pairs each team
-- with its opponent in that game: a "self-join".

with rest as (

    select * from {{ ref('int_team_rest') }}

),

paired as (

    select
        t.game_id,
        t.season,
        t.game_date,
        t.team_id,
        t.team,
        o.team                                      as opponent,
        t.is_home,
        t.is_win,
        t.points,
        t.point_diff,
        t.days_rest,
        o.days_rest                                 as opponent_days_rest,
        t.days_rest - o.days_rest                   as rest_advantage
    from rest as t
    join rest as o
        on  t.game_id = o.game_id
        and t.team_id <> o.team_id

),

final as (

    select
        *,

        -- Buckets for the dashboard. Season openers (no previous game) and
        -- 3+ days (including the 2020 bubble restart) are grouped.
        case
            when days_rest is null then 'Season opener'
            when days_rest = 0     then '0 (back-to-back)'
            when days_rest = 1     then '1 day'
            when days_rest = 2     then '2 days'
            else '3+ days'
        end                                         as rest_bucket,

        case
            when rest_advantage is null then 'Season opener'
            when rest_advantage <= -2   then 'Opponent +2 or more'
            when rest_advantage = -1    then 'Opponent +1'
            when rest_advantage = 0     then 'Even rest'
            when rest_advantage = 1     then 'Team +1'
            else 'Team +2 or more'
        end                                         as rest_advantage_bucket,

        case
            when days_rest = 0 and opponent_days_rest = 0 then 'Both on back-to-back'
            when days_rest = 0                            then 'Only team on back-to-back'
            when opponent_days_rest = 0                   then 'Only opponent on back-to-back'
            else 'Neither on back-to-back'
        end                                         as back_to_back_matchup

    from paired

)

select * from final
