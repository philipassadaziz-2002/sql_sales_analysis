    
  -- ============================================================
--                      CUSTOMER CHURN ANALYSIS
-- Business Question: What percentage of customers have churned, and how many remain active?
-- ============================================================

    WITH last_purchase AS (
        -- Step 1: Get each customer's purchase history
        SELECT
                customerkey
                ,
                full_name
                ,
                orderdate
                ,
                 --     row_number() DESC = most recent purchase gets rn = 1
                row_number() over (partition by customerkey order by orderdate DESC) AS rn
               ,
               first_purchase_date 

                

        FROM 
                customer_revenue_full_name
       
              
   )
   , 
   churned_customers AS (
       -- Step 2: Classify each customer as Active or Churned
   SELECT
           customerkey
           ,
           full_name
           ,
           orderdate as last_purchase_date
           ,
           --         Churned = last purchase older than 6 months from latest order
           case when orderdate < (SELECT max(orderdate)from sales) - interval '6 months' 
           then 'Churned' else 'Active' end as customer_status
           
    FROM
           last_purchase
    WHERE
           rn = 1 
           
           AND
                  --         Exclude new customers (first_purchase < 6 months ago)
              first_purchase_date < (SELECT max(orderdate) from sales) - interval '6 months' )
-- Step 5: Summarize count and percentage per status
    SELECT
            customer_status
            ,
            count(customer_status) as count
            ,
           round(count(customer_status) /sum(count(customerkey)) over () ,2)as status_percentage
    FROM
          churned_customers
    GROUP BY
          customer_status;

        