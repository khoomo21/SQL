
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
GO
CREATE TABLE dbo.Products (
    ProductID   INT           NOT NULL PRIMARY KEY,
    ProductName VARCHAR(50)   NOT NULL,
    Price       DECIMAL(10,2) NULL  -- allow NULL initially to demo ISNULL later
);
GO

INSERT INTO dbo.Products (ProductID, ProductName, Price)
VALUES (1, 'Mouse', 19.99),
       (2, 'Keyboard', 49.90),
       (3, 'USB-C Cable', 8.50);
GO
