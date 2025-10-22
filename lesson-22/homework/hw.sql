
SET NOCOUNT ON;

------------------------------------------------------------
-- EASY
------------------------------------------------------------

-- 1) Running total sales per customer
SELECT sale_id, customer_id, customer_name, order_date, total_amount,
       SUM(total_amount) OVER (
           PARTITION BY customer_id
           ORDER BY order_date, sale_id
           ROWS UNBOUNDED PRECEDING
       ) AS running_total_per_customer
FROM dbo.sales_data
ORDER BY customer_id, order_date, sale_id;
GO

-- 2) Number of orders per product_category
SELECT sale_id, product_category, product_name, order_date,
       COUNT(*) OVER (PARTITION BY product_category) AS orders_in_category
FROM dbo.sales_data
ORDER BY product_category, order_date, sale_id;
GO

-- 3) Max total_amount per product_category (as window)
SELECT sale_id, product_category, product_name, total_amount,
       MAX(total_amount) OVER (PARTITION BY product_category) AS max_total_in_category
FROM dbo.sales_data
ORDER BY product_category, total_amount DESC, sale_id;
GO

-- 4) Min unit_price per product_category (as window)
SELECT sale_id, product_category, product_name, unit_price,
       MIN(unit_price) OVER (PARTITION BY product_category) AS min_price_in_category
FROM dbo.sales_data
ORDER BY product_category, unit_price, sale_id;
GO

-- 5) Moving average of sales (3 days: prev, curr, next) by order_date
SELECT sale_id, order_date, total_amount,
       AVG(CAST(total_amount AS DECIMAL(18,4))) OVER (
           ORDER BY order_date, sale_id
           ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ) AS moving_avg_3days
FROM dbo.sales_data
ORDER BY order_date, sale_id;
GO

-- 6) Total sales per region (as window)
SELECT sale_id, region, total_amount,
       SUM(total_amount) OVER (PARTITION BY region) AS region_total_sales
FROM dbo.sales_data
ORDER BY region, sale_id;
GO

-- 7) Rank customers by total purchase amount (ties get same rank)
WITH ctot AS (
  SELECT customer_id, customer_name, SUM(total_amount) AS total_spent
  FROM dbo.sales_data
  GROUP BY customer_id, customer_name
)
SELECT customer_id, customer_name, total_spent,
       DENSE_RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
FROM ctot
ORDER BY spend_rank, customer_id;
GO

-- 8) Difference between current and previous sale amount per customer
SELECT sale_id, customer_id, order_date, total_amount,
       (total_amount - LAG(total_amount) OVER (
            PARTITION BY customer_id ORDER BY order_date, sale_id
        )) AS diff_vs_prev
FROM dbo.sales_data
ORDER BY customer_id, order_date, sale_id;
GO

-- 9) Top 3 most expensive products in each category (by unit_price)
;WITH prod AS (
  SELECT product_category, product_name, MAX(unit_price) AS max_price
  FROM dbo.sales_data
  GROUP BY product_category, product_name
),
r AS (
  SELECT *,
         DENSE_RANK() OVER (PARTITION BY product_category ORDER BY max_price DESC) AS rk
  FROM prod
)
SELECT product_category, product_name, max_price
FROM r
WHERE rk <= 3
ORDER BY product_category, rk, max_price DESC, product_name;
GO

-- 10) Cumulative sum of sales per region by order_date
SELECT region, order_date, sale_id, total_amount,
       SUM(total_amount) OVER (
           PARTITION BY region
           ORDER BY order_date, sale_id
           ROWS UNBOUNDED PRECEDING
       ) AS region_running_total
FROM dbo.sales_data
ORDER BY region, order_date, sale_id;
GO


------------------------------------------------------------
-- MEDIUM
------------------------------------------------------------

-- 1) Cumulative revenue per product_category (running sum by date)
SELECT product_category, order_date, sale_id, total_amount,
       SUM(total_amount) OVER (
         PARTITION BY product_category
         ORDER BY order_date, sale_id
         ROWS UNBOUNDED PRECEDING
       ) AS category_cumulative_revenue
FROM dbo.sales_data
ORDER BY product_category, order_date, sale_id;
GO

-- 2) Sample: cumulative sum of IDs (sum of previous values)
-- (используй свою таблицу с ID как в примере)
-- SELECT ID,
--        SUM(ID) OVER (ORDER BY ID ROWS UNBOUNDED PRECEDING) AS SumPreValues
-- FROM dbo.YourIdTable
-- ORDER BY ID;

-- 3) OneColumn: sum of previous values to current value
-- (таблица создана в условии)
SELECT Value,
       SUM(Value) OVER (ORDER BY Value ROWS UNBOUNDED PRECEDING) AS [Sum of Previous]
FROM dbo.OneColumn
ORDER BY Value;
GO

-- 4) Customers who purchased from >1 product_category
WITH catcnt AS (
  SELECT customer_id, customer_name, COUNT(DISTINCT product_category) AS distinct_cats
  FROM dbo.sales_data
  GROUP BY customer_id, customer_name
)
SELECT customer_id, customer_name, distinct_cats
FROM catcnt
WHERE distinct_cats > 1
ORDER BY customer_id;
GO

-- 5) Customers with above-average spending in their region
WITH tot AS (
  SELECT region, customer_id, customer_name, SUM(total_amount) AS total_spent
  FROM dbo.sales_data
  GROUP BY region, customer_id, customer_name
)
SELECT region, customer_id, customer_name, total_spent
FROM (
  SELECT t.*,
         AVG(total_spent) OVER (PARTITION BY region) AS avg_region_spent
  FROM tot AS t
) x
WHERE x.total_spent > x.avg_region_spent
ORDER BY region, total_spent DESC;
GO

-- 6) Rank customers by total spending within each region (ties same rank)
WITH tot AS (
  SELECT region, customer_id, customer_name, SUM(total_amount) AS total_spent
  FROM dbo.sales_data
  GROUP BY region, customer_id, customer_name
)
SELECT region, customer_id, customer_name, total_spent,
       DENSE_RANK() OVER (PARTITION BY region ORDER BY total_spent DESC) AS regional_rank
FROM tot
ORDER BY region, regional_rank, customer_id;
GO

-- 7) Running total of total_amount per customer_id by order_date
SELECT customer_id, customer_name, order_date, sale_id, total_amount,
       SUM(total_amount) OVER (
         PARTITION BY customer_id
         ORDER BY order_date, sale_id
         ROWS UNBOUNDED PRECEDING
       ) AS cumulative_sales
FROM dbo.sales_data
ORDER BY customer_id, order_date, sale_id;
GO

-- 8) Monthly sales growth rate vs previous month (overall)
WITH m AS (
  SELECT
      DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
      SUM(total_amount) AS month_sales
  FROM dbo.sales_data
  GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)
SELECT month_start,
       month_sales,
       100.0 * (month_sales - LAG(month_sales) OVER (ORDER BY month_start))
             / NULLIF(LAG(month_sales) OVER (ORDER BY month_start), 0) AS growth_rate_pct
FROM m
ORDER BY month_start;
GO

-- 9) Rows where total_amount > last order’s total_amount (per customer)
SELECT customer_id, customer_name, sale_id, order_date, total_amount,
       LAG(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date, sale_id) AS prev_amount
FROM dbo.sales_data
QUALIFY  -- (если QUALIFY недоступен в твоей версии, используй CTE ниже)
       total_amount >
       LAG(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date, sale_id);
GO
