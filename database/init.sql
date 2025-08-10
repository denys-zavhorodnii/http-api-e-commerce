-- E-commerce Database Schema
-- This script creates the database structure and populates it with sample data

-- Drop tables if they exist (for clean initialization)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS product_images;
DROP TABLE IF EXISTS product_categories;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS brands;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS users;

-- Create users table
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    country TEXT DEFAULT 'USA',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create suppliers table
CREATE TABLE suppliers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    contact_person TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    country TEXT DEFAULT 'USA',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create brands table
CREATE TABLE brands (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    logo_url TEXT,
    website TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create categories table
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    parent_id INTEGER,
    image_url TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Create products table
CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    sku TEXT UNIQUE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    sale_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    brand_id INTEGER,
    supplier_id INTEGER,
    stock_quantity INTEGER DEFAULT 0,
    min_stock_level INTEGER DEFAULT 5,
    weight DECIMAL(8,2),
    dimensions TEXT, -- "LxWxH in inches"
    is_active BOOLEAN DEFAULT 1,
    is_featured BOOLEAN DEFAULT 0,
    rating_average DECIMAL(3,2) DEFAULT 0.00,
    rating_count INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE SET NULL,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
);

-- Create product_categories table (many-to-many relationship)
CREATE TABLE product_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    UNIQUE(product_id, category_id)
);

-- Create product_images table
CREATE TABLE product_images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    image_url TEXT NOT NULL,
    alt_text TEXT,
    is_primary BOOLEAN DEFAULT 0,
    sort_order INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Create reviews table
CREATE TABLE reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title TEXT,
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT 0,
    is_approved BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create orders table
CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_number TEXT UNIQUE NOT NULL,
    user_id INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending', -- pending, processing, shipped, delivered, cancelled
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    shipping_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    shipping_address TEXT,
    shipping_city TEXT,
    shipping_state TEXT,
    shipping_zip_code TEXT,
    shipping_country TEXT,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create order_items table
CREATE TABLE order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    product_name TEXT NOT NULL,
    product_sku TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Insert sample data

-- Users
INSERT INTO users (username, email, first_name, last_name, phone, address, city, state, zip_code) VALUES
('john_doe', 'john@example.com', 'John', 'Doe', '555-0101', '123 Main St', 'New York', 'NY', '10001'),
('jane_smith', 'jane@example.com', 'Jane', 'Smith', '555-0102', '456 Oak Ave', 'Los Angeles', 'CA', '90210'),
('bob_wilson', 'bob@example.com', 'Bob', 'Wilson', '555-0103', '789 Pine Rd', 'Chicago', 'IL', '60601'),
('alice_brown', 'alice@example.com', 'Alice', 'Brown', '555-0104', '321 Elm St', 'Houston', 'TX', '77001'),
('charlie_davis', 'charlie@example.com', 'Charlie', 'Davis', '555-0105', '654 Maple Dr', 'Phoenix', 'AZ', '85001'),
('diana_miller', 'diana@example.com', 'Diana', 'Miller', '555-0106', '987 Cedar Ln', 'Miami', 'FL', '33101'),
('edward_taylor', 'edward@example.com', 'Edward', 'Taylor', '555-0107', '147 Birch St', 'Seattle', 'WA', '98101'),
('fiona_clark', 'fiona@example.com', 'Fiona', 'Clark', '555-0108', '258 Spruce Ave', 'Boston', 'MA', '02101'),
('george_white', 'george@example.com', 'George', 'White', '555-0109', '369 Willow Rd', 'Denver', 'CO', '80201'),
('helen_jones', 'helen@example.com', 'Helen', 'Jones', '555-0110', '741 Aspen Dr', 'San Francisco', 'CA', '94101');

-- Suppliers
INSERT INTO suppliers (name, contact_person, email, phone, address, city, state, zip_code) VALUES
('TechSupply Co', 'Mike Johnson', 'mike@techsupply.com', '555-1001', '100 Industrial Blvd', 'Austin', 'TX', '73301'),
('Global Electronics', 'Sarah Chen', 'sarah@globalelec.com', '555-1002', '200 Tech Park', 'San Jose', 'CA', '95110'),
('Quality Parts Inc', 'David Lee', 'david@qualityparts.com', '555-1003', '300 Manufacturing Ave', 'Detroit', 'MI', '48201'),
('Smart Solutions', 'Lisa Wang', 'lisa@smartsolutions.com', '555-1004', '400 Innovation Dr', 'Seattle', 'WA', '98101'),
('Premium Components', 'Tom Anderson', 'tom@premiumcomp.com', '555-1005', '500 Quality St', 'Boston', 'MA', '02101'),
('Gaming Gear Supply', 'Alex Rodriguez', 'alex@gaminggear.com', '555-1006', '600 Gaming St', 'Las Vegas', 'NV', '89101'),
('Audio Solutions', 'Maria Garcia', 'maria@audiosolutions.com', '555-1007', '700 Sound Ave', 'Nashville', 'TN', '37201'),
('Eco Supplies', 'James Wilson', 'james@ecosupplies.com', '555-1008', '800 Green Blvd', 'Portland', 'OR', '97201'),
('Pet Supply Co', 'Emma Thompson', 'emma@petsupply.com', '555-1009', '900 Pet Lane', 'Denver', 'CO', '80201'),
('Auto Parts Plus', 'Robert Martinez', 'robert@autoparts.com', '555-1010', '1000 Car Dr', 'Atlanta', 'GA', '30301');

-- Brands
INSERT INTO brands (name, description, logo_url, website) VALUES
('TechPro', 'Professional grade technology solutions', 'https://example.com/logos/techpro.png', 'https://techpro.com'),
('SmartLife', 'Smart home and lifestyle products', 'https://example.com/logos/smartlife.png', 'https://smartlife.com'),
('EcoTech', 'Environmentally friendly technology', 'https://example.com/logos/ecotech.png', 'https://ecotech.com'),
('PowerMax', 'High-performance power solutions', 'https://example.com/logos/powermax.png', 'https://powermax.com'),
('InnovateCorp', 'Cutting-edge innovation company', 'https://example.com/logos/innovatecorp.png', 'https://innovatecorp.com'),
('GameMaster', 'Premium gaming equipment and accessories', 'https://example.com/logos/gamemaster.png', 'https://gamemaster.com'),
('SoundWave', 'High-quality audio equipment', 'https://example.com/logos/soundwave.png', 'https://soundwave.com'),
('GreenLiving', 'Sustainable and eco-friendly products', 'https://example.com/logos/greenliving.png', 'https://greenliving.com'),
('PetCare Plus', 'Premium pet care and accessories', 'https://example.com/logos/petcareplus.png', 'https://petcareplus.com'),
('AutoTech', 'Automotive technology and accessories', 'https://example.com/logos/autotech.png', 'https://autotech.com');

