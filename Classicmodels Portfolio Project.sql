SELECT * 
FROM classicmodels.customers;

-- Finding customers in a specific country

SELECT customerName, city, state, country 
FROM customers 
WHERE country = 'USA';

-- Calculating the average credit limit:

SELECT AVG(creditLimit) AS avgCreditLimit 
FROM customers;

-- List of customers with a credit limit above a certain amount:

SELECT customerName, creditLimit 
FROM customers 
WHERE creditLimit > 50000;

-- Counting the number of customers by country:

SELECT country, COUNT(*) AS numberOfCustomers 
FROM customers 
GROUP BY country;

-- Top 5 Customers by Credit Limit

SELECT customerName, creditLimit
FROM customers
ORDER BY creditLimit DESC
LIMIT 5;

-- Customers by Sales Representative

SELECT salesRepEmployeeNumber, COUNT(*) AS numberOfCustomers
FROM customers
GROUP BY salesRepEmployeeNumber
ORDER BY numberOfCustomers DESC;

-- Customer Distribution by Country

SELECT country, COUNT(*) AS numberOfCustomers
FROM customers
GROUP BY country
ORDER BY numberOfCustomers DESC;

-- Average Credit Limit by Country

SELECT country, AVG(creditLimit) AS averageCreditLimit
FROM customers
GROUP BY country
ORDER BY averageCreditLimit DESC;

-- Customers Without Sales Representative

SELECT customerName, city, country
FROM customers
WHERE salesRepEmployeeNumber IS NULL;

-- Total Credit Limit by Sales Representative

SELECT salesRepEmployeeNumber, SUM(creditLimit) AS totalCreditLimit
FROM customers
GROUP BY salesRepEmployeeNumber
ORDER BY totalCreditLimit DESC;

-- Customers in a Specific City

SELECT customerName, contactLastName, contactFirstName, phone
FROM customers
WHERE city = 'Las Vegas';

-- Credit Limit Range Analysis

SELECT 
    CASE 
        WHEN creditLimit < 20000 THEN 'Below 20,000'
        WHEN creditLimit BETWEEN 20000 AND 50000 THEN '20,000 - 50,000'
        WHEN creditLimit BETWEEN 50001 AND 100000 THEN '50,001 - 100,000'
        ELSE 'Above 100,000'
    END AS creditLimitRange,
    COUNT(*) AS numberOfCustomers
FROM customers
GROUP BY creditLimitRange
ORDER BY creditLimitRange;

-- Find Duplicate Phone Numbers

SELECT phone, COUNT(*) AS count
FROM customers
GROUP BY phone
HAVING COUNT(*) > 1;

-- Find Customers with Missing Postal Codes

SELECT customerName, city, country
FROM customers
WHERE postalCode IS NULL OR postalCode = '';

-- Customers with the Longest Names

SELECT customerName, LENGTH(customerName) AS nameLength
FROM customers
ORDER BY nameLength DESC
LIMIT 5;

-- Customers with No Address Line 2

SELECT customerName, city, country
FROM customers
WHERE addressLine2 IS NULL OR addressLine2 = '';

-- Identify Customers in Multiple Cities (by Name)

SELECT customerName, GROUP_CONCAT(DISTINCT city ORDER BY city ASC SEPARATOR ', ') AS cities
FROM customers
GROUP BY customerName
HAVING COUNT(DISTINCT city) > 1;

-- Customers Whose Credit Limit Exceeds the Average by 50%

SELECT customerName, creditLimit
FROM customers
WHERE creditLimit > (SELECT AVG(creditLimit) FROM customers) * 1.5;

-- Identify Sales Representatives Handling Customers Across Multiple Countries

SELECT salesRepEmployeeNumber, GROUP_CONCAT(DISTINCT country ORDER BY country ASC SEPARATOR ', ') AS countries
FROM customers
GROUP BY salesRepEmployeeNumber
HAVING COUNT(DISTINCT country) > 1;

-- Identify Potential Customer Duplicates by Similar Names

SELECT c1.customerName AS customer1, c2.customerName AS customer2, c1.city, c1.country
FROM customers c1
JOIN customers c2 ON c1.customerNumber != c2.customerNumber
WHERE SOUNDEX(c1.customerName) = SOUNDEX(c2.customerName)
ORDER BY c1.customerName, c1.city;

-- Identify Customers with the Same Postal Code but Different Cities

SELECT postalCode, GROUP_CONCAT(DISTINCT city ORDER BY city ASC SEPARATOR ', ') AS cities
FROM customers
WHERE postalCode IS NOT NULL AND postalCode != ''
GROUP BY postalCode
HAVING COUNT(DISTINCT city) > 1;

-- Customers with No Recent Activity (Based on a Hypothetical 'lastOrderDate')

SELECT customerName, lastOrderDate
FROM customers
WHERE lastOrderDate < CURDATE() - INTERVAL 1 YEAR;

-- Finding the Percentage Contribution of Each Country to the Total Credit Limit

SELECT country, 
       SUM(creditLimit) AS totalCreditLimit,
       ROUND((SUM(creditLimit) / (SELECT SUM(creditLimit) FROM customers)) * 100, 2) AS percentageContribution
FROM customers
GROUP BY country
ORDER BY percentageContribution DESC;

-- These are Customers Grouped by Initial Letter of the Name

SELECT LEFT(customerName, 1) AS initial, COUNT(*) AS numberOfCustomers
FROM customers
GROUP BY initial
ORDER BY initial;

-- These are Total Revenue by Order

