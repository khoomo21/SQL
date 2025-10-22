
/* ============================================================
1) Combine Two Tables (LEFT JOIN Person -> Address)
   Expected: firstName, lastName, city, state (NULL if no address)
============================================================ */

-- Sample setup from prompt
IF OBJECT_ID('dbo.Person','U') IS NOT NULL DROP TABLE dbo.Person;
IF OBJECT_ID('dbo.Address','U') IS NOT NULL DROP TABLE dbo.Address;
GO
CREATE TABLE Person (personId INT, firstName VARCHAR(255), lastName VARCHAR(255));
CREATE TABLE Address (addressId INT, personId INT, city VARCHAR(255), state VARCHAR(255));
TRUNCATE TABLE Person;
INSERT INTO Person (personId, lastName, firstName) VALUES (1,'Wang','Allen'), (2,'Alice','Bob');
TRUNCATE TABLE Address;
INSERT INTO Address (addressId, personId, city, state) VALUES (1,2,'New York City','New York'),
                                                             (2,3,'Leetcode','California');
GO

-- Solution
SELECT p.firstName,
       p.lastName,
       a.city,
       a.state
FROM dbo.Person  AS p
LEFT JOIN dbo.Address AS a
  ON a.personId = p.personId;
GO


/* ============================================================
2) Employees Earning More Than Their Managers (self-join)
   Expected: Employee (name)
============================================================ */

-- Sample setup from prompt
IF OBJECT_ID('dbo.Employee','U') IS NOT NULL DROP TABLE dbo.Employee;
GO
CREATE TABLE Employee (id INT, name VARCHAR(255), salary INT, managerId INT);
TRUNCATE TABLE Employee;
INSERT INTO Employee (id, name, salary, managerId) VALUES
(1,'Joe',70000,3),
(2,'Henry',80000,4),
(3,'Sam',60000,NULL),
(4,'Max',90000,NULL);
GO

-- Solution
SELECT e.name AS Employee
FROM dbo.Employee AS e
JOIN dbo.Employee AS m
  ON e.managerId = m.id
WHERE e.salary > m.salary;
GO


/* ============================================================
3) Duplicate Emails
   Expected: Email (all that appear more than once)
============================================================ */

-- Sample setup from prompt
IF OBJECT_ID('dbo.PersonEmails','U') IS NOT NULL DROP TABLE dbo.PersonEmails;
GO
CREATE TABLE PersonEmails (id INT, email VARCHAR(255));
TRUNCATE TABLE PersonEmails;
INSERT INTO PersonEmails (id, email) VALUES
(1,'a@b.com'), (2,'c@d.com'), (3,'a@b.com');
GO

-- Solution
SELECT email AS Email
FROM dbo.PersonEmails
GROUP BY email
HAVING COUNT(*) > 1;
GO


/* ============================================================
4) Delete Duplicate Emails (keep smallest id per email)
   Write a DELETE (not SELECT)
============================================================ */

-- Example table Person (id,email). Create fresh demo:
IF OBJECT_ID('dbo.PersonDedup','U') IS NOT NULL DROP TABLE dbo.PersonDedup;
GO
CREATE TABLE PersonDedup (id INT, email VARCHAR(255));
INSERT INTO PersonDedup(id,email) VALUES
(1,'john@example.com'), (2,'bob@example.com'), (3,'john@example.com');

;WITH d AS (
  SELECT id, email,
         ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS rn
  FROM dbo.PersonDedup
)
DELETE FROM d WHERE rn > 1;

-- Check result:
SELECT * FROM dbo.PersonDedup;
GO


/* ============================================================
5) Find parents who have ONLY girls (return ParentName only)
   boys(Id,name,ParentName), girls(Id,name,ParentName)
============================================================ */

IF OBJECT_ID('dbo.boys','U') IS NOT NULL DROP TABLE dbo.boys;
IF OBJECT_ID('dbo.girls','U') IS NOT NULL DROP TABLE dbo.girls;
GO
CREATE TABLE boys  (Id INT PRIMARY KEY, name VARCHAR(100), ParentName VARCHAR(100));
CREATE TABLE girls (Id INT PRIMARY KEY, name VARCHAR(100), ParentName VARCHAR(100));

