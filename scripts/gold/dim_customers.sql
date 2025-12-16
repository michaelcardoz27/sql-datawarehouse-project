CREATE view [gold].[dim_customers] as
select
ROW_NUMBER() over (order by cst_id) as customer_key,
ci.cst_id customer_ID,
ci.cst_key customer_number,
ci.cst_firstname customer_firstname,
ci.cst_lastname customer_lastname,
la.cntry country,
ci.cst_marital_status customer_marital_status,
case when ci.cst_gndr != 'N/A' then ci.cst_gndr -----CRM is the master for gender
	else coalesce(ca.GEN,'N/A')
	end as gender,
ca.bdate birth_date,
ci.cst_create_date created_date
from silver.crm_cust_info as ci
left join silver.erp_CUST_AZ12 as ca
on ci.cst_key = ca.CID
left join silver.erp_LOC_A101 as la
on ci.cst_key = la.CID
