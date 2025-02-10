-- DATABASE CREATION AND NORMALIZATION
	-- BOLT LOGISTICS
    
CREATE DATABASE Bolt_logistics;
USE Bolt_logistics;

-- Creating tables (Fact table(Shipments), and Dimension Tables - to achieve 3NF)
-- 1. Customers table
CREATE TABLE Customers (
    Customer_ID INT AUTO_INCREMENT PRIMARY KEY,
    Customer_Name VARCHAR(100) NOT NULL,
    Customer_type ENUM('Individual', 'Business'),
    Address TEXT NOT NULL,
    Phone VARCHAR(15) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE
);

-- 2. Clients Table
CREATE TABLE Clients (
    Client_ID INT AUTO_INCREMENT PRIMARY KEY,
    Client_Name VARCHAR(100) NOT NULL,
    Contact_person ENUM('Individual', 'Business'),
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15) UNIQUE NOT NULL,
    Billing_Info TEXT NOT NULL
);

-- 3. Warehouse Table
CREATE TABLE Warehouses (
    Warehouse_ID INT AUTO_INCREMENT PRIMARY KEY,
    Client_ID INT,
    Location VARCHAR(255) NOT NULL,
    Region VARCHAR(100) NOT NULL,
    FOREIGN KEY (Client_ID) REFERENCES Clients(Client_ID) ON DELETE CASCADE
);

-- 4. Orders Table
CREATE TABLE Orders (
    Order_ID INT AUTO_INCREMENT PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Client_ID INT,
    Warehouse_ID INT NOT NULL,
    Order_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Order_Status ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID) ON DELETE CASCADE,
    FOREIGN KEY (Warehouse_ID) REFERENCES Warehouses(Warehouse_ID) ON DELETE CASCADE,
    FOREIGN KEY (Client_ID) REFERENCES Clients(Client_ID) ON DELETE CASCADE
);

-- 5. Route Table
CREATE TABLE Routes (
    Route_ID INT AUTO_INCREMENT PRIMARY KEY,
    Origin VARCHAR(255) NOT NULL,
    Destination VARCHAR(255) NOT NULL,
    Distance DECIMAL(10,2) CHECK (distance >= 0),
    Duration INT CHECK (duration > 0) -- Average duration in minutes
);

-- 6. Drivers Table
CREATE TABLE Drivers (
    Driver_ID INT AUTO_INCREMENT PRIMARY KEY,
    Driver_name VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) UNIQUE NOT NULL,
    experience_level INT CHECK (experience_level BETWEEN 1 AND 10),
    Accident_Count INT NOT NULL
);
-- 7. Vehicles Table
CREATE TABLE Vehicles (
    Vehicle_ID INT AUTO_INCREMENT PRIMARY KEY,
    Vehicle_Type VARCHAR(50) NOT NULL CHECK (vehicle_type IN ('Truck', 'Van', 'Air Cargo')),
    Registration_Number VARCHAR(50) UNIQUE,
    Capacity INT CHECK (capacity > 0),
    Driver_ID INT NOT NULL,
    Mileage DECIMAL(10,2) CHECK (mileage >= 0),
	FOREIGN KEY (Driver_ID) REFERENCES Drivers(Driver_ID) ON DELETE CASCADE
);

-- 8. Carrier Table
CREATE TABLE Carriers (
    Carrier_ID INT AUTO_INCREMENT PRIMARY KEY,
    Carrier_Name VARCHAR(255) NOT NULL,
    Carrier_Type ENUM('Third-Party', 'In-House') NOT NULL,
    Contact_Person VARCHAR(255),
    Phone VARCHAR(20) UNIQUE,
    Email VARCHAR(255) UNIQUE,
    Service_Type ENUM('Air', 'Ground', 'Sea') NOT NULL,
    Average_Delivery_Time TIME,
    Reliability_Score DECIMAL(3,2) CHECK (Reliability_Score BETWEEN 0 AND 5)
);

-- 9. Shipments Table
CREATE TABLE Shipments (
    Shipment_ID INT AUTO_INCREMENT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Vehicle_ID INT,
    Route_ID INT,
    Driver_ID INT,
    Carrier_ID INT,
    Expected_delivery_date DATE NOT NULL,
    Actual_delivery_date DATE,
    Delivery_status ENUM('In Transit', 'Delivered', 'Delayed', 'Cancelled') NOT NULL,
    Shipment_Type	ENUM('Standard', 'Expedited'),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID) ON DELETE CASCADE,
    FOREIGN KEY (Vehicle_ID) REFERENCES Vehicles(Vehicle_ID) ON DELETE SET NULL,
    FOREIGN KEY (Route_ID) REFERENCES Routes(Route_ID) ON DELETE SET NULL,
    FOREIGN KEY (Driver_ID) REFERENCES Drivers(Driver_ID) ON DELETE SET NULL,
    FOREIGN KEY (Carrier_ID) REFERENCES Carriers(Carrier_ID) ON DELETE SET NULL
);

