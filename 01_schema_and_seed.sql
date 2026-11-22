-- ============================================================================
-- Project: Business Sales & Customer Performance Analysis (SQL)
-- File: 01_schema_and_seed.sql
-- Description: Creates database tables and inserts sample business records.
-- Compatibility: MySQL 8.0+ (see inline comments for SQL Server notes)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS business_sales_db;
USE business_sales_db;

-- Drop existing tables in dependency order for clean re-runs
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- 1. Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    city VARCHAR(60) NOT NULL,
    segment VARCHAR(30) NOT NULL, -- 'Consumer', 'Corporate', 'Home Office'
    signup_date DATE NOT NULL
);

-- 2. Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
);

-- 3. Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL, -- 'Completed', 'Cancelled', 'Returned'
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 4. Order Items Table
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    discount_pct DECIMAL(5, 2) DEFAULT 0.00,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================================================
-- Seed Sample Business Data
-- ============================================================================

INSERT INTO customers (customer_id, full_name, email, city, segment, signup_date) VALUES
(1, 'Aarav Sharma', 'aarav.sharma@example.com', 'Bengaluru', 'Corporate', '2025-01-12'),
(2, 'Priya Nair', 'priya.nair@example.com', 'Mumbai', 'Consumer', '2025-02-04'),
(3, 'Rohan Verma', 'rohan.verma@example.com', 'Delhi', 'Home Office', '2025-02-19'),
(4, 'Ananya Iyer', 'ananya.iyer@example.com', 'Chennai', 'Consumer', '2025-03-10'),
(5, 'Vikram Joshi', 'vikram.joshi@example.com', 'Pune', 'Corporate', '2025-04-01'),
(6, 'Meera Kulkarni', 'meera.kulkarni@example.com', 'Hyderabad', 'Home Office', '2025-04-15'),
(7, 'Siddharth Menon', 'siddharth.menon@example.com', 'Bengaluru', 'Consumer', '2025-05-08');

INSERT INTO products (product_id, product_name, category, unit_price) VALUES
(101, 'Wireless Mechanical Keyboard', 'Electronics', 4500.00),
(102, 'Ergonomic Office Chair', 'Furniture', 12500.00),
(103, 'USB-C Hub Dock', 'Electronics', 2800.00),
(104, 'Standing Desk Mat', 'Office Supplies', 1600.00),
(105, 'Noise-Canceling Headset', 'Electronics', 6200.00),
(106, 'Adjustable Laptop Stand', 'Office Supplies', 2200.00);

INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
(1001, 1, '2025-05-02', 'Completed'),
(1002, 2, '2025-05-14', 'Completed'),
(1003, 1, '2025-06-03', 'Completed'),
(1004, 3, '2025-06-18', 'Cancelled'),
(1005, 4, '2025-07-05', 'Completed'),
(1006, 5, '2025-07-22', 'Completed'),
(1007, 2, '2025-08-09', 'Completed'),
(1008, 6, '2025-08-19', 'Returned'),
(1009, 1, '2025-09-04', 'Completed'),
(1010, 5, '2025-09-21', 'Completed');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, discount_pct) VALUES
(1, 1001, 101, 2, 5.00),
(2, 1001, 103, 1, 0.00),
(3, 1002, 102, 1, 10.00),
(4, 1003, 105, 2, 0.00),
(5, 1004, 104, 3, 0.00),
(6, 1005, 104, 2, 0.00),
(7, 1005, 101, 1, 5.00),
(8, 1006, 102, 2, 15.00),
(9, 1007, 103, 2, 0.00),
(10, 1008, 106, 2, 0.00),
(11, 1009, 105, 1, 10.00),
(12, 1009, 106, 2, 0.00),
(13, 1010, 101, 3, 10.00);
