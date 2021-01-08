-- Part A - SQL Statements --
-- Question 01 --
SELECT	OrderDetails.OrderID,
		(OrderDetails.Quantity*Products.UnitPrice) AS Cost,
		Products.ProductID,
		Products.ProductName,
		Suppliers.SupplierID,
		Suppliers.Name
FROM	Products INNER JOIN OrderDetails
ON		Products.ProductID = OrderDetails.ProductID INNER JOIN Suppliers
ON		Products.SupplierID = Suppliers.SupplierID
WHERE	OrderDetails.Quantity >= 90
ORDER BY Cost;

-- Question 2 --
SELECT	Products.ProductID,
		Products.ProductName,
		CASE Products.CategoryID
			WHEN '1'	THEN 'Beverages'
			WHEN '2'	THEN 'Sauces & Syrups'
			WHEN '3'	THEN 'Desserts'
			WHEN '4'	THEN 'Cheeses'
			ELSE 'Unknown' 
		END as 'Categorys',
		Products.UnitPrice,
		ROUND(Products.UnitPrice*1.15,2) as 'UnitPrice',
		Suppliers.Name
FROM	Products INNER JOIN Suppliers 
ON		Products.SupplierID = Suppliers.SupplierID
WHERE	Products.UnitPrice >= 20 
AND		(Products.CategoryID >= 1 AND Products.CategoryID <= 4)
ORDER BY Products.ProductName

-- Question 3 --
SELECT	Customers.CompanyName,
		Customers.ContactName,
		Customers.Phone,
		Customers.Country,
		SUM(Orders.Freight) as 'Total_Freight'
FROM	Customers INNER JOIN Orders
ON		Customers.CustomerID = Orders.CustomerID
WHERE	Orders.OrderDate BETWEEN '1993-01-01' and '1993-06-30'
GROUP BY	Customers.CompanyName, 
			Customers.ContactName, 
			Customers.Phone, 
			Customers.Country

-- Question 4 --
SELECT		RTRIM(COALESCE(Employees.FirstName + ' ','') + COALESCE(Employees.MiddleName + ' ','') + COALESCE(Employees.LastName + ' ','')) as EmployeeName,
			Orders.ShipCity,
			COUNT(Orders.ShipCity) as 'Count'
FROM		Employees INNER JOIN Orders
ON			Employees.EmployeeID = Orders.EmployeeID
GROUP BY	Orders.ShipCity,RTRIM(COALESCE(Employees.FirstName + ' ','') + COALESCE(Employees.MiddleName + ' ','') + COALESCE(Employees.LastName + ' ',''))
HAVING		COUNT(Orders.ShipCity) >= 7
ORDER BY	Count, EmployeeName

-- Question 5 --
SELECT		Orders.OrderID,
			Customers.CompanyName,
			OrderDetails.Quantity*OrderDetails.UnitPrice as 'Order_Cost',
			FORMAT(Orders.ShippedDate,'MMM dd yyyy') as 'ShippedDate',
			DATEDIFF(day,Orders.OrderDate,Orders.ShippedDate) as 'Days'
FROM		Orders INNER JOIN Customers
ON			Orders.CustomerID = Customers.CustomerID INNER JOIN OrderDetails
ON			Orders.OrderID = OrderDetails.OrderID
GROUP BY	Orders.ShippedDate,
			Orders.OrderID,
			Customers.CompanyName,
			OrderDetails.Quantity*OrderDetails.UnitPrice,
			Orders.ShippedDate,
			DATEDIFF(day,Orders.OrderDate,Orders.ShippedDate)
HAVING		Orders.ShippedDate >= '1994-01-01' AND Orders.ShippedDate <= '1994-01-31' 
ORDER BY	ShippedDate

-- Question 6--
SELECT	OrderDetails.OrderID,
		Products.ProductID,
		Customers.CompanyName,
		(OrderDetails.Quantity*Products.UnitPrice) as 'OrderCost',
		FORMAT(DATEADD(DAY,10,Orders.ShippedDate),'MMM dd yyyy') as 'ShippedDate'
