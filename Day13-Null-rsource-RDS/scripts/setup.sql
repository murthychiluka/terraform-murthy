-- Create tables in RDS MySQL
-- This file is copied to EC2 via file provisioner
-- Then executed via remote-exec provisioner

-- Create tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    done BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO tasks (title, done) VALUES
    ('Learn Terraform', FALSE),
    ('Setup RDS', TRUE),
    ('Connect EC2 to RDS', FALSE);

INSERT INTO users (name, email) VALUES
    ('Murthy', 'murthy@example.com'),
    ('Admin', 'admin@example.com');

-- Verify
SELECT 'Tasks table:' as '';
SELECT * FROM tasks;

SELECT 'Users table:' as '';
SELECT * FROM users;