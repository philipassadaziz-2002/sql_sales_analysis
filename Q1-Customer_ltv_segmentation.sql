-- =====================================================
-- CUSTOMER LIFETIME VALUE (LTV) SEGMENTATION
-- Business Question: Which customer segment drives the most revenue, and what is the LTV gap
--                   between High and Low value customers?
-- Purpose: Segment customers into value tiers based on total revenue generated across all orders
-- Business Use: Identify high-value customers to prioritize retention and marketing spend
-- =====================================================

WITH ltv AS (
        -- Step 1: Calculate total lifetime revenue per customer
        SELECT
                DISTINCT customerkey
                ,
                full_name
                ,
            round(sum(total_net_revenue::numeric), 2) as total_ltv
        from
                customer_revenue_full_name
        group by
                customerkey
                ,
                full_name
)
,
ltv_percentiles AS (
        -- Step 2: Define segment boundaries using 25th and 75th percentiles
        -- P25 = Low/Mid cutoff | P75 = Mid/High cutoff
        SELECT
               percentile_cont(0.25) within group (order by total_ltv) as p25
               ,
               percentile_cont(0.75) within group (order by total_ltv) as p75
        FROM
                ltv
)
,
customer_segmentation AS (
        -- Step 3: Assign each customer to a value segment
        SELECT
                l.customerkey
                ,
                l.full_name
                ,
                l.total_ltv
                ,
                case
                        when l.total_ltv < p.p25 then '1-Low Value'
                        when l.total_ltv >= p.p25 and l.total_ltv < p.p75 then '2-Mid Value'
                        else '3-High Value'
                end as customer_segment
        FROM
                ltv as l
                ,
                ltv_percentiles as p
        )
-- Final: Summarize revenue, count, and avg LTV per segment
SELECT
        customer_segment
        ,
        round(sum(total_ltv), 2) as total_ltv
        ,
        count(customerkey) as customer_count
        ,
        round(sum(total_ltv)/count(customerkey), 2) as avg_ltv
FROM
        customer_segmentation
group by
        customer_segment