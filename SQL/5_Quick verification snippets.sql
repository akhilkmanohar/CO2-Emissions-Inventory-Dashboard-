



/* 1) Scope-year matrix to confirm parsing & mapping */
SELECT
    inventory_year,
    scope,
    SUM(emissions_tCO2e) AS tCO2e
FROM dbo.v_city_emissions_fact
GROUP BY inventory_year, scope
ORDER BY inventory_year, scope;

/* 2) Top 10 emitting subsectors for Scope 1 & 2 */
SELECT TOP (10)
    sector, subsector, scope,
    SUM(emissions_tCO2e) AS tCO2e
FROM dbo.v_city_emissions_fact
WHERE scope IN ('Scope 1','Scope 2')
GROUP BY sector, subsector, scope
ORDER BY tCO2e DESC;

/* 3) Reconcile totals view with fact aggregation */
WITH fact_sum AS (
    SELECT
        [City], [Country], inventory_year, scope,
        SUM(emissions_tCO2e) AS tCO2e
    FROM dbo.v_city_emissions_fact
    GROUP BY [City], [Country], inventory_year, scope
)
SELECT
    t.[City], t.[Country], t.inventory_year, t.scope,
    t.total_emissions_tCO2e AS totals_view_value,
    f.tCO2e                 AS recomputed_from_fact,
    (t.total_emissions_tCO2e - f.tCO2e) AS diff
FROM dbo.v_city_emissions_totals AS t
JOIN fact_sum AS f
  ON  f.[City] = t.[City]
  AND f.[Country] = t.[Country]
  AND f.inventory_year = t.inventory_year
  AND f.scope = t.scope
ORDER BY t.inventory_year, t.scope;
