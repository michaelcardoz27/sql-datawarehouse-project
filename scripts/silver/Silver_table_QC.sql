/*Check for unwanted spaces
Expectation: No results
*/
select
cst_firstname
from silver.crm_cust_info
where cst_firstname != TRIM(cst_firstname)

select
cst_lastname
from silver.crm_cust_info
where cst_lastname != TRIM(cst_lastname)

select
cst_gndr
from silver.crm_cust_info
where cst_gndr != TRIM(cst_gndr)

select
cst_key
from silver.crm_cust_info
where cst_key != TRIM(cst_key)

---Data standardization & Consistency
select
distinct cst_gndr
from silver.crm_cust_info

select
distinct cst_marital_status
from silver.crm_cust_info
--------------------------------------------------------------------

--- Check for Invalid dates in bronze layer before trnasforming and inserting to silver layer
--- check for invalid pricing and quantity
select
nullif(sls_order_dt,0) as sls_order_dt
from bronze.crm_sales_details
where sls_order_dt <= 0
or LEN(sls_order_dt) != 8
or sls_order_dt > 20500101
or sls_order_dt < 19000101

select
nullif(sls_ship_dt,0) as sls_ship_dt
from bronze.crm_sales_details
where sls_ship_dt <= 0
or LEN(sls_ship_dt) != 8
or sls_ship_dt > 20500101
or sls_ship_dt < 19000101

select
nullif(sls_due_dt,0) as sls_due_dt
from bronze.crm_sales_details
where sls_due_dt <= 0
or LEN(sls_due_dt) != 8
or sls_due_dt > 20500101
or sls_due_dt < 19000101

select
*
from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt
or sls_order_dt > sls_due_dt


select
sls_sales,
sls_quantity,
sls_price
from bronze.crm_sales_details
where sls_sales != sls_quantity*sls_price
or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
or sls_quantity is null or sls_sales is null or sls_price is null
order by sls_sales, sls_quantity, sls_price

--------------------------------------------------------------------------------------------------
select
ID
from bronze.erp_PX_CAT_G1V2
where not exists (select
distinct cat_id
from silver.crm_prod_info)

select
distinct cat_id
from silver.crm_prod_info

select
distinct CAT
from bronze.erp_PX_CAT_G1V2
where CAT != TRIM(CAT)

select
distinct SUBCAT
from bronze.erp_PX_CAT_G1V2
where SUBCAT != TRIM(SUBCAT)

select
distinct MAINTENANCE
from bronze.erp_PX_CAT_G1V2
where MAINTENANCE != TRIM(MAINTENANCE)
