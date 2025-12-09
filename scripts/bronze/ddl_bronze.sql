/*
==================================================================
DDL Script: Create Bronze Tables
==================================================================
Script Purpose:
This script creates tables in the 'bronze' schema, dropping existing tables if they already exist.
Run this script to re-define the DDL structure of 'bronze' Tables
*/

IF OBJECT_ID ('[bronze].[crm_cust_info]','U') IS NOT NULL
	DROP TABLE [bronze].[crm_cust_info];
CREATE TABLE [bronze].[crm_cust_info](
	[cst_id] [int] NULL,
	[cst_key] [nvarchar](50) NULL,
	[cst_firstname] [nvarchar](50) NULL,
	[cst_lastname] [nvarchar](50) NULL,
	[cst_marital_status] [nvarchar](50) NULL,
	[cst_gndr] [nvarchar](50) NULL,
	[cst_create_date] [date] NULL
);

IF OBJECT_ID ('[bronze].[crm_prod_info]','U') IS NOT NULL
	DROP TABLE [bronze].[crm_prod_info];
CREATE TABLE [bronze].[crm_prod_info](
	[prd_id] [int] NULL,
	[prd_key] [nvarchar](50) NULL,
	[prd_nm] [nvarchar](50) NULL,
	[prd_cost] [int] NULL,
	[prd_line] [nvarchar](50) NULL,
	[prd_start_dt] [datetime] NULL,
	[prd_end_dt] [datetime] NULL
);

IF OBJECT_ID ('[bronze].[crm_sales_details]','U') IS NOT NULL
	DROP TABLE [bronze].[crm_sales_details];
CREATE TABLE [bronze].[crm_sales_details](
	[sls_ord_num] [nvarchar](50) NULL,
	[sls_prd_key] [nvarchar](50) NULL,
	[sls_cust_id] [int] NULL,
	[sls_order_dt] [int] NULL,
	[sls_ship_dt] [int] NULL,
	[sls_due_dt] [int] NULL,
	[sls_sales] [int] NULL,
	[sls_quantity] [int] NULL,
	[sls_price] [int] NULL
);

IF OBJECT_ID ('[bronze].[erp_CUST_AZ12]','U') IS NOT NULL
	DROP TABLE [bronze].[erp_CUST_AZ12];
CREATE TABLE [bronze].[erp_CUST_AZ12](
	[CID] [nvarchar](50) NULL,
	[BDATE] [date] NULL,
	[GEN] [nvarchar](50) NULL
);

IF OBJECT_ID ('[bronze].[erp_LOC_A101]','U') IS NOT NULL
	DROP TABLE [bronze].[erp_LOC_A101];
CREATE TABLE [bronze].[erp_LOC_A101](
	[CID] [nvarchar](50) NULL,
	[CNTRY] [nvarchar](50) NULL
);

IF OBJECT_ID ('[bronze].[erp_PX_CAT_G1V2]','U') IS NOT NULL
	DROP TABLE [bronze].[erp_PX_CAT_G1V2];
CREATE TABLE [bronze].[erp_PX_CAT_G1V2](
	[ID] [nvarchar](50) NULL,
	[CAT] [nvarchar](50) NULL,
	[SUBCAT] [nvarchar](50) NULL,
	[MAINTENANCE] [nvarchar](50) NULL
);
