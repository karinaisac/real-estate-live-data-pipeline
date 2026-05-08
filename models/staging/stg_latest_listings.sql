with raw as (
select *
from {{ source('real_estate_listings', 'latest_listings') }}
),

floor_fixed as (
    select *,
        REGEXP_REPLACE(floor, r' aukšt\.', '') AS floor_cleaned
    from raw
),

cleaned as (

select
source,
url,
district, 
address,
property_type,
price_eur,
price_per_m2_eur,
area_m2,
CAST(ROUND(rooms) AS INT64) AS rooms,
SAFE_CAST(SPLIT(floor_cleaned, '/')[OFFSET(0)] AS INT64) as floor_number,
SAFE_CAST(SPLIT(floor_cleaned, '/')[OFFSET(1)] AS INT64) as total_floors

from floor_fixed
WHERE (year_built <= 2026 OR year_built IS NULL)
AND price_eur IS NOT NULL 
AND price_per_m2_eur IS NOT NULL 
AND district IS NOT NULL
AND LENGTH(district) <= 25
)

select * from cleaned