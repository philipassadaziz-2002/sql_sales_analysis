CREATE VIEW customer_sales AS

WITH customer_revenue AS (
SELECT
	s.customerkey
	,
            s.orderdate
	,
            sum(s.quantity::double PRECISION * s.netprice * s.exchangerate) AS total_net_revenue
	,
            count(s.orderkey) AS count
	,
            c.countryfull
	,
            c.age
	,
            c.givenname
	,
            c.surname
FROM
	sales s
LEFT JOIN customer c ON
	c.customerkey = s.customerkey
GROUP BY
	s.customerkey
	, s.orderdate
	, c.countryfull
	, c.age
	, c.givenname
	, c.surname
        )
 SELECT
	customerkey
	,
    orderdate
	,
    total_net_revenue
	,
    count
	,
    countryfull
	,
    age
	,
    givenname
	,
    surname
	,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date
	,
    EXTRACT(YEAR FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM
	customer_revenue cr;