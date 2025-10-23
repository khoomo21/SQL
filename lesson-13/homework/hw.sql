ниже — один аккуратный **T-SQL** скрипт для Lesson 13 (строки, математика и немного окон). Вставляй в SSMS и запускай блоками. Всё рассчитано на данные из твоего сетапа выше.

```sql
SET NOCOUNT ON;

------------------------------------------------------------
-- EASY
------------------------------------------------------------

-- 1) "100-Steven King" (EMPLOYEE_ID + '-' + FIRST_NAME + ' ' + LAST_NAME)
SELECT CONCAT(e.EMPLOYEE_ID, '-', e.FIRST_NAME, ' ', e.LAST_NAME) AS EmpString
FROM dbo.Employees AS e
WHERE e.EMPLOYEE_ID = 100;
GO

-- 2) В PHONE_NUMBER заменить подстроку '124' на '999'
UPDATE dbo.Employees
SET PHONE_NUMBER = REPLACE(PHONE_NUMBER, '124', '999');
-- Проверка:
SELECT EMPLOYEE_ID, PHONE_NUMBER FROM dbo.Employees ORDER BY EMPLOYEE_ID;
GO

-- 3) Имя и длина имени для имён на A/J/M, отсортировать по FIRST_NAME
SELECT
  FIRST_NAME                    AS FirstName,
  LEN(FIRST_NAME)               AS FirstNameLength
FROM dbo.Employees
WHERE LEFT(FIRST_NAME, 1) IN ('A','J','M')
ORDER BY FIRST_NAME;
GO

-- 4) Суммарная зарплата по MANAGER_ID
SELECT
  MANAGER_ID,
  SUM(SALARY) AS TotalSalary
FROM dbo.Employees
GROUP BY MANAGER_ID
ORDER BY MANAGER_ID;
GO

-- 5) Для каждой строки TestMax — год и максимальное из (Max1, Max2, Max3)
SELECT
  t.Year1 AS [Year],
  MAX(v.mx) AS Highest
FROM dbo.TestMax AS t
CROSS APPLY (VALUES (t.Max1),(t.Max2),(t.Max3)) AS v(mx)
GROUP BY t.Year1
ORDER BY t.Year1;
GO

-- 6) Фильмы с нечётным id и description <> 'boring'
SELECT id, movie, description, rating
FROM dbo.cinema
WHERE id % 2 = 1
  AND description <> 'boring'
ORDER BY id;
GO

-- 7) Отсортировать SingleOrder по Id, но 0 — всегда последним (одним выражением)
SELECT Id, Vals
FROM dbo.SingleOrder
ORDER BY NULLIF(Id, 0);   -- NULL сортируется в конце в ASC
GO

-- 8) Первый ненулевой идентификатор из набора колонок (ssn, passportid, itin)
SELECT
  id,
  COALESCE(ssn, passportid, itin) AS FirstNonNull
FROM dbo.person
ORDER BY id;
GO


------------------------------------------------------------
-- MEDIUM
------------------------------------------------------------

-- 1) Разбить FullName на First/Middle/Last (3 части)
SELECT
  StudentID,
  FullName,
  LEFT(FullName, CHARINDEX(' ', FullName + ' ') - 1)                             AS FirstName,
  NULLIF(
    SUBSTRING(
      FullName,
      CHARINDEX(' ', FullName + ' ') + 1,
      CHARINDEX(' ', REVERSE(FullName) + ' ') - 1
    ), ''
  )                                                                               AS MiddleName,
  RIGHT(FullName, CHARINDEX(' ', REVERSE(FullName) + ' ') - 1)                    AS LastName
FROM dbo.Students
ORDER BY StudentID;
GO

-- 2) Для клиентов с доставкой в CA — выбрать их заказы, доставленные в TX
SELECT o.*
FROM dbo.Orders AS o
WHERE o.DeliveryState = 'TX'
  AND EXISTS (SELECT 1 FROM dbo.Orders AS ca
              WHERE ca.CustomerID = o.CustomerID AND ca.DeliveryState = 'CA')
ORDER BY o.CustomerID, o.OrderID;
GO

-- 3) Групповая конкатенация из DMLTable по порядку (STRING_AGG)
SELECT STRING_AGG(String, ' ') WITHIN GROUP (ORDER BY SequenceNumber) AS RebuiltText
FROM dbo.DMLTable;
GO

-- 4) Сотрудники, у кого в (FIRST_NAME + LAST_NAME) буква 'a' встречается ≥ 3 раз
SELECT
  EMPLOYEE_ID, FIRST_NAME, LAST_NAME
FROM dbo.Employees
WHERE (
  LEN(LOWER(FIRST_NAME + LAST_NAME))
  - LEN(REPLACE(LOWER(FIRST_NAME + LAST_NAME), 'a', ''))
) >= 3
ORDER BY EMPLOYEE_ID;
GO

-- 5) Число сотрудников по департаменту и % тех, кто работает > 3 лет
SELECT
  DEPARTMENT_ID,
  COUNT(*) AS EmpCount,
  CAST(100.0 * SUM(CASE WHEN DATEDIFF(year, HIRE_DATE, GETDATE()) >= 3 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2))
    AS PctOver3Years
FROM dbo.Employees
GROUP BY DEPARTMENT_ID
ORDER BY DEPARTMENT_ID;
GO


------------------------------------------------------------
-- DIFFICULT
------------------------------------------------------------

-- 1) Заменить значение строки суммой её значения и всех предыдущих (running sum)
-- (Показываю как выборку; если нужно “перезаписать”, обычно делают через staging)
SELECT
  StudentID, FullName, Grade,
  SUM(Grade) OVER (ORDER BY StudentID ROWS UNBOUNDED PRECEDING) AS RunningGrade
FROM dbo.Students
ORDER BY StudentID;
GO

-- 2) Студенты, у которых совпадает день рождения
SELECT Birthday, STRING_AGG(StudentName, ', ') AS Names, COUNT(*) AS Cnt
FROM dbo.Student
GROUP BY Birthday
HAVING COUNT(*) > 1
ORDER BY Birthday;
GO

-- 3) Сумма очков по уникальным парам игроков (A,B) == (B,A)
;WITH Norm AS (
  SELECT
    CASE WHEN PlayerA <= PlayerB THEN PlayerA ELSE PlayerB END AS P1,
    CASE WHEN PlayerA <= PlayerB THEN PlayerB ELSE PlayerA END AS P2,
    Score
  FROM dbo.PlayerScores
)
SELECT P1 AS Player1, P2 AS Player2, SUM(Score) AS TotalScore
FROM Norm
GROUP BY P1, P2
ORDER BY Player1, Player2;
GO

-- 4) Разнести строку 'tf56sd#%OqH' на Upper/Lower/Num/Other
DECLARE @s VARCHAR(100) = 'tf56sd#%OqH';

;WITH Tally AS (
  SELECT TOP (LEN(@s)) ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS n
  FROM sys.all_objects
),
Chars AS (
  SELECT n,
         SUBSTRING(@s, n, 1) AS ch
  FROM Tally
)
SELECT
  (SELECT STRING_AGG(ch, '') WITHIN GROUP (ORDER BY n)
   FROM Chars WHERE ch COLLATE Latin1_General_CS_AS BETWEEN 'A' AND 'Z') AS Uppercase,
  (SELECT STRING_AGG(ch, '') WITHIN GROUP (ORDER BY n)
   FROM Chars WHERE ch COLLATE Latin1_General_CS_AS BETWEEN 'a' AND 'z') AS Lowercase,
  (SELECT STRING_AGG(ch, '') WITHIN GROUP (ORDER BY n)
   FROM Chars WHERE ch BETWEEN '0' AND '9') AS Numbers,
  (SELECT STRING_AGG(ch, '') WITHIN GROUP (ORDER BY n)
   FROM Chars WHERE NOT(
        ch COLLATE Latin1_General_CS_AS BETWEEN 'A' AND 'Z'
        OR ch COLLATE Latin1_General_CS_AS BETWEEN 'a' AND 'z'
        OR ch BETWEEN '0' AND '9'
   )) AS Others;
GO
```

если что-то из «трудных» хочешь сделать именно `UPDATE`-ом (перезаписью), скажи какую таблицу правим — накину безопасный шаблон через временную таблицу/CTE, чтобы не угробить исходные данные.

