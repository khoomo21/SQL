
SET NOCOUNT ON;

---------------------------------------------------------------------------------------------------
-- PART 1 — Stored Procedures
---------------------------------------------------------------------------------------------------

-- Setup (как в условии)
IF OBJECT_ID('dbo.Employees','U') IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID('dbo.DepartmentBonus','U') IS NOT NULL DROP TABLE dbo.DepartmentBonus;
GO
CREATE TABLE dbo.Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName  NVARCHAR(50),
    LastName   NVARCHAR(50),
    Department NVARCHAR(50),
    Salary     DECIMAL(10,2)
);
CREATE TABLE dbo.DepartmentBonus (
    Department      NVARCHAR(50) PRIMARY KEY,
    BonusPercentage DECIMAL(5,2)
);
INSERT INTO dbo.Employees VALUES
(1,'John','Doe','Sales',5000),
(2,'Jane','Smith','Sales',5200),
(3,'Mike','Brown','IT',6000),
(4,'Anna','Taylor','HR',4500);
INSERT INTO dbo.DepartmentBonus VALUES
('Sales',10),('IT',15),('HR',8);
GO

-- Task 1: proc, которая создаёт #EmployeeBonus, заполняет и возвращает
IF OBJECT_ID('dbo.sp_BuildEmployeeBonus','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_BuildEmployeeBonus;
GO
CREATE PROCEDURE dbo.sp_BuildEmployeeBonus
AS
BEGIN
    SET NOCOUNT ON;
    IF OBJECT_ID('tempdb..#EmployeeBonus') IS NOT NULL DROP TABLE #EmployeeBonus;

    CREATE TABLE #EmployeeBonus (
        EmployeeID  INT        NOT NULL,
        FullName    NVARCHAR(120) NOT NULL,
        Department  NVARCHAR(50)  NOT NULL,
        Salary      DECIMAL(10,2) NOT NULL,
        BonusAmount DECIMAL(10,2) NOT NULL
    );

    INSERT INTO #EmployeeBonus (EmployeeID, FullName, Department, Salary, BonusAmount)
    SELECT e.EmployeeID,
           CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
           e.Department,
           e.Salary,
           CAST(e.Salary * (b.BonusPercentage/100.0) AS DECIMAL(10,2)) AS BonusAmount
    FROM dbo.Employees e
    JOIN dbo.DepartmentBonus b ON b.Department = e.Department;

    SELECT * FROM #EmployeeBonus ORDER BY EmployeeID;
END
GO
-- Пример запуска:
-- EXEC dbo.sp_BuildEmployeeBonus;

-- Task 2: proc — повысить зарплаты департамента на X% и вернуть обновлённых
IF OBJECT_ID('dbo.sp_IncreaseSalaryByDepartment','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_IncreaseSalaryByDepartment;
GO
CREATE PROCEDURE dbo.sp_IncreaseSalaryByDepartment
    @Department   NVARCHAR(50),
    @IncreasePct  DECIMAL(6,3)  -- например 7.5 = +7.5%
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Employees
    SET Salary = CAST(Salary * (1 + @IncreasePct/100.0) AS DECIMAL(10,2))
    WHERE Department = @Department;

    SELECT EmployeeID, FirstName, LastName, Department, Salary
    FROM dbo.Employees
    WHERE Department = @Department
    ORDER BY EmployeeID;
END
GO
-- Пример:
-- EXEC dbo.sp_IncreaseSalaryByDepartment @Department='Sales', @IncreasePct=5;


---------------------------------------------------------------------------------------------------
-- PART 2 — MERGE
---------------------------------------------------------------------------------------------------

-- Setup (как в условии)
IF OBJECT_ID('dbo.Products_Current','U') IS NOT NULL DROP TABLE dbo.Products_Current;
IF OBJECT_ID('dbo.Products_New','U')     IS NOT NULL DROP TABLE dbo.Products_New;
GO
CREATE TABLE dbo.Products_Current (
    ProductID   INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    Price       DECIMAL(10,2)
);
CREATE TABLE dbo.Products_New (
    ProductID   INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    Price       DECIMAL(10,2)
);
INSERT INTO dbo.Products_Current VALUES
(1,'Laptop',1200),(2,'Tablet',600),(3,'Smartphone',800);
INSERT INTO dbo.Products_New VALUES
(2,'Tablet Pro',700),(3,'Smartphone',850),(4,'Smartwatch',300);
GO

-- Task 3: MERGE (update match, insert new, delete missing)
MERGE dbo.Products_Current AS T
USING dbo.Products_New     AS S
   ON T.ProductID = S.ProductID
WHEN MATCHED THEN
    UPDATE SET T.ProductName = S.ProductName,
               T.Price       = S.Price
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ProductID, ProductName, Price)
    VALUES (S.ProductID, S.ProductName, S.Price)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE
