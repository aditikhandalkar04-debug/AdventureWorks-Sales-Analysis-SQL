-- Q1. What is the total order quantity for each year?
SELECT 2015 as Year,  sum(orderquantity) as Totalquantity 
from adventureworks_sales_2015
UNION ALL
SELECT 2016 as Year,  sum(orderquantity) as Totalquantity 
from adventureworks_sales_2016
UNION ALL
SELECT 2017 as Year,  sum(orderquantity) as Totalquantity 
from adventureworks_sales_2017
ORDER BY Year;

2--Find the total sales amount for each year from 2015 to 2017.”
SELECT 2015 AS year, SUM(p.productprice* s.orderquantity) as Totalamount
FROM adventureworks_products p
JOIN adventureworks_sales_2015 s
ON p.productkey = s.productkey
Union all
SELECT 2016 AS year, SUM(p.productprice * s.orderquantity) as Totalamount
FROM adventureworks_products p
JOIN adventureworks_sales_2016 s
ON p.productkey = s.productkey
union all
SELECT 2017 AS year, SUM(p.productprice * s.orderquantity) as Totalamount
FROM adventureworks_products p
JOIN adventureworks_sales_2017 s
ON p.productkey = s.productkey
order by year;



--  Q3: Category-wise Total Sales (2015–2017)
SELECT categoryname,
SUM(sales) AS Total_sales
FROM(
SELECT 2015 as sales_year, c.categoryname, SUM(p.productprice * s.orderquantity) as sales
FROM adventureworks_products p
JOIN adventureworks_product_subcategory sub
ON p.productsubcategorykey = sub.productsubcategorykey
JOIN adventureworks_product_category c
ON c.productcategorykey = sub.productcategorykey
JOIN adventureworks_sales_2015 s
ON p.productkey = s.productkey
GROUP BY c.categoryname
UNION ALL
SELECT 2016 as sales_year, c.categoryname, SUM(p.productprice * s.orderquantity) as sales
FROM adventureworks_products p
JOIN adventureworks_product_subcategory sub
ON p.productsubcategorykey = sub.productsubcategorykey
JOIN adventureworks_product_category c
ON c.productcategorykey = sub.productcategorykey
JOIN adventureworks_sales_2016 s
ON p.productkey = s.productkey
GROUP BY c.categoryname
UNION ALL
SELECT 2017 as sales_year, c.categoryname, SUM(p.productprice * s.orderquantity) as sales
FROM adventureworks_products p
JOIN adventureworks_product_subcategory sub
ON p.productsubcategorykey = sub.productsubcategorykey
JOIN adventureworks_product_category c
ON c.productcategorykey = sub.productcategorykey
JOIN adventureworks_sales_2017 s
ON p.productkey = s.productkey
GROUP BY c.categoryname
) as t
GROUP BY categoryname
ORDER BY total_sales DESC;


-- Q4: Top 10 Products by Total Sales

SELECT * FROM adventureworks_products;
SELECT * FROM adventureworks_sales_2015;

SELECT productname,
       SUM(total_sales) AS total_sales
FROM (
    SELECT p.productname,
           SUM(p.productprice * s.orderquantity) AS total_sales
    FROM adventureworks_products p
    JOIN adventureworks_sales_2015 s
        ON p.productkey = s.productkey
    GROUP BY p.productname

    UNION ALL

    SELECT p.productname,
           SUM(p.productprice * s.orderquantity) AS total_sales
    FROM adventureworks_products p
    JOIN adventureworks_sales_2016 s
        ON p.productkey = s.productkey
    GROUP BY p.productname

    UNION ALL

    SELECT p.productname,
           SUM(p.productprice * s.orderquantity) AS total_sales
    FROM adventureworks_products p
    JOIN adventureworks_sales_2017 s
        ON p.productkey = s.productkey
    GROUP BY p.productname
) AS t
GROUP BY productname
ORDER BY total_sales DESC
LIMIT 10;


5-- “Customer Segmentation: Classify customers into High, Medium, and Low segments based on their total sales from 2015 to 2017.”
WITH customer_sales as (
	SELECT c.customerkey, c.firstname, c.lastname, SUM(p.productprice * s.orderquantity) as Total_sales
	FROM adventureworks_customers c
	JOIN adventureworks_sales_2015 s
	ON c.customerkey = s.customerkey
	JOIN adventureworks_products p
	ON p.productkey = s.productkey
	GROUP BY c.customerkey, c.firstname, c.lastname
   
UNION ALL

	SELECT c.customerkey, c.firstname, c.lastname, SUM(p.productprice * s.orderquantity) as Total_sales
	FROM adventureworks_customers c
	JOIN adventureworks_sales_2016 s
	ON c.customerkey = s.customerkey
	JOIN adventureworks_products p
	ON p.productkey = s.productkey
	GROUP BY c.customerkey, c.firstname, c.lastname 

UNION ALL
	SELECT c.customerkey, c.firstname, c.lastname,  SUM(p.productprice * s.orderquantity) as Total_sales
	FROM adventureworks_customers c
	JOIN adventureworks_sales_2017 s
	ON c.customerkey = s.customerkey
	JOIN adventureworks_products p
	ON p.productkey = s.productkey
	GROUP BY c.customerkey, c.firstname, c.lastname	
) 
SELECT customerkey, firstname, lastname,
SUM(Total_sales) as total_sales 
FROM customer_sales 
GROUP BY customerkey, firstname, lastname
ORDER BY Total_sales DESC 
LIMIT 10;


