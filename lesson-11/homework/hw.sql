SET NOCOUNT ON;

------------------------------------------------------------
-- 🟢 EASY-LEVEL (7)
------------------------------------------------------------

-- 1) Orders after 2022 with customer names
-- Return: OrderID, CustomerName, OrderDate
SELECT o.OrderID, c.CustomerName, o.OrderDate
FROM dbo.Orders    AS o
JOIN dbo.Customers AS c ON c.CustomerID = o.CustomerID
WHERE o.OrderDate > '2022-12-31';
GO

-- 2) Employees in Sales or Marketing
-- Return: EmployeeName, DepartmentName
SELECT e.EmployeeName, d.DepartmentName
FROM dbo.Employees   AS e
JOIN dbo.Departments AS d ON d.DeptID = e.DeptID
WHERE d.DepartmentName IN ('Sales', 'Marketing');
GO

-- 3) Max salary per department
-- Return: DepartmentName, MaxSalary
SELECT d.DepartmentName, MAX(e.Salary) AS MaxSalary
FROM dbo.Departments AS d
JOIN dbo.Employees   AS e ON e.DeptID = d.DeptID
GROUP BY d.DepartmentName;
GO

-- 4) USA customers with orders in 2023
-- Return: CustomerName, OrderID, OrderDate
SELECT c.CustomerName, o.OrderID, o.OrderDate
FROM dbo.Customers AS c
JOIN dbo.Orders    AS o ON o.CustomerID = c.CustomerID
WHERE c.Country = 'USA'
  AND o.OrderDate >= '2023-01-01'
  AND o.OrderDate <  '2024-01-01';
GO

-- 5) Orders count per customer
-- Return: CustomerName, TotalOrders
SELECT c.CustomerName, COUNT(o.OrderID) AS TotalOrders
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerName;
GO

-- 6) Products supplied by specific suppliers
-- Return: ProductName, SupplierName
SELECT p.ProductName, s.SupplierName
FROM dbo.Products  AS p
JOIN dbo.Suppliers AS s ON s.SupplierID = p.SupplierID
WHERE s.SupplierName IN ('Gadget Supplies', 'Clothing Mart');
GO

-- 7) Most recent order per customer (include customers with no orders)
-- Return: CustomerName, MostRecentOrderDate
SELECT c.CustomerName, MAX(o.OrderDate) AS MostRecentOrderDate
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerName;
GO


------------------------------------------------------------
-- 🟠 MEDIUM-LEVEL (6)
------------------------------------------------------------

-- 1) Customers with any order where total > 500
-- Return: CustomerName, OrderTotal
SELECT c.CustomerName, o.TotalAmount AS OrderTotal
FROM dbo.Orders    AS o
JOIN dbo.Customers AS c ON c.CustomerID = o.CustomerID
WHERE o.TotalAmount > 500;
GO

-- 2) Product sales in 2022 OR amount > 400
-- Return: ProductName, SaleDate, SaleAmount
SELECT p.ProductName, s.SaleDate, s.SaleAmount
FROM dbo.Sales    AS s
JOIN dbo.Products AS p ON p.ProductID = s.ProductID
WHERE (s.SaleDate >= '2022-01-01' AND s.SaleDate < '2023-01-01')
   OR s.SaleAmount > 400;
GO

-- 3) Total sales amount per product
-- Return: ProductName, TotalSalesAmount
SELECT p.ProductName, SUM(s.SaleAmount) AS TotalSalesAmount
FROM dbo.Products AS p
LEFT JOIN dbo.Sales AS s ON s.ProductID = p.ProductID
GROUP BY p.ProductName;
GO

-- 4) HR employees with Salary > 60000
-- Return: EmployeeName, DepartmentName, Salary
SELECT e.EmployeeName, d.DepartmentName, e.Salary
FROM dbo.Employees   AS e
JOIN dbo.Departments AS d ON d.DeptID = e.DeptID
WHERE d.DepartmentName = 'HR'
  AND e.Salary > 60000;
GO

-- 5) Products sold in 2023 with stock > 100 (assumes Products.StockQuantity)
-- Return: ProductName, SaleDate, StockQuantity
SELECT DISTINCT p.ProductName, s.SaleDate, p.StockQuantity
FROM dbo.Sales    AS s
JOIN dbo.Products AS p ON p.ProductID = s.ProductID
WHERE s.SaleDate >= '2023-01-01'
  AND s.SaleDate <  '2024-01-01'
  AND p.StockQuantity > 100;
GO

-- 6) Employees in Sales OR hired after 2020
-- Return: EmployeeName, DepartmentName, HireDate
SELECT e.EmployeeName, d.DepartmentName, e.HireDate
FROM dbo.Employees   AS e
LEFT JOIN dbo.Departments AS d ON d.DeptID = e.DeptID
WHERE d.DepartmentName = 'Sales'
   OR e.HireDate >= '2021-01-01';
GO

