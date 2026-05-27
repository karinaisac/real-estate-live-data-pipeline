# real-estate-live-data-pipeline

## Overview
A live data pipeline that scrapes real estate listings from [Aruodas.lt](https://www.aruodas.lt) — Lithuania's primary property listing platform — loads them into BigQuery, transforms them in dbt, and visualizes them in a Looker Studio dashboard.

The project covers **apartment and house listings in Vilnius, Lithuania**, with fields including district, price, price per m², floor, number of rooms, and year built. The pipeline is designed to refresh hourly, giving a near-real-time view of the Vilnius property market.

> **Current limitation:** The scraper runs locally and must be triggered manually. The intended production setup would run the scraper in the cloud on an hourly schedule. The dbt model is already scheduled to run hourly in dbt Cloud.

## Stack
- **Scraping:** Python (AI-assisted script generation), targeting Aruodas.lt
- **Warehouse:** Google BigQuery
- **Transformation:** dbt Cloud (hourly schedule configured)
- **Visualization:** Looker Studio (Google Data Studio)

## Pipeline Architecture

```
Aruodas.lt listings
        │
        ▼
Python scraper (local, manual trigger)
        │  scraped_at, listing fields
        ▼
BigQuery — raw table
        │
        ▼
dbt — staging (clean, cast, parse fields)
        │
        ▼
dbt — marts (final view for dashboard)
        │
        ▼
Looker Studio dashboard
```

**Intended production flow:** scraper runs hourly in the cloud → BigQuery raw table auto-updates → dbt scheduled run picks up new rows → dashboard reflects latest listings.

## Data Cleaning

The raw scraped data required several transformations before it was usable for analysis:

| Issue | Example (raw) | Fix applied |
|---|---|---|
| Floor stored as string with Lithuanian text | `3/5 aukšt.` | Parsed into `floor_number` and `total_floors` integers |
| Scraped metadata not needed for analysis | `raw_text`, `source_id`, `url`, `status` | Dropped in staging |
| Price and area already numeric | `305000`, `69.7` | Cast to correct numeric types |
| Timestamp fields in ISO format | `2026-05-08T08:30:52+00:00` | Cast to TIMESTAMP |

### Data sample (pre-cleaning)
| source | source_id | url | title | city | district | address | property_type | price_eur | price_per_m2_eur | area_m2 | rooms | floor | year_built | status | raw_text | scraped_at | first_seen_at | last_seen_at |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| aruodas_vilnius_apartments | butai-vilniuje-zveryne-... | https://m.aruodas.lt/... | Paribio g. | Vilnius | Žvėrynas | Paribio g. | apartment | 305000 | 4378 | 69.7 | 4.0 | 3/5 aukšt. | 1971 | active | Vilnius, Žvėrynas... | 2026-05-08T08:30:52+00:00 | 2026-05-06T18:22:17+00:00 | 2026-05-08T08:42:28+00:00 |

## Model Structure

```
models/
├── staging/
│   └── stg_aruodas_listings.sql    -- Type casts, floor parsing, column drops
└── marts/
    └── fct_listings.sql             -- Final view; apartments and houses unified
```

| Model | Type | Key detail |
|---|---|---|
| `stg_aruodas_listings` | View | Cleans raw scrape; parses `floor` string; drops metadata columns |
| `fct_listings` | View | Analysis-ready listings table consumed by Looker Studio |

## Dashboard & Key Findings

Four charts are included in the dashboard, covering listing supply and pricing across Vilnius districts.

### 1. Apartment listings by district
<img width="732" height="552" alt="real estate 1" src="https://github.com/user-attachments/assets/0db8561a-5e61-4421-ac2f-4948abb09c71" />

**Finding:** *Naujamiestis and Senamiestis have the highest count of apartment listings, reflecting their central location, density of housing, high demand for housing in these areas and, accordingly, high turnover of apartments in these areas. ongoing development. All other areas in the chart have a lower number of listings, reflecting that these areas have lower demand and also lower turnover of apartments, which is consistent with their lower-density, residential character.*

### 2. House listings by district
<img width="731" height="550" alt="real estate 2" src="https://github.com/user-attachments/assets/90296d01-5537-491a-ac01-f3085f066331" />

**Finding:** *House listings are concentrated in outer districts of Vilnius that have lower density, are farther from the city center, and those that have larger plot sizes make standalone houses more common. Antakalnis has the highest number of listings of houses, as it corresponds to all of these descriptions, but it is also relatively close to the city center and, accordingly, has higher demand for houses from residents that want more space but don't want to be very far from the city. Pilaitė, Balsiai, Pavilnys, and Naujoji Vilnia follow, as they also correspond to these conditions, but are located farther from the city center and likely have lower demand and turnover rates.*

### 3. Average price per m² by district — apartments
<img width="747" height="555" alt="real estate 3" src="https://github.com/user-attachments/assets/3e4600be-bc86-4fff-93ac-a8fce05c2f8b" />

**Finding:** *Paupys has the highest m2 price, corresponding to its great location, trendy vibe, and glamorous marketing. Senamiestis (Old Town), Užupis, and Žvėrynas follow Paupys closely in terms of price, reflecting their great location, established local character, and prestige. Districts such as Naujamiestis, Šnipiškės, Markučiai, and others follow these districts - they are also in high demand and have relatively high m2 prices, but are either farther from the city center or are less presitigious than the other areas.*

### 4. Average price per m² by district — houses
<img width="707" height="545" alt="real estate 4" src="https://github.com/user-attachments/assets/5a248832-4e32-4069-8414-5fe3041da9e9" />

**Finding:** *The pricing hierarchy shifts somewhat for houses, with Žvėrynas and Antakalnis leading. The gap between top and bottom districts is wider for houses than apartments, likely reflecting greater variation in plot size, build quality, and proximity to green space.*

## How to Run

### 1. Run the scraper
```bash
# From the project root
python scraper/aruodas_scraper.py
```
This writes new rows to the BigQuery raw table. Run this manually until a cloud scheduler is configured.

### 2. Run dbt
```bash
# Run all models
dbt run

# Run a specific model
dbt run --select stg_aruodas_listings
dbt run --select fct_listings

# Run tests
dbt test
```

### 3. View the dashboard
[Open in Looker Studio →](https://datastudio.google.com/reporting/a76370a9-d724-433c-be7c-3a3414e6efca)

## Future Improvements
- Move scraper to a cloud scheduler (Cloud Run + Cloud Scheduler) for true hourly automation
- Add price change tracking using `first_seen_at` and `last_seen_at` to flag listings where price dropped or rose
- Add a listing age metric (days on market) as a demand signal
- Expand coverage to other Lithuanian cities
