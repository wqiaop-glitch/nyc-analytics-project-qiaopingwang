-- Fact table for 311 DOT requests

WITH requests_base AS (

    SELECT
        request_id,
        created_date,
        closed_date,
        borough,
        incident_zip,
        complaint_type,
        descriptor,
        incident_address,
        address_type,
        street_name,
        cross_street_1,
        cross_street_2,
        SAFE_CAST(latitude AS FLOAT64) AS latitude,
        SAFE_CAST(longitude AS FLOAT64) AS longitude,
        status,
        method_of_submission AS channel_type,
        resolution_description
    FROM {{ ref('stg_nyc_311_dot') }}

),

fact_ready AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['rb.request_id']) }} AS request_key,
        CAST(rb.request_id AS STRING) AS request_id,

        dcreated.date_key AS created_date_key,
        dclosed.date_key AS closed_date_key,
        dl.location_key,
        dct.complaint_type_key,

        rb.incident_address,
        rb.address_type,
        rb.street_name,
        rb.cross_street_1,
        rb.cross_street_2,
        rb.latitude,
        rb.longitude,
        CASE
            WHEN LOWER(rb.status) = 'closed' THEN TRUE
            ELSE FALSE
        END AS is_closed,
        rb.status,
        rb.channel_type,
        rb.resolution_description

    FROM requests_base rb

    LEFT JOIN {{ ref('dim_date') }} dcreated
        ON DATE(rb.created_date) = dcreated.full_date

    LEFT JOIN {{ ref('dim_date') }} dclosed
        ON DATE(rb.closed_date) = dclosed.full_date

    LEFT JOIN {{ ref('dim_location') }} dl
        ON rb.borough = dl.borough
       AND CAST(rb.incident_zip AS STRING) = dl.zip_code

    LEFT JOIN {{ ref('dim_complaint_type') }} dct
        ON rb.complaint_type = dct.complaint_type
       AND rb.descriptor = dct.descriptor

)

SELECT *
FROM fact_ready