FROM	Products INNER JOIN OrderDetails
ON		Products.ProductID = OrderDetails.ProductID INNER JOIN Orders
ON		OrderDetails.OrderID = Orders.OrderID INNER JOIN Customers
ON		Orders.CustomerID = Customers.CustomerID
WHERE	DATEPART(year,Orders.OrderDate) = '1994'
AND		(OrderDetails.Quantity*Products.UnitPrice) >= 2500
ORDER BY Customers.CompanyName

-- Question 7--
SELECT	'Supliers' as 'table',
		Suppliers.Name,
		'' as 'ContactName',
		'' as 'Phone'
FROM	Suppliers
WHERE	SupplierID >= 1
AND		SupplierID <=5
UNION
SELECT	'Customers' as 'table',
		CompanyName,
		Customers.ContactName,
		Phone
FROM	Customers
WHERE	Customers.Country IN('Canada','Italy')
ORDER BY Suppliers.Name


-- Question 8--
SELECT	Customers.CustomerID,
		Customers.Phone,
		CONCAT(Employees.LastName,',', Employees.FirstName) as 'Name',
		Orders.OrderID,
		FORMAT(Orders.OrderDate,'yyyy-MM-dd') as 'OrderDate'
FROM	Customers INNER JOIN Orders
ON		Customers.CustomerID = Orders.CustomerID INNER JOIN	Employees
ON		Orders.EmployeeID = Employees.EmployeeID
WHERE	Orders.ShippedDate is NULL 
AND		Employees.City = 'New Westminster'
ORDER BY Customers.CompanyName,Orders.OrderDate

--Part B - Stored Procedures, Triggers, and Functions
-- Question 1--
CREATE VIEW suppliers_products_vw 
AS
SELECT	Products.ProductID,
		Products.QuantityPerUnit,
		Products.UnitsInStock,
		Products.UnitsOnOrder,
		Suppliers.Name
FROM	Products INNER JOIN Suppliers
ON		Products.SupplierID = Suppliers.SupplierID
WHERE	Products.UnitsOnOrder > 0

SELECT *
FROM suppliers_products_vw 
ORDER BY ProductID

-- Question 2--
UPDATE	Customers
SET		Customers.Fax = 'Unknown'
FROM	Customers INNER JOIN Orders
ON		Customers.CustomerID = Orders.CustomerID
WHERE	Customers.Fax is NULL
AND		Orders.ShipCountry = 'Portugal'

-- Question 3--
INSERT INTO Employees(Employees.EmployeeID, Employees.LastName, Employees.FirstName, Employees.BirthDate)
VALUES('10','Stevenson','Susan','1990-05-13')

INSERT INTO Employees(Employees.EmployeeID, Employees.LastName, Employees.FirstName, Employees.BirthDate)
VALUES('11','Thompson','Darlene','1995-09-10')

-- Question 4--
CREATE VIEW employee_inform_vw
AS
SELECT	Employees.EmployeeID,
		CONCAT(Employees.FirstName,' ',Employees.LastName) as 'Name',
		CASE
			WHEN Employees.Phone IS NULL		THEN ''
			WHEN Employees.Phone IS NOT NULL	THEN CONCAT ( '(', SUBSTRING(Employees.Phone, 1, 3), ') ', SUBSTRING(Employees.Phone, 5, 4),'-',SUBSTRING(Employees.Phone, 6, 8))
		END as 'Phone',
		FORMAT(Employees.BirthDate,'MMM dd yyyy') as 'BirthDate'
FROM	Employees

SELECT *
FROM employee_inform_vw
WHERE EmployeeID IN ( 3, 9, 11 )

-- Question 5--
SELECT	Customers.CustomerID,
		Customers.ContactName,
		Customers.Phone,
		Orders.OrderID,
		FORMAT(Orders.OrderDate,'yyyy-MM-dd') as 'OrderDate'
FROM	Customers INNER JOIN Orders 
ON		Customers.CustomerID = Orders.CustomerID INNER JOIN Employees
ON		Orders.EmployeeID = Employees.EmployeeID
WHERE	Orders.OrderID IN (	SELECT	Orders.OrderID FROM	Orders WHERE	Orders.ShippedDate IS NULL )
AND		Employees.EmployeeID IN (SELECT Employees.EmployeeID FROM Employees WHERE Employees.City = 'New Westminster')
ORDER BY	CustomerID

