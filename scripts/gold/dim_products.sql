Create view gold.dim_products as
select 
	ROW_NUMBER() over (order by pn.prd_start_dt, pn.prd_key) as product_key,
	pn.prd_id product_id, 
	pn.prd_key product_number,
	pn.prd_nm product_name,
	pn.cat_id category_id,
	pc.CAT category,
	pc.SUBCAT subcategory,
	pc.MAINTENANCE maintenance,
	pn.prd_cost cost,
	pn.prd_line producy_line,
	pn.prd_start_dt start_date
from silver.crm_prod_info pn
left join silver.erp_PX_CAT_G1V2 pc
on pn.cat_id = pc.ID
where pn.prd_end_dt is null ---- Filter out historical data
