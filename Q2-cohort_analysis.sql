-- ============================================================
--                       Cohort Revenue Analysis
--Customer Lifetime Value (LTV) Segmentation:
-- Which customer segment contributes the most to total revenue,
-- and what is the LTV gap between High and Low value customers?
-- ============================================================

SELECT
 -- Step 1: Cast cohort year to TEXT for clean display 
    cs.cohort_year::TEXT AS cohort_year
    ,               
-- Step 2: Total net revenue per cohort 
    ROUND(SUM(cs.total_net_revenue::NUMERIC), 2)      
        AS total_revenue
    ,                              
-- Step 3: Unique customer count — DISTINCT prevents double-counting
    COUNT(DISTINCT cs.customerkey)                     
        AS customerkey
    ,                               
-- Step 4: ARPU — Average Revenue Per User per cohort
    ROUND(
        SUM(cs.total_net_revenue)::NUMERIC 
        / COUNT(DISTINCT cs.customerkey), 2
    ) AS customer_revenue                              

FROM
    customer_sales AS cs                               
-- Step 5: Keep only each customer's FIRST transaction to define cohort membership
WHERE
    first_purchase_date = orderdate                    
                                                       

GROUP BY
    cohort_year                                       

ORDER BY
    cohort_year                                        
