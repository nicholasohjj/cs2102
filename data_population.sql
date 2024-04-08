TRUNCATE TABLE Hires CASCADE;
TRUNCATE TABLE Returned CASCADE;
TRUNCATE TABLE Handover CASCADE;
TRUNCATE TABLE Assigns CASCADE;
TRUNCATE TABLE Bookings CASCADE;
TRUNCATE TABLE CarDetails CASCADE;
TRUNCATE TABLE CarModels CASCADE;
TRUNCATE TABLE Drivers CASCADE;
TRUNCATE TABLE Employees CASCADE;
TRUNCATE TABLE Locations CASCADE;
TRUNCATE TABLE Customers CASCADE;


-- Populate the Locations table
INSERT INTO Locations (zip, lname, laddr) VALUES
(10001, 'Location1', 'Address1'),
(10002, 'Location2', 'Address2'),
(10003, 'Location3', 'Address3');

-- Populate the Customers table
INSERT INTO Customers (email, dob, address, phone, fsname, lsname) VALUES
('customer1@example.com', '1990-01-01', 'Address1', 82345678, 'FirstName1', 'LastName1'),
('customer2@example.com', '1995-02-02', 'Address2', 83456789, 'FirstName2', 'LastName2'),
('customer3@example.com', '2000-03-03', 'Address3', 84567890, 'FirstName3', 'LastName3');

-- Populate the Employees table
INSERT INTO Employees (eid, ename, ephone, zip) VALUES
(1, 'Employee1', 82345678, 10001),
(2, 'Employee2', 83456789, 10002),
(3, 'Employee3', 84567890, 10003);

-- Populate the Drivers table
INSERT INTO Drivers (eid, pdvl) VALUES
(1, 'PDVL1'),
(2, 'PDVL2'),
(3, 'PDVL3');

-- Populate the CarModels table
INSERT INTO CarModels (brand, model, capacity, deposit, daily) VALUES
('Brand1', 'Model1', 5, 1000, 50),
('Brand2', 'Model2', 7, 1500, 50),
('Brand3', 'Model3', 4, 1200, 60);

-- Populate the CarDetails table
INSERT INTO CarDetails (plate, color, pyear, brand, model, zip) VALUES
('Plate1', 'Red', 2019, 'Brand1', 'Model1', 10001),
('Plate2', 'Blue', 2020, 'Brand2', 'Model2', 10002),
('Plate3', 'Green', 2018, 'Brand3', 'Model3', 10003);

-- Populate the Bookings table
INSERT INTO Bookings (bid, sdate, days, email, ccnum, bdate, brand, model, zip) VALUES
(1, '2024-01-01', 5, 'customer1@example.com', 'CCNum1', '2023-12-25', 'Brand1', 'Model1', 10001),
(2, '2024-02-01', 7, 'customer2@example.com', 'CCNum2', '2024-01-25', 'Brand2', 'Model2', 10002),
(3, '2024-03-01', 4, 'customer3@example.com', 'CCNum3', '2024-02-25', 'Brand3', 'Model3', 10003);

-- Populate the Assigns table
INSERT INTO Assigns (bid, plate) VALUES
(1, 'Plate1'),
(2, 'Plate2');

-- Populate the Handover table
INSERT INTO Handover (bid, eid) VALUES
(1, 1),
(2, 2);

-- Populate the Returned table
INSERT INTO Returned (bid, eid, ccnum, cost) VALUES
(1, 1, 'CCNum1', 100),
(2, 2, 'CCNum2', 150);

-- Populate the Hires table
INSERT INTO Hires (bid, eid, fromdate, todate, ccnum) VALUES
(1, 1, '2024-01-01', '2024-01-06', 'CCNum1'),
(2, 2, '2024-02-01', '2024-02-06', 'CCNum2');