-- Categories (with hierarchy)
INSERT INTO categories (name, description, parent_id, image_url) VALUES
('Electronics', 'Electronic devices and components', NULL, 'https://example.com/categories/electronics.jpg'),
('Computers', 'Desktop and laptop computers', 1, 'https://example.com/categories/computers.jpg'),
('Smartphones', 'Mobile phones and accessories', 1, 'https://example.com/categories/smartphones.jpg'),
('Gaming', 'Gaming equipment and accessories', 1, 'https://example.com/categories/gaming.jpg'),
('Audio', 'Audio equipment and accessories', 1, 'https://example.com/categories/audio.jpg'),
('Home & Garden', 'Home improvement and garden products', NULL, 'https://example.com/categories/home-garden.jpg'),
('Kitchen', 'Kitchen appliances and tools', 6, 'https://example.com/categories/kitchen.jpg'),
('Outdoor', 'Outdoor and camping equipment', 6, 'https://example.com/categories/outdoor.jpg'),
('Smart Home', 'Smart home automation products', 6, 'https://example.com/categories/smart-home.jpg'),
('Garden', 'Garden tools and equipment', 6, 'https://example.com/categories/garden.jpg'),
('Fashion', 'Clothing and accessories', NULL, 'https://example.com/categories/fashion.jpg'),
('Men', 'Men''s clothing and accessories', 11, 'https://example.com/categories/men.jpg'),
('Women', 'Women''s clothing and accessories', 11, 'https://example.com/categories/women.jpg'),
('Sports', 'Sports equipment and apparel', NULL, 'https://example.com/categories/sports.jpg'),
('Fitness', 'Fitness equipment and accessories', 14, 'https://example.com/categories/fitness.jpg'),
('Outdoor Sports', 'Outdoor sports and recreation', 14, 'https://example.com/categories/outdoor-sports.jpg'),
('Books', 'Books and educational materials', NULL, 'https://example.com/categories/books.jpg'),
('Fiction', 'Fiction books and novels', 17, 'https://example.com/categories/fiction.jpg'),
('Non-Fiction', 'Non-fiction and educational books', 17, 'https://example.com/categories/non-fiction.jpg'),
('Automotive', 'Automotive accessories and equipment', NULL, 'https://example.com/categories/automotive.jpg'),
('Pet Supplies', 'Pet care and accessories', NULL, 'https://example.com/categories/pet-supplies.jpg'),
('Health & Wellness', 'Health and wellness products', NULL, 'https://example.com/categories/health-wellness.jpg'),
('Office', 'Office supplies and equipment', NULL, 'https://example.com/categories/office.jpg');

