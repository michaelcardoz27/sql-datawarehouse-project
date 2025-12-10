/*
This file transforms and cleans the data before being inserted into the Silver layer
*/

INSERT INTO silver.crm_cust_info(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date)
select
cst_id,
cst_key,
Trim(cst_firstname) as cst_firstname,
Trim(cst_lastname) as cst_lastname,
CASE WHEN upper(trim(cst_marital_status)) = 'M' then 'Married'
	 WHEN upper(trim(cst_marital_status)) = 'S' THEN 'Single'
	 ELSE 'N/A'
END cst_marital_status,
CASE WHEN upper(trim(CST_GNDR)) = 'F' then 'Female'
	 WHEN upper(trim(CST_GNDR)) = 'M' THEN 'Male'
	 ELSE 'N/A'
END cst_gndr,
cst_create_date
from(
SELECT
*,
ROW_NUMBER () over (partition by cst_id order by cst_create_date desc) as flag_last
FROM bronze.crm_cust_info
) t
where flag_last = 1


