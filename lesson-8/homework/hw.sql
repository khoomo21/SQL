/* ============================================================
   lesson-8 Practice — SQL Server (case-insensitive by default)
   ============================================================ */

SET NOCOUNT ON;

---------------------------------------------------------------
-- EASY-LEVEL TASKS
---------------------------------------------------------------

-- 1) кол-во продуктов в каждой категории (Products)
SELECT Category, COUNT(*) AS ProductCount
FROM dbo.Products
GROUP BY Category;
GO

-- 2) средняя цена в категории 'Electronics'
SELECT AVG(CAST(Price AS DECIMAL(18,2))) AS AvgPrice_Electronics
FROM dbo.Products
WHERE Category = 'Electronics';
GO

-- 3) клиенты из городов, начинающихся на 'L' (Customers)
SELECT *
FROM dbo.Customers
WHERE City LIKE 'L%';
GO

-- 4) продукты, чьи имена заканчиваются на 'er'
SELECT ProductName
FROM dbo.Products
WHERE ProductName LIKE '%er';
GO

-- 5) клиенты из стран, заканчивающихся на 'A'
SELECT *
FROM dbo.Customers
WHERE Country LIKE '%A';
GO

-- 6) максимальная цена среди всех продуктов
SELECT MAX(Price) AS MaxProductPrice
FROM dbo.Products;
GO

-- 7) ярлык по остаткам: Low/Sufficient
SELECT ProductID, ProductName, StockQuantity,
       CASE WHEN StockQuantity < 30 THEN 'Low Stock' ELSE 'Sufficient' END AS StockLabel
FROM dbo.Products;
GO

-- 8) кол-во клиентов по странам
SELECT Country, COUNT(*) AS CustomerCount
FROM dbo.Customers
GROUP BY Country;
GO

-- 9) мин/макс количество в заказах (Orders)
SELECT MIN(Quantity) AS MinQty, MAX(Quantity) AS MaxQty
FROM dbo.Orders;
GO


---------------------------------------------------------------
-- MEDIUM-LEVEL TASKS
---------------------------------------------------------------

-- 1) клиенты, кто сделал заказ в янв 2023, но не имеет счета-фактуры в янв 2023 (Orders vs Invoices)
SELECT DISTINCT o.CustomerID
FROM dbo.Orders   AS o
WHERE o.OrderDate >= '2023-01-01'
  AND o.OrderDate <  '2023-02-01'
  AND NOT EXISTS (
        SELECT 1
        FROM dbo.Invoices AS i
        WHERE i.CustomerID = o.CustomerID
          AND i.InvoiceDate >= '2023-01-01'
          AND i.InvoiceDate <  '2023-02-01'
  );
GO

-- 2) объединить имена продуктов из Products и Products_Discounted, сохраняя дубликаты
SELECT ProductName FROM dbo.Products
UNION ALL
SELECT ProductName FROM dbo.Products_Discounted;
GO

-- 3) объединить имена продуктов без дубликатов
SELECT ProductName FROM dbo.Products
UNION
SELECT ProductName FROM dbo.Products_Discounted;
GO

-- 4) средняя сумма заказа по годам (Orders)
-- предполагается колонка OrderAmount
SELECT YEAR(OrderDate) AS OrderYear,
       AVG(CAST(OrderAmount AS DECIMAL(18,2))) AS AvgOrderAmount
FROM dbo.Orders
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear;
GO

-- 5) группировка продуктов по цене: Low/Mid/High (Products)
SELECT ProductName,
       CASE
           WHEN Price < 100 THEN 'Low'
           WHEN Price BETWEEN 100 AND 500 THEN 'Mid'
           ELSE 'High'
       END AS PriceGroup
FROM dbo.Products;
GO

-- 6) PIVOT: годы в отдельные колонки -> сохранить в Population_Each_Year
-- City_Population(City, Year, Population)
IF OBJECT_ID('dbo.Population_Each_Year', 'U') IS NOT NULL DROP TABLE dbo.Population_Each_Year;
SELECT City, [2012], [2013]
INTO dbo.Population_Each_Year
FROM (
    SELECT City, [Year], Population
    FROM dbo.City_Population
) AS src
PIVOT (
    SUM(Population) FOR [Year] IN ([2012], [2013])
) AS p;
-- проверка
SELECT * FROM dbo.Population_Each_Year;
GO

-- 7) сумма продаж по продукту (Sales)
-- предполагается колонка Amount; если её нет, замени на (Quantity*UnitPrice)
SELECT ProductID,
       SUM(Amount) AS TotalSales
FROM dbo.Sales
GROUP BY ProductID
ORDER BY ProductID;
GO

-- 8) продукты, где в имени есть 'oo'
SELECT ProductName
FROM dbo.Products
WHERE ProductName LIKE '%oo%';
GO

-- 9) PIVOT: города в отдельные колонки -> сохранить в Population_Each_City
-- столбцы: Bektemir, Chilonzor, Yakkasaroy
IF OBJECT_ID('dbo.Population_Each_City', 'U') IS NOT NULL DROP TABLE dbo.Population_Each_City;
SELECT [Year], [Bektemir], [Chilonzor], [Yakkasaroy]
INTO dbo.Population_Each_City
FROM (
    SELECT [Year], City, Population
    FROM dbo.City_Population
) AS src
PIVOT (
    SUM(Population) FOR City IN ([Bektemir], [Chilonzor], [Yakkasaroy])
) AS p;
-- проверка
SELECT * FROM dbo.Population_Each_City;
GO

