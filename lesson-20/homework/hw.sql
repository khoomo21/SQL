
SET NOCOUNT ON;

--------------------------------------------------------------------------------
-- 1) Customers with at least one purchase in March 2024 (EXISTS)
--------------------------------------------------------------------------------
SELECT DISTINCT s.CustomerName
FROM #Sales AS s
WHERE EXISTS (
    SELECT 1
    FROM #Sales AS x
    WHERE x.CustomerName = s.CustomerName
      AND x.SaleDate >= '2024-03-01' AND x.SaleDate < '2024-04-01'
);
GO

--------------------------------------------------------------------------------
-- 2) Product with the highest total revenue (subquery / derived)
--------------------------------------------------------------------------------
WITH Totals AS (
    SELECT Product,
           SUM(Quantity * Price) AS TotalRevenue
    FROM #Sales
    GROUP BY Product
)
SELECT TOP (1) Product, TotalRevenue
FROM Totals
ORDER BY TotalRevenue DESC;
-- Вариант строго через подзапрос:
-- SELECT t.*
-- FROM Totals t
-- WHERE t.TotalRevenue = (SELECT MAX(TotalRevenue) FROM Totals);
GO

--------------------------------------------------------------------------------
-- 3) Second highest sale AMOUNT (per row) using a subquery (distinct)
--------------------------------------------------------------------------------
WITH RowAmt AS (
    SELECT DISTINCT CAST(Quantity * Price AS DECIMAL(18,2)) AS Amount
    FROM #Sales
)
SELECT MAX(Amount) AS SecondHighestAmount
FROM RowAmt
WHERE Amount < (SELECT MAX(Amount) FROM RowAmt);
GO

--------------------------------------------------------------------------------
-- 4) Total quantity sold per month (subquery)
--------------------------------------------------------------------------------
SELECT m.YM, m.TotalQty
FROM (
    SELECT
        CONVERT(char(7), SaleDate, 120) AS YM,  -- YYYY-MM
        SUM(Quantity) AS TotalQty
    FROM #Sales
    GROUP BY CONVERT(char(7), SaleDate, 120)
) AS m
ORDER BY m.YM;
GO

--------------------------------------------------------------------------------
-- 5) Customers who bought the same products as another customer (EXISTS)
--------------------------------------------------------------------------------
SELECT DISTINCT s.CustomerName
FROM #Sales AS s
WHERE EXISTS (
    SELECT 1
    FROM #Sales AS t
    WHERE t.Product = s.Product
      AND t.CustomerName <> s.CustomerName
);
GO

--------------------------------------------------------------------------------
-- 6) Fruits: count per person per fruit (pivot/cond. aggregation)
--------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#Fruits') IS NOT NULL DROP TABLE #Fruits;
SELECT * INTO #Fruits FROM Fruits;

SELECT
    Name,
    SUM(CASE WHEN Fruit = 'Apple'  THEN 1 ELSE 0 END) AS Apple,
    SUM(CASE WHEN Fruit = 'Orange' THEN 1 ELSE 0 END) AS Orange,
    SUM(CASE WHEN Fruit = 'Banana' THEN 1 ELSE 0 END) AS Banana
FROM #Fruits
GROUP BY Name
ORDER BY Name;
GO

--------------------------------------------------------------------------------
-- 7) Family: return all ancestor -> descendant pairs (transitive closure)
--------------------------------------------------------------------------------
;WITH R AS (
    SELECT ParentId AS PID, ChildID AS CHID
    FROM Family
    UNION ALL
    SELECT R.PID, F.ChildID
    FROM R
    JOIN Family AS F ON F.ParentId = R.CHID
)
SELECT DISTINCT PID, CHID
FROM R
ORDER BY PID, CHID
OPTION (MAXRECURSION 32767);
GO

--------------------------------------------------------------------------------
-- 8) For customers who had a CA delivery, list their TX orders
--------------------------------------------------------------------------------
SELECT o.*
FROM #Orders AS o
WHERE o.DeliveryState = 'TX'
  AND EXISTS (
      SELECT 1
      FROM #Orders AS c
      WHERE c.CustomerID = o.CustomerID
        AND c.DeliveryState = 'CA'
  )
ORDER BY o.CustomerID, o.OrderID;
GO

--------------------------------------------------------------------------------
-- 9) Insert the names into address if missing (append name=FullName)
--------------------------------------------------------------------------------
-- добавим метку name=<fullname>, если её нет в address
UPDATE r
SET address = RTRIM(address) + ' name=' + r.fullname
FROM #residents AS r
WHERE r.address NOT LIKE '%name=%';

SELECT * FROM #residents ORDER BY resid;
GO

--------------------------------------------------------------------------------
-- 10) Routes Tashkent -> Khorezm: show cheapest and most expensive paths
--------------------------------------------------------------------------------
;WITH Paths AS (
    -- старт из Tashkent
    SELECT
        RouteID,
        DepartureCity,
        ArrivalCity,
