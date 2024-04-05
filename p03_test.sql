/*Test Procedure 1: add_employees */

/*
Constraint tested: Add into employees and if pdvl is not null, add into drivers
Expected result: Employee4 to Employee6 added into employees, Employee4 and 6 added into drivers
*/
CALL add_employees(
  ARRAY[4,5,6], 
  ARRAY['Employee4', 'Employee5','Employee6'], 
  ARRAY[81111111,82222222,83333333], 
  ARRAY[10001,10002,10003], 
  ARRAY['PDVL4',NULL,'PDLV6']
);

/*
Constraint tested: if arrays are empty, do not add into employees. All arrs can be assumed to have the same size.
Expected result: There should only be 6 Employees and 5 Drivers
*/
CALL add_employees(
  ARRAY[]::integer[], 
  ARRAY[]::text[], 
  ARRAY[]::integer[], 
  ARRAY[]::integer[], 
  ARRAY[]::text[]
);

SELECT * FROM employees;
SELECT * FROM drivers;

/*Test Procedure 2: add_car */

/*
Constraint tested: Add a car model with corresponding car details
Expected result: Brand4, Model4  added into carmodels, 3 cars added to cardetails with brand as 'Brand4', model as 'Model4'
*/
CALL add_car (
  'Brand4', 
  'Model4',
  5,
  1040.00,
  50.00,
  ARRAY['Plate4','Plate5','Plate6'], 
  ARRAY['Purple','Yellow','Black'],
  ARRAY[2020,2021,2022],
  ARRAY[10001,10002,10002]
);

/*
Constraint tested: Add a car model with corresponding car details -- checking if size of arr could cause problem
Expected result: Brand5, Model5  added into carmodels, 1 car added to cardetails with brand as 'Brand5', model as 'Model5'
*/
CALL add_car (
  'Brand5', 
  'Model5',
  5,
  1050.00,
  60.00,
  ARRAY['Plate7'], 
  ARRAY['Purple'],
  ARRAY[2023],
  ARRAY[10003]
);

/*
Constraint tested: Add a car model even if it does not have any car details 
Expected result: Brand6 Model7  added into carmodels, 0 cars added to cardetails with brand as 'Brand6', model as 'Model6'
*/
CALL add_car (
  'Brand6', 
  'Model6',
  6,
  200.00,
  100.00,
  ARRAY[]::text[], 
  ARRAY[]::text[],
  ARRAY[]::integer[],
  ARRAY[]::integer[]
);

SELECT * FROM carmodels;
SELECT * FROM cardetails;


INSERT INTO CUSTOMERS (email, address, dob, phone, fsname, lsname, age) VALUES ('test@gmail.com', 'address1', NOW()::DATE-1000, '39872', 'Ricco', 'Lim', 22);
INSERT INTO CUSTOMERS (email, address, dob, phone, fsname, lsname, age) VALUES ('test2@gmail.com', 'address2', NOW()::DATE-500, '1234', 'Ricco2', 'Lim2', 22);
INSERT INTO cardetails (plate, color, pyear, car_brand, car_model, location_zip) VALUES ('carplate1', 'red', 2002, 'brand1', 'model1', 22222);

INSERT INTO BOOKINGS (bid, sdate, days, ccnum, bdate, email, brand, model, zip) VALUES (123, NOW()::DATE, 5, '123', NOW()::DATE - 5, 'test@gmail.com', 'brand1', 'model1', 22222);
INSERT INTO BOOKINGS (bid, sdate, days, ccnum, bdate, email, brand, model, zip) VALUES (124, NOW()::DATE+5, 5, '123', NOW()::DATE - 10, 'test2@gmail.com', 'brand2', 'model2', 22222);
INSERT INTO BOOKINGS (bid, sdate, days, ccnum, bdate, email, brand, model, zip) VALUES (125, NOW()::DATE+7, 20, '123', NOW()::DATE - 10, 'test2@gmail.com', 'brand2', 'model2', 22222);

SELECT compute_revenue(NOW()::date-1, now()::DATE+50);
CALL return_car(123, 1);

select * from returned;

SELECT * FROM carmodels;
SELECT * FROM cardetails;
select * from bookings;