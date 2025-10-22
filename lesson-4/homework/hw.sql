/* ONE FILE: Easy + Medium T-SQL snippets
   Optionally uncomment and set DB:
   -- USE YourDatabaseName;
   -- GO
*/
SET NOCOUNT ON;

/* =========================
   🟢 EASY-LEVEL TASKS (10)
   ========================= */

-- 1) Top 5 employees
SELECT TOP (5) *
FROM dbo.Employees;
GO

-- 2) DISTINCT Category from Products
SELECT DISTINCT Category
FROM dbo.Products;
GO

-- 3) Products with Price > 100
SELECT *
FROM dbo.Products
WHERE Price > 100;
GO

-- 4) Customers with FirstName starting with 'A'
SELECT *
FROM dbo.Customers
WHERE FirstName LIKE 'A%';
GO

-- 5) Products ordered by Price ASC
SELECT *
FROM dbo.Products
ORDER BY Price ASC;
GO

-- 6) Employees with Salary >= 60000 AND DepartmentName = 'HR'
SELECT *
FROM dbo.Employees
WHERE Salary >= 60000
  AND DepartmentName = 'HR';
GO

-- 7) ISNULL for Email (display only); to persist, use the UPDATE below
SELECT EmpID, Name, ISNULL(Email, 'noemail@example.com') AS Email
FROM dbo.Employees;
-- UPDATE dbo.Employees SET Email = ISNULL(Email, 'noemail@example.com') WHERE Email IS NULL;
GO

-- 8) Products with Price BETWEEN 50 AND 100 (inclusive)
SELECT *
FROM dbo.Products
WHERE Price BETWEEN 50 AND 100;
GO

-- 9) DISTINCT on (Category, ProductName)
SELECT DISTINCT Category, ProductName
FROM dbo.Products;
GO

-- 10) DISTINCT on (Category, ProductName) + ORDER BY ProductName DESC
SELECT DISTINCT Category, ProductName
FROM dbo.Products
ORDER BY ProductName DESC;
GO


/* =========================
   🟠 MEDIUM-LEVEL TASKS (listed 9)
   ========================= */

-- 1) Top 10 products ordered by Price DESC
SELECT TOP (10) *
FROM dbo.Products
ORDER BY Price DESC;
GO

-- 2) COALESCE: first non-NULL of FirstName or LastName
SELECT EmpID,
       COALESCE(FirstName, LastName) AS DisplayName
FROM dbo.Employees;
GO

-- 3) DISTINCT Category and Price
SELECT DISTINCT Category, Price
FROM dbo.Products;
GO

-- 4) Employees: (Age BETWEEN 30 AND 40) OR DepartmentName = 'Mark

