

/* Basic shape */
SELECT COUNT(*) AS row_count
FROM stg.cdp_city_emissions_raw;

SELECT * FROM stg.cdp_city_emissions_raw;

SELECT 
    MIN([Year_covered_by_main_inventory]) AS min_year,
    MAX([Year_covered_by_main_inventory]) AS max_year,
    COUNT(DISTINCT [Year_covered_by_main_inventory]) AS years_reported
FROM stg.cdp_city_emissions_raw;

SELECT DISTINCT [City], [Country]
FROM stg.cdp_city_emissions_raw;

SELECT DISTINCT [Emissions_Data_Group]
FROM stg.cdp_city_emissions_raw
ORDER BY 1;

/* What "scopes" are present (raw names) */
SELECT DISTINCT [Emissions_Column_Name] 
FROM stg.cdp_city_emissions_raw;                        /* Help to identify the scope of emmision*/

/* Row-level numeric parsing check */
SELECT TOP (20)
    row_id,
    [Emissions_Row_Name],
    [Emissions_Column_Name],
    [Emissions_Response_Answer] AS raw_value,
    TRY_CONVERT(decimal(18,2), REPLACE([Emissions_Response_Answer], ',', '')) AS value_tCO2e,
    [Emissions_Notation_Key],
    [Emissions_Data_Group]
FROM stg.cdp_city_emissions_raw
ORDER BY row_id;

/* Totals vs granular lines */
SELECT
    [Emissions_Data_Group],
    COUNT(*) AS rows_
FROM stg.cdp_city_emissions_raw
GROUP BY [Emissions_Data_Group]
ORDER BY rows_ DESC;

/* Map column → scope label and sum values */
WITH base AS (
    SELECT
        [City],
        [Country],
        [Year_covered_by_main_inventory]  AS inventory_year,
        CASE 
            WHEN [Emissions_Column_Name] LIKE 'Direct emissions (%' THEN 'Scope 1'
            WHEN [Emissions_Column_Name] LIKE 'Indirect emissions from the use of grid-supplied%' THEN 'Scope 2'
            WHEN [Emissions_Column_Name] LIKE 'Emissions occurring outside the jurisdiction boundary%' THEN 'Out-of-boundary'
            ELSE 'Other/Unknown'
        END AS scope_label,
        TRY_CONVERT(decimal(18,2), REPLACE([Emissions_Response_Answer], ',', '')) AS emissions_tCO2e,
        [Emissions_Notation_Key],
        [Emissions_Data_Group]
    FROM stg.cdp_city_emissions_raw
)
SELECT
    inventory_year,
    scope_label,
    SUM(emissions_tCO2e) AS sum_tCO2e,
    COUNT(*) AS rows_
FROM base
WHERE ( [Emissions_Notation_Key] IS NULL OR [Emissions_Notation_Key] NOT IN ('NO','NE') )
GROUP BY inventory_year, scope_label
ORDER BY inventory_year, scope_label;


Select Distinct Emissions_Row_Name from stg.cdp_city_emissions_raw  /* Find out the sectors and subsections and identify the seperator */

/* Sector & Subsector parse check on granular lines only */
WITH parsed AS (
    SELECT
        row_id,
        [Emissions_Row_Name],
        LEFT([Emissions_Row_Name], NULLIF(CHARINDEX(' > ', [Emissions_Row_Name]) - 1, -1)) AS sector,
        CASE 
            WHEN CHARINDEX(' > ', [Emissions_Row_Name]) > 0 
                 THEN LTRIM(SUBSTRING([Emissions_Row_Name], CHARINDEX(' > ', [Emissions_Row_Name]) + 3, 4000))
            ELSE NULL
        END AS subsector,
        TRY_CONVERT(decimal(18,2), REPLACE([Emissions_Response_Answer], ',', '')) AS emissions_tCO2e,
        [Emissions_Data_Group]
    FROM stg.cdp_city_emissions_raw
)
SELECT TOP (20)
    row_id, sector, subsector, emissions_tCO2e, [Emissions_Data_Group]
FROM parsed
WHERE [Emissions_Data_Group] IN ('SubSector','GridSubSector')
ORDER BY emissions_tCO2e DESC;

/* Null / zero checks */
SELECT
    SUM(CASE WHEN TRY_CONVERT(decimal(18,2), REPLACE([Emissions_Response_Answer], ',', '')) IS NULL THEN 1 ELSE 0 END) AS null_numeric_values,
    SUM(CASE WHEN TRY_CONVERT(decimal(18,2), REPLACE([Emissions_Response_Answer], ',', '')) = 0 THEN 1 ELSE 0 END) AS zeros
FROM stg.cdp_city_emissions_raw;
