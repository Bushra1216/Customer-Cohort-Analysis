
USE master;


--Create the database if not exists
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name= 'retail_db')
BEGIN

    CREATE DATABASE retail_db;
END
GO


USE retail_db;


--Create the table if not exists
IF NOT EXISTS(SELECT * FROM sys.tables WHERE name= 'RETAIL')
BEGIN
    CREATE TABLE RETAIL(
      InvoiceNo VARCHAR(20),
      StockCode VARCHAR(20),
      Description VARCHAR(255),
      Quantity INT,
      InvoiceDate DATETIME, 
      UnitPrice DECIMAL(10,2), 
      CustomerID INT, --integer IDs for customers
      Country VARCHAR(20),
      Revenue DECIMAL(18,2)

);
END
GO


select * from RETAIL;
  

--Import data from csv file into the RETAIL table using bulk insert method
BULK INSERT RETAIL FROM 'C:\Users\Shanj\OneDrive\Desktop\data analysis\dataset\cleaned_retail.csv'
WITH (
    FIRSTROW=2,
	  FIELDTERMINATOR='|',
	  ROWTERMINATOR='\n',
	  TABLOCK

);




