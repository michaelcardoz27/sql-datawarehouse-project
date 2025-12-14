CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE 
		@start_time DATETIME,
		@end_time DATETIME,
		@batch_start_time DATETIME,
		@batch_end_time DATETIME;

	BEGIN TRY
		SET @batch_start_time = GETDATE();

		PRINT '=======================================';
		PRINT 'Loading Silver Layer';
		PRINT '=======================================';

		/* ---------------------------------------
		   Loading CRM Tables
		   --------------------------------------- */

		/* CRM Customer Information */
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;

		PRINT '>> Inserting data into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname),
			TRIM(cst_lastname),
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				ELSE 'N/A'
			END,
			CASE 
				WHEN UPPER(TRIM(CST_GNDR)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(CST_GNDR)) = 'M' THEN 'Male'
				ELSE 'N/A'
			END,
			cst_create_date
		FROM (
			SELECT *,
				   ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
		) t
		WHERE flag_last = 1;

		SET @end_time = GETDATE();
		PRINT 'Time taken: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		/* CRM Product Information */
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prod_info';
		TRUNCATE TABLE silver.crm_prod_info;

		PRINT '>> Inserting data into: silver.crm_prod_info';
		INSERT INTO silver.crm_prod_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
			SUBSTRING(prd_key, 7, LEN(prd_key)),
			prd_nm,
			ISNULL(prd_cost, 0),
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'N/A'
			END,
			CAST(prd_start_dt AS DATE),
			CAST(
				LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1
				AS DATE
			)
		FROM bronze.crm_prod_info;

		SET @end_time = GETDATE();
		PRINT 'Time taken: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		/* CRM Sales Details */
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;

		PRINT '>> Inserting data into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt <= 0 
				  OR LEN(sls_order_dt) <> 8
				  OR sls_order_dt > 20500101
				  OR sls_order_dt < 19000101
				THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END,
			CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE),
			CAST(CAST(sls_due_dt AS VARCHAR) AS DATE),
			CASE
				WHEN sls_sales IS NULL
				  OR sls_sales <= 0
				  OR sls_sales <> sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END,
			sls_quantity,
			CASE
				WHEN sls_price IS NULL
				  OR sls_price <= 0
				THEN
					(
						CASE
							WHEN sls_sales IS NULL
							  OR sls_sales <= 0
							  OR sls_sales <> sls_quantity * ABS(sls_price)
							THEN sls_quantity * ABS(sls_price)
							ELSE sls_sales
						END
					) / sls_quantity
				ELSE sls_price
			END
		FROM bronze.crm_sales_details;

		SET @end_time = GETDATE();
		PRINT 'Time taken: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		/* ---------------------------------------
		   Loading ERP Tables
		   --------------------------------------- */

		/* ERP Customer */
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_CUST_AZ12';
		TRUNCATE TABLE silver.erp_CUST_AZ12;

		PRINT '>> Inserting data into: silver.erp_CUST_AZ12';
		INSERT INTO silver.erp_CUST_AZ12 (CID, BDATE, GEN)
		SELECT
			CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID)) ELSE CID END,
			CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END,
			CASE gen
				WHEN 'F' THEN 'Female'
				WHEN 'M' THEN 'Male'
				WHEN 'Male' THEN 'Male'
				WHEN 'Female' THEN 'Female'
				ELSE 'N/A'
			END
		FROM bronze.erp_CUST_AZ12;

		SET @end_time = GETDATE();
		PRINT 'Time taken: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		/* ERP Location */
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_LOC_A101';
		TRUNCATE TABLE silver.erp_LOC_A101;

		PRINT '>> Inserting data into: silver.erp_LOC_A101';
		INSERT INTO silver.erp_LOC_A101 (CID, CNTRY)
		SELECT
			REPLACE(CID, '-', ''),
			CASE 
				WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
				WHEN TRIM(CNTRY) IN ('USA', 'US') THEN 'United States'
				WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'N/A'
				ELSE TRIM(CNTRY)
			END
		FROM bronze.erp_LOC_A101;

		SET @end_time = GETDATE();
		PRINT 'Time taken: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		/* ERP Product Category */
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_PX_CAT_G1V2';
		TRUNCATE TABLE silver.erp_PX_CAT_G1V2;

		PRINT '>> Inserting data into: silver.erp_PX_CAT_G1V2';
		INSERT INTO silver.erp_PX_CAT_G1V2 (ID, CAT, SUBCAT, MAINTENANCE)
		SELECT * FROM bronze.erp_PX_CAT_G1V2;

		SET @end_time = GETDATE();
		PRINT 'Time taken: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		SET @batch_end_time = GETDATE();
		PRINT '===================================';
		PRINT '   - Total duration: ' 
			  + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) 
			  + ' second(s)';
		PRINT '===================================';

	END TRY
	BEGIN CATCH
		PRINT '==================================';
		PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
		PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
		PRINT '==================================';
	END CATCH
END