-- Question 6 --
UPDATE	Employees
SET		Employees.Phone = 6042537581
WHERE	Employees.EmployeeID = 10

-- Question 7 --
CREATE VIEW order_shipped_vw 
AS
SELECT	Orders.OrderID,
		FORMAT(Orders.OrderDate,'yyyy-MM-dd') as 'OrderDate',
		FORMAT(Orders.ShippedDate,'yyyy-MM-dd') as 'ShippedDate',
		CONCAT(Employees.FirstName,' ',Employees.LastName) as 'EmployeeName',
		Shippers.CompanyName,
		DATEDIFF(day,Orders.OrderDate,Orders.ShippedDate) as 'DayDifference'
FROM	Orders INNER JOIN Employees
ON		Orders.EmployeeID = Employees.EmployeeID INNER JOIN Shippers
ON		Orders.ShipperID = Shippers.ShipperID
WHERE	DATEDIFF(day,Orders.OrderDate,Orders.ShippedDate) > 10
AND		YEAR(Orders.OrderDate) >= '1993'

SELECT *
FROM order_shipped_vw
ORDER BY OrderDate;


-- Question 8 --
DELETE FROM Employees WHERE Employees.EmployeeID = 10 OR Employees.EmployeeID = 11
GO
--Part C - Stored Procedures, Triggers, and Functions
-- Question 1--
CREATE PROCEDURE orders_by_dates_sp
	@start_date smalldatetime = 0,
	@end_date smalldatetime = 0
AS
IF (@start_date = 0 or @end_date = 0)
	BEGIN
		PRINT 'Please enter valid dates' 
	END
ELSE
	BEGIN
		SELECT	Orders.OrderID,
				OrderDetails.ProductID,
				Customers.CompanyName,
				FORMAT(Orders.OrderDate,'MMM dd yyyy') as 'OrderDate',
				FORMAT(Orders.ShippedDate,'MMM dd yyyy') as 'ShippedDate'
		FROM	Orders INNER JOIN OrderDetails
		ON		Orders.OrderID = OrderDetails.OrderID INNER JOIN Customers
		ON		Orders.CustomerID = Customers.CustomerID
		WHERE	Orders.ShippedDate BETWEEN @start_date and @end_date
		ORDER BY Orders.ShippedDate
	END

EXECUTE orders_by_dates_sp
EXECUTE orders_by_dates_sp '1994-03-01'
EXECUTE orders_by_dates_sp '1994-03-01', '1994-03-31'
GO

-- Question 2 --
CREATE TRIGGER insert_employee_tr
ON Employees
AFTER INSERT
AS
IF ((SELECT Phone FROM inserted) IS NULL OR (SELECT Phone FROM inserted) = '')
	BEGIN
		PRINT 'Phone number is incorrect'
		ROLLBACK TRANSACTION
	END

INSERT Employees		-- Trigger should prevent the insert and print message.
VALUES( 20, 'Doe', 'Jane', 'Sally', '15 Pine Street', 'Vancouver', 'BC', 'V6X 4T6', NULL, '1975-05-23' );

INSERT Employees		-- Trigger should prevent the insert and print message.
VALUES( 20, 'Doe', 'Jane', 'Sally', '15 Pine Street', 'Vancouver', 'BC', 'V6X 4T6', '', '1975-05-23' );

INSERT Employees		--Trigger should allow the insert.
VALUES( 20, 'Doe', 'Jane', 'Sally', '15 Pine Street', 'Vancouver', 'BC', 'V6X 4T6', '6045552581', '1975-05-23' );
GO

-- Question 3--
CREATE TRIGGER check_shippeddate_tr
ON Orders
AFTER UPDATE
AS
IF ( (SELECT ShippedDate FROM inserted) > (SELECT RequiredDate FROM inserted) )
	BEGIN
		PRINT 'Order was shipped after the required date'
	END
ELSE
	BEGIN
		PRINT 'Order was shipped successfully'
	END