OUTPUT $action AS MergeAction, inserted.*, deleted.*;
-- Финальное состояние:
SELECT * FROM dbo.Products_Current ORDER BY ProductID;
GO


---------------------------------------------------------------------------------------------------
-- Task 4: Tree Node (Root / Inner / Leaf)
---------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.Tree','U') IS NOT NULL DROP TABLE dbo.Tree;
GO
CREATE TABLE dbo.Tree (id INT PRIMARY KEY, p_id INT NULL);
INSERT INTO dbo.Tree (id, p_id) VALUES
(1, NULL),(2,1),(3,1),(4,2),(5,2);

SELECT
    t.id,
    CASE
        WHEN t.p_id IS NULL THEN 'Root'
        WHEN NOT EXISTS (SELECT 1 FROM dbo.Tree ch WHERE ch.p_id = t.id) THEN 'Leaf'
        ELSE 'Inner'
    END AS type
FROM dbo.Tree AS t
ORDER BY t.id;
GO


---------------------------------------------------------------------------------------------------
-- Task 5: Confirmation Rate
-- (ENUM заменим на NVARCHAR(10) для SQL Server)
---------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.Signups','U') IS NOT NULL DROP TABLE dbo.Signups;
IF OBJECT_ID('dbo.Confirmations','U') IS NOT NULL DROP TABLE dbo.Confirmations;
GO
CREATE TABLE dbo.Signups (
    user_id    INT PRIMARY KEY,
    time_stamp DATETIME
);
CREATE TABLE dbo.Confirmations (
    user_id    INT,
    time_stamp DATETIME,
    action     NVARCHAR(10) CHECK (action IN ('confirmed','timeout'))
);
INSERT INTO dbo.Signups (user_id, time_stamp) VALUES
(3,'2020-03-21 10:16:13'),(7,'2020-01-04 13:57:59'),
(2,'2020-07-29 23:09:44'),(6,'2020-12-09 10:39:37');
INSERT INTO dbo.Confirmations (user_id, time_stamp, action) VALUES
(3,'2021-01-06 03:30:46','timeout'),
(3,'2021-07-14 14:00:00','timeout'),
(7,'2021-06-12 11:57:29','confirmed'),
(7,'2021-06-13 12:58:28','confirmed'),
(7,'2021-06-14 13:59:27','confirmed'),
(2,'2021-01-22 00:00:00','confirmed'),
(2,'2021-02-28 23:59:59','timeout');

WITH C AS (
    SELECT user_id,
           COUNT(*)                           AS total_req,
           SUM(CASE WHEN action='confirmed' THEN 1 ELSE 0 END) AS confirmed_cnt
    FROM dbo.Confirmations
    GROUP BY user_id
)
SELECT s.user_id,
       CAST(COALESCE(1.0 * c.confirmed_cnt / NULLIF(c.total_req,0), 0.0) AS DECIMAL(4,2)) AS confirmation_rate
FROM dbo.Signups s
LEFT JOIN C c ON c.user_id = s.user_id
ORDER BY s.user_id;  -- порядок не важен для проверки
GO
