

/* Granular facts, cleaned for Power BI */
CREATE OR ALTER VIEW dbo.v_city_emissions_fact AS
WITH prepared AS (
    SELECT
        s.row_id,
        s.[City],
        s.[Country],
        s.[Year_covered_by_main_inventory] AS inventory_year,

        /* Map scope from the column header */
        CASE 
            WHEN s.[Emissions_Column_Name] LIKE 'Direct emissions (%' THEN 'Scope 1'
            WHEN s.[Emissions_Column_Name] LIKE 'Indirect emissions from the use of grid-supplied%' THEN 'Scope 2'
            WHEN s.[Emissions_Column_Name] LIKE 'Emissions occurring outside the jurisdiction boundary%' THEN 'Out-of-boundary'
            ELSE 'Other/Unknown'
        END AS scope_label,

        /* Split "Sector > Subsector" */
        LEFT(s.[Emissions_Row_Name], NULLIF(CHARINDEX(' > ', s.[Emissions_Row_Name]) - 1, -1)) AS sector_raw,
        CASE 
            WHEN CHARINDEX(' > ', s.[Emissions_Row_Name]) > 0 
                 THEN LTRIM(SUBSTRING(s.[Emissions_Row_Name], CHARINDEX(' > ', s.[Emissions_Row_Name]) + 3, 4000))
            ELSE NULL
        END AS subsector_raw,

        /* Parse numeric value (text with thousands separators) */
        TRY_CONVERT(decimal(18,2), REPLACE(s.[Emissions_Response_Answer], ',', '')) AS emissions_tCO2e,

        s.[Emissions_Data_Group],
        s.[Emissions_Notation_Key],
        s.[Emissions_Column_Name],
        s.[Emissions_Row_Name]
    FROM stg.cdp_city_emissions_raw AS s
    WHERE s.[Emissions_Data_Group] IN ('SubSector','GridSubSector')  -- keep only granular lines
      AND (s.[Emissions_Notation_Key] IS NULL OR s.[Emissions_Notation_Key] NOT IN ('NO','NE')) -- drop Not Occurring/Not Estimated if present
)
SELECT
    row_id,
    [City],
    [Country],
    inventory_year,
    scope_label AS scope,

    /* Clean sector/subsector text: drop any trailing caret notes (^) and extra spaces */
    TRIM(REPLACE(REPLACE(sector_raw, '^',''), '  ^',''))    AS sector,
    TRIM(REPLACE(REPLACE(subsector_raw, '^',''), '  ^','')) AS subsector,

    emissions_tCO2e,
    CAST('tCO2e' AS varchar(16)) AS unit,

    [Emissions_Data_Group] AS data_granularity,
    [Emissions_Column_Name] AS scope_source_text,
    [Emissions_Row_Name]    AS sector_source_text
FROM prepared;


select * From dbo.v_city_emissions_fact