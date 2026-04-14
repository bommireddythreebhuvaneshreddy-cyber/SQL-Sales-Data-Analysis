CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    price NUMERIC(10,2)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT
);

INSERT INTO customers (customer_name, city) VALUES
('Ravi Kumar', 'Hyderabad'),
('Anjali Sharma', 'Mumbai'),
('Rahul Verma', 'Delhi');

INSERT INTO products (product_name, price) VALUES
('Laptop', 50000),
('Mouse', 500),
('Keyboard', 1500);

INSERT INTO orders (customer_id, order_date) VALUES
(1, '2025-01-15'),
(2, '2025-02-10'),
(1, '2025-03-05');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 3, 1),
(3, 2, 3);



SELECT 
    o.order_id,
    c.customer_name,
    SUM(p.price * oi.quantity) AS total_sales
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id
JOIN order_items oi 
    ON o.order_id = oi.order_id
JOIN products p 
    ON oi.product_id = p.product_id
GROUP BY o.order_id, c.customer_name;



SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM') AS month,
    SUM(p.price * oi.quantity) AS monthly_revenue
FROM orders o
JOIN order_items oi 
    ON o.order_id = oi.order_id
JOIN products p 
    ON oi.product_id = p.product_id
GROUP BY month
ORDER BY month;




SELECT customer_name, total_spent
FROM (
    SELECT 
        c.customer_name,
        SUM(p.price * oi.quantity) AS total_spent
    FROM customers c
    JOIN orders o 
        ON c.customer_id = o.customer_id
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    JOIN products p 
        ON oi.product_id = p.product_id
    GROUP BY c.customer_name
) customer_totals
WHERE total_spent > (
    SELECT AVG(total_spent)
    FROM (
        SELECT 
            SUM(p.price * oi.quantity) AS total_spent
        FROM orders o
        JOIN order_items oi 
            ON o.order_id = oi.order_id
        JOIN products p 
            ON oi.product_id = p.product_id
        GROUP BY o.customer_id
    ) avg_data
);


SELECT 
    o.order_date,
    SUM(p.price * oi.quantity) AS daily_sales,
    SUM(SUM(p.price * oi.quantity))
        OVER (ORDER BY o.order_date)
        AS running_total
FROM orders o
JOIN order_items oi 
    ON o.order_id = oi.order_id
JOIN products p 
    ON oi.product_id = p.product_id
GROUP BY o.order_date;


SELECT 
    customer_name,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS rank_position
FROM (
    SELECT 
        c.customer_name,
        SUM(p.price * oi.quantity) AS total_spent
    FROM customers c
    JOIN orders o 
        ON c.customer_id = o.customer_id
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    JOIN products p 
        ON oi.product_id = p.product_id
    GROUP BY c.customer_name
) ranked_data;
