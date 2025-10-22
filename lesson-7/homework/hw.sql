/* ============================================================
   🟢 EASY-LEVEL TASKS (10)
   ============================================================ */

-- 1) MIN цена продукта (Products)
SELECT MIN(Price) AS MinPrice
FROM dbo.Products;
GO

-- 2) MAX зарплата (Employees)
SELECT MAX(Salary) AS MaxSalary
FROM dbo.Employees;
GO

-- 3) количество строк в Customers
SELECT COUNT(*) AS CustomerCount
FROM dbo.Customers;
GO

-- 4) число уникальных категорий в Products
SELECT COUNT(DISTINCT Category) AS DistinctCategoryCount
FROM dbo.Products;
GO

-- 5) общая сумма продаж по продукту id = 7 (Sales)
-- Вариант A: если есть Amount (сумма строки)
SELECT SUM(Amount) AS TotalSales_Product7
FROM dbo.Sales
WHERE ProductID = 7;

-- Вариант B: если Amount нет, но есть Quantity и UnitPrice
-- SELECT SUM(Quantity * UnitPrice) AS TotalSales_Product7
-- FROM dbo.Sales
-- WHERE ProductID = 7;
GO

-- 6) средний возраст сотрудников
SELECT AVG(CAST(Age AS DECIMAL(10,2))) AS AvgAge
FROM dbo.Employees;
GO

-- 7) число сотрудников по департаментам
-- Если у тебя DeptID:
SELECT DeptID, COUNT(*) AS EmpCount
FROM dbo.Employees
GROUP BY DeptID;

-- Если у тебя DepartmentName:
-- SELECT DepartmentName, COUNT(*) AS EmpCount
-- FROM dbo.Employees
-- GROUP BY DepartmentName;
GO

-- 8) мин/макс цена по категории (Products)
SELECT Category,
       MIN(Price) AS MinPrice,
       MAX(Price) AS MaxPrice
FROM dbo.Products
GROUP BY Category;
GO

-- 9) общие продажи по каждому клиенту (Sales)
-- Вариант A: есть Amount
SELECT CustomerID, SUM(Amount) AS TotalSales
FROM dbo.Sales
GROUP BY CustomerID;

-- Вариант B: нет Amount
-- SELECT CustomerID, SUM(Quantity * UnitPrice) AS TotalSales
-- FROM dbo.Sales
-- GROUP BY CustomerID;
GO

-- 10) департаменты, где сотрудников > 5
-- (достаточно DeptID)
SELECT DeptID
FROM dbo.Employees
GROUP BY DeptID
HAVING COUNT(*) > 5;
GO


/* ============================================================
   🟠 MEDIUM-LEVEL TASKS (9)
   ============================================================ */

-- 1) общая и средняя продажа по категории (Sales + Products)
-- Вариант A: есть Amount
SELECT p.Category,
       SUM(s.Amount)                           AS TotalSales,
       AVG(CAST(s.Amount AS DECIMAL(18,2)))    AS AvgSales
FROM dbo.Sales s
JOIN dbo.Products p ON p.ProductID = s.ProductID
GROUP BY p.Category;

-- Вариант B: нет Amount
-- SELECT p.Category,
--        SUM(s.Quantity * s.UnitPrice)                        AS TotalSales,
--        AVG(CAST(s.Quantity * s.UnitPrice AS DECIMAL(18,2))) AS AvgSales
-- FROM dbo.Sales s
-- JOIN dbo.Products p ON p.ProductID = s.ProductID
-- GROUP BY p.Category;
GO

-- 2) число сотрудников в департаменте HR
-- (если текстовый DepartmentName)
SELECT COUNT(*) AS HrCount
FROM dbo.Employees
WHERE DepartmentName = 'HR';

-- Если только DeptID, подставь нужный:
-- SELECT COUNT(*) FROM dbo.Employees WHERE DeptID = 10;
GO

-- 3) максимальная и минимальная зарплата по департаментам
SELECT DeptID,
       MAX(Salary) AS MaxSalary,
       MIN(Salary) AS MinSalary
FROM dbo.Employees
GROUP BY DeptID;
GO

-- 4) средняя зарплата по департаментам
SELECT DeptID,
       AVG(CAST(Salary AS DECIMAL(18,2))) AS AvgSalary
FROM dbo.Employees
GROUP BY DeptID;
GO

-- 5) AVG зарплата и COUNT сотрудников по департаментам
SELECT DeptID,
       AVG(CAST(Salary AS DECIMAL(18,2))) AS AvgSalary,
       COUNT(*)                            AS EmpCount
FROM dbo.Employees
GROUP BY DeptID;
GO

-- 6) категории с средней ценой > 400 (Products)
SELECT Category
FROM dbo.Products
GROUP BY Category
HAVING AVG(CAST(Price AS DECIMAL(18,2))) > 400;
GO

-- 7) общие продажи по годам (Sales)
-- Требуется дата заказа, напр. OrderDate
-- Вариант A: Amount есть
SELECT YEAR(OrderDate) AS SalesYear,
       SUM(Amount)     AS TotalSales
FROM dbo.Sales
GROUP BY YEAR(OrderDate)
ORDER BY SalesYear;

-- Вариант B: без Amount
-- SELECT YEAR(OrderDate) AS SalesYear,
--        SUM(Quantity * UnitPrice) AS TotalSales
-- FROM dbo.Sales
-- GROUP BY YEAR(OrderDate)
-- ORDER BY SalesYear;
GO

-- 8) клиенты, оформившие минимум 3 заказа
-- Вариант A: есть OrderID
SELECT CustomerID
FROM dbo.Sales
GROUP BY CustomerID
HAVING COUNT(DISTINCT OrderID) >= 3;

-- Вариант B: без OrderID (считаем строки)
-- SELECT CustomerID
-- FROM dbo.Sales
-- GROUP BY CustomerID
-- HAVING COUNT(*) >= 3;
GO

-- 9) департаменты с средней зарплатной нагрузкой > 60000
-- (достаточно DeptID)
SELECT DeptID
FROM dbo.Employees
GROUP BY DeptID
HAVING AVG(CAST(Salary AS DECIMAL(18,2))) > 60000;
GO