-- 10. Description Table for all the tables
CREATE TABLE Data_Dictionary (
	Table_Name VARCHAR(50),
    Column_Name VARCHAR(50),
    Description TEXT,
    Data_Type VARCHAR(100),
    Related_to VARCHAR(50)
);

-- Insert the description into the table
INSERT INTO data_dictionary (Table_Name, Column_Name, Description, Data_Type, Related_to) VALUES
-- Customers Table
('Customers', 'Customer_ID', 'Unique customer identifier', 'INT (PK, AUTO_INCREMENT)', NULL),
('Customers', 'Name', 'Customer’s full name or business name', 'VARCHAR(255)', NULL),
('Customers', 'Customer_Type', 'Type of customer', "ENUM('Individual', 'Business')", NULL),
('Customers', 'Address', 'Delivery address', 'TEXT', NULL),
('Customers', 'Phone', 'Contact number', 'VARCHAR(20) UNIQUE', NULL),
('Customers', 'Email', 'Contact email', 'VARCHAR(255) UNIQUE', NULL),

-- Clients Table
('Clients', 'Client_ID', 'Unique client identifier', 'INT (PK, AUTO_INCREMENT)', NULL),
('Clients', 'Name', 'Business name', 'VARCHAR(255)', NULL),
('Clients', 'Contact_Person', 'Logistics manager for the client', 'VARCHAR(255)', NULL),
('Clients', 'Email', 'Contact email', 'VARCHAR(255) UNIQUE', NULL),
('Clients', 'Phone', 'Contact number', 'VARCHAR(20) UNIQUE', NULL),
('Clients', 'Billing_Info', 'Payment and billing details', 'TEXT', NULL),

-- Warehouse Table
('Warehouses', 'Warehouse_ID', 'Unique warehouse identifier', 'INT (PK, AUTO_INCREMENT)', NULL),
('Warehouses', 'Client_ID', 'Client who owns/uses this warehouse', 'INT (FK)', 'Clients'),
('Warehouses', 'Location', 'Physical location', 'VARCHAR(255)', NULL),
('Warehouses', 'Region', 'Geographic region', 'VARCHAR(100)', NULL),

-- Orders Table
('Orders', 'Order_ID', 'Unique order identifier', 'INT (PK, AUTO_INCREMENT)', NULL),
('Orders', 'Customer_ID', 'The customer who placed the order', 'INT (FK)', 'Customers'),
('Orders', 'Client_ID', 'The business that owns the order', 'INT (FK)', 'Clients'),
('Orders', 'Warehouse_ID', 'Warehouse from which the order is shipped', 'INT (FK)', 'Warehouses'),
('Orders', 'Order_Date', 'Date the order was placed', 'DATE', NULL),
('Orders', 'Status', 'Order status', "ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled')", NULL),

-- Routes Table
('Routes', 'Route_ID', 'Unique route identifier', 'INT (PK, AUTO_INCREMENT)', NULL),
('Routes', 'Origin', 'Starting location', 'VARCHAR(255)', NULL),
('Routes', 'Destination', 'End location', 'VARCHAR(255)', NULL),
('Routes', 'Distance', 'Distance in kilometers/miles', 'FLOAT', NULL),
('Routes', 'Duration', 'Estimated travel time', 'TIME', NULL),

-- Drivers Table
('Drivers', 'Driver_ID', 'Unique driver identifier', 'INT (PK, AUTO_INCREMENT)', NULL),
('Drivers', 'Name', 'Driver’s full name', 'VARCHAR(255)', NULL),
('Drivers', 'License_Number', 'Unique driver license', 'VARCHAR(50) UNIQUE', NULL),
('Drivers', 'Experience_Level', 'Experience classification', 'INT', NULL),
('Drivers','Accident_Count','Number of Accidents involved in', 'INT', NULL),

