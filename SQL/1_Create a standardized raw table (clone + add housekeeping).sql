


-- If re-running, drop the table first (optional)
IF OBJECT_ID('stg.cdp_city_emissions_raw') IS NOT NULL
    DROP TABLE stg.cdp_city_emissions_raw;
GO

-- Clone the imported table and append a source_file column
SELECT 
    CAST(NULL AS BIGINT) AS row_id,   -- will fill as IDENTITY next
    t.*,
    CAST('2023_City_Wide_Emissions_Berlin.csv' AS nvarchar(200)) AS source_file
INTO stg.cdp_city_emissions_raw
FROM dbo.[2023_City_Wide_Emissions_Berlin] AS t;
GO

-- Add identity and a clustered primary key for performance
ALTER TABLE stg.cdp_city_emissions_raw
    ADD CONSTRAINT PK_cdp_city_emissions_raw
    PRIMARY KEY CLUSTERED (row_id);
GO

-- Make row_id an IDENTITY (SQL Server doesn't allow altering directly;
-- this is optional; if you care, recreate table; otherwise keep as PK only)


---------------------------------------------------------------------------------------------------------------------------------------------------

USE Emissions_Berlin;
GO

-- 1) Rename the nullable row_id so we can keep it (for now)
EXEC sp_rename 'stg.cdp_city_emissions_raw.row_id', 'row_id_old', 'COLUMN';
GO

-- 2) Add a fresh identity column that auto-populates unique values
ALTER TABLE stg.cdp_city_emissions_raw
  ADD row_id BIGINT IDENTITY(1,1) NOT NULL;
GO

select * From stg.cdp_city_emissions_raw

-- 3) Make it the primary key
ALTER TABLE stg.cdp_city_emissions_raw
  ADD CONSTRAINT PK_cdp_city_emissions_raw
  PRIMARY KEY CLUSTERED (row_id);
GO

-- (Optional) When you’re happy, drop the old column:
-- ALTER TABLE stg.cdp_city_emissions_raw DROP COLUMN row_id_old;


SELECT COUNT(*) AS rows_loaded FROM stg.cdp_city_emissions_raw;


-----------------------------------------------------------------------------------------

/*
Later, if you want Munich (or any city):

Use the Import Wizard again to bring that CSV into a new table (e.g., dbo.[2023_City_Wide_Emissions_Munich]),

Replace the staging table with a single statement:

TRUNCATE TABLE stg.cdp_city_emissions_raw;

INSERT INTO stg.cdp_city_emissions_raw
SELECT 
    CAST(NULL AS BIGINT) AS row_id, 
    m.*,
    CAST('2023_City_Wide_Emissions_Munich.csv' AS nvarchar(200)) AS source_file
FROM dbo.[2023_City_Wide_Emissions_Munich] AS m;


Power BI connected to dbo.v_city_emissions_fact will refresh and reflect the new city (no schema changes). */