-- Products
INSERT INTO products (name, description, sku, price, sale_price, cost_price, brand_id, supplier_id, stock_quantity, min_stock_level, weight, dimensions, is_featured, rating_average, rating_count) VALUES
('TechPro Laptop Pro', 'High-performance laptop with 16GB RAM and 512GB SSD', 'TP-LP-001', 1299.99, 1199.99, 800.00, 1, 1, 25, 5, 4.5, '14x9.5x0.7', 1, 4.6, 128),
('SmartLife Smartphone X', '5G smartphone with 128GB storage and triple camera', 'SL-SX-001', 899.99, 849.99, 600.00, 2, 2, 50, 10, 0.4, '6.1x3.0x0.3', 1, 4.4, 89),
('EcoTech Solar Panel', '100W portable solar panel for outdoor use', 'ET-SP-001', 199.99, NULL, 120.00, 3, 3, 15, 3, 8.0, '20x15x1', 0, 4.8, 45),
('PowerMax Wireless Charger', 'Fast wireless charging pad for smartphones', 'PM-WC-001', 79.99, 69.99, 35.00, 4, 4, 100, 20, 0.3, '4x4x0.2', 0, 4.2, 67),
('InnovateCorp Smart Watch', 'Fitness tracking smartwatch with heart rate monitor', 'IC-SW-001', 299.99, NULL, 180.00, 5, 5, 30, 8, 0.1, '1.5x1.5x0.3', 1, 4.5, 156),
('TechPro Gaming Mouse', 'RGB gaming mouse with 16000 DPI sensor', 'TP-GM-001', 89.99, 79.99, 45.00, 1, 1, 75, 15, 0.2, '5x3x1.5', 0, 4.3, 92),
('SmartLife Bluetooth Speaker', 'Portable waterproof Bluetooth speaker', 'SL-BS-001', 129.99, 109.99, 70.00, 2, 2, 40, 8, 1.2, '8x3x3', 0, 4.1, 78),
('EcoTech LED Bulb Pack', 'Energy-efficient LED bulbs, pack of 4', 'ET-LB-001', 24.99, 19.99, 12.00, 3, 3, 200, 40, 0.1, '2x2x4', 0, 4.7, 234),
('PowerMax Power Bank', '20000mAh portable power bank with fast charging', 'PM-PB-001', 59.99, 49.99, 30.00, 4, 4, 60, 12, 0.8, '6x3x1', 0, 4.4, 89),
('InnovateCorp VR Headset', 'Virtual reality headset for gaming and entertainment', 'IC-VR-001', 399.99, 349.99, 250.00, 5, 5, 20, 5, 1.5, '10x8x6', 1, 4.6, 67),
('TechPro Mechanical Keyboard', 'RGB mechanical keyboard with Cherry MX switches', 'TP-MK-001', 149.99, 129.99, 80.00, 1, 1, 35, 7, 2.1, '14x5x1', 0, 4.5, 123),
('SmartLife Security Camera', '1080p wireless security camera with night vision', 'SL-SC-001', 89.99, 79.99, 55.00, 2, 2, 45, 9, 0.5, '3x3x2', 0, 4.2, 98),
('EcoTech Smart Thermostat', 'WiFi-enabled smart thermostat for home automation', 'ET-ST-001', 199.99, 179.99, 110.00, 3, 3, 25, 5, 0.3, '4x4x1', 0, 4.6, 87),
('PowerMax Surge Protector', '8-outlet surge protector with USB charging ports', 'PM-SP-001', 39.99, 34.99, 20.00, 4, 4, 80, 16, 0.8, '12x3x1', 0, 4.3, 145),
('InnovateCorp Drone', '4K camera drone with GPS and obstacle avoidance', 'IC-DR-001', 599.99, 549.99, 350.00, 5, 5, 15, 3, 2.5, '12x12x4', 1, 4.7, 78),
('TechPro Gaming Headset', '7.1 surround sound gaming headset with noise cancellation', 'TP-GH-001', 129.99, 109.99, 65.00, 1, 1, 40, 8, 0.8, '8x7x4', 0, 4.4, 156),
('SmartLife Smart Bulb', 'WiFi-enabled color-changing smart bulb', 'SL-SB-001', 34.99, 29.99, 18.00, 2, 2, 120, 24, 0.2, '2x2x3', 0, 4.3, 89),
('EcoTech Water Filter', 'Under-sink water filtration system', 'ET-WF-001', 89.99, 79.99, 45.00, 3, 3, 35, 7, 3.2, '12x8x6', 0, 4.5, 67),
('PowerMax Car Charger', 'Fast USB-C car charger with multiple ports', 'PM-CC-001', 29.99, 24.99, 15.00, 4, 4, 150, 30, 0.3, '4x2x1', 0, 4.1, 234),
('InnovateCorp Smart Lock', 'Keyless entry smart lock with fingerprint scanner', 'IC-SL-001', 199.99, 179.99, 110.00, 5, 5, 25, 5, 1.8, '6x4x2', 0, 4.6, 78),
('TechPro Webcam', '4K webcam with built-in microphone and privacy cover', 'TP-WC-001', 79.99, 69.99, 40.00, 1, 1, 60, 12, 0.4, '4x3x2', 0, 4.2, 123),
('SmartLife Fitness Tracker', 'Waterproof fitness band with heart rate monitor', 'SL-FT-001', 49.99, 39.99, 25.00, 2, 2, 85, 17, 0.1, '2x1x0.5', 0, 4.4, 189),
('EcoTech Air Purifier', 'HEPA air purifier with air quality sensor', 'ET-AP-001', 149.99, 129.99, 80.00, 3, 3, 30, 6, 8.5, '20x12x12', 0, 4.7, 98),
('PowerMax Solar Charger', 'Portable solar charger for phones and tablets', 'PM-SC-001', 44.99, 39.99, 22.00, 4, 4, 70, 14, 0.6, '8x6x1', 0, 4.3, 145),
('InnovateCorp Smart Mirror', 'Touchscreen smart mirror with voice control', 'IC-SM-001', 299.99, 269.99, 180.00, 5, 5, 15, 3, 12.0, '24x18x2', 0, 4.5, 56),
('TechPro Monitor Stand', 'Adjustable monitor stand with cable management', 'TP-MS-001', 89.99, 79.99, 45.00, 1, 1, 45, 9, 3.2, '20x8x8', 0, 4.1, 78),
('SmartLife Pet Tracker', 'GPS pet tracking collar with activity monitoring', 'SL-PT-001', 79.99, 69.99, 40.00, 2, 2, 55, 11, 0.3, '3x2x1', 0, 4.6, 92),
('EcoTech Compost Bin', 'Smart composting bin with temperature monitoring', 'ET-CB-001', 69.99, 59.99, 35.00, 3, 3, 40, 8, 5.5, '16x12x12', 0, 4.4, 67),
('PowerMax Generator', 'Portable 2000W generator with fuel efficiency', 'PM-GE-001', 399.99, 349.99, 220.00, 4, 4, 20, 4, 45.0, '24x18x18', 0, 4.8, 34),
('InnovateCorp Smart Garden', 'Automated indoor garden with LED grow lights', 'IC-SG-001', 199.99, 179.99, 110.00, 5, 5, 25, 5, 8.8, '20x16x12', 0, 4.3, 89),
('GameMaster Pro Controller', 'Professional gaming controller with customizable buttons', 'GM-PC-001', 89.99, 79.99, 45.00, 6, 6, 60, 12, 0.5, '6x4x2', 0, 4.6, 134),
('SoundWave Studio Headphones', 'Professional studio headphones with noise isolation', 'SW-SH-001', 199.99, 179.99, 110.00, 7, 7, 35, 7, 0.8, '8x7x4', 0, 4.7, 89),
('GreenLiving Bamboo Utensils', 'Eco-friendly bamboo kitchen utensil set', 'GL-BU-001', 34.99, 29.99, 18.00, 8, 8, 150, 30, 1.2, '12x8x2', 0, 4.4, 156),
('PetCare Plus GPS Collar', 'GPS tracking collar for dogs and cats', 'PC-GC-001', 129.99, 119.99, 70.00, 9, 9, 40, 8, 0.4, '4x3x1', 0, 4.5, 78),
('AutoTech Dash Cam', '4K dashboard camera with night vision', 'AT-DC-001', 149.99, 129.99, 80.00, 10, 10, 55, 11, 0.6, '5x4x2', 0, 4.3, 112),
('GameMaster RGB Mousepad', 'Large RGB gaming mousepad with wireless charging', 'GM-RM-001', 49.99, 39.99, 25.00, 6, 6, 80, 16, 0.3, '14x12x0.1', 0, 4.2, 98),
('SoundWave Bluetooth Earbuds', 'True wireless earbuds with active noise cancellation', 'SW-BE-001', 159.99, 139.99, 85.00, 7, 7, 70, 14, 0.1, '2x2x1', 0, 4.6, 145),
('GreenLiving Reusable Bags', 'Set of 5 eco-friendly reusable shopping bags', 'GL-RB-001', 19.99, 16.99, 10.00, 8, 8, 200, 40, 0.8, '16x12x1', 0, 4.8, 234),
('PetCare Plus Automatic Feeder', 'Smart automatic pet feeder with app control', 'PC-AF-001', 89.99, 79.99, 45.00, 9, 9, 30, 6, 2.5, '10x8x6', 0, 4.4, 67),
('AutoTech Tire Pressure Monitor', 'Real-time tire pressure monitoring system', 'AT-TP-001', 79.99, 69.99, 40.00, 10, 10, 65, 13, 0.2, '3x2x1', 0, 4.1, 89),
('TechPro USB Hub', '7-port USB 3.0 hub with power delivery', 'TP-UH-001', 39.99, 34.99, 20.00, 1, 1, 120, 24, 0.4, '6x4x1', 0, 4.3, 167),
('SmartLife Smart Plug', 'WiFi smart plug with energy monitoring', 'SL-SP-001', 24.99, 19.99, 12.00, 2, 2, 180, 36, 0.2, '3x2x1', 0, 4.5, 198),
('EcoTech Compostable Phone Case', 'Biodegradable phone case made from plant materials', 'ET-CP-001', 29.99, 24.99, 15.00, 3, 3, 90, 18, 0.1, '6x3x0.5', 0, 4.2, 123),
('PowerMax Portable Speaker', 'Waterproof portable speaker with 20-hour battery', 'PM-PS-001', 89.99, 79.99, 45.00, 4, 4, 45, 9, 1.8, '8x6x4', 0, 4.4, 89),
('InnovateCorp Smart Scale', 'WiFi smart scale with body composition analysis', 'IC-SS-001', 149.99, 129.99, 80.00, 5, 5, 35, 7, 2.2, '12x12x1', 0, 4.6, 78),
('Fashion Forward T-Shirt', 'Premium cotton t-shirt with modern design', 'FF-TS-001', 29.99, 24.99, 15.00, 11, 11, 100, 20, 0.3, '12x8x1', 0, 4.3, 45),
('Elegant Summer Dress', 'Lightweight summer dress with floral pattern', 'ES-SD-001', 89.99, 79.99, 45.00, 11, 11, 75, 15, 0.5, '14x10x2', 1, 4.6, 78),
('Classic Denim Jeans', 'High-quality denim jeans with perfect fit', 'CD-DJ-001', 79.99, 69.99, 40.00, 11, 11, 60, 12, 0.8, '16x12x3', 0, 4.4, 56),
('Athletic Running Shoes', 'Professional running shoes with cushioning', 'AR-RS-001', 129.99, 119.99, 70.00, 12, 12, 80, 16, 1.2, '18x14x4', 1, 4.7, 92),
('Yoga Mat Premium', 'Non-slip yoga mat with carrying strap', 'YM-PM-001', 49.99, 44.99, 25.00, 12, 12, 120, 24, 1.5, '24x6x0.5', 0, 4.5, 67),
('Basketball Court Shoes', 'High-performance basketball shoes', 'BC-CS-001', 149.99, 139.99, 80.00, 12, 12, 65, 13, 1.4, '19x15x5', 0, 4.6, 81),
('Hiking Boots Pro', 'Waterproof hiking boots for outdoor adventures', 'HB-PRO-001', 199.99, 179.99, 110.00, 12, 12, 45, 9, 2.1, '20x16x6', 1, 4.8, 103),
('The Great Adventure Novel', 'Bestselling adventure novel by acclaimed author', 'B-GAN-001', 19.99, 16.99, 8.00, 13, 13, 200, 40, 0.8, '8x6x1', 1, 4.7, 156),
('Science & Technology Guide', 'Comprehensive guide to modern technology', 'B-STG-001', 34.99, 29.99, 15.00, 13, 13, 150, 30, 1.2, '10x7x1.5', 0, 4.5, 89),
('Mystery Thriller Collection', 'Three bestselling mystery novels in one', 'B-MTC-001', 24.99, 21.99, 12.00, 13, 13, 180, 36, 1.0, '9x6x1.2', 0, 4.4, 112),
('Business Strategy Handbook', 'Essential guide for entrepreneurs', 'B-BSH-001', 44.99, 39.99, 20.00, 13, 13, 120, 24, 1.5, '11x8x1.8', 1, 4.6, 134),
('Office Desk Organizer', 'Multi-compartment desk organizer', 'OD-ORG-001', 39.99, 34.99, 20.00, 23, 23, 90, 18, 1.8, '12x8x6', 0, 4.3, 45),
('Ergonomic Office Chair', 'Adjustable office chair with lumbar support', 'EO-OC-001', 299.99, 279.99, 180.00, 23, 23, 35, 7, 25.0, '28x24x42', 1, 4.8, 67),
('Wireless Office Mouse', 'Ergonomic wireless mouse for office use', 'WO-OM-001', 49.99, 44.99, 25.00, 23, 23, 110, 22, 0.2, '6x4x2', 0, 4.4, 78),
('Desk Lamp LED', 'Adjustable LED desk lamp with touch control', 'DL-LED-001', 79.99, 69.99, 40.00, 23, 23, 85, 17, 2.5, '15x8x25', 0, 4.5, 56),
('Document Scanner Pro', 'High-speed document scanner for office', 'DS-PRO-001', 199.99, 179.99, 110.00, 23, 23, 40, 8, 3.2, '18x12x8', 1, 4.7, 89);

