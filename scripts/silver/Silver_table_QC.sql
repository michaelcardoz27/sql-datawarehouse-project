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

SELECT
    sls_sales,
    sls_quantity,
    sls_price,

    /* Corrected sales */
    CASE
        WHEN sls_sales IS NULL
          OR sls_sales <= 0
          OR sls_sales <> sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales2,

    /* Corrected price based on corrected sales */
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
    END AS sls_price2,

    /* Fallback price logic */
    CASE
        WHEN sls_price IS NULL
          OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price3

FROM bronze.crm_sales_details
WHERE
    sls_sales <> sls_quantity * sls_price
    OR sls_sales <= 0
    OR sls_quantity <= 0
    OR sls_price <= 0
    OR sls_quantity IS NULL
    OR sls_sales IS NULL
    OR sls_price IS NULL
ORDER BY
    sls_sales,
    sls_quantity,
    sls_price;
