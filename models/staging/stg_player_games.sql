with source as (

    select * from {{ source('raw', 'player_logs') }}      

),

renamed as (

    select
        game_id                    as game_id,
        player_id                  as player_id,
        player_name                as player_name,
        team_id                    as team_id,
        team_abbreviation          as team,            

        cast(season_id as integer) - 20000 as season,    
        game_date                  as game_date,

        min                   as minutes,
        pts                  as points,
        reb               as rebounds,
        ast                 as assists

    from source

)

select * from renamed