-- Product Categories (many-to-many relationships)
INSERT INTO product_categories (product_id, category_id, sort_order) VALUES
(1, 2, 1), (1, 1, 2), -- Laptop in Computers and Electronics
(2, 3, 1), (2, 1, 2), -- Smartphone in Smartphones and Electronics
(3, 8, 1), (3, 1, 2), -- Solar Panel in Outdoor and Electronics
(4, 1, 1), -- Wireless Charger in Electronics
(5, 15, 1), (5, 1, 2), -- Smart Watch in Fitness and Electronics
(6, 2, 1), (6, 4, 2), -- Gaming Mouse in Computers and Gaming
(7, 8, 1), (7, 5, 2), -- Bluetooth Speaker in Outdoor and Audio
(8, 6, 1), (8, 1, 2), -- LED Bulbs in Home & Garden and Electronics
(9, 1, 1), -- Power Bank in Electronics
(10, 2, 1), (10, 4, 2), -- VR Headset in Computers and Gaming
(11, 2, 1), (11, 4, 2), -- Mechanical Keyboard in Computers and Gaming
(12, 6, 1), (12, 9, 2), -- Security Camera in Home & Garden and Smart Home
(13, 6, 1), (13, 9, 2), -- Smart Thermostat in Home & Garden and Smart Home
(14, 1, 1), -- Surge Protector in Electronics
(15, 8, 1), (15, 1, 2), -- Drone in Outdoor and Electronics
(16, 4, 1), (16, 5, 2), -- Gaming Headset in Gaming and Audio
(17, 9, 1), (17, 1, 2), -- Smart Bulb in Smart Home and Electronics
(18, 6, 1), (18, 1, 2), -- Water Filter in Home & Garden and Electronics
(19, 20, 1), (19, 1, 2), -- Car Charger in Automotive and Electronics
(20, 6, 1), (20, 9, 2), -- Smart Lock in Home & Garden and Smart Home
(21, 2, 1), (21, 1, 2), -- Webcam in Computers and Electronics
(22, 15, 1), (22, 1, 2), -- Fitness Tracker in Fitness and Electronics
(23, 6, 1), (23, 1, 2), -- Air Purifier in Home & Garden and Electronics
(24, 8, 1), (24, 1, 2), -- Solar Charger in Outdoor and Electronics
(25, 6, 1), (25, 9, 2), -- Smart Mirror in Home & Garden and Smart Home
(26, 2, 1), (26, 23, 2), -- Monitor Stand in Computers and Office
(27, 21, 1), (27, 1, 2), -- Pet Tracker in Pet Supplies and Electronics
(28, 6, 1), (28, 10, 2), -- Compost Bin in Home & Garden and Garden
(29, 8, 1), (29, 1, 2), -- Generator in Outdoor and Electronics
(30, 6, 1), (30, 10, 2), -- Smart Garden in Home & Garden and Garden
(31, 4, 1), (31, 1, 2), -- Pro Controller in Gaming and Electronics
(32, 5, 1), (32, 1, 2), -- Studio Headphones in Audio and Electronics
(33, 7, 1), (33, 6, 2), -- Bamboo Utensils in Kitchen and Home & Garden
(34, 21, 1), (34, 1, 2), -- GPS Collar in Pet Supplies and Electronics
(35, 20, 1), (35, 1, 2), -- Dash Cam in Automotive and Electronics
(36, 4, 1), (36, 1, 2), -- RGB Mousepad in Gaming and Electronics
(37, 5, 1), (37, 1, 2), -- Bluetooth Earbuds in Audio and Electronics
(38, 6, 1), (38, 22, 2), -- Reusable Bags in Home & Garden and Health & Wellness
(39, 21, 1), (39, 9, 2), -- Automatic Feeder in Pet Supplies and Smart Home
(40, 20, 1), (40, 1, 2), -- Tire Monitor in Automotive and Electronics
(41, 1, 1), (41, 23, 2), -- USB Hub in Electronics and Office
(42, 9, 1), (42, 1, 2), -- Smart Plug in Smart Home and Electronics
(43, 1, 1), (43, 22, 2), -- Phone Case in Electronics and Health & Wellness
(44, 5, 1), (44, 8, 2), -- Portable Speaker in Audio and Outdoor
(45, 15, 1), (45, 9, 2), -- Smart Scale in Fitness and Smart Home
(46, 12, 1), (46, 11, 2), -- Fashion Forward T-Shirt in Men and Fashion
(47, 13, 1), (47, 11, 2), -- Elegant Summer Dress in Women and Fashion
(48, 12, 1), (48, 11, 2), -- Classic Denim Jeans in Men and Fashion
(49, 15, 1), (49, 14, 2), -- Athletic Running Shoes in Fitness and Sports
(50, 15, 1), (50, 14, 2), -- Yoga Mat Premium in Fitness and Sports
(51, 15, 1), (51, 14, 2), -- Basketball Court Shoes in Fitness and Sports
(52, 16, 1), (52, 14, 2), -- Hiking Boots Pro in Outdoor Sports and Sports
(53, 18, 1), (53, 17, 2), -- The Great Adventure Novel in Fiction and Books
(54, 19, 1), (54, 17, 2), -- Science & Technology Guide in Non-Fiction and Books
(55, 18, 1), (55, 17, 2), -- Mystery Thriller Collection in Fiction and Books
(56, 19, 1), (56, 17, 2), -- Business Strategy Handbook in Non-Fiction and Books
(57, 23, 1), -- Office Desk Organizer in Office
(58, 23, 1), -- Ergonomic Office Chair in Office
(59, 23, 1), -- Wireless Office Mouse in Office
(60, 23, 1), -- Desk Lamp LED in Office
(61, 23, 1); -- Document Scanner Pro in Office

