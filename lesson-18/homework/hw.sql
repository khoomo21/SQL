SET NOCOUNT ON;

---------------------------------------------------------------------------------------------------
-- ДАНО: таблицы Products, Sales уже созданы и заполнены (из условия)
-- Если нужно — раскомментируй, чтобы гарантированно быть в чистом контексте:
-- USE YourDatabaseName;
-- GO
---------------------------------------------------------------------------------------------------

/* ================================================================================================
   1) TEMP TABLE: #MonthlySales — продажи за текущий месяц
   Return: ProductID, TotalQuantity, TotalRevenue
================================================================================================ */
IF OBJECT_ID('tempdb..#MonthlySales') IS NOT NULL DROP TABLE #MonthlySales;
CREATE TABLE #MonthlySales (
    ProductID     INT         NOT NULL PRIMARY KEY,
    TotalQuantity INT         NOT NULL,
    TotalRevenue  DECIMAL(18,2) NOT NULL
);

INSERT INTO #MonthlySales (ProductID, TotalQuantity, TotalRevenue)
SELECT
    s.ProductID,
    SUM(s.Quantity)                                           AS TotalQuantity,
    SUM(s.Quantity * p.Price)                                 AS TotalRevenue
FROM dbo.Sales AS s
JOIN dbo.Products AS p ON p.ProductID = s.ProductID
WHERE s.SaleDate >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
  AND s.SaleDate <  DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
GROUP BY s.ProductID;

SELECT * FROM #MonthlySales ORDER BY ProductID;
GO

/* ================================================================================================
   2) VIEW: vw_ProductSalesSummary — инфо о продукте + общий объём продаж за всё время
   Return: ProductID, ProductName, Category, TotalQuantitySold
================================================================================================ */
IF OBJECT_ID('dbo.vw_ProductSalesSummary', 'V') IS NOT NULL DROP VIEW dbo.vw_ProductSalesSummary;
GO
CREATE VIEW dbo.vw_ProductSalesSummary
AS
SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    ISNULL(SUM(s.Quantity), 0) AS TotalQuantitySold
FROM dbo.Products AS p
LEFT JOIN dbo.Sales AS s ON s.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName, p.Category;
GO

-- Быстрый просмотр
SELECT * FROM dbo.vw_ProductSalesSummary ORDER BY ProductID;
GO

