/* =====================================
   🟢 EASY-LEVEL TASKS
   ===================================== */

-- 1) alias для колонки: ProductName AS Name
SELECT ProductID, ProductName AS [Name], Price
FROM dbo.Products;
GO

-- 2) alias для таблицы Customers как Client
SELECT c.*
FROM dbo.Customers AS c;   -- c = "Client"
GO

-- 3) UNION: ProductName из Products и Products_Discounted (уникальные строки)
SELECT ProductName FROM dbo.Products
UNION
SELECT ProductName FROM dbo.Products_Discounted;
GO

-- 4) INTERSECT: пересечение ProductName между двумя таблицами
SELECT ProductName FROM dbo.Products
INTERSECT
SELECT ProductName FROM dbo.Products_Discounted;
GO

-- 5) DISTINCT: уникальные имена клиентов + страна
-- подставь свои поля: если у тебя FirstName/LastName — собери ФИО.
SELECT DISTINCT
       COALESCE(NULLIF(LTRIM(RTRIM(
           CASE
               WHEN COL_LENGTH('dbo.Customers','CustomerName') IS NOT NULL
               THEN CustomerName
               ELSE CONCAT(ISNULL(FirstName,''),' ',ISNULL(LastName,''))
           END
       )), ''), '(no name)') AS CustomerName,
       Country
FROM dbo.Customers;
GO

-- 6) CASE: флаг цены ('High' > 1000, иначе 'Low')
SELECT ProductID, ProductName, Price,
       CASE WHEN Price > 1000 THEN 'High' ELSE 'Low' END AS PriceBand
FROM dbo.Products;
GO

-- 7) IIF: 'Yes' если StockQuantity > 100, иначе 'No' (Products_Discounted)
SELECT ProductName,
       IIF(StockQuantity > 100, 'Yes', 'No') AS InStock100Plus
FROM dbo.Products_Discounted;
GO


/* =====================================
   🟠 MEDIUM-LEVEL TASKS
   ===================================== */

-- 1) (повтор) UNION: ProductName из обеих таблиц
SELECT ProductName FROM dbo.Products
UNION
SELECT ProductName FROM dbo.Products_Discounted;
GO

-- 2) EXCEPT: что есть в Products, но НЕТ в Products_Discounted
SELECT ProductName FROM dbo.Products
EXCEPT
SELECT ProductName FROM dbo.Products_Discounted;
GO

-- 3) IIF: 'Expensive' если Price > 1000, иначе 'Affordable'
SELECT ProductID, ProductName, Price,
       IIF(Price > 1000, 'Expensive', 'Affordable') AS PriceClass
FROM dbo.Products;
GO

-- 4) сотрудники: Age < 25 ИЛИ Salary > 60000
SELECT *
FROM dbo.Employees
WHERE Age < 25
   OR Salary > 60000;
GO

-- 5) повысить зарплату на 10% для HR ИЛИ для EmployeeID = 5
-- внимание: меняет данные.
UPDATE dbo.Employees
SET Salary = Salary * 1.10
WHERE DepartmentName = 'HR'
   OR EmployeeID = 5;
GO

