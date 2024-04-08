/*
Group 147
1. Isabel Teo Jing Lin
  - add_employees
  - add_cars
  - corresponding tests and cross-checking tests of triggers
2. Ricco Lim
  - return_car
  - compute_revenue
  - Added in some tests for return_car and cross-checked auto_assigns & top_n_location
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
DECLARE
i int = 1; /* plpg arrs start from 1 */
val int = 0;
BEGIN
/* all arr can be assumed to have same length so just check one */
IF array_length(eids, 1) = 0 THEN
  RETURN;
END IF;

FOREACH val IN ARRAY eids LOOP
    INSERT INTO Employees (eid, ename, ephone, zip) VALUES (eids[i], enames[i], ephones[i], zips[i]);
    IF pdvls[i] IS NOT NULL THEN
        INSERT INTO Drivers (eid, pdvl) VALUES (eids[i], pdvls[i]);
    END IF;
    i:= i+1;
END LOOP;

END;
$$ LANGUAGE plpgsql;

-- PROCEDURE 2

CREATE OR REPLACE PROCEDURE add_car (
  brand   TEXT   , model  TEXT   , capacity INT  ,
  deposit NUMERIC, daily  NUMERIC,
  plates  TEXT[] , colors TEXT[] , pyears   INT[], zips INT[]
) AS $$
DECLARE
i int = 1; /* plpg arrs start from 1 */
val text;
BEGIN
INSERT INTO CarModels (brand, model, capacity, deposit, daily) VALUES (brand, model, capacity, deposit, daily);
/* all arr can be assumed to have same length so just check one */
IF array_length(plates, 1) = 0 THEN
  RETURN;
END IF;

FOREACH val IN ARRAY plates LOOP
    INSERT INTO CarDetails (brand, model, plate, color, pyear, zip) VALUES (brand, model, plates[i], colors[i], pyears[i], zips[i]);
    i:= i+1;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP PROCEDURE IF EXISTS return_car;
-- PROCEDURE 3

CREATE OR REPLACE PROCEDURE return_car (
  bid1 INT,
  eid1 INT
) AS $$
DECLARE
    -- Variables for holding computed values
    v_cost NUMERIC; -- Computed rental cost
    v_ccnum TEXT; -- Credit card number from the booking

    -- Variables for fetching booking and car model details directly
    v_daily_rate NUMERIC; -- Daily rate for the car model
    v_days INT; -- Number of days the car was rented
    v_deposit NUMERIC; -- Deposit amount for the car model
BEGIN
    -- Fetch the necessary details with a JOIN between Bookings and CarModels
    SELECT
        b.days AS rented_days,
        cm.daily AS daily_rate,
        cm.deposit AS model_deposit,
        b.ccnum
    INTO
        v_days, v_daily_rate, v_deposit, v_ccnum
    FROM
        Bookings b
    JOIN CarModels cm ON
        b.brand = cm.brand AND b.model = cm.model
    WHERE
        b.bid = bid1;

    -- Compute the cost
    v_cost := (v_daily_rate * v_days) - v_deposit;

    -- Since we have all the required details, proceed to insert into `Returned`
    INSERT INTO Returned (bid, eid, ccnum, cost)
    VALUES (bid1, eid1, v_ccnum, v_cost);

    -- Optionally, update the Assigns and Handover tables if necessary based on your application logic
    -- For simplicity, this step is omitted here. Add it if your logic requires tracking these entities.
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE return_car (
  bid1 INT,
  eid1 INT
) AS $$
    DECLARE
        ccnum text;
        cost numeric;
BEGIN
        SELECT bookings.ccnum, (daily * days - deposit) INTO ccnum, cost FROM bookings NATURAL JOIN carmodels WHERE bid = bid1;
        INSERT INTO returned (ccnum, cost, bid, eid) VALUES (ccnum, cost, bid1, eid1);
END;
$$ LANGUAGE plpgsql;

select * from bookings;
select * from bookings b natural join carmodels cm;

-- PROCEDURE 4
CREATE OR REPLACE PROCEDURE auto_assign () AS $$
-- add declarations here
BEGIN
  -- your code here
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS compute_revenue(DATE, DATE);
-- FUNCTION 1
CREATE OR REPLACE FUNCTION compute_revenue (
  sdate1 DATE, edate1 DATE
) RETURNS NUMERIC AS $$

  DECLARE
      curs_B CURSOR FOR (SELECT * FROM BOOKINGS WHERE sdate+days <= edate1 AND sdate >= sdate1 ORDER BY brand, model);
      curs_C CURSOR FOR (SELECT * FROM carmodels);
      curs_H CURSOR FOR (SELECT * FROM hires);

      prev_B RECORD;
      curr_B RECORD;
      curr_C RECORD;
      curr_H RECORD;
      rev NUMERIC := - (SELECT COUNT(*) FROM (SELECT DISTINCT (brand, model) FROM BOOKINGS WHERE sdate+days <= edate1 AND sdate >= sdate1)) * 100;
      daily NUMERIC;

  BEGIN
      OPEN curs_B;
      LOOP
          FETCH curs_B INTO curr_B;
          EXIT WHEN NOT FOUND;

          OPEN curs_C;
          LOOP
            FETCH curs_C INTO curr_C;
            EXIT WHEN curr_C.brand = curr_B.brand AND curr_C.model = curr_C.model OR NOT FOUND;
          end loop;

          CLOSE curs_C;
          daily := curr_C.daily;
          rev := rev + (curr_B.edate-curr_B.sdate)*daily;
          prev_B := curr_B;
      end loop;
    CLOSE curs_B;

      OPEN curs_H;
      LOOP
          FETCH curs_H INTO curr_H;
          EXIT WHEN NOT FOUND;
          IF curr_H.fromdate >= sdate1 AND curr_H.todate <= edate1 THEN rev := rev + ((curr_H.todate - curr_H.fromdate + 1)*10);
          end if;
      end loop;
      CLOSE curs_H;

      return rev;
  END;
$$ LANGUAGE plpgsql;

-- FUNCTION 2
CREATE OR REPLACE FUNCTION top_n_location (
  n INT, sdate DATE, edate DATE
) RETURNS TABLE(lname TEXT, revenue NUMERIC, rank INT) AS $$
  -- your code here
$$ LANGUAGE plpgsql;
