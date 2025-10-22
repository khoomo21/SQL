SET NOCOUNT ON;

--------------------------------------------------------------------------------
-- Puzzle 1: месяц из Dt с ведущим нулём
--------------------------------------------------------------------------------
SELECT
  d.Id,
  d.Dt,
  RIGHT('0' + CAST(MONTH(d.Dt) AS VARCHAR(2)), 2) AS MonthPrefixedWithZero
FROM dbo.Dates AS d
ORDER BY d.Id;
GO

--------------------------------------------------------------------------------
-- Puzzle 2: уникальные Id и сумма максимумов Vals по (Id,rID)
--------------------------------------------------------------------------------
;WITH MaxPerId AS (
  SELECT Id, rID, MAX(Vals) AS MaxVals
  FROM dbo.MyTabel
  GROUP BY Id, rID
)
SELECT
  COUNT(DISTINCT m.Id) AS Distinct_Ids,
  m.rID,
  SUM(m.MaxVals) AS TotalOfMaxVals
FROM MaxPerId AS m
GROUP BY m.rID;
GO

--------------------------------------------------------------------------------
-- Puzzle 3: строки длиной от 6 до 10 символов
--------------------------------------------------------------------------------
SELECT Id, Vals
FROM dbo.TestFixLengths
WHERE Vals IS NOT NULL
  AND LEN(Vals) BETWEEN 6 AND 10
ORDER BY Id, Vals;
GO

--------------------------------------------------------------------------------
-- Puzzle 4: по каждому ID взять Item с максимальным Vals
--------------------------------------------------------------------------------
;WITH Ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY ID ORDER BY Vals DESC, Item) AS rn
  FROM dbo.TestMaximum
)
SELECT ID, Item, Vals
FROM Ranked
WHERE rn = 1
ORDER BY ID;  -- при желании отсортируй иначе
GO

--------------------------------------------------------------------------------
-- Puzzle 5: для каждого Id суммировать МАКС по DetailedNumber
--------------------------------------------------------------------------------
;WITH MaxPerDetail AS (
  SELECT Id, DetailedNumber, MAX(Vals) AS MaxVals
  FROM dbo.SumOfMax
  GROUP BY Id, DetailedNumber
)
SELECT Id, SUM(MaxVals) AS SumofMax
FROM MaxPerDetail
GROUP BY Id
ORDER BY Id;
GO

--------------------------------------------------------------------------------
-- Puzzle 6: показать a-b, но пусто если 0
--------------------------------------------------------------------------------
SELECT
  Id, a, b,
  CASE WHEN a - b = 0 THEN ''
       ELSE CAST(a - b AS VARCHAR(32))
  END AS [OUTPUT]
FROM dbo.TheZeroPuzzle
ORDER BY Id;
GO

/* ============================= SALES (Q&A) ============================= */

--------------------------------------------------------------------------------
-- Total revenue generated from all sales
--------------------------------------------------------------------------------
SELECT SUM(QuantitySold * UnitPrice) AS TotalRevenue
FROM dbo.Sales;
GO

--------------------------------------------------------------------------------
-- Average unit price of products
--------------------------------------------------------------------------------
SELECT AVG(UnitPrice) AS AvgUnitPrice
FROM dbo.Sales;
GO

--------------------------------------------------------------------------------
-- Number of sales transactions
--------------------------------------------------------------------------------
SELECT COUNT(*) AS TransactionsCount
FROM dbo.Sales;
GO

--------------------------------------------------------------------------------
-- Highest number of units sold in a single transaction
--------------------------------------------------------------------------------
SELECT MAX(QuantitySold) AS MaxUnitsSold
FROM dbo.Sales;
GO

--------------------------------------------------------------------------------
-- How many products were sold in each category (total quantity)
--------------------------------------------------------------------------------
SELECT Category, SUM(QuantitySold) AS TotalUnits
FROM dbo.Sales
GROUP BY Category
ORDER BY Category;
GO

--------------------------------------------------------------------------------
-- Total revenue for each region
--------------------------------------------------------------------------------
SELECT Region, SUM(QuantitySold * UnitPrice) AS RegionRevenue
FROM dbo.Sales
GROUP BY Region
ORDER BY Region;
GO

--------------------------------------------------------------------------------
-- Product that generated the highest total revenue
--------------------------------------------------------------------------------
;WITH Rev AS (
  SELECT Product, SUM(QuantitySold * UnitPrice) AS ProductRevenue
  FROM dbo.Sales
  GROUP BY Product
)
SELECT TOP (1) Product, ProductRevenue
FROM Rev
ORDER BY ProductRevenue DESC;
GO

