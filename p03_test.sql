/* Test Procedure 1*/

DELETE FROM drivers cascade;
DELETE FROM employees cascade;
DELETE FROM carmodels cascade;
DELETE FROM cardetails cascade;
DELETE FROM locations cascade;

INSERT INTO Locations (zip,lname,laddr) VALUES (11111,'loc1','loc1addr');
INSERT INTO Locations (zip,lname,laddr) VALUES (22222,'loc2','loc2addr');
INSERT INTO Locations (zip,lname,laddr) VALUES (33333,'loc3','loc3addr');

CALL add_employees(
  ARRAY[1,2,3], 
  ARRAY['J', 'JJ', 'JJJ'], 
  ARRAY[11111111,22222222,33333333], 
  ARRAY[11111,22222,33333], 
  ARRAY['driver1',NULL,NULL]
);

CALL add_employees(
  ARRAY[]::integer[], 
  ARRAY[]::text[], 
  ARRAY[]::integer[], 
  ARRAY[]::integer[], 
  ARRAY[]::text[]
);

SELECT * FROM employees;
SELECT * FROM drivers;

/*Test Procedure 2*/

CALL add_car (
  'brand1', 
  'model1',
  5,
  100.00,
  50.00,
  ARRAY['plate1','plate2','plate3'], 
  ARRAY['color1','color2','color3'],
  ARRAY[2000,2001,2002],
  ARRAY[11111,22222,33333]
);

CALL add_car (
  'brand2', 
  'model2',
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