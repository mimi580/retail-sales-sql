--Questions-- Section A--

-- Q1. Retrieve all customer records
select * from customers
order by customer_id;

-- Q2. Display customer names, cities, and segments
select customer_name, city, customer_segment
from customers
order by customer_id;

--Q3. Find customers living in Nairobi.
select customer_name, city
from customers
where city = 'Nairobi'
order by customer_name;

--Q4. Find customers registered after January 1, 2025
select * from customers
where registration_date > '2025-01-01'
order by registration_date;

--Q5. Display all unique customer cities
select distinct city
from customers
order by city;

--Q6. Retrieve the 10 most recent orders
select *
from orders
order by order_id desc 
limit 10;

--Q7. Find orders with unit prices above KSh 10,000
select * from orders
where unit_price > '10000'
order by unit_price asc;

--Q8. Find customers whose names start with A
select * from customers
where customer_name like 'A%'
order by customer_name;

--Q9. Retrieve orders with quantities between 2 and 5
select * from orders
where quantity between 2 and 5
order by order_id;

--Q10. Find orders paid through M-Pesa
select * from orders
where payment_method = 'M-Pesa'
order by order_id;


--Section B--

--Q11. Count all customers.
select count(*) as total_customers
from customers;

--Q12. Count all orders
select count(*) as total_orders
from orders;

--Q13. Calculate completed-order revenue
select round(sum(quantity * unit_price * (1 - discount / 100)), 3) as completed_order_revenue
from orders
where order_status = 'Completed';

--Q14. Calculate the average completed-order value
select round(avg(quantity * unit_price * (1 - discount / 100)), 3) as average_completed_order_value
from orders
where order_status = 'Completed';

--Q15. Find the highest and lowest product prices
select max(unit_price) as the_highest_price,
       min(unit_price) as the_lowest_price
from orders;

--Q16. Calculate revenue by product category
select product_category,
round(sum(quantity * unit_price * (1 - discount / 100)), 3) as revenue
from orders
group by product_category 
order by revenue desc;

--Q17. Count customers by city
select city, count(*) as customers
from customers
group by city 
order by customers desc, city;

--Q18. Calculate quantity sold by product.
select product_name,
       product_category,
       sum(quantity) as units_sold
 from orders
 where order_status = 'Completed'
 group by product_name, product_category
 order by units_sold;

--Q19. Find categories generating more than KSh 100,000 in revenue
select product_category,
round(sum(quantity * unit_price * (1 - discount / 100)), 3) as revenue
from orders
where order_status = 'Completed'
group by product_category
having sum(quantity * unit_price * (1 - discount / 100))> 100000
order by revenue;

--Q20. Calculate the percentage of cancelled orders
select count(*) filter(where order_status = 'Cancelled') as cancelled_orders,
count(*) as total_orders,
round(100.0 * count(*) filter (where order_status ='Cancelled') / count(*), 3) as cancelled_pcnt
from orders;

-- Section C--
-- Q21. Display orders with customer names and cities
select o.order_id, o.order_date, c.customer_name, c.city, o.product_name, o.quantity, o.order_status
from orders o
join customers c on c.customer_id = o.customer_id
order by order_date;

