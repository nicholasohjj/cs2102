/*
Group #
1. Name 1
  - Contribution A
  - Contribution B
2. Name 2
  - Contribution A
  - Contribution B
*/



/* Write your Trigger Below */

/*1. Preventing Double-Booking of Drivers*/
CREATE OR REPLACE FUNCTION check_driver_double_booking() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM Hires h
    WHERE h.eid = NEW.eid
    AND (
      (NEW.fromdate BETWEEN h.fromdate AND h.todate) OR
      (NEW.todate BETWEEN h.fromdate AND h.todate) OR
      (h.fromdate BETWEEN NEW.fromdate AND NEW.todate) OR
      (h.todate BETWEEN NEW.fromdate AND NEW.todate)
    )
  ) THEN
    RAISE EXCEPTION 'Driver is double-booked';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_driver_double_booking
BEFORE INSERT ON Hires
FOR EACH ROW EXECUTE FUNCTION check_driver_double_booking();


/*2. Preventing Double-Booking of Cars*/
CREATE OR REPLACE FUNCTION check_car_double_booking() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM Assigns a
    JOIN Bookings b ON a.bid = b.bid
    WHERE a.plate = NEW.plate
    AND (
      b.sdate <= (SELECT sdate + days FROM Bookings WHERE bid = NEW.bid)
      AND (SELECT sdate FROM Bookings WHERE bid = NEW.bid) <= (b.sdate + b.days)
    )
  ) THEN
    RAISE EXCEPTION 'Car is double-booked';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_car_double_booking
BEFORE INSERT ON Assigns
FOR EACH ROW EXECUTE FUNCTION check_car_double_booking();

/*3. Ensuring Handover Location Matches Booking Location*/
CREATE OR REPLACE FUNCTION check_handover_location() RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT zip FROM Employees WHERE eid = NEW.eid) != (SELECT zip FROM Bookings WHERE bid = NEW.bid) THEN
    RAISE EXCEPTION 'Employee and booking locations do not match';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_handover_location
BEFORE INSERT ON Handover
FOR EACH ROW EXECUTE FUNCTION check_handover_location();

/*4.Ensuring Assigned Car Matches Booking Car Model*/
CREATE OR REPLACE FUNCTION check_car_model_match() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM CarDetails cd
    JOIN Bookings b ON cd.brand = b.brand AND cd.model = b.model
    WHERE cd.plate = NEW.plate AND b.bid = NEW.bid
  ) THEN
    RAISE EXCEPTION 'Assigned car does not match booking car model';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_car_model_match
BEFORE INSERT ON Assigns
FOR EACH ROW EXECUTE FUNCTION check_car_model_match();

/*5. Ensuring Assigned Car Is Parked at Booking Location*/
CREATE OR REPLACE FUNCTION check_car_parking_location() RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT zip FROM CarDetails WHERE plate = NEW.plate) != (SELECT zip FROM Bookings WHERE bid = NEW.bid) THEN
    RAISE EXCEPTION 'Assigned car is not parked at the booking location';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_car_parking_location
BEFORE INSERT ON Assigns
FOR EACH ROW EXECUTE FUNCTION check_car_parking_location();

/*6. Ensuring Drivers Are Hired Within Booking Dates*/
CREATE OR REPLACE FUNCTION check_driver_hire_dates() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Bookings b
    WHERE b.bid = NEW.bid
    AND NEW.fromdate >= b.sdate
    AND NEW.todate <= (b.sdate + b.days)
  ) THEN
    RAISE EXCEPTION 'Driver hire dates are outside the booking period';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_driver_hire_dates
BEFORE INSERT ON Hires
FOR EACH ROW EXECUTE FUNCTION check_driver_hire_dates();

/*
  Write your Routines Below
    Comment out your routine if you cannot complete
    the routine.
    If any of your routine causes error (even those
    that are incomplete), you may get 0 mark for P03.
*/

-- PROCEDURE 1
CREATE OR REPLACE PROCEDURE add_employees (
  eids INT[], enames TEXT[], ephones INT[], zips INT[], pdvls TEXT[]
) AS $$
-- add declarations here
BEGIN
  -- your code here
END;
$$ LANGUAGE plpgsql;


-- PROCEDURE 2
CREATE OR REPLACE PROCEDURE add_car (
  brand   TEXT   , model  TEXT   , capacity INT  ,
  deposit NUMERIC, daily  NUMERIC,
  plates  TEXT[] , colors TEXT[] , pyears   INT[], zips INT[]
) AS $$
-- add declarations here
BEGIN
  -- your code here
END;
$$ LANGUAGE plpgsql;


-- PROCEDURE 3
CREATE OR REPLACE PROCEDURE return_car (
  bid INT, eid INT
) AS $$
-- add declarations here
BEGIN
  -- your code here
END;
$$ LANGUAGE plpgsql;


-- PROCEDURE 4
CREATE OR REPLACE PROCEDURE auto_assign () AS $$
-- add declarations here
BEGIN
  -- your code here
END;
$$ LANGUAGE plpgsql;


-- FUNCTION 1
CREATE OR REPLACE FUNCTION compute_revenue (
  sdate DATE, edate DATE
) RETURNS NUMERIC AS $$
  -- your code here
$$ LANGUAGE plpgsql;


-- FUNCTION 2
CREATE OR REPLACE FUNCTION top_n_location (
  n INT, sdate DATE, edate DATE
) RETURNS TABLE(lname TEXT, revenue NUMERIC, rank INT) AS $$
  -- your code here
$$ LANGUAGE plpgsql;
