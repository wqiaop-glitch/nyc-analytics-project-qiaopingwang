-- Fact table for open restaurant applications

WITH restaurant_base AS (

    SELECT
        objectid,
        time_of_submission,
        borough,
        zip,
        restaurant_name,
        legal_business_name,
        doing_business_as_dba,
        CAST(food_service_establishment AS STRING) AS food_service_establishment,
        business_address,
        street,
        bulding_number,
        SAFE_CAST(latitude AS FLOAT64) AS latitude,
        SAFE_CAST(longitude AS FLOAT64) AS longitude,
        SAFE_CAST(sidewalk_dimensions_length AS INT64) AS sidewalk_length_ft,
        SAFE_CAST(sidewalk_dimensions_width AS INT64) AS sidewalk_width_ft,
        SAFE_CAST(sidewalk_dimensions_area AS INT64) AS sidewalk_area_sqft,
        qualify_alcohol,
        landmark_district_or_building AS is_landmark_location,
        healthcompliance_terms AS health_compliance_terms_accepted,
        CAST(sla_serial_number AS STRING) AS sla_serial_number,
        sla_license_type,
        seating_interest_sidewalk AS seating_interest,
        approved_for_sidewalk_seating AS approved_for_sidewalk,
        approved_for_roadway_seating AS approved_for_roadway
    FROM {{ ref('stg_nyc_open_restaurant_apps') }}

),

fact_ready AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['rb.objectid']) }} AS application_key,
        CAST(rb.objectid AS STRING) AS objectid,
        rb.time_of_submission AS application_submitted,

        dd.date_key AS submission_date_key,
        dl.location_key,
        dr.restaurant_key,
        dst.seating_type_key,

        rb.business_address,
        rb.street,
        rb.bulding_number,
        rb.latitude,
        rb.longitude,
        rb.sidewalk_length_ft,
        rb.sidewalk_width_ft,
        rb.sidewalk_area_sqft,
        rb.qualify_alcohol,
        rb.is_landmark_location,
        rb.health_compliance_terms_accepted,
        rb.sla_serial_number,
        rb.sla_license_type

    FROM restaurant_base rb

    LEFT JOIN {{ ref('dim_date') }} dd
        ON DATE(rb.time_of_submission) = dd.full_date

    LEFT JOIN {{ ref('dim_location') }} dl
        ON rb.borough = dl.borough
       AND CAST(rb.zip AS STRING) = dl.zip_code

    LEFT JOIN {{ ref('dim_restaurant') }} dr
        ON rb.restaurant_name = dr.restaurant_name
       AND rb.legal_business_name = dr.legal_business_name
       AND rb.doing_business_as_dba = dr.doing_business_as_dba
       AND rb.food_service_establishment = dr.food_service_establishment
       AND rb.business_address = dr.restaurant_business_address

    LEFT JOIN {{ ref('dim_seating_type') }} dst
        ON rb.seating_interest = dst.seating_interest
       AND rb.approved_for_sidewalk = dst.approved_for_sidewalk
       AND rb.approved_for_roadway = dst.approved_for_roadway

)

SELECT *
FROM fact_ready