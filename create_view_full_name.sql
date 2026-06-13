CREATE OR REPLACE VIEW public.customer_revenue_full_name 
AS WITH customer_revenue AS (
         SELECT s.customerkey,
            s.orderdate,
            sum(s.quantity::double precision * s.netprice * s.exchangerate) AS total_net_revenue,
            count(s.orderkey) AS count,
            c.countryfull,
            c.age,
            c.givenname,
            c.surname
           FROM sales s
             LEFT JOIN customer c ON c.customerkey = s.customerkey
          GROUP BY s.customerkey, s.orderdate, c.countryfull, c.age, c.givenname, c.surname
        )
 SELECT customerkey,
    orderdate,
    total_net_revenue,
    count AS number_orders,
    countryfull,
    age,
    concat(givenname,surname) As full_name,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
   FROM customer_revenue cr;