-- Product Images
INSERT INTO product_images (product_id, image_url, alt_text, is_primary, sort_order) VALUES
(1, 'https://example.com/products/laptop-pro-1.jpg', 'TechPro Laptop Pro Front View', 1, 1),
(1, 'https://example.com/products/laptop-pro-2.jpg', 'TechPro Laptop Pro Side View', 0, 2),
(2, 'https://example.com/products/smartphone-x-1.jpg', 'SmartLife Smartphone X Front View', 1, 1),
(2, 'https://example.com/products/smartphone-x-2.jpg', 'SmartLife Smartphone X Back View', 0, 2),
(3, 'https://example.com/products/solar-panel-1.jpg', 'EcoTech Solar Panel', 1, 1),
(4, 'https://example.com/products/wireless-charger-1.jpg', 'PowerMax Wireless Charger', 1, 1),
(5, 'https://example.com/products/smart-watch-1.jpg', 'InnovateCorp Smart Watch', 1, 1),
(6, 'https://example.com/products/gaming-mouse-1.jpg', 'TechPro Gaming Mouse', 1, 1),
(7, 'https://example.com/products/bluetooth-speaker-1.jpg', 'SmartLife Bluetooth Speaker', 1, 1),
(8, 'https://example.com/products/led-bulbs-1.jpg', 'EcoTech LED Bulb Pack', 1, 1),
(9, 'https://example.com/products/power-bank-1.jpg', 'PowerMax Power Bank', 1, 1),
(10, 'https://example.com/products/vr-headset-1.jpg', 'InnovateCorp VR Headset', 1, 1),
(11, 'https://example.com/products/mechanical-keyboard-1.jpg', 'TechPro Mechanical Keyboard', 1, 1),
(12, 'https://example.com/products/security-camera-1.jpg', 'SmartLife Security Camera', 1, 1),
(13, 'https://example.com/products/smart-thermostat-1.jpg', 'EcoTech Smart Thermostat', 1, 1),
(14, 'https://example.com/products/surge-protector-1.jpg', 'PowerMax Surge Protector', 1, 1),
(15, 'https://example.com/products/drone-1.jpg', 'InnovateCorp Drone', 1, 1),
(16, 'https://example.com/products/gaming-headset-1.jpg', 'TechPro Gaming Headset', 1, 1),
(17, 'https://example.com/products/smart-bulb-1.jpg', 'SmartLife Smart Bulb', 1, 1),
(18, 'https://example.com/products/water-filter-1.jpg', 'EcoTech Water Filter', 1, 1),
(19, 'https://example.com/products/car-charger-1.jpg', 'PowerMax Car Charger', 1, 1),
(20, 'https://example.com/products/smart-lock-1.jpg', 'InnovateCorp Smart Lock', 1, 1),
(21, 'https://example.com/products/webcam-1.jpg', 'TechPro Webcam', 1, 1),
(22, 'https://example.com/products/fitness-tracker-1.jpg', 'SmartLife Fitness Tracker', 1, 1),
(23, 'https://example.com/products/air-purifier-1.jpg', 'EcoTech Air Purifier', 1, 1),
(24, 'https://example.com/products/solar-charger-1.jpg', 'PowerMax Solar Charger', 1, 1),
(25, 'https://example.com/products/smart-mirror-1.jpg', 'InnovateCorp Smart Mirror', 1, 1),
(26, 'https://example.com/products/monitor-stand-1.jpg', 'TechPro Monitor Stand', 1, 1),
(27, 'https://example.com/products/pet-tracker-1.jpg', 'SmartLife Pet Tracker', 1, 1),
(28, 'https://example.com/products/compost-bin-1.jpg', 'EcoTech Compost Bin', 1, 1),
(29, 'https://example.com/products/generator-1.jpg', 'PowerMax Generator', 1, 1),
(30, 'https://example.com/products/smart-garden-1.jpg', 'InnovateCorp Smart Garden', 1, 1),
(31, 'https://example.com/products/pro-controller-1.jpg', 'GameMaster Pro Controller', 1, 1),
(32, 'https://example.com/products/studio-headphones-1.jpg', 'SoundWave Studio Headphones', 1, 1),
(33, 'https://example.com/products/bamboo-utensils-1.jpg', 'GreenLiving Bamboo Utensils', 1, 1),
(34, 'https://example.com/products/gps-collar-1.jpg', 'PetCare Plus GPS Collar', 1, 1),
(35, 'https://example.com/products/dash-cam-1.jpg', 'AutoTech Dash Cam', 1, 1),
(36, 'https://example.com/products/rgb-mousepad-1.jpg', 'GameMaster RGB Mousepad', 1, 1),
(37, 'https://example.com/products/bluetooth-earbuds-1.jpg', 'SoundWave Bluetooth Earbuds', 1, 1),
(38, 'https://example.com/products/reusable-bags-1.jpg', 'GreenLiving Reusable Bags', 1, 1),
(39, 'https://example.com/products/automatic-feeder-1.jpg', 'PetCare Plus Automatic Feeder', 1, 1),
(40, 'https://example.com/products/tire-monitor-1.jpg', 'AutoTech Tire Pressure Monitor', 1, 1),
(41, 'https://example.com/products/usb-hub-1.jpg', 'TechPro USB Hub', 1, 1),
(42, 'https://example.com/products/smart-plug-1.jpg', 'SmartLife Smart Plug', 1, 1),
(43, 'https://example.com/products/phone-case-1.jpg', 'EcoTech Compostable Phone Case', 1, 1),
(44, 'https://example.com/products/portable-speaker-1.jpg', 'PowerMax Portable Speaker', 1, 1),
(45, 'https://example.com/products/smart-scale-1.jpg', 'InnovateCorp Smart Scale', 1, 1),
(46, 'https://example.com/products/fashion-tshirt-1.jpg', 'Fashion Forward T-Shirt', 1, 1),
(47, 'https://example.com/products/summer-dress-1.jpg', 'Elegant Summer Dress', 1, 1),
(48, 'https://example.com/products/denim-jeans-1.jpg', 'Classic Denim Jeans', 1, 1),
(49, 'https://example.com/products/running-shoes-1.jpg', 'Athletic Running Shoes', 1, 1),
(50, 'https://example.com/products/yoga-mat-1.jpg', 'Yoga Mat Premium', 1, 1),
(51, 'https://example.com/products/basketball-shoes-1.jpg', 'Basketball Court Shoes', 1, 1),
(52, 'https://example.com/products/hiking-boots-1.jpg', 'Hiking Boots Pro', 1, 1),
(53, 'https://example.com/products/adventure-novel-1.jpg', 'The Great Adventure Novel', 1, 1),
(54, 'https://example.com/products/tech-guide-1.jpg', 'Science & Technology Guide', 1, 1),
(55, 'https://example.com/products/mystery-collection-1.jpg', 'Mystery Thriller Collection', 1, 1),
(56, 'https://example.com/products/business-handbook-1.jpg', 'Business Strategy Handbook', 1, 1),
(57, 'https://example.com/products/desk-organizer-1.jpg', 'Office Desk Organizer', 1, 1),
(58, 'https://example.com/products/office-chair-1.jpg', 'Ergonomic Office Chair', 1, 1),
(59, 'https://example.com/products/wireless-mouse-1.jpg', 'Wireless Office Mouse', 1, 1),
(60, 'https://example.com/products/desk-lamp-1.jpg', 'Desk Lamp LED', 1, 1),
(61, 'https://example.com/products/document-scanner-1.jpg', 'Document Scanner Pro', 1, 1);

