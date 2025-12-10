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
