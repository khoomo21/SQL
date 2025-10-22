SET NOCOUNT ON;

----------------------------------------------------------------
-- EASY
----------------------------------------------------------------

-- 1) Split "Name" by comma → Name, Surname (TestMultipleColumns)
-- Пример строки: 'Steven, King'
SELECT
  LTRIM(RTRIM(SUBSTRING(Name, 1, CHARINDEX(',', Name + ',') - 1))) AS [Name],
  LTRIM(RTRIM(SUBSTRING(Name, CHARINDEX(',', Name + ',') + 1, 8000))) AS [Surname]
FROM dbo.TestMultipleColumns;
GO

-- 2) Строки, в которых есть символ % (TestPercent)
SELECT *
FROM dbo.TestPercent
WHERE val LIKE '%!%%' ESCAPE '!';
-- Альтернатива: WHERE val LIKE '%[%]%'
GO

-- 3) Разбить строку по точке . (Splitter)
-- Таблица Splitter(val). Каждая часть отдельной строкой.
SELECT s.val,
       split.value AS part
FROM dbo.Splitter AS s
CROSS APPLY STRING_SPLIT(s.val, '.') AS split;
-- Если нужна позиция, на SQL Server 2022+:
-- CROSS APPLY STRING_SPLIT(s.val, '.', 1) AS split  -- split.ordinal
GO

-- 4) Строки, где в Vals > 2 точек (testDots)
SELECT *
FROM dbo.testDots
WHERE (LEN(Vals) - LEN(REPLACE(Vals, '.', ''))) > 2;
GO

-- 5) Посчитать число пробелов в строке (CountSpaces)
SELECT val,
       LEN(val) - LEN(REPLACE(val, ' ', '')) AS SpaceCount
FROM dbo.CountSpaces;
GO

-- 6) Сотрудники, кто зарабатывает больше своего менеджера (Employee)
SELECT e.name AS EmployeeName
FROM dbo.Employee AS e
JOIN dbo.Employee AS m ON m.id = e.managerId
WHERE e.salary > m.salary;
GO

-- 7) Стаж >10 и <15 лет (Employees)
SELECT
  EmployeeID,
  FirstName,
  LastName,
  HireDate,
  DATEDIFF(YEAR, HireDate, GETDATE()) AS YearsOfService
FROM dbo.Employees
WHERE DATEDIFF(YEAR, HireDate, GETDATE()) > 10
  AND DATEDIFF(YEAR, HireDate, GETDATE()) < 15;
-- Если нужна «календарная точность», можно сравнить годовщины через DATEADD.
GO


----------------------------------------------------------------
-- MEDIUM
----------------------------------------------------------------

-- 1) Даты с температурой выше вчерашней (weather)
-- weather(id, recordDate, temperature)
SELECT id
FROM (
  SELECT
    id,
    temperature,
    LAG(temperature) OVER (ORDER BY recordDate) AS prev_temp
  FROM dbo.weather
) t
WHERE t.prev_temp IS NOT NULL
  AND t.temperature > t.prev_temp;
GO

-- 2) Первая дата логина для каждого игрока (Activity)
-- Activity(player_id, event_date, ...), где логин — любая запись игрока
SELECT player_id,
       MIN(event_date) AS first_login_date
FROM dbo.Activity
GROUP BY player_id;
GO

-- 3) Вернуть третий элемент списка (fruits)
-- fruits(id, list) где list = 'apple,banana,orange,...'
-- SQL Server 2022+: STRING_SPLIT с порядком
SELECT f.id, s.value AS third_item
FROM dbo.fruits AS f
CROSS APPLY (
  SELECT value, ordinal
  FROM STRING_SPLIT(f.list, ',', 1)
) AS s
WHERE s.ordinal = 3;
-- Если нет 2022+, нужен другой подход (XML/JSON/PARSENAME).
GO

-- 4) Этап занятости по HIRE_DATE (Employees)
-- New Hire <1; Junior 1–5; Mid 5–10; Senior 10–20; Veteran >20
WITH yrs AS (
  SELECT
    EmployeeID,
    FirstName,
    LastName,
    HireDate,
    DATEDIFF(YEAR, HireDate, GETDATE()) AS y
  FROM dbo.Employees
)
SELECT
  EmployeeID, FirstName, LastName, HireDate,
  CASE
    WHEN y < 1 THEN 'New Hire'
    WHEN y >= 1  AND y < 5  THEN 'Junior'
    WHEN y >= 5  AND y < 10 THEN 'Mid-Level'
    WHEN y >= 10 AND y < 20 THEN 'Senior'
    ELSE 'Veteran'
  END AS EmploymentStage
FROM yrs;
GO

-- 5) Извлечь целое число в начале строки Vals (GetIntegers)
-- Возвращает начальные цифры; если строка не начинается с цифры — NULL.
SELECT
  Vals,
  CASE
    WHEN Vals LIKE '[0-9]%' THEN
      SUBSTRING(
        Vals,
        1,
        COALESCE(NULLIF(PATINDEX('%[^0-9]%', Vals), 0) - 1, LEN(Vals))
      )
    ELSE NULL
  END AS LeadingInteger
FROM dbo.GetIntegers;
GO

