SET NOCOUNT ON;

------------------------------------------------------------
-- 🟢 EASY-LEVEL (10)
------------------------------------------------------------

-- 1) сотрудники с Salary > 50000 + название отдела
SELECT e.EmployeeName, e.Salary, d.DepartmentName
FROM dbo.Employees AS e
LEFT JOIN dbo.Departments AS d ON d.DeptID = e.DeptID
WHERE e.Salary > 50000;
GO

-- 2) клиенты и даты заказов в 2023
SELECT c.FirstName, c.LastName, o.OrderDate
FROM dbo.Orders AS o
JOIN dbo.Customers AS c ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= '2023-01-01' AND o.OrderDate < '2024-01-01';
GO

-- 3) все сотрудники + название отдела (включая без отдела)
SELECT e.EmployeeName, d.DepartmentName
FROM dbo.Employees AS e
LEFT JOIN dbo.Departments AS d ON d.DeptID = e.DeptID;
GO

-- 4) все поставщики и их продукты (включая поставщиков без продуктов)
SELECT s.SupplierName, p.ProductName
FROM dbo.Suppliers AS s
LEFT JOIN dbo.Products  AS p ON p.SupplierID = s.SupplierID;
GO

-- 5) все заказы и их платежи, включая «висячие» с любой стороны
SELECT o.OrderID, o.OrderDate, p.PaymentDate, p.Amount
FROM dbo.Orders AS o
FULL OUTER JOIN dbo.Payments AS p ON p.OrderID = o.OrderID;
GO

-- 6) сотрудник + его менеджер (self-join)
SELECT e.EmployeeName,
       m.EmployeeName AS ManagerName
FROM dbo.Employees AS e
LEFT JOIN dbo.Employees AS m ON m.EmployeeID = e.ManagerID;
GO

-- 7) студенты, записанные на 'Math 101'
SELECT s.StudentName, c.CourseName
FROM dbo.Enrollments AS e
JOIN dbo.Students    AS s ON s.StudentID = e.StudentID
JOIN dbo.Courses     AS c ON c.CourseID  = e.CourseID
WHERE c.CourseName = 'Math 101';
GO

-- 8) клиенты, сделавшие заказ с количеством > 3
SELECT c.FirstName, c.LastName, o.Quantity
FROM dbo.Orders AS o
JOIN dbo.Customers AS c ON c.CustomerID = o.CustomerID
WHERE o.Quantity > 3;
GO

-- 9) сотрудники из отдела 'Human Resources'
SELECT e.EmployeeName, d.DepartmentName
FROM dbo.Employees AS e
JOIN dbo.Departments AS d ON d.DeptID = e.DeptID
WHERE d.DepartmentName = 'Human Resources';
GO


------------------------------------------------------------
-- 🟠 MEDIUM-LEVEL (9)
------------------------------------------------------------

-- 1) отделы, где > 5 сотрудников
SELECT d.DepartmentName, COUNT(*) AS EmployeeCount
FROM dbo.Employees   AS e
JOIN dbo.Departments AS d ON d.DeptID = e.DeptID
GROUP BY d.DepartmentName
HAVING COUNT(*) > 5;
GO

-- 2) продукты, которые ни разу не продавались (по Sales)
-- вариант через NOT EXISTS
SELECT p.ProductID, p.ProductName
FROM dbo.Products AS p
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Sales AS s WHERE s.ProductID = p.ProductID
);
GO

-- 3) клиенты, у которых есть хотя бы один заказ + количество заказов
SELECT c.FirstName, c.LastName, COUNT(*) AS TotalOrders
FROM dbo.Customers AS c
JOIN dbo.Orders    AS o ON o.CustomerID = c.CustomerID
GROUP BY c.FirstName, c.LastName;
GO

-- 4) только те записи, где и сотрудник, и отдел существуют (без NULL)
SELECT e.EmployeeName, d.DepartmentName
FROM dbo.Employees   AS e
JOIN dbo.Departments AS d ON d.DeptID = e.DeptID;
GO

-- 5) пары сотрудников с одним менеджером
SELECT e1.EmployeeName AS Employee1,
       e2.EmployeeName AS Employee2,
       e1.ManagerID
FROM dbo.Employees AS e1
JOIN dbo.Employees AS e2
  ON e1.ManagerID = e2.ManagerID
 AND e1.EmployeeID < e2.EmployeeID   -- избежать дубликатов и самосочетаний
WHERE e1.ManagerID IS NOT NULL;
GO

-- 6) заказы 2022 + имя клиента
SELECT o.OrderID, o.OrderDate, c.FirstName, c.LastName
FROM dbo.Orders    AS o
JOIN dbo.Customers AS c ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= '2022-01-01' AND o.OrderDate < '2023-01-01';
GO

-- 7) сотрудники из 'Sales' с Salary > 60000
SELECT e.EmployeeName, e.Salary, d.DepartmentName
FROM dbo.Employees   AS e
JOIN dbo.Departments AS d ON d.DeptID = e.DeptID
WHERE d.DepartmentName = 'Sales'
  AND e.Salary > 60000;
GO

-- 8) только те заказы, у которых есть платеж
SELECT o.OrderID, o.OrderDate, p.PaymentDate, p.Amount
FROM dbo.Orders   AS o
JOIN dbo.Payments AS p ON p.OrderID = o.OrderID;
GO

-- 9) продукты, которые никогда не заказывались (по Orders)
SELECT p.ProductID, p.ProductName
FROM dbo.Products AS p
LEFT JOIN dbo.Orders AS o ON o.ProductID = p.ProductID
WHERE o.ProductID IS NULL;
GO

