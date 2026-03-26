-- Seating type dimension for open restaurant applications

WITH seating_source AS (

    SELECT DISTINCT
        seating_interest_sidewalk AS seating_interest,
        approved_for_sidewalk_seating AS approved_for_sidewalk,
        approved_for_roadway_seating AS approved_for_roadway
    FROM {{ ref('stg_nyc_open_restaurant_apps') }}

),

seating_dimension AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'seating_interest',
            'approved_for_sidewalk',
            'approved_for_roadway'
        ]) }} AS seating_type_key,

        seating_interest,
        approved_for_sidewalk,
        approved_for_roadway
    FROM seating_source

)

SELECT *
FROM seating_dimension