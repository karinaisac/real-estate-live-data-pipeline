# real-estate-live-data-pipeline

My project consists of having AI set up a Python script that scraped data from Aruodas, the main website for real estate listings in Lithuania, and I then connected this data to BigQuery to house the data. The scraper runs locally and therefore needs to be run manually by me, but the idea would be (in an ideal world) to have the scraper run in the cloud and run hourly. I have set up a scheduler in dbt to rerun the data model hourly. BigQuery was then connected to dbt to clean and transform the data into one view, since the table does not have that many variables. In my case, the data underwent the staging and marts stage, skipping intermediate, since no joins were needed here. The mart was then connected to Looker via BigQuery, taking advantage of the Google ecosystem, and a dashboard was created in Looker to analyze the data.

The data looks at listings in Vilnius, Lithuania, both apartments and houses. Several variables were scraped from the listings, such as property type, district, address, price, price per m2, the number of rooms, the floor number out of the total number of floors, and the year it was built. I chose to drop several columns from the scraped data, as I considered them unnecessary and not really useful for analysis. I included a data sample below for reference on what the uncleaned data looked like before the ELT process.

## Data Sample
| source | source_id | url | title | city | district | address | property_type | price_eur | price_per_m2_eur | area_m2 | rooms | floor | year_built | status | raw_text | scraped_at | first_seen_at | last_seen_at |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| aruodas_vilnius_apartments | butai-vilniuje-zveryne-paribio-g-moderniai-ir-kokybiskai-irengtas-labai-erdvus-1-3650377 | https://m.aruodas.lt/butai-vilniuje-zveryne-paribio-g-moderniai-ir-kokybiskai-irengtas-labai-erdvus-1-3650377/ | Paribio g. | Vilnius | Žvėrynas | Paribio g. | apartment | 305000 | 4378 | 69.7 | 4.0 | 3/5 aukšt. | 1971 | active | Vilnius, Žvėrynas Paribio g. 305 000 € 4378 €/m² Sumažėjusi 1,6% 4 kamb. 69,7 m² 3/5 aukšt. 1971 m. Centrinis Įrengtas Pasidomėkite būsto paskola | 2026-05-08T08:30:52+00:00 | 2026-05-06T18:22:17+00:00 | 2026-05-08T08:42:28+00:00 |


I decided to create four charts in my dashboard, but there are many more possibilities.


One chart looked at total number of apartment listings by district.


<img width="732" height="552" alt="real estate 1" src="https://github.com/user-attachments/assets/0db8561a-5e61-4421-ac2f-4948abb09c71" />


Meanwhile, another chart looked at the total number of house listings by district.


<img width="731" height="550" alt="real estate 2" src="https://github.com/user-attachments/assets/90296d01-5537-491a-ac01-f3085f066331" />


The results of these make a lot of sense if you live in Vilnius and have a feeling of the city and its trends.


The next two charts I made look at the average price per m2 (in eur) across districts, first looking at apartments and then houses.


<img width="747" height="555" alt="real estate 3" src="https://github.com/user-attachments/assets/3e4600be-bc86-4fff-93ac-a8fce05c2f8b" />


<img width="707" height="545" alt="real estate 4" src="https://github.com/user-attachments/assets/5a248832-4e32-4069-8414-5fe3041da9e9" />



Again, the results make a lot of sense and just work to prove the assumptions I had in my mind.



## View the full dashboard here: https://datastudio.google.com/reporting/a76370a9-d724-433c-be7c-3a3414e6efca
