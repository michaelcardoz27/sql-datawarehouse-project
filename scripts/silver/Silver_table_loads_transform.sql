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
----------------------------------------------------------------------------------------------

insert into silver.crm_sales_details(
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
select
sls_ord_num,
sls_prd_key,
sls_cust_id,
case when sls_order_dt <= 0 or LEN(sls_order_dt) != 8 or sls_order_dt > 20500101 or sls_order_dt < 19000101 then NULL
	else cast(cast(sls_order_dt as varchar) as date)
	end as sls_order_dt,
cast(CAST(sls_ship_dt as varchar) as date) as sls_ship_dt,
cast(CAST(sls_due_dt as varchar) as date) as sls_due_dt,
CASE
    WHEN sls_sales IS NULL
        OR sls_sales <= 0
        OR sls_sales <> sls_quantity * ABS(sls_price)
    THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales
END AS sls_sales,
sls_quantity,
CASE
        WHEN sls_price IS NULL
          OR sls_price <= 0
          OR sls_price <>
             (
                 CASE
                     WHEN sls_sales IS NULL
                       OR sls_sales <= 0
                       OR sls_sales <> sls_quantity * ABS(sls_price)
                     THEN sls_quantity * ABS(sls_price)
                     ELSE sls_sales
                 END
             ) / sls_quantity
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
    END AS sls_price
FROM bronze.crm_sales_details
------------------------------------------------------------------------------------------
insert into silver.erp_CUST_AZ12(
CID,
BDATE,
GEN
)
select
case when CID like 'NAS%'
	then SUBSTRING(CID,4,len(cid))
	else CID
	end as CID,
case when bdate > getdate()
	then null
	else bdate
	end as bdate,
case gen
	when 'F' then 'Female'
	when 'M' then 'Male'
	when 'Male' then 'Male'
	when 'Female' then 'Female'
	else 'N/A'
	end as gen
from bronze.erp_CUST_AZ12
-------------------------------------------------------------------------------------------
insert into silver.erp_LOC_A101(
CID,
CNTRY
)
select
REPLACE(CID,'-','') as CID,
case when TRIM(CNTRY) = 'DE' then 'Germany'
	when TRIM(CNTRY) in ('USA','US') then 'United States'
	when TRIM (CNTRY) = '' or CNTRY IS NULL then 'N/A'
	else TRIM(CNTRY)
end CNTRY
from bronze.erp_LOC_A101
-------------------------------------------------------------------------------------------
insert into silver.erp_PX_CAT_G1V2(
ID,
CAT,
SUBCAT,
MAINTENANCE
)
select
*
from bronze.erp_PX_CAT_G1V2


