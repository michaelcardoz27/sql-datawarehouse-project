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
where flag_last = 1;
--------------------------------------------------------------------------------------
Insert into silver.crm_prod_info(
	[prd_id],
	[cat_id],
	[prd_key],
	[prd_nm],
	[prd_cost],
	[prd_line],
	[prd_start_dt],
	[prd_end_dt])
select
prd_id,
Replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
prd_nm,
isnull(prd_cost,0) as prd_cost,
CASE UPPER(TRIM(prd_line))
	 WHEN 'M' then 'Mountain'
	 WHEN 'R' then 'Road'
	 WHEN 'S' then 'Other Sales'
	 WHEN 'T' then 'Touring'
	 Else 'n/a'
END as prd_line,
cast(prd_start_dt as date) as prd_start_dt,
cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
from bronze.crm_prod_info;
