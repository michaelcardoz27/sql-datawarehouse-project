/*
Stored Procedure: Load Bronze Layer (Source -> Bronze)
Script Purpose:
This stored procedure loads data into the 'bronze schema from external CSV files.
It performs the following actions:
- Truncates the bronze tables before loading data.
- Uses the BULK INSERT command to load data from csv Files to bronze tables.
Parameters:
None.
This stored procedure does not accept any parameters or return any values.
Usage Example:
EXEC bronze. load_bronze;
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		set @batch_start_time = GETDATE()
		PRINT '=======================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=======================================';

		PRINT '---------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '---------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_inFo';
		Truncate TABLE bronze.crm_cust_inFo;

		PRINT '>> Inserting data into: bronze.crm_cust_inFo';
		BULK INSERT bronze.crm_cust_inFo
		FROM 'C:\Users\mis\Desktop\SQL tasks\SQL Project Files\sql-data-warehouse-project\datasets\source_crm\cust_info.CSV'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT 'Time taken: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: bronze.crm_prod_info';
		Truncate TABLE bronze.crm_prod_info;
		PRINT '>> Inserting data into: bronze.crm_prod_info';
		BULK INSERT bronze.crm_prod_info
		FROM 'C:\Users\mis\Desktop\SQL tasks\SQL Project Files\sql-data-warehouse-project\datasets\source_crm\prd_info.CSV'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE()
		PRINT 'Time taken: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		Truncate TABLE bronze.crm_sales_details;
		PRINT '>> Inserting data into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\mis\Desktop\SQL tasks\SQL Project Files\sql-data-warehouse-project\datasets\source_crm\sales_details.CSV'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE()
		PRINT 'Time taken: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds'

		PRINT '---------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '---------------------------------------';

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: bronze.erp_CUST_AZ12';
		Truncate TABLE bronze.erp_CUST_AZ12;
		PRINT '>> Inserting data into: bronze.erp_CUST_AZ12';
		BULK INSERT bronze.erp_CUST_AZ12
		FROM 'C:\Users\mis\Desktop\SQL tasks\SQL Project Files\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.CSV'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE()
		PRINT 'Time taken: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: bronze.erp_LOC_A101';
		Truncate TABLE bronze.erp_LOC_A101;
		PRINT '>> Inserting data into: bronze.erp_LOC_A101';
		BULK INSERT bronze.erp_LOC_A101
		FROM 'C:\Users\mis\Desktop\SQL tasks\SQL Project Files\sql-data-warehouse-project\datasets\source_erp\LOC_A101.CSV'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE()
		PRINT 'Time taken: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: bronze.erp_PX_CAT_G1V2';
		Truncate TABLE bronze.erp_PX_CAT_G1V2;
		PRINT '>> Inserting data into: bronze.erp_PX_CAT_G1V2';
		BULK INSERT bronze.erp_PX_CAT_G1V2
		FROM 'C:\Users\mis\Desktop\SQL tasks\SQL Project Files\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.CSV'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE()
		PRINT 'Time taken: ' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' seconds'

		SET @batch_end_time = GETDATE()
		PRINT '==================================='
		PRINT '   - Total duration: ' + cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar) + ' second(s)'
		PRINT '==================================='

	END TRY
	BEGIN CATCH
		PRINT '=================================='
		PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER'
		PRINT 'ERROR NUMBER' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT '=================================='
	END CATCH
END

