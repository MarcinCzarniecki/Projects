
--Familiarize with the data

SELECT *
FROM dbo.SalesData;

SELECT TOP 10 *
FROM dbo.SalesData;


-- Calculation of sales for every single transaction

SELECT *, (Sales * Quantity) AS [Total_Sales]
FROM dbo.SalesData;


--Calculation the percentage of shipping costs - CTE

WITH Percentage(Row_ID, Order_ID, Sales, Shipping_Cost, Total_Sales)
AS
(
SELECT Row_ID, Order_ID, Sales, Shipping_Cost, (Sales * Quantity) AS [Total_Sales]
FROM dbo.SalesData
)
SELECT *,  (Shipping_Cost/Total_Sales)*100 AS [Shipping_Cost_Percentage]
FROM Percentage
ORDER BY Row_ID



--Calculation the percentage of shipping costs - TEMP TABLE

DROP TABLE IF exists #Percentage
CREATE TABLE #Percentage
(
Row_ID float,
Order_ID nvarchar(255),
Sales float,
Shipping_Cost float, 
Total_Sales float
)
INSERT INTO #Percentage
SELECT Row_ID, Order_ID, Sales, Shipping_Cost, (Sales * Quantity) AS [Total_Sales]
FROM dbo.SalesData

SELECT *,  (Shipping_Cost/Total_Sales)*100 AS [Shipping_Cost_Percentage]
FROM #Percentage
ORDER BY Row_ID;



-- Sales by category

SELECT Category,
	ROUND(SUM(Sales * Quantity), 2) AS [Total_Sales],
	ROUND(MIN(Sales * Quantity), 2) AS [Minimum_Sales],
	ROUND(MAX(Sales * Quantity), 2) AS [Maximum_Sales],
	ROUND(AVG(Sales * Quantity), 2) AS [Average_Sales]
FROM dbo.SalesData
GROUP BY Category;


--Sales by category and region

SELECT Category,Region, 
	ROUND(SUM(Sales * Quantity), 2) AS [Total_Sales],
	ROUND(MIN(Sales * Quantity), 2) AS [Minimum_Sales],
	ROUND(MAX(Sales * Quantity), 2) AS [Maximum_Sales],
	ROUND(AVG(Sales * Quantity), 2) AS [Average_Sales]
FROM dbo.SalesData
GROUP BY Category, Region
ORDER BY Region DESC;


-- Total sales by customer and sub-category

SELECT Sub_Category, Customer_Name, 
	SUM(Sales * Quantity) AS 'Total_Sales'
FROM dbo.SalesData
GROUP BY GROUPING SETS ((Customer_Name, Sub_Category), Customer_Name, Sub_Category,())
ORDER BY Customer_Name;



--Rolling sales by customer and product

SELECT Customer_Name, Product_Name,
	ROUND(SUM(Sales * Quantity),2) AS 'Total_Sales'
FROM dbo.SalesData
GROUP BY ROLLUP ( Customer_Name, Product_Name );


--The most profitable customer

SELECT Customer_Name,
	ROUND(SUM(Sales * Quantity),2) AS 'Total_Sales'
FROM dbo.SalesData
GROUP BY Customer_Name
ORDER BY 'Total_Sales' DESC;


-- Looking at avg, sum, min, max price partitioned by sub-category


SELECT Sub_Category, Product_Name, Sales,
		AVG(Sales) OVER (PARTITION BY Sub_Category) AS 'Average_price',
		SUM(Sales) OVER (PARTITION BY Sub_Category) AS 'Sum_of_prices',
		COUNT(Product_Name)  OVER (PARTITION BY Sub_Category) AS 'Number_0f_products',
		MIN(Sales) OVER (PARTITION BY Sub_Category) AS 'Minimum_price',
		MAX(Sales) OVER( PARTITION BY Sub_Category) AS 'Maximal_price'
FROM dbo.SalesData
ORDER BY Sub_Category, Product_Name;



-- Looking at running total partitioned by country


SELECT Country, Customer_Name, Product_Name, Sales,
		SUM(Sales) OVER (PARTITION BY Country 
			ORDER BY Country
			ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS 'Current_and_1_Preceding',
		SUM(Sales) OVER (PARTITION BY Country 
			ORDER BY Country
			ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS 'Current_and_2_Preceding',
		SUM(Sales) OVER (PARTITION BY Country 
			ORDER BY Country
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'Running_total'
FROM dbo.SalesData;



--Looking at random 100 rows with offset 

SELECT Row_ID, Product_Name, Category, Sales
FROM dbo.SalesData
ORDER BY Row_ID
OFFSET 50 ROWS FETCH NEXT 100 ROWS ONLY;


--Usage of LAG and LEAD functions for analysis

SELECT Row_ID, Customer_Name, Order_Date, Sales,
		LAG(Sales) OVER (PARTITION BY Customer_Name ORDER BY Order_Date) AS 'Preceding_sales',
		Sales - LAG(Sales) OVER (PARTITION BY Customer_Name ORDER BY Order_Date) AS 'Difference_preceding_sales',
		LAG(Order_Date) OVER (PARTITION BY Customer_Name ORDER BY Order_Date) AS 'Date_preceding_sales',
		LEAD(Sales) OVER (PARTITION BY Customer_Name ORDER BY Order_Date) AS 'Next_sales',
		Sales - LEAD(Sales) OVER (PARTITION BY Customer_Name ORDER BY Order_Date) AS 'Difference_with_next_sales', 
		LEAD(Order_Date) OVER ( PARTITION BY Customer_Name ORDER BY Order_Date) AS 'Date_next_sales'
FROM dbo.SalesData;


--Looking at returned products - INNER JOIN

SELECT *
FROM dbo.SalesData sd
INNER JOIN dbo.ReturnsData rd
ON rd.Order_ID = sd.Order_ID
ORDER BY sd.Row_ID;


--Looking at returned products - SUBQUERY

SELECT *
FROM dbo.SalesData
WHERE ORDER_ID IN (SELECT Order_ID
					FROM dbo.ReturnsData)
ORDER BY Row_ID;