SELECT o.orderNumber, o.orderDate, o.customerNumber,
       SUM(od.quantityOrdered * od.priceEach) AS totalRevenue
FROM orders o
JOIN orderDetails od ON o.orderNumber = od.orderNumber
GROUP BY o.orderNumber, o.orderDate, o.customerNumber
ORDER BY totalRevenue DESC;

-- These are Orders by Status

SELECT o.status, COUNT(*) AS numberOfOrders
FROM orders o
GROUP BY o.status
ORDER BY numberOfOrders DESC;

-- These are Delayed Orders (Shipped After Required Date)

SELECT o.orderNumber, o.orderDate, o.requiredDate, o.shippedDate, 
       DATEDIFF(o.shippedDate, o.requiredDate) AS delayInDays,
       c.customerName
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber
WHERE o.shippedDate > o.requiredDate;

-- These are the Revenue by Customer

SELECT c.customerName, SUM(od.quantityOrdered * od.priceEach) AS totalRevenue
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderDetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerName
ORDER BY totalRevenue DESC;

-- These are Top 5 Products by Sales within a Date Range

SELECT od.productCode, SUM(od.quantityOrdered * od.priceEach) AS totalSales
FROM orderDetails od
JOIN orders o ON od.orderNumber = o.orderNumber
WHERE o.orderDate BETWEEN '2003-07-07' AND '2004-04-03'
GROUP BY od.productCode
ORDER BY totalSales DESC
LIMIT 5;

-- Showing the Average Order Value by Status

SELECT o.status, AVG(orderValue) AS averageOrderValue
FROM (
    SELECT o.orderNumber, o.status, SUM(od.quantityOrdered * od.priceEach) AS orderValue
    FROM orders o
    JOIN orderDetails od ON o.orderNumber = od.orderNumber
    GROUP BY o.orderNumber, o.status
) AS orderTotals
GROUP BY status
ORDER BY averageOrderValue DESC;

-- Customers with the Most Orders

SELECT c.customerName, COUNT(o.orderNumber) AS numberOfOrders
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.customerName
ORDER BY numberOfOrders DESC
LIMIT 5;

-- Orders with the Most Products

SELECT o.orderNumber, COUNT(od.productCode) AS numberOfProducts
FROM orders o
JOIN orderDetails od ON o.orderNumber = od.orderNumber
GROUP BY o.orderNumber
ORDER BY numberOfProducts DESC
LIMIT 5;

-- Total Revenue by Month

SELECT DATE_FORMAT(o.orderDate, '%Y-%m') AS orderMonth,
       SUM(od.quantityOrdered * od.priceEach) AS totalRevenue
FROM orders o
JOIN orderDetails od ON o.orderNumber = od.orderNumber
GROUP BY orderMonth
ORDER BY orderMonth;

-- Find Orders with Missing Ship Date

SELECT o.orderNumber, o.orderDate, o.status, c.customerName
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber
WHERE o.shippedDate IS NULL;

-- product commonly purchased together

With prod_sales as
(
Select orderNumber, t1.productcode, productline
FROM orderdetails t1
inner join products t2
on t1.productcode = t2.productcode
)

Select distinct t1.ordernumber, t1.productline as product_one, t2.productline as product_two
from prod_sales t1
left join prod_sales t2 
on t1.ordernumber = t2.ordernumber and t1.productline <> t2.productline

-- List of Products with Basic Details

SELECT productCode, productName, productLine, quantityInStock, buyPrice, MSRP
FROM products;

-- Show Payments by Customer

SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments;

-- Products with Descriptions Longer Than 100 Characters

SELECT productCode, productName, LENGTH(productDescription) AS descriptionLength
FROM products
WHERE LENGTH(productDescription) > 100;

-- Total Payments per Customer

SELECT customerNumber, SUM(amount) AS totalPayments
FROM payments
GROUP BY customerNumber;

-- Products Sorted by MSRP

SELECT productCode, productName, MSRP
FROM products
ORDER BY MSRP DESC;

-- Payments Above a Certain Amount

SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments
WHERE amount > 500;

-- Products with Stock Levels Below 20

SELECT productCode, productName, quantityInStock
FROM products
WHERE quantityInStock < 20;

-- Most Recent Payment for Each Customer

SELECT customerNumber, MAX(paymentDate) AS mostRecentPaymentDate
FROM payments
GROUP BY customerNumber;

-- Total Amount Paid Per Payment Date

SELECT paymentDate, SUM(amount) AS totalAmount
FROM payments
GROUP BY paymentDate
ORDER BY paymentDate;

-- Products and Their Vendors

SELECT productCode, productName, productVendor
FROM products;

-- temporary table

CREATE TEMPORARY TABLE temp_product_summary (
    productCode VARCHAR(15),
    productName VARCHAR(70),
    productLine VARCHAR(50),
    quantityInStock SMALLINT,
    buyPrice DECIMAL(10,2),
    MSRP DECIMAL(10,2)
);

INSERT INTO temp_product_summary (productCode, productName, productLine, quantityInStock, buyPrice, MSRP)
SELECT productCode, productName, productLine, quantityInStock, buyPrice, MSRP
FROM products;

-- Querying the temporary table
SELECT * 
FROM temp_product_summary;

-- Finding products with stock levels below 20

SELECT productCode, productName, quantityInStock
FROM temp_product_summary
WHERE quantityInStock < 20;

-- Drop the temporary table
DROP TEMPORARY TABLE IF EXISTS temp_product_summary;