-- Reviews
INSERT INTO reviews (product_id, user_id, rating, title, comment, is_verified_purchase) VALUES
(1, 1, 5, 'Excellent laptop!', 'This laptop exceeded my expectations. Fast performance and great build quality.', 1),
(1, 2, 4, 'Great performance', 'Very good laptop for the price. Only giving 4 stars because the battery could be better.', 1),
(2, 3, 5, 'Amazing phone', 'Best smartphone I''ve ever owned. Camera quality is outstanding.', 1),
(2, 4, 4, 'Good phone', 'Solid smartphone with good features. Wish it had more storage.', 1),
(3, 5, 5, 'Perfect for camping', 'This solar panel is exactly what I needed for outdoor adventures.', 1),
(4, 1, 4, 'Works well', 'Good wireless charger, charges my phone quickly.', 1),
(5, 2, 5, 'Great fitness tracker', 'Love this smartwatch! Tracks everything I need for workouts.', 1),
(6, 3, 4, 'Good gaming mouse', 'Responsive and comfortable for long gaming sessions.', 1),
(7, 4, 4, 'Nice speaker', 'Good sound quality and waterproof design.', 1),
(8, 5, 5, 'Energy efficient', 'These LED bulbs are bright and save money on electricity.', 1),
(9, 1, 4, 'Reliable power bank', 'Good capacity and fast charging.', 1),
(10, 2, 5, 'Immersive VR experience', 'Amazing VR headset with great graphics and tracking.', 1),
(11, 3, 5, 'Best keyboard ever', 'Mechanical switches feel amazing and the RGB is beautiful.', 1),
(12, 4, 4, 'Good security camera', 'Clear video quality and easy to set up.', 1),
(13, 5, 5, 'Smart home essential', 'This thermostat has saved me money on heating and cooling.', 1),
(14, 1, 4, 'Good surge protection', 'Multiple outlets and USB ports are convenient.', 1),
(15, 2, 5, 'Amazing drone', '4K camera quality is incredible and flight is very stable.', 1),
(16, 3, 5, 'Perfect for gaming', 'Amazing sound quality and very comfortable for long sessions.', 1),
(17, 4, 4, 'Great smart bulb', 'Easy to set up and control with my phone.', 1),
(18, 5, 5, 'Clean water', 'Water tastes much better now. Easy installation.', 1),
(19, 1, 4, 'Fast charging', 'Charges my phone quickly in the car.', 1),
(20, 2, 5, 'Secure and convenient', 'No more keys! Fingerprint scanner works perfectly.', 1),
(21, 3, 4, 'Good webcam', 'Clear video quality for video calls.', 1),
(22, 4, 5, 'Great fitness tracker', 'Tracks all my workouts accurately.', 1),
(23, 5, 5, 'Clean air', 'Noticeable improvement in air quality at home.', 1),
(24, 1, 4, 'Good solar charger', 'Charges my devices when camping.', 1),
(25, 2, 5, 'Amazing smart mirror', 'Voice control works great and display is clear.', 1),
(26, 3, 4, 'Sturdy stand', 'Holds my monitor securely and looks professional.', 1),
(27, 4, 5, 'Pet safety', 'Never lose my dog again! GPS tracking is accurate.', 1),
(28, 5, 4, 'Good compost bin', 'Helps reduce waste and creates great compost.', 1),
(29, 1, 5, 'Reliable generator', 'Perfect backup power for emergencies.', 1),
(30, 2, 4, 'Smart garden', 'Automated watering and lighting works well.', 1),
(31, 3, 5, 'Pro controller', 'Customizable buttons and great build quality.', 1),
(32, 4, 5, 'Studio quality', 'Perfect for recording and mixing music.', 1),
(33, 5, 4, 'Eco-friendly', 'Beautiful bamboo utensils that are sustainable.', 1),
(34, 1, 5, 'Pet tracking', 'GPS collar works perfectly for my cat.', 1),
(35, 2, 4, 'Good dash cam', 'Clear video recording and easy to use.', 1),
(36, 3, 4, 'Nice mousepad', 'RGB lighting looks great and surface is smooth.', 1),
(37, 4, 5, 'Amazing earbuds', 'Sound quality is incredible and battery life is long.', 1),
(38, 5, 5, 'Eco-friendly bags', 'Strong and reusable. Great for shopping.', 1),
(39, 1, 4, 'Automatic feeding', 'Keeps my pets fed on schedule when I''m away.', 1),
(40, 2, 4, 'Tire monitoring', 'Real-time pressure updates are very helpful.', 1),
(41, 3, 4, 'Good USB hub', 'Multiple ports and fast data transfer.', 1),
(42, 4, 5, 'Smart plug', 'Easy to control and monitor energy usage.', 1),
(43, 5, 4, 'Eco phone case', 'Good protection and biodegradable material.', 1),
(44, 1, 4, 'Portable speaker', 'Good sound quality and long battery life.', 1),
(45, 2, 5, 'Smart scale', 'Tracks all my health metrics accurately.', 1),
(46, 3, 4, 'Great t-shirt', 'Comfortable and stylish. Perfect fit for everyday wear.', 1),
(47, 4, 5, 'Beautiful dress', 'Absolutely love this dress! Perfect for summer events.', 1),
(48, 5, 4, 'Quality jeans', 'Great fit and durable material. Worth the price.', 1),
(49, 1, 5, 'Excellent running shoes', 'Perfect for my daily runs. Great cushioning and support.', 1),
(50, 2, 4, 'Good yoga mat', 'Non-slip surface works well. Carrying strap is convenient.', 1),
(51, 3, 5, 'Great basketball shoes', 'Excellent performance on the court. Great ankle support.', 1),
(52, 4, 5, 'Perfect hiking boots', 'Waterproof and comfortable for long hikes.', 1),
(53, 5, 5, 'Amazing novel', 'Could not put it down! Highly recommend for adventure lovers.', 1),
(54, 1, 4, 'Informative guide', 'Well-written and comprehensive. Great for tech enthusiasts.', 1),
(55, 2, 4, 'Thrilling collection', 'Three great mystery novels in one. Excellent value.', 1),
(56, 3, 5, 'Essential handbook', 'Must-read for anyone starting a business. Practical advice.', 1),
(57, 4, 4, 'Good organizer', 'Keeps my desk tidy. Multiple compartments are useful.', 1),
(58, 5, 5, 'Comfortable chair', 'Best office chair I have ever owned. Great lumbar support.', 1),
(59, 1, 4, 'Reliable mouse', 'Good wireless performance. Battery life is decent.', 1),
(60, 2, 4, 'Nice lamp', 'Adjustable brightness and good LED lighting.', 1),
(61, 3, 5, 'Fast scanner', 'High-speed scanning with excellent image quality.', 1);

