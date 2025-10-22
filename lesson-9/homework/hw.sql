
/* ============================================================
   🟢 EASY (10 puzzles)
   ============================================================ */
SET NOCOUNT ON;

-- 1) Products × Suppliers: all combinations (cartesian)
SELECT p.ProductName, s.SupplierName
FROM dbo.Products AS p
CROSS JOIN dbo.Suppliers AS s;
GO

-- 2) Departments × Employees: all combinations (cartesian)
SELECT d.DepartmentName, e.EmployeeName
FROM dbo.Departments AS d
CROSS JOIN dbo.Employees   AS e;
GO

-- 3) Supplier actually supplies product
SELECT s.SupplierName, p.ProductName
FROM dbo.Products  AS p
JOIN dbo.Suppliers AS s ON s.SupplierID = p.SupplierID;
GO

-- 4) Customers and their order IDs
SELECT c.CustomerName, o.OrderID
FROM dbo.Orders    AS o
JOIN dbo.Customers AS c ON c.CustomerID = o.CustomerID;
GO

-- 5) Students × Courses: all combinations
SELECT st.StudentName, c.CourseName
FROM dbo.Students AS st
CROSS JOIN dbo.Courses  AS c;
GO

-- 6) Products × Orders where IDs match
SELECT p.ProductName, o.OrderID
FROM dbo.Orders   AS o
JOIN dbo.Products AS p ON p.ProductID = o.ProductID;
GO

-- 7) Employees whose DepartmentID matches a department
SELECT e.EmployeeName, d.DepartmentName, e.DeptID
FROM dbo.Employees   AS e
JOIN dbo.Departments AS d ON d.DeptID = e.DeptID;
GO

-- 8) Student names and their enrolled course IDs
SELECT st.StudentName, en.CourseID
FROM dbo.Enrollments AS en
JOIN dbo.Students    AS st ON st.StudentID = en.StudentID;
GO

-- 9) Orders that have matching payments
SELECT DISTINCT o.OrderID
FROM dbo.Orders   AS o
JOIN dbo.Payments AS p ON p.OrderID = o.OrderID;
GO

-- 10) Orders where product price > 100
SELECT o.OrderID, p.ProductName, p.Price
FROM dbo.Orders   AS o
JOIN dbo.Products AS p ON p.ProductID = o.ProductID
WHERE p.Price > 100;
GO


/* ============================================================
   🟡 MEDIUM (10 puzzles)
   ============================================================ */

-- 1) Mismatched employee-department combos (IDs not equal)
-- all pairs where e.DeptID <> d.DeptID
SELECT e.EmployeeName, e.DeptID AS EmpDeptID, d.DepartmentName, d.DeptID AS DeptID
FROM dbo.Employees   AS e
CROSS JOIN dbo.Departments AS d
WHERE e.DeptID <> d.DeptID;
GO

-- 2) Orders where ordered qty > stock qty
-- assumes Orders.Quantity, Products.StockQuantity
SELECT o.OrderID, p.ProductName, o.Quantity, p.StockQuantity
FROM dbo.Orders   AS o
JOIN dbo.Products AS p ON p.ProductID = o.ProductID
WHERE o.Quantity > p.StockQuantity;
GO

-- 3) Customer names and ProductIDs where sale amount >= 500
-- assumes Sales(CustomerID, ProductID, Amount)
SELECT c.CustomerName, s.ProductID, s.Amount
FROM dbo.Sales     AS s
JOIN dbo.Customers AS c ON c.CustomerID = s.CustomerID
WHERE s.Amount >= 500;
GO

-- 4) Student names and course names they’re enrolled in
SELECT st.StudentName, c.CourseName
FROM dbo.Enrollments AS en
JOIN dbo.Students    AS st ON st.StudentID = en.StudentID
JOIN dbo.Courses     AS c  ON c.CourseID  = en.CourseID;
GO

-- 5) Products & Suppliers where supplier name contains 'Tech'
SELECT p.ProductName, s.SupplierName
FROM dbo.Products  AS p
JOIN dbo.Suppliers AS s ON s.SupplierID = p.SupplierID
WHERE s.SupplierName LIKE '%Tech%';
GO

-- 6) Orders where payment amount < total amount
-- assumes Orders.TotalAmount; Payments may have multiple rows per order -> sum them
WITH PayPerOrder AS (
    SELECT p.OrderID, SUM(p.Amount) AS PaidAmount
    FROM dbo.Payments AS p
    GROUP BY p.OrderID
)
SELECT o.OrderID, o.TotalAmount, ISNULL(pp.PaidAmount, 0) AS PaidAmount
FROM dbo.Orders AS o
LEFT JOIN PayPerOrder AS pp ON pp.OrderID = o.OrderID
WHERE ISNULL(pp.PaidAmount, 0) < o.TotalAmount;
GO

-- 7) Department Name for each employee
SELECT e.EmployeeName, d.DepartmentName
FROM dbo.Employees   AS e
LEFT JOIN dbo.Departments AS d ON d.DeptID = e.DeptID;
GO

-- 8) Products in categories 'Electronics' or 'Furniture'
SELECT p.ProductName, p.CategoryID, c.CategoryName
FROM dbo.Products  AS p
LEFT JOIN dbo.Categories AS c ON c.CategoryID = p.CategoryID
WHERE (c.CategoryName IN ('Electronics', 'Furniture'))
   OR (p.CategoryID IN (
        SELECT CategoryID FROM dbo.Categories WHERE CategoryName IN ('Electronics','Furniture')
      ));
/* If Products already has CategoryName directly:
-- WHERE p.Category IN ('Electronics','Furniture');
*/
GO

-- 9) All sales from customers who are from 'USA'
SELECT s.*
FROM dbo.Sales     AS s
JOIN dbo.Customers AS c ON c.CustomerID = s.CustomerID
WHERE c.Country = 'USA';
GO

-- 10) Orders made by customers from 'Germany' with order total > 100
SELECT o.OrderID, o.TotalAmount, c.CustomerName
FROM dbo.Orders    AS o
JOIN dbo.Customers AS c ON c.CustomerID = o.CustomerID
WHERE c.Country = 'Germany'
  AND o.TotalAmount > 100;
GO