--Q22. Calculate total spending by customer
select c.customer_id,
       c.customer_name,
       c.customer_segment,
       count(*)                                                     as completed_orders,
       round(sum(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) as total_spent
from customers c
join orders o on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name, c.customer_segment
order by total_spent desc;

--Q23. Identify customers who have never ordered
select c.customer_id,
       c.customer_name,
       c.city,
       c.customer_segment,
       c.registration_date
from customers c
left join orders o on o.customer_id = c.customer_id
where o.order_id is null
order by c.registration_date;

--Q24. Find the 10 highest-spending customers
select c.customer_id,
       c.customer_name,
       c.city,
       c.customer_segment,
       round(sum(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) as total_spent
from customers c
join orders o on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name, c.city, c.customer_segment
order by total_spent desc
limit 10;

--Q25.Calculate revenue by customer city--
select c.city,
       count(distinct c.customer_id)                                as buying_customers,
       round(sum(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) as revenue
from customers c
join orders o on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by c.city
order by revenue desc;

--Q26. Identify customers with more than five orders--
select c.customer_id,
       c.customer_name,
       c.customer_segment,
       count(o.order_id) as total_orders
from customers c
join orders o on o.customer_id = c.customer_id
group by c.customer_id, c.customer_name, c.customer_segment
having count(o.order_id) > 5
order by total_orders desc, c.customer_id;


--Q27. Calculate average customer spending by segment--
with customer_totals as (
select o.customer_id,
           sum(o.quantity * o.unit_price * (1 - o.discount / 100)) as total_spent
    from orders o
    where o.order_status = 'Completed'
    group by o.customer_id
)
select c.customer_segment,
       count(*)                      as buying_customers,
       round(avg(ct.total_spent), 2) as avg_spend_per_customer
from customer_totals ct
join customers c on c.customer_id = ct.customer_id
group by c.customer_segment
order by avg_spend_per_customer desc;

--Q28. Identify the most popular category among VIP customers--
select o.product_category,
       count(*)                                                    as vip_orders,
       sum(o.quantity)                                             as vip_units,
       round(sum(o.quantity * o.unit_price * (1 - o.discount / 100))
             filter (where o.order_status = 'Completed'), 2)       as vip_completed_revenue
from orders o
join customers c on c.customer_id = o.customer_id
where c.customer_segment = 'VIP'
group by o.product_category
order by vip_orders desc
limit 1;


--Section D--

--Q29. Find customers spending above the average total spending per purchasing customer--
WITH customer_totals AS (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100)) AS total_spent
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT c.customer_id,
       c.customer_name,
       c.customer_segment,
       ROUND(ct.total_spent, 2)                                   AS total_spent,
       ROUND((SELECT AVG(total_spent) FROM customer_totals), 2)  AS avg_per_customer
FROM customer_totals ct
JOIN customers c ON c.customer_id = ct.customer_id
WHERE ct.total_spent > (SELECT AVG(total_spent) FROM customer_totals)
ORDER BY ct.total_spent DESC;

--Q30. Find products priced above the overall average unit price--
SELECT DISTINCT product_name,
       product_category,
       unit_price,
       (SELECT ROUND(AVG(unit_price), 2) FROM orders) AS overall_avg_price
FROM orders
WHERE unit_price > (SELECT AVG(unit_price) FROM orders)
ORDER BY unit_price DESC;
 
 
-- Q31: Use a CTE to identify the three highest-revenue months
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date                  AS month,
           SUM(quantity * unit_price * (1 - discount / 100))      AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT TO_CHAR(month, 'YYYY-MM') AS month,
       ROUND(revenue, 2)         AS revenue
FROM monthly
ORDER BY revenue DESC
LIMIT 3;

--Q32. Find customers purchasing from at least three categories--
SELECT c.customer_id,
       c.customer_name,
       c.customer_segment,
       COUNT(DISTINCT o.product_category) AS categories_bought
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name, c.customer_segment
HAVING COUNT(DISTINCT o.product_category) >= 3
ORDER BY categories_bought DESC, c.customer_id;

--Q33. Use a CTE to calculate category revenue, cost, profit, and profit margin--
WITH category_totals AS (
    SELECT product_category,
           SUM(quantity * unit_price * (1 - discount / 100)) AS revenue,
           SUM(quantity * cost_price)                        AS cost
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT product_category,
       ROUND(revenue, 2)                                         AS revenue,
       ROUND(cost, 2)                                            AS cost,
       ROUND(revenue - cost, 2)                                  AS profit,
       ROUND((revenue - cost) / NULLIF(revenue, 0) * 100, 2)     AS profit_margin_pct
FROM category_totals
ORDER BY profit DESC;

--Q34. Find customers whose latest completed order is more than 90 days before the latest order date in the dataset--
WITH last_completed AS (
    SELECT customer_id,
           MAX(order_date) AS last_completed_order
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT c.customer_id,
       c.customer_name,
       c.customer_segment,
       lc.last_completed_order,
       (SELECT MAX(order_date) FROM orders) - lc.last_completed_order AS days_since_last_order
FROM last_completed lc
JOIN customers c ON c.customer_id = lc.customer_id
WHERE (SELECT MAX(order_date) FROM orders) - lc.last_completed_order > 90
ORDER BY days_since_last_order DESC;

--Section E--

--Q35. Rank customers by spending using RANK()--
WITH customer_totals AS (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100)) AS total_spent
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT RANK() OVER (ORDER BY ct.total_spent DESC) AS spending_rank,
       c.customer_id,
       c.customer_name,
       c.customer_segment,
       ROUND(ct.total_spent, 2)                   AS total_spent
FROM customer_totals ct
JOIN customers c ON c.customer_id = ct.customer_id
ORDER BY spending_rank, c.customer_id;

--Q36. Number each customer's orders by recency using ROW_NUMBER()--
SELECT customer_id,
       order_id,
       order_date,
       product_name,
       order_status,
       ROW_NUMBER() OVER (PARTITION BY customer_id
                          ORDER BY order_date DESC, order_id DESC) AS recency_number
FROM orders
ORDER BY customer_id, recency_number;

--Q37. Rank products within categories using DENSE_RANK().--
WITH product_revenue AS (
    SELECT product_category,
           product_name,
           SUM(quantity * unit_price * (1 - discount / 100)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category, product_name
)
SELECT product_category,
       DENSE_RANK() OVER (PARTITION BY product_category ORDER BY revenue DESC) AS rank_in_category,
       product_name,
       ROUND(revenue, 2) AS revenue
FROM product_revenue
ORDER BY product_category, rank_in_category;

--Q38. Calculate cumulative monthly revenue--
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date             AS month,
           SUM(quantity * unit_price * (1 - discount / 100)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT TO_CHAR(month, 'YYYY-MM')                    AS month,
       ROUND(revenue, 2)                            AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS cumulative_revenue
FROM monthly
ORDER BY month;

--Q39. Compare monthly revenue using LAG()--
with 
monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date             AS month,
           SUM(quantity * unit_price * (1 - discount / 100)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT TO_CHAR(month, 'YYYY-MM')                                AS month,
       ROUND(revenue, 2)                                        AS revenue,
       ROUND(LAG(revenue) OVER (ORDER BY month), 2)             AS previous_month_revenue,
       ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2)   AS change_ksh
FROM monthly
ORDER BY month;

--Q40. Calculate month-over-month revenue growth (%)--
with
monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date             AS month,
           SUM(quantity * unit_price * (1 - discount / 100)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
),
with_previous AS (
    SELECT month,
           revenue,
           LAG(revenue) OVER (ORDER BY month) AS previous_revenue
    FROM monthly
)
SELECT TO_CHAR(month, 'YYYY-MM')                                               AS month,
       ROUND(revenue, 2)                                                       AS revenue,
       ROUND(previous_revenue, 2)                                              AS previous_month_revenue,
       ROUND((revenue - previous_revenue) / NULLIF(previous_revenue, 0) * 100, 2) AS mom_growth_pct
FROM with_previous
ORDER BY month;

--Q41. Divide customers into four spending groups using NTILE(4)--
WITH customer_totals AS (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100)) AS total_spent
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT NTILE(4) OVER (ORDER BY ct.total_spent DESC) AS spending_quartile,
       c.customer_id,
       c.customer_name,
       c.customer_segment,
       ROUND(ct.total_spent, 2)                     AS total_spent
FROM customer_totals ct
JOIN customers c ON c.customer_id = ct.customer_id
ORDER BY spending_quartile, ct.total_spent DESC;

--Q42. Calculate each category's share of total revenue using window functions--
select
product_category,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2)                 AS revenue,
       ROUND(SUM(SUM(quantity * unit_price * (1 - discount / 100))) OVER (), 2)    AS total_revenue,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100)) * 100
             / SUM(SUM(quantity * unit_price * (1 - discount / 100))) OVER (), 2)  AS revenue_share_pct
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY revenue DESC;