-- Orders
INSERT INTO orders (order_number, user_id, status, subtotal, tax_amount, shipping_amount, total_amount, shipping_address, shipping_city, shipping_state, shipping_zip_code) VALUES
('ORD-2024-001', 1, 'delivered', 1299.99, 104.00, 15.00, 1418.99, '123 Main St', 'New York', 'NY', '10001'),
('ORD-2024-002', 2, 'shipped', 899.99, 72.00, 15.00, 986.99, '456 Oak Ave', 'Los Angeles', 'CA', '90210'),
('ORD-2024-003', 3, 'processing', 199.99, 16.00, 10.00, 225.99, '789 Pine Rd', 'Chicago', 'IL', '60601'),
('ORD-2024-004', 4, 'pending', 79.99, 6.40, 10.00, 96.39, '321 Elm St', 'Houston', 'TX', '77001'),
('ORD-2024-005', 5, 'delivered', 299.99, 24.00, 15.00, 338.99, '654 Maple Dr', 'Phoenix', 'AZ', '85001'),
('ORD-2024-006', 1, 'delivered', 89.99, 7.20, 10.00, 107.19, '123 Main St', 'New York', 'NY', '10001'),
('ORD-2024-007', 2, 'shipped', 129.99, 10.40, 10.00, 150.39, '456 Oak Ave', 'Los Angeles', 'CA', '90210'),
('ORD-2024-008', 3, 'processing', 24.99, 2.00, 5.00, 31.99, '789 Pine Rd', 'Chicago', 'IL', '60601'),
('ORD-2024-009', 6, 'delivered', 159.98, 12.80, 15.00, 187.78, '987 Cedar Ln', 'Miami', 'FL', '33101'),
('ORD-2024-010', 7, 'shipped', 299.98, 24.00, 15.00, 338.98, '147 Birch St', 'Seattle', 'WA', '98101'),
('ORD-2024-011', 8, 'processing', 89.98, 7.20, 10.00, 107.18, '258 Spruce Ave', 'Boston', 'MA', '02101'),
('ORD-2024-012', 9, 'pending', 199.98, 16.00, 15.00, 230.98, '369 Willow Rd', 'Denver', 'CO', '80201'),
('ORD-2024-013', 10, 'delivered', 129.98, 10.40, 10.00, 150.38, '741 Aspen Dr', 'San Francisco', 'CA', '94101'),
('ORD-2024-014', 4, 'shipped', 79.98, 6.40, 10.00, 96.38, '321 Elm St', 'Houston', 'TX', '77001'),
('ORD-2024-015', 5, 'processing', 149.98, 12.00, 15.00, 176.98, '654 Maple Dr', 'Phoenix', 'AZ', '85001'),
('ORD-2024-016', 1, 'delivered', 89.98, 7.20, 10.00, 107.18, '123 Main St', 'New York', 'NY', '10001');