UPDATE Orders						-- Trigger should print message that shipped 
SET ShippedDate = '1994-04-20'		-- date late, and row will update.
WHERE OrderID = 11051
  AND CustomerID = 'LAMAI'
  AND EmployeeID = 7;

UPDATE Orders						-- Trigger should print message that order 
SET ShippedDate = '1994-04-10'		-- shipped on time, and row will update.
WHERE OrderID = 11039
  AND CustomerID = 'LINOD'
  AND EmployeeID = 1;
GO

-- Question 4 --
CREATE PROCEDURE shipping_date_sp 
	@shipped_date datetime = NULL
AS
IF (@shipped_date IS NULL)
	BEGIN
		PRINT 'Please enter a valid shipped date'
	END
ELSE
	BEGIN
	SELECT	Orders.OrderID,
			Customers.CompanyName,
			Customers.Phone,
			FORMAT(Orders.OrderDate,'MMM dd yyyy') as 'OrderDate',
			FORMAT(Orders.RequiredDate,'MMM dd yyyy') as 'RequiredDate',
			FORMAT(Orders.ShippedDate,'MMM dd yyyy') as 'ShippedDate'
	FROM	Orders INNER JOIN Customers
	ON		Orders.CustomerID = Customers.CustomerID
	WHERE	Orders.ShippedDate = @shipped_date
	ORDER BY Orders.OrderDate  
	END;

EXECUTE shipping_date_sp;				-- Date missing. Print message.

EXECUTE shipping_date_sp '1994-03-01';	-- Print result set below.
GO

-- Question 5 --
CREATE PROCEDURE sales_by_employees_sp 
AS
SELECT	Employees.EmployeeID,
		CONCAT(Employees.FirstName,' ',Employees.LastName) as 'Name',
		SUM((OrderDetails.Quantity*OrderDetails.UnitPrice)) as 'InvoiceCost'
FROM	Employees INNER JOIN Orders
ON		Employees.EmployeeID = Orders.EmployeeID INNER JOIN OrderDetails
ON		Orders.OrderID = OrderDetails.OrderID
GROUP BY Employees.EmployeeID, Employees.FirstName, Employees.LastName
ORDER BY Employees.LastName

EXECUTE sales_by_employees_sp

-- Question 6 --
CREATE FUNCTION OrderCost(
	@Discount real,
	@UnitPrice money,
	@Quantity smallint,
	@Freight money
	)
RETURNS DEC (10,2)
AS
	BEGIN
		RETURN ((1.0 - @Discount)*(@UnitPrice*@Quantity)+@Freight)
	END;
GO

-- Question 7 --
CREATE PROCEDURE total_cost_sp
	@start_id varchar(5),
	@end_id varchar(5)
AS
SELECT	OrderDetails.OrderID,
		Products.EnglishName,
		dbo.OrderCost(OrderDetails.Discount, OrderDetails.UnitPrice, OrderDetails.Quantity, Orders.Freight) as 'TotalCost'
FROM	OrderDetails INNER JOIN Orders
ON		OrderDetails.OrderID = Orders.OrderID INNER JOIN Products
ON		OrderDetails.ProductID = Products.ProductID
WHERE	OrderDetails.OrderID BETWEEN @start_id AND @end_id
ORDER BY OrderDetails.OrderID

EXECUTE total_cost_sp 10800, 10850;
GO
-- Question 8 --
CREATE FUNCTION determine_discount
	(
	@qty	int,
	@addDiscount	DEC(10, 2)
	)
RETURNS TABLE
AS
RETURN
	(
	SELECT	Customers.CustomerID,
			Customers.CompanyName,
			Products.ProductName,
			OrderDetails.Quantity,
			OrderDetails.Discount,
			OrderDetails.Discount + @addDiscount AS NewDiscount
	FROM	Customers INNER JOIN Orders
	  ON	Customers.CustomerID = Orders.CustomerID INNER JOIN OrderDetails
	  ON	Orders.OrderID = OrderDetails.OrderID INNER JOIN Products
	  ON	OrderDetails.ProductID = Products.ProductID
	WHERE	Products.Discontinued = 0 AND
			OrderDetails.Quantity = @qty
		)

SELECT * 
FROM determine_discount( 80, 0.05 );