--Section F--
--Q43. Create a monthly_sales_summary view (month, orders, revenue, cost, profit), then select from it.--
CREATE OR REPLACE VIEW monthly_sales_summary as
SELECT DATE_TRUNC('month', order_date)::date                                   AS month,
       COUNT(*)                                                                AS orders,
       ROUND(COALESCE(SUM(quantity * unit_price * (1 - discount / 100))
             FILTER (WHERE order_status = 'Completed'), 0), 2)                 AS revenue,
       ROUND(COALESCE(SUM(quantity * cost_price)
             FILTER (WHERE order_status = 'Completed'), 0), 2)                 AS cost,
       ROUND(COALESCE(SUM(quantity * unit_price * (1 - discount / 100) - quantity * cost_price)
             FILTER (WHERE order_status = 'Completed'), 0), 2)                 AS profit
FROM orders
GROUP BY DATE_TRUNC('month', order_date);
 
SELECT TO_CHAR(month, 'YYYY-MM') AS month, orders, revenue, cost, profit
FROM monthly_sales_summary
ORDER BY month;

--Q44. Create a PL/pgSQL function that returns completed-order revenue for a supplied customer ID — show it for one customer and for an ID that does not exist (it must return 0).--
CREATE OR REPLACE FUNCTION customer_completed_revenue(p_customer_id INTEGER)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_revenue NUMERIC;
BEGIN
    SELECT COALESCE(ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2), 0)
    INTO v_revenue
    FROM orders
    WHERE customer_id = p_customer_id
      AND order_status = 'Completed';
 
    RETURN v_revenue;
