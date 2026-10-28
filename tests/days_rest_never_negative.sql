-- A team can't play its next game before its last one: rest is 0 or more.

select *
from {{ ref('int_team_rest') }}
where days_rest < 0