WITH totalsales AS (
SELECT c.customerkey, c.firstname, c.lastname, SUM(p.productprice * s.orderquantity) as total_sales
FROM adventureworks_customers c
JOIN adventureworks_sales_2015 s
ON c.customerkey = s.customerkey
JOIN adventureworks_products p
ON p.productkey = s.productkey
GROUP BY c.customerkey, c.firstname, c.lastname

UNION ALL

SELECT c.customerkey, c.firstname, c.lastname, SUM(p.productprice * s.orderquantity) as total_sales
FROM adventureworks_customers c
JOIN adventureworks_sales_2016 s
ON c.customerkey = s.customerkey
JOIN adventureworks_products p
ON p.productkey = s.productkey
GROUP BY c.customerkey, c.firstname, c.lastname

UNION ALL

SELECT c.customerkey,c.firstname, c.lastname, SUM(p.productprice * s.orderquantity) as total_sales
FROM adventureworks_customers c
JOIN adventureworks_sales_2017 s
ON c.customerkey = s.customerkey
JOIN adventureworks_products p
ON p.productkey = s.productkey
GROUP BY c.customerkey, c.firstname, c.lastname
),


total_customer_sales AS(
SELECT customerkey, firstname, lastname, SUM(total_sales) AS total_sales
FROM totalsales
GROUP BY customerkey, firstname, lastname
)
SELECT customerkey, firstname, lastname, total_sales,
	CASE
		WHEN total_sales >= 20000 THEN 'High' 
		WHEN total_sales >= 10000 THEN 'Medium'
		ELSE 'Low'
END AS customer_segment
FROM total_customer_sales
ORDER BY total_sales DESC;


6-- Which product categories sold more than 5,000 units across all available sales?
SELECT c.categoryname, SUM(s.orderquantity) as total_quantity
FROM adventureworks_sales_2015 s
JOIN adventureworks_products p
ON p.productkey = s.productkey
JOIN  adventureworks_product_subcategory sub
ON p.productsubcategorykey = sub.productsubcategorykey
JOIN adventureworks_product_category c
ON sub.productcategorykey = c.productcategorykey
GROUP BY c.categoryname
HAVING SUM(s.orderquantity) > 5000;


7 -- Find the total sales amount for each country from 2015 to 2017 and display the countries in 
--descending order of total sales
WITH country_wise_sales AS (
    SELECT 
        2015 AS sales_year,
        t.country,
        SUM(p.productprice * s.orderquantity) AS total_sales
    FROM adventureworks_sales_2015 s
    JOIN adventureworks_territories t
        ON s.territorykey = t.salesterritorykey
    JOIN adventureworks_products p
        ON p.productkey = s.productkey
    GROUP BY t.country

    UNION ALL

    SELECT 
        2016 AS sales_year,
        t.country,
        SUM(p.productprice * s.orderquantity) AS total_sales
    FROM adventureworks_sales_2016 s
    JOIN adventureworks_territories t
        ON s.territorykey = t.salesterritorykey
    JOIN adventureworks_products p
        ON p.productkey = s.productkey
    GROUP BY t.country

    UNION ALL

    SELECT 
        2017 AS sales_year,
        t.country,
        SUM(p.productprice * s.orderquantity) AS total_sales
    FROM adventureworks_sales_2017 s
    JOIN adventureworks_territories t
        ON s.territorykey = t.salesterritorykey
    JOIN adventureworks_products p
        ON p.productkey = s.productkey
    GROUP BY t.country
)
SELECT 
    sales_year,
    country,
    total_sales
FROM country_wise_sales
ORDER BY sales_year, total_sales DESC;


8-- Find the top 10 customers based on the total number of products they purchased from 2015 to 2017.
SELECT customerkey,
       firstname,
       lastname,
       SUM(TotalQuantity) AS TotalQuantity
