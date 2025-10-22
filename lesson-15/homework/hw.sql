SET NOCOUNT ON;

------------------------------------------------------------
-- Level 1: Basic Subqueries
------------------------------------------------------------

-- 1) Employees with minimum salary
SELECT e.*
FROM employees AS e
WHERE e.salary = (SELECT MIN(salary) FROM employees);
GO

-- 2) Products priced above the average
SELECT p.*
FROM products AS p
WHERE p.price > (SELECT AVG(price) FROM products);
GO


------------------------------------------------------------
-- Level 2: Nested Subqueries with Conditions
------------------------------------------------------------

-- 3) Employees in "Sales" department
SELECT e.*
FROM employees AS e
WHERE e.department_id IN (
  SELECT d.id FROM departments AS d WHERE d.department_name = 'Sales'
);
GO

-- 4) Customers with NO orders
SELECT c.*
FROM customers AS c
WHERE NOT EXISTS (
  SELECT 1 FROM orders AS o WHERE o.customer_id = c.customer_id
);
GO


------------------------------------------------------------
-- Level 3: Aggregation and Grouping in Subqueries
------------------------------------------------------------

-- 5) Products with MAX price in each category
SELECT p.*
FROM products AS p
WHERE p.price = (
  SELECT MAX(p2.price)
  FROM products AS p2
  WHERE p2.category_id = p.category_id
);
GO

-- 6) Employees in the department with the HIGHEST average salary
SELECT e.*
FROM employees AS e
WHERE e.department_id IN (
  SELECT TOP (1) WITH TIES department_id
  FROM employees
  GROUP BY department_id
  ORDER BY AVG(salary) DESC
);
GO


------------------------------------------------------------
-- Level 4: Correlated Subqueries
------------------------------------------------------------

-- 7) Employees earning ABOVE their department average
SELECT e.*
FROM employees AS e
WHERE e.salary > (
  SELECT AVG(e2.salary)
  FROM employees AS e2
  WHERE e2.department_id = e.department_id
);
GO

-- 8) Students with the HIGHEST grade per course
SELECT s.name, g.course_id, g.grade
FROM grades  AS g
JOIN students AS s ON s.student_id = g.student_id
WHERE g.grade = (
  SELECT MAX(g2.grade)
  FROM grades AS g2
  WHERE g2.course_id = g.course_id
);
GO


------------------------------------------------------------
-- Level 5: Subqueries with Ranking and Complex Conditions
------------------------------------------------------------

-- 9) Products with the THIRD-HIGHEST (distinct) price per category
-- (ровно две БОЛЬШЕ отличные цены в той же категории)
SELECT p.*
FROM products AS p
WHERE 2 = (
  SELECT COUNT(DISTINCT p2.price)
  FROM products AS p2
  WHERE p2.category_id = p.category_id
    AND p2.price > p.price
);
GO

