create database Coffee_sales;

use coffee_sales

------------------------------------ ADD DATE TIME COLUMN --------------------------------
--- Add Month column 
alter Table Sales add Month varchar(3)

UPDATE sales
set Month = FORMAT(transaction_date, 'MMM')

--- Adjust something
alter table sales add New_Time time

update sales
set Time = FORMAT(time, 'HH:mm:ss')

SELECT * FROM Sales

--- Add date name column
alter table Sales add Name_of_date varchar(15)

UPDATE sales
set Name_of_date = DATENAME(weekday, transaction_date) 

--- Rename the column Name_of_date to Name_of_day
EXEC sp_rename 'Sales.Name_of_date', 'Name_of_day', 'COLUMN'
--- Add time name column
alter table Sales add Time_of_day varchar(20)

UPDATE Sales 
set Time_of_day = 
	case
		WHEN DATEPART(hour,time) between 0 and 11 THEN 'Morning'
		WHEN DATEPART(hour,time) between 12 and 16 THEN 'Afternoon'
		ELSE 'Evening'
	end

SELECT * FROM sales

--- Add revenue column
alter table Sales add Revenue decimal(5,2)


UPDATE Sales 
set Revenue  = transaction_qty * unit_price


---------------------------------------------- SOVLE THE PROBLEM --------------------------------------------
---- Total sales analysis ---
---1 Cal culate total sales for each respective month
SELECT MONTH, FORMAT(SUM(Revenue),'C') Total_Revenue FROM sales
GROUP BY Month, datepart(month,transaction_date)
ORDER BY DATEPART(month,transaction_date) asc

---2 Determine the month-on-month increase or decrease in sales.
WITH table1 as
(SELECT 
	month, SUM(revenue) Revenue, DATEPART(MONTH,transaction_date) Month_num
FROM Sales
GROUP BY month, DATEPART(MONTH,transaction_date))
-------
SELECT
	Month, Revenue,
	isnull(cast(cast(((Revenue - previous_month)/previous_month)*100 as decimal(5,2)) as varchar(5)), 0)+'%' Growth
FROM 
(SELECT Month, Revenue, lag(Revenue) OVER (ORDER BY Month_num) Previous_month
FROM table1) AS Table2;

---3 Calculate the difference in sales between the selected month and the previous month.
WITH Table1 as 
(SELECT
	month, sum(revenue) Revenue, DATEPART(month,transaction_date) Month_num
FROM Sales
GROUP BY month, DATEPART(month,transaction_date))
------
SELECT
	Month, isnull(FORMAT((Revenue - Previous_qty),'N0'),0) AS Difference
FROM 
(SELECT 
	month, Revenue, lag(Revenue) OVER (ORDER BY Month_Num) Previous_qty
FROM Table1) AS Table2

--- 4 Calculate the total number of orders for each respective month
SELECT
	Month, FORMAT(COUNT(transaction_id),'N0') Number_orders
FROM Sales 
GROUP BY Month, DATEPART(month, transaction_date)
ORDER BY datepart(month,transaction_date) asc

--- 5 Determine the month-on-month increase or decrease in the number of orders
WITH table1 as
(SELECT month, COUNT(transaction_id) Number_orders, datepart(MONTH,transaction_date) Month_num
FROM sales
GROUP BY month, datepart(month,transaction_date))
-----------
SELECT 
	Month, Number_orders, Previous_orders, 
	isnull(cast(cast((Number_orders - Previous_orders)/(cast(Number_orders as float))*100 as decimal(5,2)) 
		as varchar(5)),0)+'%' '%Change'
FROM 
(SELECT 
	month, Month_num, Number_orders,
	lag(number_orders) OVER (ORDER BY month_num) Previous_orders
FROM table1) as table2;

--- 6 Calculate the difference in the number of orders between the selected month and the previous month
With table1 as 
(SELECT Month, COUNT(transaction_id) Number_orders, datepart(month, transaction_date) Month_num
FROM Sales
GROUP BY Month, datepart(month, transaction_date))
---------
SELECT
	Month, isnull((Number_orders - Previous_orders),0) Difference 
FROM 
(SELECT 
	Month, Number_orders, 
	lag(Number_orders) OVER (ORDER BY (month_num)) Previous_orders
FROM table1) AS Table2

--- 7 Calculate the total quantity sold for each respective month
SELECT
	Month, FORMAT(SUM(transaction_qty),'N0') Quantity
FROM Sales 
GROUP BY Month, DATEPART(month, transaction_date)
ORDER BY datepart(month,transaction_date) asc

--- 8 Determine the month-on-month increase or decrease in the total quantity sold
WITH table1 as
(SELECT month, SUM(transaction_qty) Quantity, datepart(MONTH,transaction_date) Month_num
FROM sales
GROUP BY month, datepart(month,transaction_date))
-----------
SELECT 
	Month, Quantity, isnull(Previous_qty,0), 
	isnull(cast(cast((Quantity - Previous_qty)/(cast(Quantity as float))*100 as decimal(5,2)) 
		as varchar(5)),0)+'%' '%Change'
FROM 
(SELECT 
	month, Month_num, Quantity,
	lag(Quantity) OVER (ORDER BY month_num) Previous_qty
FROM table1) as table2;

--- 9 Calculate the difference in the total quantity sold between the selected month and the previous month
With table1 as 
(SELECT Month, SUM(transaction_qty) Quantity, datepart(month, transaction_date) Month_num
FROM Sales
GROUP BY Month, datepart(month, transaction_date))
---------
SELECT
	Month, isnull(FORMAT((Quantity - Previous_qty),'N0'),0) Difference 
FROM 
(SELECT 
	Month, Quantity, 
	lag(Quantity) OVER (ORDER BY (month_num)) Previous_qty
FROM table1) AS Table2