FROM (
    SELECT 2015 AS year,
           c.customerkey, c.firstname, c.lastname,
           SUM(s.orderquantity) AS TotalQuantity
    FROM adventureworks_customers c
    JOIN adventureworks_sales_2015 s
        ON c.customerkey = s.customerkey
    GROUP BY c.customerkey, c.firstname, c.lastname

    UNION ALL

    SELECT 2016 AS year,
           c.customerkey, c.firstname, c.lastname,
           SUM(s.orderquantity) AS TotalQuantity
    FROM adventureworks_customers c
    JOIN adventureworks_sales_2016 s
        ON c.customerkey = s.customerkey
    GROUP BY c.customerkey, c.firstname, c.lastname

    UNION ALL

    SELECT 2017 AS year,
           c.customerkey, c.firstname, c.lastname,
           SUM(s.orderquantity) AS TotalQuantity
    FROM adventureworks_customers c
    JOIN adventureworks_sales_2017 s
        ON c.customerkey = s.customerkey
    GROUP BY c.customerkey, c.firstname, c.lastname

) AS orderquantity
GROUP BY customerkey, firstname, lastname
ORDER BY TotalQuantity DESC
LIMIT 10;


-- Which products have the highest return quantity?
SELECT p.productname, SUM(r.returnquantity) as Total_return
FROM adventureworks_products p
JOIN adventureworks_returns r
ON p.productkey = r.productkey
GROUP BY p.productname
ORDER BY Total_return DESC;


9-- Which product categories have the highest return rate?

WITH sold_quantity AS (
SELECT c.categoryname, SUM(s.orderquantity) AS total_sold
FROM adventureworks_sales_2015 s
JOIN adventureworks_products p
ON s.productkey = p.productkey
JOIN  adventureworks_product_subcategory sub
ON p.productsubcategorykey = sub.productsubcategorykey
JOIN adventureworks_product_category c
ON sub.productcategorykey  = c.productcategorykey
GROUP BY c.categoryname

UNION ALL

SELECT c.categoryname, SUM(s.orderquantity) AS total_sold
FROM adventureworks_sales_2016 s
JOIN adventureworks_products p
ON s.productkey = p.productkey
JOIN  adventureworks_product_subcategory sub
ON p.productsubcategorykey = sub.productsubcategorykey
JOIN adventureworks_product_category c
ON sub.productcategorykey  = c.productcategorykey
GROUP BY c.categoryname

UNION ALL

SELECT c.categoryname, SUM(s.orderquantity) AS total_sold
FROM adventureworks_sales_2017 s
JOIN adventureworks_products p
ON s.productkey = p.productkey
JOIN  adventureworks_product_subcategory sub
ON p.productsubcategorykey = sub.productsubcategorykey
JOIN adventureworks_product_category c
ON sub.productcategorykey  = c.productcategorykey
GROUP BY c.categoryname

),
total_slod as(
SELECT 
	categoryname,
	SUM(total_sold) AS total_sold
FROM sold_quantity
GROUP BY categoryname
),

total_return AS (
SELECT c.categoryname,
SUM(r.returnquantity) as total_return
FROM adventureworks_returns r
JOIN adventureworks_products p
ON r.productkey = p.productkey
JOIN adventureworks_product_subcategory sub
ON p.productsubcategorykey = sub.productsubcategorykey
JOIN adventureworks_product_category c
ON sub.productcategorykey = c.productcategorykey
GROUP BY c.categoryname
)

SELECT s.categoryname,
		s.total_sold,
		r.total_return,
		ROUND((r.total_return * 100.0 / s.total_sold),2) as return_rate
FROM total_slod s
JOIN total_return r
	ON s.categoryname = r.categoryname
ORDER BY return_rate DESC;

--What is the monthly sales trend from 2015 to 2017?
SELECT 
    EXTRACT(YEAR FROM s.orderdate) AS sales_year,
    EXTRACT(MONTH FROM s.orderdate) AS sales_month,
    SUM(p.productprice * s.orderquantity) AS monthly_sales
FROM adventureworks_sales_2015 s
JOIN adventureworks_products p
    ON p.productkey = s.productkey
GROUP BY 
    EXTRACT(YEAR FROM s.orderdate),
    EXTRACT(MONTH FROM s.orderdate)

UNION ALL

SELECT 
    EXTRACT(YEAR FROM s.orderdate) AS sales_year,
    EXTRACT(MONTH FROM s.orderdate) AS sales_month,
    SUM(p.productprice * s.orderquantity) AS monthly_sales
FROM adventureworks_sales_2016 s
JOIN adventureworks_products p
    ON p.productkey = s.productkey
GROUP BY 
    EXTRACT(YEAR FROM s.orderdate),
    EXTRACT(MONTH FROM s.orderdate)

UNION ALL

SELECT 
    EXTRACT(YEAR FROM s.orderdate) AS sales_year,
    EXTRACT(MONTH FROM s.orderdate) AS sales_month,
    SUM(p.productprice * s.orderquantity) AS monthly_sales
FROM adventureworks_sales_2017 s
JOIN adventureworks_products p
    ON p.productkey = s.productkey
GROUP BY 
    EXTRACT(YEAR FROM s.orderdate),
    EXTRACT(MONTH FROM s.orderdate)
ORDER BY sales_year, sales_month;











