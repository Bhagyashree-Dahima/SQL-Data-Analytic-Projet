/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- Create Schemas

CREATE SCHEMA gold;
GO

CREATE TABLE gold.dim_customers(
	customer_key int,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

CREATE TABLE gold.dim_products(
	product_key int ,
	product_id int ,
	product_number nvarchar(50) ,
	product_name nvarchar(50) ,
	category_id nvarchar(50) ,
	category nvarchar(50) ,
	subcategory nvarchar(50) ,
	maintenance nvarchar(50) ,
	cost int,
	product_line nvarchar(50),
	start_date date 
);
GO

CREATE TABLE gold.fact_sales(
	order_number nvarchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO

TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM 'C:\Users\BHAGYASHREE\Downloads\gold.dim_customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.dim_products;
GO

BULK INSERT gold.dim_products
FROM 'C:\Users\BHAGYASHREE\Downloads\gold.report_products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM 'C:\Users\BHAGYASHREE\Downloads\gold.fact_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO
 DROP TABLE IF EXISTS gold.dim_products; 
 GO 
 -- Create table matching the NEW gold.report_products.csv 
 CREATE TABLE gold.dim_products ( product_key INT, 
							product_name NVARCHAR(255), 
							category NVARCHAR(100), 
							subcategory NVARCHAR(100), 
							cost INT, last_sale_date DATE, 
							recency_in_months INT, 
							product_segment NVARCHAR(50), 
							lifespan INT, 
							total_orders INT,
							total_sales INT, 
							total_quantity INT, 
							total_customers INT, 
							avg_selling_price DECIMAL(12,2), 
							avg_order_revenue DECIMAL(12,2), 
							avg_monthly_revenue DECIMAL(12,2) );
GO 
-- Import the NEW product report
BULK INSERT gold.dim_products 
FROM 'C:\Users\BHAGYASHREE\Downloads\gold.report_products.csv' 
WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', FIELDQUOTE = '"', ROWTERMINATOR = '0x0a', TABLOCK ); 
GO 
-- Verify 
SELECT COUNT(*) AS total_products FROM gold.dim_products;
GO 
-- Check the imported data 
SELECT TOP 10 * FROM gold.dim_products;
GO

select * from gold.dim_products