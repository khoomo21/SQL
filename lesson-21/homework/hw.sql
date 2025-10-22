SET NOCOUNT ON;

------------------------------------------------------------
-- 1) Row number per sale by SaleDate
------------------------------------------------------------
SELECT SaleID, ProductName, SaleDate, SaleAmount,
       ROW_NUMBER() OVER (ORDER BY SaleDate, SaleID) AS RowNumByDate
FROM dbo.ProductSales
ORDER BY SaleDate, SaleID;
GO

------------------------------------------------------------
-- 2) Rank products by total quantity sold (dense ranks, no gaps)
------------------------------------------------------------
WITH q AS (
  SELECT ProductName, SUM(Quantity) AS TotalQty
  FROM dbo.ProductSales
  GROUP BY ProductName
)
SELECT ProductName, TotalQty,
       DENSE_RANK() OVER (ORDER BY TotalQty DESC) AS QtyRank
FROM q
ORDER BY QtyRank, ProductName;
GO

------------------------------------------------------------
-- 3) Top sale per customer by SaleAmount
------------------------------------------------------------
WITH r AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY SaleAmount DESC, SaleDate, SaleID) AS rn
  FROM dbo.ProductSales
)
SELECT CustomerID, SaleID, ProductName, SaleDate, SaleAmount
FROM r
WHERE rn = 1
ORDER BY CustomerID;
GO

------------------------------------------------------------
-- 4) Each sale with next sale amount (by SaleDate)
------------------------------------------------------------
SELECT SaleID, SaleDate, SaleAmount,
       LEAD(SaleAmount) OVER (ORDER BY SaleDate, SaleID) AS NextSaleAmount
FROM dbo.ProductSales
ORDER BY SaleDate, SaleID;
GO

------------------------------------------------------------
-- 5) Each sale with previous sale amount (by SaleDate)
------------------------------------------------------------
SELECT SaleID, SaleDate, SaleAmount,
       LAG(SaleAmount) OVER (ORDER BY SaleDate, SaleID) AS PrevSaleAmount
FROM dbo.ProductSales
ORDER BY SaleDate, SaleID;
GO

------------------------------------------------------------
-- 6) Sales greater than previous sale’s amount (global)
------------------------------------------------------------
WITH x AS (
  SELECT *, LAG(SaleAmount) OVER (ORDER BY SaleDate, SaleID) AS PrevAmt
  FROM dbo.ProductSales
)
SELECT SaleID, SaleDate, SaleAmount, PrevAmt
FROM x
WHERE PrevAmt IS NOT NULL AND SaleAmount > PrevAmt
ORDER BY SaleDate, SaleID;
GO

------------------------------------------------------------
-- 7) Difference from previous sale (per product)
------------------------------------------------------------
SELECT ProductName, SaleID, SaleDate, SaleAmount,
       (SaleAmount - LAG(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate, SaleID)) AS DiffFromPrev
FROM dbo.ProductSales
ORDER BY ProductName, SaleDate, SaleID;
GO

------------------------------------------------------------
-- 8) % change vs NEXT sale (global, by date order)
------------------------------------------------------------
SELECT SaleID, SaleDate, SaleAmount,
       LEAD(SaleAmount) OVER (ORDER BY SaleDate, SaleID) AS NextAmt,
       100.0 * (LEAD(SaleAmount) OVER (ORDER BY SaleDate, SaleID) - SaleAmount)
             / NULLIF(SaleAmount,0) AS PctChangeToNext
FROM dbo.ProductSales
ORDER BY SaleDate, SaleID;
GO

------------------------------------------------------------
-- 9) Ratio current / previous (within same product)
------------------------------------------------------------
SELECT ProductName, SaleID, SaleDate, SaleAmount,
       CAST(SaleAmount AS DECIMAL(18,4))
       / NULLIF(LAG(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate, SaleID),0) AS RatioToPrev
FROM dbo.ProductSales
ORDER BY ProductName, SaleDate, SaleID;
GO

------------------------------------------------------------
-- 10) Difference from the very first sale of that product
------------------------------------------------------------
SELECT ProductName, SaleID, SaleDate, SaleAmount,
       SaleAmount
       - FIRST_VALUE(SaleAmount) OVER (
           PARTITION BY ProductName ORDER BY SaleDate, SaleID
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
         ) AS DiffFromFirst
FROM dbo.ProductSales
ORDER BY ProductName, SaleDate, SaleID;
GO

------------------------------------------------------------
-- 11) Sales increasing continuously (each > previous) per product
------------------------------------------------------------
WITH s AS (
  SELECT ProductName, SaleID, SaleDate, SaleAmount,
         LAG(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate, SaleID) AS PrevAmt
  FROM dbo.ProductSales
)
SELECT ProductName, SaleID, SaleDate, SaleAmount, PrevAmt
FROM s
WHERE PrevAmt IS NOT NULL AND SaleAmount > PrevAmt
ORDER BY ProductName, SaleDate, SaleID;
GO

