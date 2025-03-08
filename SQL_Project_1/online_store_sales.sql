-- creating database  
CREATE DATABASE onlinebookstore;

-- switching to Database
USE onlinebookstore;

-- creating books table
DROP TABLE IF EXISTS books;
CREATE TABLE books(
book_id SERIAl PRIMARY KEY,
title VARCHAR(100),
genre VARCHAR(100),
published_year VARCHAR(100),
price NUMERIC(10,2),
stock INT
);

-- creating customers table
DROP TABLE IF EXISTS customers;
CREATE TABLE customers(
customer_id SERIAL PRIMARY KEY,
name VARCHAR(100),
email VARCHAR(100),
phone VARCHAR(15),
city VARCHAR(50),
country VARCHAR(150)
);

-- creating orders table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders(
order_id SERIAL PRIMARY KEY,
customer_id INT REFERENCES customers(customer_id),
book_id INT REFERENCES books(book_id),
order_date Date,
quantity INT,
Total NUMERIC(10,2)
);

SELECT * FROM books;
SELECT * FROM customers;
SELECT * FROM orders;

-- BASIC QUERIES
-- Q1 retrive all the books in 'Fiction' genre
SELECT * FROM books
WHERE genre = 'fiction';

-- Q2 find books published after the year 1950
SELECT * FROM books
WHERE published_year > 1950 ;

-- Q3 list all the customers from Canada
SELECT * FROM customers
WHERE country = 'canada';

-- Q4 show orders placed in november 2023
SELECT * FROM orders
WHERE order_date LIKE "2023-11-%";

-- Q5 retrive the total stocks available
SELECT SUM(stock) as total_stocks_available FROM books;

-- Q6 find the details of the most expensive books available
SELECT * FROM books
ORDER BY price DESC
LIMIT 1; -- FOR THE MOST EXPENSIVE BOOK ONLY / REMOVE THIS LINE YOU WILL GET MOST EXPENSIVE BOOKS LIST

-- Q7 show all the customers who ordered more than 1 quantity of books
SELECT * FROM orders
WHERE quantity > 1;

-- Q8 retrive all orders where the total amount exceeds $20
SELECT * FROM orders
WHERE total_amount > 20 ;

-- Q9 retrive all genre available 
SELECT DISTINCT(genre) Genre FROM books;

-- Q10 find the book with lowest stock
SELECT * FROM books
ORDER BY stock
LIMIT 1;

-- Q11 calculate the total revenue generated from all the orders
SELECT ROUND(SUM(total_amount),2) AS total_revenue FROM orders;


-- ADVANCE QUERIES
-- Q1 retrive the total number of books sold in each Genre
SELECT b.genre , SUM(o.quantity) as total
FROM books b join orders o
on b.book_id = o.book_id
GROUP BY b.genre;

-- Q2 find the avg price of the books in 'fantacy' gerne
SELECT ROUND(AVG(price),2) as avg_price 
FROM books
WHERE genre = 'fantasy';

-- Q3 list out customers who have placed at least 2 orders
SELECT o.customer_id ,c.name , COUNT(o.order_id) AS total_count
FROM orders o JOIN customers c
ON c.customer_id = o.customer_id
GROUP BY o.customer_id ,  c.name
HAVING COUNT(o.order_id) > 1;

-- Q4 find the most frequntly ordered book
SELECT book_id , count(order_id) as Order_times
FROM orders
GROUP BY book_id 
ORDER BY book_id DESC
LIMIT 1;

-- Q5 show the top 3 most expensive books of 'fantasy' genre
SELECT title,price 
FROM books
WHERE genre = 'fantasy'
ORDER BY price DESC
LIMIT 3;

-- Q6 retrive the total quantity of the books sold by the author
SELECT b.author , SUM(o.quantity) AS total_quant
FROM books b  JOIN orders o 
ON b.book_id = o.book_id
GROUP BY b.author
ORDER BY SUM(o.quantity) DESC;

-- Q7 list the cities where customers spends more than $30 
SELECT DISTINCT c.country 
FROM customers c JOIN orders o
ON c.customer_id = o.customer_id
where o.total_amount > 30;

-- Q8 find the customer who spend most on orders
SELECT c.customer_id , SUM(o.total_amount) as total_spent
FROM customers c JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY SUM(o.total_amount) DESC
LIMIT 1;

-- Q9 calculate the stock remaining after fulfilling the orders
SELECT b.book_id ,b.title , b.stock , 
	COALESCE(SUM(o.quantity),0) AS order_quantity ,
	(b.stock - COALESCE(SUM(o.quantity),0)) AS remaining_stock 
FROM books b LEFT JOIN orders o
ON b.book_id = o.book_id
GROUP BY b.book_id , b.title , b.stock;