-- Vehicles Table
('Vehicles', 'Vehicle_ID', 'Unique vehicle identifier', 'INT (PK, AUTO_INCREMENT)', NULL),
('Vehicles', 'Vehicle_Type', 'Type of vehicle', "ENUM('Truck', 'Van', 'Bike')", NULL),
('Vehicles', 'Registration_Number', 'Unique vehicle number', 'VARCHAR(50) UNIQUE', NULL),
('Vehicles', 'Capacity', 'Maximum load capacity (kg/lbs)', 'INT', NULL),
('Vehicles', 'Driver_ID', 'Assigned driver', 'INT (FK)', 'Drivers'),
('Vehicles', 'Mileage', 'Distance covered', 'FLOAT', NULL),

-- Carrier Table
('Carriers', 'Carrier_ID', 'Unique carrier identifier', 'INT (PK, AUTO_INCREMENT)', NULL),
('Carriers', 'Name', 'Carrier company name', 'VARCHAR(255)', NULL),
('Carriers', 'Carrier_Type', 'External or company-owned carrier', "ENUM('Third-Party', 'In-House')", NULL),
('Carriers', 'Contact_Person', 'Carrier contact', 'VARCHAR(255)', NULL),
('Carriers', 'Phone', 'Contact number', 'VARCHAR(20) UNIQUE', NULL),
('Carriers', 'Email', 'Contact email', 'VARCHAR(255) UNIQUE', NULL),
('Carriers', 'Service_Type', 'Mode of transport', "ENUM('Air', 'Ground', 'Sea')", NULL),
('Carriers', 'Average_Delivery_Time', 'Expected delivery time', 'TIME', NULL),
('Carriers', 'Reliability_Score', 'Performance rating', 'DECIMAL(3,2)', NULL),


-- Shipments Table
('Shipments', 'Shipment_ID', 'Unique shipment identifier', 'INT (PK, AUTO_INCREMENT)', NULL),
('Shipments', 'Order_ID', 'The order being shipped', 'INT (FK)', 'Orders'),
('Shipments', 'Vehicle_ID', 'Vehicle used for transport', 'INT (FK)', 'Vehicles'),
('Shipments', 'Route_ID', 'Assigned route', 'INT (FK)', 'Routes'),
('Shipments', 'Driver_ID', 'Assigned Driver', 'INT (FK)', 'Drivers'),
('Shipments', 'Carrier_ID', 'The carrier handling the shipment', 'INT (FK)', 'Carriers'),
('Shipments', 'Expected_Delivery_Date', 'Estimated delivery date', 'DATE', NULL),
('Shipments', 'Actual_Delivery_Date', 'Actual delivery date (NULL if not delivered yet)', 'DATE', NULL),
('Shipments', 'Delivery_status', 'Status of Delivery', "ENUM('In Transit', 'Delivered', 'Delayed', 'Cancelled')", NULL),
('Shipments', 'Shipment_Type', 'Type of shipment', "ENUM('Standard', 'Expedited')", NULL);

-- Confirmation of Data entry
SELECT * FROM data_dictionary;

-- Applying Indexes for faster Query Performance
# Customers table
CREATE INDEX idx_customers_email ON Customers(Email);
CREATE INDEX idx_customers_phone ON Customers(Phone);

# Clients table
CREATE INDEX idx_clients_company ON Clients(Company_Name);

# Orders Table
CREATE INDEX idx_orders_customer ON Orders(Customer_ID);
CREATE INDEX idx_orders_warehouse ON Orders(Warehouse_ID);
CREATE INDEX idx_orders_date ON Orders(Order_Date);
CREATE INDEX idx_orders_status ON Orders(Status);

# Carriers table
CREATE INDEX idx_carriers_name ON Carriers(Carrier_Name);

# Warehouse table
CREATE INDEX idx_warehouses_location ON Warehouses(Location);

# Routes table
CREATE INDEX idx_routes_origin ON Routes(Origin);
CREATE INDEX idx_routes_destination ON Routes(Destination);

# Vehicle table
CREATE INDEX idx_vehicles_reg ON Vehicles(Registration_Number);

# Shipment Table
CREATE INDEX idx_shipments_order ON Shipments(Order_ID);
CREATE INDEX idx_shipments_carrier ON Shipments(Carrier_ID);
CREATE INDEX idx_shipments_expected_delivery ON Shipments(Expected_Delivery_Date);


/* 
With this database of a logistics oprations company, one can use it to conduct various analysis such as:-
	1. Finding the delivery efficiency by region
    2. Identifying popular routes
    3. Creating a risk score for drivers based on accident count
    4. Delivery Rate
    5. Carrier Performance Analysis
    6. Warehouse Utilization
    7. Route & Logistics Optimization
    8. Fleet Utilization & Fuel Efficiency
    9. Financial & Business Insights
    10. Lost Business Analysis e.g Cancelled Orders
*/