------------------------------------------------------------
-- 12) Running total (“closing balance”) of sale amounts (global)
------------------------------------------------------------
SELECT SaleID, SaleDate, SaleAmount,
       SUM(SaleAmount) OVER (ORDER BY SaleDate, SaleID
                             ROWS UNBOUNDED PRECEDING) AS RunningTotal
FROM dbo.ProductSales
ORDER BY SaleDate, SaleID;
GO

------------------------------------------------------------
-- 13) Moving average of last 3 sales (global)
------------------------------------------------------------
SELECT SaleID, SaleDate, SaleAmount,
       AVG(CAST(SaleAmount AS DECIMAL(18,4))) OVER (
           ORDER BY SaleDate, SaleID
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS MovingAvg3
FROM dbo.ProductSales
ORDER BY SaleDate, SaleID;
GO

------------------------------------------------------------
-- 14) Difference from global average sale amount
------------------------------------------------------------
SELECT SaleID, ProductName, SaleDate, SaleAmount,
       (SaleAmount - AVG(SaleAmount) OVER ()) AS DiffFromAvg
FROM dbo.ProductSales
ORDER BY SaleDate, SaleID;
GO


/* ==========================================================================================
   Employees1 windows
   ========================================================================================== */

------------------------------------------------------------
-- A) Employees who share the same salary rank (ties shown)
------------------------------------------------------------
WITH r AS (
  SELECT *,
         DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank,
         COUNT(*) OVER (PARTITION BY Salary)      AS SameSalaryCount
  FROM dbo.Employees1
)
SELECT EmployeeID, Name, Department, Salary, SalaryRank
FROM r
WHERE SameSalaryCount > 1
ORDER BY SalaryRank, Department, Name;
GO

------------------------------------------------------------
-- B) Top 2 highest salaries in each department (dense)
------------------------------------------------------------
WITH r AS (
  SELECT *,
         DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS rk
  FROM dbo.Employees1
)
SELECT Department, EmployeeID, Name, Salary
FROM r
WHERE rk <= 2
ORDER BY Department, rk, Salary DESC, Name;
GO

------------------------------------------------------------
-- C) Lowest-paid employee(s) in each department (ties kept)
------------------------------------------------------------
WITH r AS (
  SELECT *,
         DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary ASC) AS rk
  FROM dbo.Employees1
)
SELECT Department, EmployeeID, Name, Salary
FROM r
WHERE rk = 1
ORDER BY Department, Name;
GO

------------------------------------------------------------
-- D) Running total of salaries in each department (ordered by HireDate)
------------------------------------------------------------
SELECT Department, EmployeeID, Name, HireDate, Salary,
       SUM(Salary) OVER (PARTITION BY Department
                         ORDER BY HireDate, EmployeeID
                         ROWS UNBOUNDED PRECEDING) AS DeptRunningTotal
FROM dbo.Employees1
ORDER BY Department, HireDate, EmployeeID;
GO

------------------------------------------------------------
-- E) Total salary of each department WITHOUT GROUP BY
------------------------------------------------------------
SELECT Department, EmployeeID, Name, Salary,
       SUM(Salary) OVER (PARTITION BY Department) AS DeptTotalSalary
FROM dbo.Employees1
ORDER BY Department, EmployeeID;
GO

------------------------------------------------------------
-- F) Average salary in each department WITHOUT GROUP BY
------------------------------------------------------------
SELECT Department, EmployeeID, Name, Salary,
       AVG(Salary) OVER (PARTITION BY Department) AS DeptAvgSalary
FROM dbo.Employees1
ORDER BY Department, EmployeeID;
GO

------------------------------------------------------------
-- G) Difference between employee salary and department average
------------------------------------------------------------
SELECT Department, EmployeeID, Name, Salary,
       Salary - AVG(Salary) OVER (PARTITION BY Department) AS DiffVsDeptAvg
FROM dbo.Employees1
ORDER BY Department, EmployeeID;
GO

------------------------------------------------------------
-- H) Moving average salary over 3 employees (current, prev, next) per dept
------------------------------------------------------------
SELECT Department, EmployeeID, Name, HireDate, Salary,
       AVG(CAST(Salary AS DECIMAL(18,4))) OVER (
           PARTITION BY Department
           ORDER BY HireDate, EmployeeID
           ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ) AS DeptMovingAvg3
FROM dbo.Employees1
ORDER BY Department, HireDate, EmployeeID;
GO

------------------------------------------------------------
-- I) Sum of salaries for the last 3 hired employees (overall)
------------------------------------------------------------
WITH r AS (
  SELECT *,
         ROW_NUMBER() OVER (ORDER BY HireDate DESC, EmployeeID DESC) AS rn
  FROM dbo.Employees1
)
SELECT SUM(Salary) AS SumLast3Hires
FROM r
WHERE rn <= 3;
GO

