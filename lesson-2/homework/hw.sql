
/* =========================
   BASIC-LEVEL TASKS (10)
   ========================= */

-- 1) Create table Employees
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL DROP TABLE dbo.Employees;
GO
CREATE TABLE dbo.Employees (
    EmpID   INT         NOT NULL PRIMARY KEY,
    Name    VARCHAR(50) NOT NULL,
    Salary  DECIMAL(10,2) NOT NULL
);
GO

-- 2) Insert three records using different approaches

-- (a) Single-row INSERT
INSERT INTO dbo.Employees (EmpID, Name, Salary)
VALUES (1, 'Alice', 5000.00);

-- (b) Multi-row VALUES
INSERT INTO dbo.Employees (EmpID, Name, Salary)
VALUES (2, 'Bob', 6200.50),
       (3, 'Cara', 4800.00);

-- (c) INSERT...SELECT (from a VALUES table constructor)
INSERT INTO dbo.Employees (EmpID, Name, Salary)
SELECT v.EmpID, v.Name, v.Salary
FROM (VALUES (4, 'Dan', 5500.00)) AS v(EmpID, Name, Salary);
GO

-- 3) Update Salary of EmpID = 1 to 7000
UPDATE dbo.Employees
SET Salary = 7000.00
WHERE EmpID = 1;
GO

-- 4) Delete record where EmpID = 2
DELETE FROM dbo.Employees
WHERE EmpID = 2;
GO

/* 5) Brief definition:
   DELETE   = removes rows; can filter with WHERE; logged row-by-row; keeps structure; identity not reset.
   TRUNCATE = removes ALL rows; minimal logging; cannot use WHERE; resets identity; blocked if FK references exist.
   DROP     = removes the OBJECT itself (table/schema/DB); structure and data are gone.
*/

-- 6) Modify Name column to VARCHAR(100)
ALTER TABLE dbo.Employees
ALTER COLUMN Name VARCHAR(100) NOT NULL;
GO

-- 7) Add Department column (VARCHAR(50))
ALTER TABLE dbo.Employees
ADD Department VARCHAR(50) NULL;
GO

-- 8) Change Salary data type to FLOAT
ALTER TABLE dbo.Employees
ALTER COLUMN Salary FLOAT NOT NULL;
GO

-- 9) Create Departments table
IF OBJECT_ID('dbo.Departments', 'U') IS NOT NULL DROP TABLE dbo.Departments;
GO
CREATE TABLE dbo.Departments (
    DepartmentID   INT          NOT NULL PRIMARY KEY,
    DepartmentName VARCHAR(50)  NOT NULL
);
GO

-- 10) Remove all records from Employees without deleting structure
-- (Use TRUNCATE when there are no FK constraints referencing Employees)
TRUNCATE TABLE dbo.Employees;
GO


/* =========================
   INTERMEDIATE-LEVEL TASKS (6)
   ========================= */

-- 1) Insert five records into Departments using INSERT INTO ... SELECT
INSERT INTO dbo.Departments (DepartmentID, DepartmentName)
SELECT d.DepartmentID, d.DepartmentName
FROM (VALUES
    (1, 'HR'),
    (2, 'IT'),
    (3, 'Finance'),
    (4, 'Operations'),
    (5, 'Management')
) AS d(DepartmentID, DepartmentName);
GO

-- Re-seed Employees with some rows so the next steps make sense
INSERT INTO dbo.Employees (EmpID, Name, Salary, Department)
VALUES (1, 'Alice', 7000.00, NULL),
       (3, 'Cara', 4800.00, NULL),
       (4, 'Dan', 5500.00, NULL);
GO

-- 2) Update Department of all employees where Salary > 5000 to 'Management'
UPDATE dbo.Employees
SET Department = 'Management'
WHERE Salary > 5000;
GO

-- 3) Remove all employees but keep the table structure intact
-- (Either TRUNCATE if allowed, or DELETE with no WHERE if FKs block truncation)
TRUNCATE TABLE dbo.Employees;
-- Alternative if TRUNCATE is not allowed:
-- DELETE FROM dbo.Employees;
GO

-- 4) Drop the Department column from Employees
ALTER TABLE dbo.Employees
DROP COLUMN Department;
GO

-- 5) Rename Employees table to StaffMembers
EXEC sp_rename 'dbo.Employees', 'StaffMembers';
GO

-- 6) Completely remove the Departments table
DROP TABLE dbo.Departments;
GO
