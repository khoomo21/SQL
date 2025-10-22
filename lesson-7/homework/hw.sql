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
-- SELECT SUM(Qua

