CREATE VIEW [gold].[fact_sales] as
SELECT
	sls_ord_num order_number,
	pr.product_key,
	cs.customer_key,
	sls_order_dt order_date,
	sls_ship_dt ship_date,
	sls_due_dt due_date,
	sls_sales sales_amount,
	sls_quantity quantity,
	sls_price price
FROM silver.crm_sales_details sd
left join gold.dim_products pr
on sd.sls_prd_key = pr.product_number
left join gold.dim_customers cs
on sd.sls_cust_id = cs.customer_id