-- Order Items
INSERT INTO order_items (order_id, product_id, product_name, product_sku, quantity, unit_price, total_price) VALUES
(1, 1, 'TechPro Laptop Pro', 'TP-LP-001', 1, 1299.99, 1299.99),
(2, 2, 'SmartLife Smartphone X', 'SL-SX-001', 1, 899.99, 899.99),
(3, 3, 'EcoTech Solar Panel', 'ET-SP-001', 1, 199.99, 199.99),
(4, 4, 'PowerMax Wireless Charger', 'PM-WC-001', 1, 79.99, 79.99),
(5, 5, 'InnovateCorp Smart Watch', 'IC-SW-001', 1, 299.99, 299.99),
(6, 6, 'TechPro Gaming Mouse', 'TP-GM-001', 1, 89.99, 89.99),
(7, 7, 'SmartLife Bluetooth Speaker', 'SL-BS-001', 1, 129.99, 129.99),
(8, 8, 'EcoTech LED Bulb Pack', 'ET-LB-001', 1, 24.99, 24.99),
(9, 16, 'TechPro Gaming Headset', 'TP-GH-001', 1, 129.99, 129.99),
(9, 17, 'SmartLife Smart Bulb', 'SL-SB-001', 1, 29.99, 29.99),
(10, 18, 'EcoTech Water Filter', 'ET-WF-001', 1, 89.99, 89.99),
(10, 19, 'PowerMax Car Charger', 'PM-CC-001', 1, 24.99, 24.99),
(10, 20, 'InnovateCorp Smart Lock', 'IC-SL-001', 1, 179.99, 179.99),
(11, 21, 'TechPro Webcam', 'TP-WC-001', 1, 69.99, 69.99),
(11, 22, 'SmartLife Fitness Tracker', 'SL-FT-001', 1, 19.99, 19.99),
(12, 23, 'EcoTech Air Purifier', 'ET-AP-001', 1, 129.99, 129.99),
(12, 24, 'PowerMax Solar Charger', 'PM-SC-001', 1, 39.99, 39.99),
(13, 25, 'InnovateCorp Smart Mirror', 'IC-SM-001', 1, 269.99, 269.99),
(13, 26, 'TechPro Monitor Stand', 'TP-MS-001', 1, 79.99, 79.99),
(14, 27, 'SmartLife Pet Tracker', 'SL-PT-001', 1, 69.99, 69.99),
(14, 28, 'EcoTech Compost Bin', 'ET-CB-001', 1, 9.99, 9.99),
(15, 29, 'PowerMax Generator', 'PM-GE-001', 1, 349.99, 349.99),
(15, 30, 'InnovateCorp Smart Garden', 'IC-SG-001', 1, 179.99, 179.99),
(16, 31, 'GameMaster Pro Controller', 'GM-PC-001', 1, 79.99, 79.99),
(16, 32, 'SoundWave Studio Headphones', 'SW-SH-001', 1, 9.99, 9.99),
(17, 46, 'Fashion Forward T-Shirt', 'FF-TS-001', 2, 24.99, 49.98),
(17, 47, 'Elegant Summer Dress', 'ES-SD-001', 1, 79.99, 79.99),
(18, 49, 'Athletic Running Shoes', 'AR-RS-001', 1, 119.99, 119.99),
(18, 50, 'Yoga Mat Premium', 'YM-PM-001', 1, 44.99, 44.99),
(19, 53, 'The Great Adventure Novel', 'B-GAN-001', 1, 16.99, 16.99),
(19, 54, 'Science & Technology Guide', 'B-STG-001', 1, 29.99, 29.99),
(20, 57, 'Office Desk Organizer', 'OD-ORG-001', 1, 34.99, 34.99),
(20, 58, 'Ergonomic Office Chair', 'EO-OC-001', 1, 279.99, 279.99);

-- Create indexes for better performance
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_brand_id ON products(brand_id);
CREATE INDEX idx_products_supplier_id ON products(supplier_id);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_stock_quantity ON products(stock_quantity);
CREATE INDEX idx_products_rating_average ON products(rating_average);
CREATE INDEX idx_product_categories_product_id ON product_categories(product_id);
CREATE INDEX idx_product_categories_category_id ON product_categories(category_id);
CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