INSERT INTO boys (Id, name, ParentName) VALUES
(1,'John','Michael'), (2,'David','James'), (3,'Alex','Robert'),
(4,'Luke','Michael'), (5,'Ethan','David'), (6,'Mason','George');

INSERT INTO girls (Id, name, ParentName) VALUES
(1,'Emma','Mike'), (2,'Olivia','James'), (3,'Ava','Robert'),
(4,'Sophia','Mike'), (5,'Mia','John'), (6,'Isabella','Emily'),
(7,'Charlotte','George');

-- Parents that appear in girls but never in boys
SELECT DISTINCT g.ParentName
FROM dbo.girls AS g
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.boys AS b WHERE b.ParentName = g.ParentName
);
GO


/* ============================================================
6) Total over 50 and least (TSQL2012 Sales.Orders)
   Task: "Find total Sales amount for orders which weights > 50 for each customer
          along with their least weight."

   Note: TSQL2012's Sales.Orders table has no "weight" column; it DOES have
         'freight' (money) and Sales.OrderDetails with qty, unitprice, discount.
         Below I assume “weight” = Orders.freight.
         Total sales = SUM(qty*unitprice*(1-discount)) per customer.

   Schemas confirmed from the TSQL2012 script (Sales.Orders, Sales.OrderDetails). :contentReference[oaicite:0]{index=0}
============================================================ */

-- Use database TSQL2012 if installed:
-- USE TSQL2012;

WITH OrderAmounts AS (
  SELECT od.orderid,
         SUM(od.qty * od.unitprice * (1 - od.discount)) AS order_amount
  FROM Sales.OrderDetails AS od
  GROUP BY od.orderid
)
SELECT o.custid,
       SUM(oa.order_amount) AS TotalSalesAmount_ForFreightGT50,
       MIN(o.freight)       AS LeastFreightInQualifiedOrders
FROM Sales.Orders AS o
JOIN OrderAmounts  AS oa ON oa.orderid = o.orderid
WHERE o.freight > 50
GROUP BY o.custid
ORDER BY o.custid;
GO


/* ============================================================
7) Carts — align items from Cart1 and Cart2 (FULL OUTER JOIN)
   Expected columns: [Item Cart 1], [Item Cart 2]
============================================================ */

DROP TABLE IF EXISTS dbo.Cart1;
DROP TABLE IF EXISTS dbo.Cart2;
GO
CREATE TABLE dbo.Cart1 (Item VARCHAR(100) PRIMARY KEY);
CREATE TABLE dbo.Cart2 (Item VARCHAR(100) PRIMARY KEY);
INSERT INTO dbo.Cart1(Item) VALUES ('Sugar'),('Bread'),('Juice'),('Soda'),('Flour');
INSERT INTO dbo.Cart2(Item) VALUES ('Sugar'),('Bread'),('Butter'),('Cheese'),('Fruit');

SELECT
  c1.Item AS [Item Cart 1],
  c2.Item AS [Item Cart 2]
FROM dbo.Cart1 AS c1
FULL OUTER JOIN dbo.Cart2 AS c2
  ON c1.Item = c2.Item
ORDER BY
  CASE WHEN c1.Item IS NOT NULL AND c2.Item IS NOT NULL THEN 1
       WHEN c1.Item IS NOT NULL AND c2.Item IS NULL     THEN 2
       ELSE 3 END,
  COALESCE(c1.Item, c2.Item);
GO


/* ============================================================
8) Customers Who Never Order (LEFT JOIN anti-semi)
   Expected: Customers (name)
============================================================ */

-- Sample setup from prompt
IF OBJECT_ID('dbo.Customers','U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.Orders','U')    IS NOT NULL DROP TABLE dbo.Orders;
GO
CREATE TABLE Customers (id INT, name VARCHAR(255));
CREATE TABLE Orders    (id INT, customerId INT);
TRUNCATE TABLE Customers;
INSERT INTO Customers (id, name) VALUES (1,'Joe'),(2,'Henry'),(3,'Sam'),(4,'Max');
TRUNCATE TABLE Orders;
INSERT INTO Orders (id, customerId) VALUES (1,3),(2,1);
GO

-- Solution
SELECT c.name AS Customers
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
  ON o.customerId = c.id
WHERE o.id IS NULL;
GO