--------------------------------------------------------------------------------
-- Running total of revenue ordered by sale date
--------------------------------------------------------------------------------
SELECT
  SaleID, SaleDate,
  QuantitySold * UnitPrice AS Revenue,
  SUM(QuantitySold * UnitPrice) OVER (ORDER BY SaleDate, SaleID) AS RunningRevenue
FROM dbo.Sales
ORDER BY SaleDate, SaleID;
GO

--------------------------------------------------------------------------------
-- Category contribution to total revenue (share)
--------------------------------------------------------------------------------
;WITH Cat AS (
  SELECT Category, SUM(QuantitySold * UnitPrice) AS CatRevenue
  FROM dbo.Sales
  GROUP BY Category
),
Tot AS (
  SELECT SUM(CatRevenue) AS AllRevenue FROM Cat
)
SELECT
  c.Category,
  c.CatRevenue,
  CAST(100.0 * c.CatRevenue / NULLIF(t.AllRevenue,0) AS DECIMAL(6,2)) AS PctOfTotal
FROM Cat c CROSS JOIN Tot t
ORDER BY c.CatRevenue DESC;
GO

/* =========================== CUSTOMERS (Q&A) =========================== */

--------------------------------------------------------------------------------
-- Show all sales with corresponding customer names
--------------------------------------------------------------------------------
SELECT s.SaleID, s.SaleDate, s.Product, s.QuantitySold, s.UnitPrice, s.Region,
       c.CustomerID, c.CustomerName
FROM dbo.Sales AS s
JOIN dbo.Customers AS c ON c.CustomerID = s.CustomerID
ORDER BY s.SaleDate, s.SaleID;
GO

--------------------------------------------------------------------------------
-- List customers who have NOT made any purchases
--------------------------------------------------------------------------------
SELECT c.CustomerID, c.CustomerName, c.Region, c.JoinDate
FROM dbo.Customers AS c
LEFT JOIN dbo.Sales AS s ON s.CustomerID = c.CustomerID
WHERE s.CustomerID IS NULL
ORDER BY c.CustomerID;
GO

--------------------------------------------------------------------------------
-- Total revenue generated from each customer
--------------------------------------------------------------------------------
SELECT c.CustomerID, c.CustomerName,
       SUM(s.QuantitySold * s.UnitPrice) AS CustomerRevenue
FROM dbo.Customers c
JOIN dbo.Sales s ON s.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CustomerName
ORDER BY CustomerRevenue DESC, c.CustomerID;
GO

--------------------------------------------------------------------------------
-- Customer who contributed the most revenue
--------------------------------------------------------------------------------
;WITH CustRev AS (
  SELECT c.CustomerID, c.CustomerName,
         SUM(s.QuantitySold * s.UnitPrice) AS Revenue
  FROM dbo.Customers c
  JOIN dbo.Sales s ON s.CustomerID = c.CustomerID
  GROUP BY c.CustomerID, c.CustomerName
)
SELECT TOP (1) *
FROM CustRev
ORDER BY Revenue DESC;
GO

--------------------------------------------------------------------------------
-- Total sales per customer (both revenue and number of orders)
--------------------------------------------------------------------------------
SELECT c.CustomerID, c.CustomerName,
       COUNT(*) AS OrdersCount,
       SUM(s.QuantitySold * s.UnitPrice) AS TotalRevenue
FROM dbo.Customers c
JOIN dbo.Sales s ON s.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CustomerName
ORDER BY c.CustomerID;
GO

/* ============================ PRODUCTS (Q&A) =========================== */

--------------------------------------------------------------------------------
-- Products that have been sold at least once
-- (сопоставляем по названию; при наличии ProductID — лучше по ID)
--------------------------------------------------------------------------------
SELECT DISTINCT p.ProductID, p.ProductName, p.Category
FROM dbo.Products p
JOIN dbo.Sales    s ON s.Product = p.ProductName
ORDER BY p.ProductID;
GO

--------------------------------------------------------------------------------
-- Most expensive product (by SellingPrice)
--------------------------------------------------------------------------------
SELECT TOP (1) ProductID, ProductName, Category, SellingPrice
FROM dbo.Products
ORDER BY SellingPrice DESC, ProductID;
GO

--------------------------------------------------------------------------------
-- Products with SellingPrice above category average
--------------------------------------------------------------------------------
SELECT
  p.ProductID, p.ProductName, p.Category, p.SellingPrice,
  AVG(p.SellingPrice) OVER (PARTITION BY p.Category) AS AvgSellingInCategory
FROM dbo.Products p
WHERE p.SellingPrice >
      AVG(p.SellingPrice) OVER (PARTITION BY p.Category)
ORDER BY p.Category, p.SellingPrice DESC, p.ProductID;
GO