END;
$$;


--Q45. Segment customers into High, Medium and Low Value, and explain why you chose your thresholds.--

-- Thresholds (Completed-order spending per buying customer):
--   High   = KSh 300,000 or more
--   Medium = KSh 100,000 to 299,999.99
--   Low    = under KSh 100,000
-- Why: spending is very uneven. The median buying customer has spent about KSh 90,000
-- (roughly one big-ticket item such as a phone or fridge), the average is about
-- KSh 183,000 and the top customer KSh 848,000. KSh 100,000 therefore separates
-- one-off buyers from customers who have come back for more, and KSh 300,000 picks out
-- the small group (28 customers, about a fifth) who bring in nearly two-thirds of all
-- revenue. Round KSh amounts were chosen over percentiles because management can
-- understand them and they stay fixed as new data arrives.
-- The 18 customers with no Completed orders are left out (see Q23).
WITH customer_totals AS (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100)) AS total_spent
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT c.customer_id,
       c.customer_name,
       c.customer_segment,
       ROUND(ct.total_spent, 2) AS total_spent,
       CASE
           WHEN ct.total_spent >= 300000 THEN 'High Value'
           WHEN ct.total_spent >= 100000 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS value_band
FROM customer_totals ct
JOIN customers c ON c.customer_id = ct.customer_id
ORDER BY ct.total_spent DESC;
 
-- Summary of the bands: how many customers, and what share of revenue each brings in.
WITH customer_totals AS (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100)) AS total_spent
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
banded AS (
    SELECT total_spent,
           CASE
               WHEN total_spent >= 300000 THEN 'High Value'
               WHEN total_spent >= 100000 THEN 'Medium Value'
               ELSE 'Low Value'
           END AS value_band
    FROM customer_totals
)
SELECT value_band,
       COUNT(*)                                                  AS customers,
       ROUND(SUM(total_spent), 2)                                AS revenue,
       ROUND(SUM(total_spent) * 100 / SUM(SUM(total_spent)) OVER (), 2) AS revenue_share_pct
FROM banded
GROUP BY value_band
ORDER BY MIN(total_spent) DESC;

--Q46. Produce a management report: top five customers, top five products, the most profitable category, and the lowest-revenue month--
WITH top_customers AS (
    SELECT c.customer_name                                          AS item,
           SUM(o.quantity * o.unit_price * (1 - o.discount / 100))  AS value
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
    ORDER BY value DESC
    LIMIT 5
),
top_products AS (
    SELECT product_name                                       AS item,
           SUM(quantity * unit_price * (1 - discount / 100))  AS value
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_name
    ORDER BY value DESC
    LIMIT 5
),
best_category AS (
    SELECT product_category                                                          AS item,
           SUM(quantity * unit_price * (1 - discount / 100) - quantity * cost_price) AS value
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
    ORDER BY value DESC
    LIMIT 1
),
worst_month AS (
    SELECT TO_CHAR(month, 'YYYY-MM') AS item,
           revenue                   AS value
    FROM monthly_sales_summary
    ORDER BY revenue ASC
    LIMIT 1
)
SELECT '1. Top 5 customers (revenue)'   AS report_section,
       ROW_NUMBER() OVER (ORDER BY value DESC) AS position, item, ROUND(value, 2) AS ksh
FROM top_customers
UNION ALL
SELECT '2. Top 5 products (revenue)',
       ROW_NUMBER() OVER (ORDER BY value DESC), item, ROUND(value, 2)
FROM top_products
UNION ALL
SELECT '3. Most profitable category (profit)', 1, item, ROUND(value, 2)
FROM best_category
UNION ALL
SELECT '4. Lowest-revenue month (revenue)', 1, item, ROUND(value, 2)
FROM worst_month
ORDER BY report_section, position;







