



/* Aggregated totals for quick KPIs and trendlines */
CREATE OR ALTER VIEW dbo.v_city_emissions_totals AS
WITH fact AS (
    SELECT * FROM dbo.v_city_emissions_fact
)
SELECT
    [City],
    [Country],
    inventory_year,
    scope,
    SUM(emissions_tCO2e) AS total_emissions_tCO2e
FROM fact
GROUP BY [City], [Country], inventory_year, scope

UNION ALL

/* Overall total across scopes (per year) */
SELECT
    [City],
    [Country],
    inventory_year,
    CAST('All scopes' AS varchar(32)) AS scope,
    SUM(emissions_tCO2e) AS total_emissions_tCO2e
FROM fact
GROUP BY [City], [Country], inventory_year;

select * from dbo.v_city_emissions_totals