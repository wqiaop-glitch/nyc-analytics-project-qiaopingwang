-- Restaurant dimension for open restaurant applications

WITH restaurant_source AS (

    SELECT DISTINCT
        restaurant_name,
        legal_business_name,
        doing_business_as_dba,
        CAST(food_service_establishment AS STRING) AS food_service_establishment,
        business_address AS restaurant_business_address,
        SAFE_CAST(latitude AS FLOAT64) AS latitude,
        SAFE_CAST(longitude AS FLOAT64) AS longitude
    FROM {{ ref('stg_nyc_open_restaurant_apps') }}
    WHERE restaurant_name IS NOT NULL

),

restaurant_dimension AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'restaurant_name',
            'legal_business_name',
            'doing_business_as_dba',
            'food_service_establishment',
            'restaurant_business_address'
        ]) }} AS restaurant_key,

        restaurant_name,
        legal_business_name,
        doing_business_as_dba,
        food_service_establishment,
        restaurant_business_address,
        latitude,
        longitude
    FROM restaurant_source

)

SELECT *
FROM restaurant_dimension