/* ============================================================
   PUZZLE 1: FIND DISTINCT VALUES (based on two columns)
   ============================================================ */

-- подготовка таблицы
IF OBJECT_ID('dbo.InputTbl', 'U') IS NOT NULL DROP TABLE dbo.InputTbl;
GO
CREATE TABLE dbo.InputTbl (
    col1 VARCHAR(10),
    col2 VARCHAR(10)
);
INSERT INTO dbo.InputTbl (col1, col2) VALUES 
('a', 'b'),
('a', 'b'),
('b', 'a'),
('c', 'd'),
('c', 'd'),
('m', 'n'),
('n', 'm');
GO

-- способ 1: CASE + DISTINCT (симметричные пары)
SELECT DISTINCT
    CASE WHEN col1 < col2 THEN col1 ELSE col2 END AS col1,
    CASE WHEN col1 < col2 THEN col2 ELSE col1 END AS col2
FROM dbo.InputTbl;
GO

-- способ 2: GROUP BY по уникальной паре
SELECT 
    MIN(col1) AS col1,
    MAX(col2) AS col2
FROM dbo.InputTbl
GROUP BY 
    CASE 
        WHEN col1 < col2 THEN col1 + col2 
        ELSE col2 + col1 
    END;
GO


/* ============================================================
   PUZZLE 2: REMOVE ROWS WHERE ALL VALUES = 0
   ============================================================ */

-- подготовка таблицы
IF OBJECT_ID('dbo.TestMultipleZero', 'U') IS NOT NULL DROP TABLE dbo.TestMultipleZero;
GO
CREATE TABLE dbo.TestMultipleZero (
    A INT NULL,
    B INT NULL,
    C INT NULL,
    D INT NULL
);

INSERT INTO dbo.TestMultipleZero (A,B,C,D)
VALUES 
    (0,0,0,1),
    (0,0,1,0),
    (0,1,0,0),
    (1,0,0,0),
    (0,0,0,0),
    (1,1,1,0);
GO

-- способ 1: фильтр через сумму
SELECT *
FROM dbo.TestMultipleZero
WHERE (A + B + C + D) <> 0;
GO

-- способ 2: фильтр через логическое условие
SELECT *
FROM dbo.TestMultipleZero
WHERE NOT (A=0 AND B=0 AND C=0 AND D=0);
GO


/* ============================================================
   PUZZLE 3: FIND ROWS WITH ODD IDs
   ============================================================ */

-- подготовка таблицы
IF OBJECT_ID('dbo.section1', 'U') IS NOT NULL DROP TABLE dbo.section1;
GO
CREATE TABLE dbo.section1 (
    id INT,
    name VARCHAR(20)
);
INSERT INTO dbo.section1 (id, name)
VALUES 
(1, 'Been'),
(2, 'Roma'),
(3, 'Steven'),
(4, 'Paulo'),
(5, 'Genryh'),
(6, 'Bruno'),
(7, 'Fred'),
(8, 'Andro');
GO

-- выбор нечётных ID
SELECT *
FROM dbo.section1
WHERE id % 2 = 1;
GO

