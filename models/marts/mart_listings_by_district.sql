with listings_by_district as (
    select
        district,
        property_type,
        COUNT(*) as total_listings,
        AVG(price_eur) AS avg_price_eur,
        AVG(price_per_m2_eur) AS avg_price_per_m2_eur,
        AVG(area_m2) AS avg_area
    FROM {{ ref('stg_latest_listings') }}
    GROUP BY property_type, district
)
select * from listings_by_district