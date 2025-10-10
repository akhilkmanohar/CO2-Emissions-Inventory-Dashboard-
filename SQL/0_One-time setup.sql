

USE Emissions_Berlin;

GO

-- Create a staging schema to keep things tidy
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
    EXEC('CREATE SCHEMA stg');
GO
