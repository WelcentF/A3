
DROP SCHEMA IF EXISTS FoodDelivery CASCADE;
CREATE SCHEMA FoodDelivery;
SET search_path TO FoodDelivery;

-- =========================================
-- ENTITY TABLES
-- =========================================

-- Customer
CREATE TABLE Customer (
    cID INT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL,
    address TEXT NOT NULL
);

-- Restaurant
CREATE TABLE Restaurant (
    rID INT PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    phone TEXT NOT NULL,
    cuisineType TEXT NOT NULL,
    UNIQUE (name, address)
);

-- Driver
CREATE TABLE Driver (
    driverID INT PRIMARY KEY,
    name TEXT NOT NULL,
    vehicleType TEXT NOT NULL,
    phone TEXT NOT NULL
);

-- MenuItem
-- Each menu item belongs to exactly one restaurant.
CREATE TABLE MenuItem (
    mID INT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    price NUMERIC(10,2) NOT NULL
        CHECK (price >= 0),
    rID INT NOT NULL REFERENCES Restaurant(rID)
);

-- Orders
-- Each order belongs to exactly one customer
-- and is received by exactly one restaurant.
CREATE TABLE Orders (
    oID INT PRIMARY KEY,
    orderDateTime TIMESTAMP NOT NULL,
    orderStatus TEXT NOT NULL
        CHECK (orderStatus IN
            ('placed', 'preparing', 'cancelled', 'delivered')),
    cID INT NOT NULL REFERENCES Customer(cID),
    rID INT NOT NULL REFERENCES Restaurant(rID)
);

-- Payment
-- Every payment belongs to exactly one order.
-- Each order can have at most one payment.
-- paymentStatus: pending, successful, or failed.
-- paymentDate records the time of the payment attempt.
CREATE TABLE Payment (
    pID INT PRIMARY KEY,
    paymentAmount NUMERIC(10,2) NOT NULL
        CHECK (paymentAmount >= 0),
    paymentMethod TEXT NOT NULL,
    paymentDate TIMESTAMP NOT NULL,
    paymentStatus TEXT NOT NULL
        CHECK (paymentStatus IN ('pending', 'successful', 'failed')),
    oID INT NOT NULL UNIQUE REFERENCES Orders(oID)
);

-- Delivery
-- Each delivery represents a completed delivery.
-- Every delivery belongs to exactly one order
-- and was completed by exactly one driver.
CREATE TABLE Delivery (
    deliveryID INT PRIMARY KEY,
    pickupTime TIMESTAMP NOT NULL,
    deliveryTime TIMESTAMP NOT NULL,
    oID INT NOT NULL UNIQUE REFERENCES Orders(oID),
    driverID INT NOT NULL REFERENCES Driver(driverID),
    CHECK (deliveryTime > pickupTime)
);

-- Contains: Order <-> MenuItem
-- Each order can contain multiple menu items.
-- Each menu item can appear in multiple orders.
-- quantity and priceAtPurchase are
-- attributes of the Contains relationship.
CREATE TABLE Contains (
    containsID INT PRIMARY KEY,
    oID INT NOT NULL REFERENCES Orders(oID),
    mID INT NOT NULL REFERENCES MenuItem(mID),
    quantity INT NOT NULL CHECK (quantity > 0),
    priceAtPurchase NUMERIC(10,2) NOT NULL
        CHECK (priceAtPurchase >= 0),
    UNIQUE (oID, mID)
);

-- =========================================
-- CONSTRAINTS NOT ENFORCED BY THIS SCHEMA
-- =========================================

-- 1. Every restaurant must offer at least one menu item.

-- 2. Every order must contain at least one menu item.

-- 3. Every order must have exactly one payment.
--    The schema enforces at most one payment per order,
--    but does not enforce at least one payment.

-- 4. All menu items contained in an order must
--    belong to the restaurant receiving that order.

-- 5. An order marked 'delivered' must have
--    exactly one associated delivery record.

-- 6. An order with a failed payment must not
--    be marked 'delivered'.

-- 7. paymentAmount should agree with the total
--    amount charged for the order, calculated
--    according to the domain's pricing rules.
