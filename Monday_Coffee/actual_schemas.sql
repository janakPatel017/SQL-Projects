DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS city;

-- Import Rules
-- 1st import to city
-- 2nd import to products
-- 3rd import to customers
-- 4th import to sales


CREATE TABLE city
(
	city_id	INT PRIMARY KEY,
	city_name VARCHAR(15),	
	population	BIGINT,
	estimated_rent	FLOAT,
	city_rank INT
);

CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,	
	customer_name VARCHAR(25),	
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);


CREATE TABLE products
(
	product_id	INT PRIMARY KEY,
	product_name VARCHAR(35),	
	Price float
);


CREATE TABLE sales
(
	sale_id	INT PRIMARY KEY,
	sale_date	date,
	product_id	INT ,
	customer_id	INT,
	total FLOAT,
	rating INT,
	 CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES Products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) 
);
-- END of SCHEMAS

-- COPYING DATA FROM CSV FILES AVAILABLE TO USE FROM SITE
COPY public.city FROM 'D:\POWER BI PROJECTS TO PUT IN RESUME\Monday_coffee_sql_project\city.csv' DELIMITER ',' CSV HEADER;
COPY public.customers FROM 'D:\POWER BI PROJECTS TO PUT IN RESUME\Monday_coffee_sql_project\customers.csv' DELIMITER ',' CSV HEADER;
COPY public.products FROM 'D:\POWER BI PROJECTS TO PUT IN RESUME\Monday_coffee_sql_project\products.csv' DELIMITER ',' CSV HEADER;
COPY public.sales FROM 'D:\POWER BI PROJECTS TO PUT IN RESUME\Monday_coffee_sql_project\sales.csv' DELIMITER ',' CSV HEADER;