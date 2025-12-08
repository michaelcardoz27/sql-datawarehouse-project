/*
================================================================================
Create Database and Schedmas
================================================================================
Script Purpose:
This script creates a new database named 'Datawarehouse' after checking if it already exists.
If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas within the database: 'bronze', 'silver', and 'gold'.
WARNING:
Running this script will drop the entire 'Datawarehouse' database if it exists.
All data in the database will be permanently deleted. Proceed with caution and ensure you have proper backups before running this script.
*/


---Using Master to create Database
USE master;
GO

---Creating Database. If the database exists, must drop and then create with code exists.
CREATE DATABASE DataWarehouse;

---Using datawarehouse for creation of schema.
use DataWarehouse;

---creating schemas for database
CREATE SCHEMA bronze;

CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
