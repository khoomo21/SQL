SET NOCOUNT ON;

------------------------------------------------------------
-- EASY
------------------------------------------------------------

-- 1) Рекурсивная numbers 1..1000
WITH nums AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM nums WHERE n < 1000
)
SELECT n FROM nums
OPTION (MAXRECURSION 1000);
GO

-- 2) Total sales per employee (derived table)  (Sales, Employees)
SELECT e.EmployeeID, e.FirstName, e.LastName, sAgg.TotalSales
FROM dbo.Employees e
JOIN (
    SELECT EmployeeID, SUM(SalesAmount) AS TotalSales
    FROM dbo.Sales
    GROUP BY EmployeeID
) AS sAgg
  ON sAgg.EmployeeID = e.EmployeeID
ORDER BY sAgg.TotalSales DESC;
GO

-- 3) CTE: средняя зарплата (Employees)
WITH avg_sal AS (
    SELECT AVG(CAST(Salary AS DECIMAL(18,2))) AS AvgSalary
    FROM dbo.Employees
)
SELECT AvgSalary FROM avg_sal;
GO

-- 4) Derived table: максимальная продажа по каждому продукту (Sales, Products)
SELECT p.ProductID, p.ProductName, x.MaxSale
FROM dbo.Products p
JOIN (
    SELECT ProductID, MAX(SalesAmount) AS MaxSale
    FROM dbo.Sales
    GROUP BY ProductID
) AS x
  ON x.ProductID = p.ProductID
ORDER BY p.ProductID;
GO

-- 5) Рекурсивно удваиваем начиная с 1, пока < 1_000_000
WITH dbl AS (
    SELECT CAST(1 AS BIGINT) AS v
    UNION ALL
    SELECT v * 2 FROM dbl WHERE v * 2 < 1000000
)
SELECT v FROM dbl
OPTION (MAXRECURSION 1000);
GO

-- 6) CTE: сотрудники, совершившие > 5 продаж (кол-во строк в Sales)
WITH s AS (
    SELECT EmployeeID, COUNT(*) AS SalesCnt
    FROM dbo.Sales
    GROUP BY EmployeeID
)
SELECT e.EmployeeID, e.FirstName, e.LastName, s.SalesCnt
FROM s
JOIN dbo.Employees e ON e.EmployeeID = s.EmployeeID
WHERE s.SalesCnt > 5
ORDER BY s.SalesCnt DESC;
GO

-- 7) CTE: продукты с суммой продаж > $500 (Sales, Products)
WITH sp AS (
    SELECT ProductID, SUM(SalesAmount) AS TotalSales
    FROM dbo.Sales
    GROUP BY ProductID
)
SELECT p.ProductID, p.ProductName, sp.TotalSales
FROM sp
JOIN dbo.Products p ON p.ProductID = sp.ProductID
WHERE sp.TotalSales > 500
ORDER BY sp.TotalSales DESC;
GO

-- 8) CTE: сотрудники с зарплатой выше среднего (Employees)
WITH avg_s AS (SELECT AVG(CAST(Salary AS DECIMAL(18,2))) AS AvgSal FROM dbo.Employees)
SELECT e.*
FROM dbo.Employees e
CROSS JOIN avg_s a
WHERE e.Salary > a.AvgSal
ORDER BY e.Salary DESC;
GO


------------------------------------------------------------
-- MEDIUM
------------------------------------------------------------

-- 1) Derived: top-5 по количеству заказов (Employees, Sales)
SELECT TOP (5)
       e.EmployeeID, e.FirstName, e.LastName,
       o.OrdersCnt
FROM dbo.Employees e
JOIN (
    SELECT EmployeeID, COUNT(*) AS OrdersCnt
    FROM dbo.Sales
    GROUP BY EmployeeID
) AS o ON o.EmployeeID = e.EmployeeID
ORDER BY o.OrdersCnt DESC, e.EmployeeID;
GO

-- 2) Derived: продажи по категориям (Sales, Products)
SELECT p.CategoryID, SUM(s.SalesAmount) AS TotalSales
FROM dbo.Sales s
JOIN dbo.Products p ON p.ProductID = s.ProductID
GROUP BY p.CategoryID
ORDER BY p.CategoryID;
GO

-- 3) Факториал для каждого Number рядом (Numbers1)
-- Numbers1(Number INT) уже создана в условии
WITH f AS (
    SELECT Number, CAST(1 AS BIGINT) AS fact, 1 AS i
    FROM dbo.Numbers1
    UNION ALL
    SELECT Number,
           fact * (i + 1),
           i + 1
    FROM f
    WHERE i < Number
)
SELECT Number, MAX(fact) AS Factorial
FROM f
GROUP BY Number
ORDER BY Number
OPTION (MAXRECURSION 32767);
GO

-- 4) Рекурсивно: разбить строку на символы по строкам (Example)
-- Example(Id, String)
WITH r AS (
    SELECT Id, String, 1 AS pos, SUBSTRING(String,1,1) AS ch
    FROM dbo.Example
    UNION ALL
    SELECT Id, String, pos+1, SUBSTRING(String,pos+1,1)
    FROM r
    WHERE pos+1 <= LEN(String)
)
SELECT Id, pos, ch
FROM r
ORDER BY Id, pos
OPTION (MAXRECURSION 32767);
GO

-- 5) CTE: разница продаж текущий месяц vs предыдущий (Sales)
WITH m AS (
    SELECT
        DATEFROMPARTS(YEAR(SaleDate), MONTH(SaleDate), 1) AS MonthStart,
        SUM(SalesAmount) AS MonthTotal
    FROM dbo.Sales
    GROUP BY DATEFROMPARTS(YEAR(SaleDate), MONTH(SaleDate), 1)
)
SELECT MonthStart,
       MonthTotal,
       MonthTotal - LAG(MonthTotal) OVER (ORDER BY MonthStart) AS DiffFromPrev
FROM m
ORDER BY MonthStart;
GO

-- 6) Derived: сотрудники с продажами > 45000 в каждом квартале
-- Считаем по кварталам 2025 (подстрой, если нужно)
WITH q AS (
    SELECT
        s.EmployeeID,
        CONVERT(char(7), DATEFROMPARTS(YEAR(SaleDate), ((DATEPART(QUARTER, SaleDate)-1)*3)+1, 1), 120) AS QStart,
        DATEPART(YEAR, SaleDate) AS Y,
        DATEPART(QUARTER, SaleDate) AS Q,
        SUM(s.SalesAmount) AS QSales
    FROM dbo.Sales s
    GROUP BY s.EmployeeID,
             DATEPART(YEAR, SaleDate),
             DATEPART(QUARTER, SaleDate)
)
SELECT EmployeeID, Y, Q, QSales
FROM q
WHERE QSales > 45000
ORDER BY EmployeeID, Y, Q;
GO


------------------------------------------------------------
-- DIFFICULT
------------------------------------------------------------

-- 1) Рекурсивный Fibonacci (первые N=30)
WITH fib AS (
    SELECT 1 AS n, CAST(0 AS BIGINT) AS a, CAST(1 AS BIGINT) AS b
    UNION ALL
    SELECT n+1, b, a+b
    FROM fib
    WHERE n < 30
)
SELECT n, a AS FibValue
FROM fib
ORDER BY n
OPTION (MAXRECURSION 32767);
GO

-- 2) Найти строки, где все символы одинаковые и длина > 1 (FindSameCharacters)
-- FindSameCh