/* ================================================================================================
   3) SCALAR FUNCTION: fn_GetTotalRevenueForProduct(@ProductID)
   Return: DECIMAL(18,2) — общая выручка по продукту
================================================================================================ */
IF OBJECT_ID('dbo.fn_GetTotalRevenueForProduct', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_GetTotalRevenueForProduct;
GO
CREATE FUNCTION dbo.fn_GetTotalRevenueForProduct(@ProductID INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @rev DECIMAL(18,2);
    SELECT @rev = SUM(s.Quantity * p.Price)
    FROM dbo.Sales s
    JOIN dbo.Products p ON p.ProductID = s.ProductID
    WHERE s.ProductID = @ProductID;
    RETURN ISNULL(@rev, 0);
END
GO

-- Пример вызова:
-- SELECT dbo.fn_GetTotalRevenueForProduct(1) AS TotalRevenueFor_1;
GO

/* ================================================================================================
   4) INLINE TVF: fn_GetSalesByCategory(@Category)
   Return: ProductName, TotalQuantity, TotalRevenue
================================================================================================ */
IF OBJECT_ID('dbo.fn_GetSalesByCategory', 'IF') IS NOT NULL DROP FUNCTION dbo.fn_GetSalesByCategory;
GO
CREATE FUNCTION dbo.fn_GetSalesByCategory(@Category VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.ProductName,
        ISNULL(SUM(s.Quantity), 0)               AS TotalQuantity,
        ISNULL(SUM(s.Quantity * p.Price), 0.00)  AS TotalRevenue
    FROM dbo.Products p
    LEFT JOIN dbo.Sales s ON s.ProductID = p.ProductID
    WHERE p.Category = @Category
    GROUP BY p.ProductName
);
GO

-- Пример:
-- SELECT * FROM dbo.fn_GetSalesByCategory('Electronics') ORDER BY TotalRevenue DESC;
GO

/* ================================================================================================
   5) SCALAR FUNCTION: fn_IsPrime(@Number) → 'Yes' / 'No'
================================================================================================ */
IF OBJECT_ID('dbo.fn_IsPrime', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_IsPrime;
GO
CREATE FUNCTION dbo.fn_IsPrime (@Number INT)
RETURNS VARCHAR(3)
AS
BEGIN
    IF (@Number IS NULL OR @Number <= 1) RETURN 'No';
    IF (@Number IN (2,3)) RETURN 'Yes';
    IF (@Number % 2 = 0) RETURN 'No';

    DECLARE @i INT = 3;
    WHILE (@i * @i) <= @Number
    BEGIN
        IF (@Number % @i = 0) RETURN 'No';
        SET @i += 2; -- только нечётные делители
    END
    RETURN 'Yes';
END
GO

-- Примеры:
-- SELECT dbo.fn_IsPrime(2) AS P2, dbo.fn_IsPrime(9) AS P9, dbo.fn_IsPrime(97) AS P97;
GO

/* ================================================================================================
   6) TVF: fn_GetNumbersBetween(@Start, @End) — возвращает все целые из диапазона (включительно)
   (мульти-стейтмент, чтобы избежать лимита MAXRECURSION в функциях)
================================================================================================ */
IF OBJECT_ID('dbo.fn_GetNumbersBetween', 'TF') IS NOT NULL DROP FUNCTION dbo.fn_GetNumbersBetween;
GO
CREATE FUNCTION dbo.fn_GetNumbersBetween(@Start INT, @End INT)
RETURNS @t TABLE (Number INT NOT NULL)
AS
BEGIN
    DECLARE @a INT = @Start, @b INT = @End, @cur INT;

    -- если диапазон задан наоборот — меняем
    IF (@a > @b)
    BEGIN
        DECLARE @tmp INT = @a; SET @a = @b; SET @b = @tmp;
    END

    SET @cur = @a;
    WHILE @cur <= @b
    BEGIN
        INSERT INTO @t(Number) VALUES (@cur);
        SET @cur += 1;
    END
    RETURN;
END
GO

-- Пример:
-- SELECT * FROM dbo.fn_GetNumbersBetween(5, 12);
GO

/* ================================================================================================
   7) N-я по величине уникальная зарплата (или NULL, если distinct < N)
   Пример запроса с параметром @N; ожидается таблица Employee(id, salary)
================================================================================================ */
-- Демо-параметр:
DECLARE @N INT = 2; -- поменяй на нужный N

WITH DistinctS AS (
    SELECT DISTINCT salary
    FROM Employee
),
Ranked AS (
    SELECT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rk
    FROM DistinctS
)
SELECT
    (SELECT salary FROM Ranked WHERE rk = @N) AS HighestNSalary;
GO

/* ================================================================================================
   8) Кто имеет больше всего друзей (Friendship взаимная)
   Таблица: RequestAccepted(requester_id, accepter_id, accept_date)
================================================================================================ */
-- Пример решения (вернёт ровно одного победителя, как в условии):
WITH AllEdges AS (
    SELECT requester_id AS id, accepter_id AS friend_id FROM RequestAccepted
    UNION ALL
    SELECT accepter_id  AS id, requester_id AS friend_id FROM RequestAccepted
),
Deg AS (
    SELECT id, COUNT(DISTINCT friend_id) AS num
    FROM AllEdges
    GROUP BY id
)
SELECT TOP (1) id, num
FROM Deg
ORDER BY num DESC, id ASC;
GO

/* ================================================================================================
   9) VIEW: vw_CustomerOrderSummary (Customers, Orders)
   Columns: customer_id, name, total_orders, total_amount, last_order_date
================================================================================================ */
IF OBJECT_ID('dbo.vw_CustomerOrderSummary', 'V') IS NOT NULL DROP VIEW dbo.vw_CustomerOrderSummary;
GO
CREATE VIEW dbo.vw_CustomerOrderSummary
AS
SELECT
    c.customer_id,
    c.name,
    COUNT(o.order_id)                             AS total_orders,
    ISNULL(SUM(o.amount), 0.00)                   AS total_amount,
    MAX(o.order_date)                             AS last_order_date
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders    AS o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name;
GO

-- Быстрый просмотр сводки
SELECT * FROM dbo.vw_CustomerOrderSummary ORDER BY customer_id;
GO

