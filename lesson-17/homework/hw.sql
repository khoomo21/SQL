SET NOCOUNT ON;

------------------------------------------------------------
-- 1) Все дистрибьюторы × регионы, нули там, где нет продаж
--    (#RegionSales уже создан и заполнен из условия)
------------------------------------------------------------
WITH R AS (SELECT DISTINCT Region FROM #RegionSales),
     D AS (SELECT DISTINCT Distributor FROM #RegionSales),
     RD AS (
       SELECT R.Region, D.Distributor
       FROM R CROSS JOIN D
     )
SELECT RD.Region,
       RD.Distributor,
       ISNULL(S.Sales, 0) AS Sales
FROM RD
LEFT JOIN #RegionSales AS S
  ON S.Region = RD.Region AND S.Distributor = RD.Distributor
ORDER BY RD.Region, RD.Distributor;
GO


------------------------------------------------------------
-- 2) Менеджеры с >= 5 прямых подчинённых (Employee из условия)
------------------------------------------------------------
SELECT e.name
FROM Employee AS e
JOIN (
    SELECT managerId, COUNT(*) AS cnt
    FROM Employee
    WHERE managerId IS NOT NULL
    GROUP BY managerId
    HAVING COUNT(*) >= 5
) AS x
  ON x.managerId = e.id;
GO


------------------------------------------------------------
-- 3) Продукты с суммой единиц ≥ 100 в феврале 2020 (Products, Orders)
------------------------------------------------------------
SELECT p.product_name,
       SUM(o.unit) AS unit
FROM Products AS p
JOIN Orders   AS o ON o.product_id = p.product_id
WHERE o.order_date >= '2020-02-01' AND o.order_date < '2020-03-01'
GROUP BY p.product_name
HAVING SUM(o.unit) >= 100
ORDER BY p.product_name;
GO


------------------------------------------------------------
-- 4) Для каждого CustomerID — вендор с наибольшим числом заказов (Orders)
------------------------------------------------------------
WITH Cnt AS (
  SELECT CustomerID, Vendor, COUNT(*) AS OrdersCnt
  FROM Orders
  GROUP BY CustomerID, Vendor
),
Ranked AS (
  SELECT CustomerID, Vendor, OrdersCnt,
         ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrdersCnt DESC, Vendor) AS rn
  FROM Cnt
)
SELECT CustomerID, Vendor
FROM Ranked
WHERE rn = 1
ORDER BY CustomerID;
GO


------------------------------------------------------------
-- 5) Проверка простого числа в @Check_Prime (WHILE)
------------------------------------------------------------
DECLARE @Check_Prime INT = 91;  -- поменяй при необходимости
DECLARE @i INT = 2, @isPrime BIT = 1;

IF @Check_Prime <= 1 SET @isPrime = 0;
WHILE @isPrime = 1 AND @i * @i <= @Check_Prime
BEGIN
    IF (@Check_Prime % @i = 0) SET @isPrime = 0;
    SET @i += 1;
END

SELECT CASE WHEN @isPrime = 1 THEN 'This number is prime'
            ELSE 'This number is not prime' END AS Result;
GO


------------------------------------------------------------
-- 6) По устройствам: кол-во локаций, наиболее «сигнальная» локация,
--    всего сигналов (Device)
------------------------------------------------------------
WITH ByLoc AS (
  SELECT Device_id, Locations, COUNT(*) AS SignalsAtLoc
  FROM Device
  GROUP BY Device_id, Locations
),
Agg AS (
  SELECT Device_id,
         COUNT(*)                      AS no_of_location,        -- distinct locations
         SUM(SignalsAtLoc)             AS no_of_signals
  FROM ByLoc
  GROUP BY Device_id
),
Pick AS (
  SELECT b.Device_id, b.Locations,
         b.SignalsAtLoc,
         ROW_NUMBER() OVER (PARTITION BY b.Device_id ORDER BY b.SignalsAtLoc DESC, b.Locations) AS rn
  FROM ByLoc AS b
)
SELECT a.Device_id,
       a.no_of_location,
       p.Locations AS max_signal_location,
       a.no_of_signals
FROM Agg AS a
JOIN Pick AS p ON p.Device_id = a.Device_id AND p.rn = 1
ORDER BY a.Device_id;
GO


------------------------------------------------------------
-- 7) Сотрудники с зарплатой >= среднего по их департаменту
--    (возвращаем EmpID, EmpName, Salary)
------------------------------------------------------------
SELECT e.EmpID, e.EmpName, e.Salary
FROM Employee AS e
JOIN (
  SELECT DeptID, AVG(Salary) AS AvgSal
  FROM Employee
  GROUP BY DeptID
) AS a ON a.DeptID = e.DeptID
WHERE e.Salary >= a.AvgSal
ORDER BY e.EmpID;
GO


------------------------------------------------------------
-- 8) Лотерея: сумма выигрышей (Numbers = winning, Tickets)
--    3 совпадения = $100; 1–2 совпадения = $10; иначе $0
------------------------------------------------------------
WITH MatchPerTicket AS (
  SELECT t.TicketID, COUNT(*) AS match_cnt
  FROM Tickets AS t
  JOIN Numbers AS n ON n.Number = t.Number
  GROUP BY t.TicketID
),
Prize AS (
  SELECT TicketID,
         CASE WHEN match_cnt = 3 THEN 100
              WHEN match_cnt BETWEEN 1 AND 2 THEN 10
              ELSE 0 END AS prize
  FROM MatchPerTicket
)
SELECT SUM(prize) AS TotalWinnings
FROM Prize;
GO

