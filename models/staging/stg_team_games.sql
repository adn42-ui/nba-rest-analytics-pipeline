-- WORKED EXAMPLE: read this one closely, then write stg_player_games.sql the same way.
--
-- A staging model does light cleanup only, one row in for one row out:
--   rename columns to snake_case, fix types, derive simple fields.
-- No joins and no business logic here; that comes in later layers.

with source as (

    -- source() points at a raw table declared in _sources.yml
    select * from {{ source('raw', 'team_logs') }}

),

renamed as (

    select
        -- ids (aliased even when unchanged, so every column comes out lowercase)
        game_id                                  as game_id,
        team_id                                  as team_id,
        team_abbreviation                        as team,

        -- season_id looks like 22023: drop the leading "2" -> 2023 (= 2023-24)
        cast(season_id as integer) - 20000        as season,
        game_date                                as game_date,

        -- MATCHUP is "BOS vs. NYK" at home and "BOS @ NYK" away
        matchup like '%vs.%'                     as is_home,
        wl = 'W'                                 as is_win,

        pts                                      as points,
        plus_minus                               as point_diff

    from source

)

select * from renamed
