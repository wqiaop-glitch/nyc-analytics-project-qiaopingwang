with source as (

    select *
    from `qiaopingwang-cis-4400-f25.nyc_hw3_raw_data.source_nyc_open_restaurant_apps`

),

cleaned as (

    select
        cast(objectid as int64) as objectid,

        case
            when lower(trim(approved_for_roadway_seating)) = 'yes' then true
            when lower(trim(approved_for_roadway_seating)) = 'no' then false
            else null
        end as approved_for_roadway_seating,

        case
            when lower(trim(approved_for_sidewalk_seating)) = 'yes' then true
            when lower(trim(approved_for_sidewalk_seating)) = 'no' then false
            else null
        end as approved_for_sidewalk_seating,

        cast(bbl as string) as bbl,
        cast(bin as string) as bin,
        trim(borough) as borough,
        trim(cast(bulding_number as string)) as building_number,
        trim(business_address) as business_address,
        cast(census_tract as string) as census_tract,
        cast(community_board as string) as community_board,
        cast(council_district as string) as council_district,
        trim(doing_business_as_dba) as doing_business_as_dba,
        cast(food_service_establishment as string) as food_service_establishment,
        cast(globalid as string) as globalid,

        case
            when lower(trim(healthcompliance_terms)) = 'yes' then true
            when lower(trim(healthcompliance_terms)) = 'no' then false
            else null
        end as healthcompliance_terms,

        trim(landmark_district_or_building) as landmark_district_or_building,
        trim(landmarkdistrict_terms) as landmarkdistrict_terms,
        safe_cast(latitude as float64) as latitude,
        trim(legal_business_name) as legal_business_name,
        safe_cast(longitude as float64) as longitude,
        trim(nta) as nta,

        case
            when lower(trim(qualify_alcohol)) = 'yes' then true
            when lower(trim(qualify_alcohol)) = 'no' then false
            else null
        end as qualify_alcohol,

        trim(restaurant_name) as restaurant_name,
        safe_cast(roadway_dimensions_area as float64) as roadway_dimensions_area,
        safe_cast(roadway_dimensions_length as float64) as roadway_dimensions_length,
        safe_cast(roadway_dimensions_width as float64) as roadway_dimensions_width,
        trim(seating_interest_sidewalk) as seating_interest_sidewalk,
        safe_cast(sidewalk_dimensions_area as float64) as sidewalk_dimensions_area,
        safe_cast(sidewalk_dimensions_length as float64) as sidewalk_dimensions_length,
        safe_cast(sidewalk_dimensions_width as float64) as sidewalk_dimensions_width,
        trim(sla_license_type) as sla_license_type,
        cast(sla_serial_number as string) as sla_serial_number,
        trim(street) as street,
        safe_cast(time_of_submission as timestamp) as time_of_submission,

        case
            when zip is null then null
            when length(regexp_replace(cast(zip as string), r'[^0-9]', '')) >= 5
                then substr(regexp_replace(cast(zip as string), r'[^0-9]', ''), 1, 5)
            else null
        end as zip

    from source

)

select *
from cleaned