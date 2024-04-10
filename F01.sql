-- FUNCTION 1
CREATE OR REPLACE FUNCTION compute_revenue (
  sdate1 DATE, edate1 DATE
) RETURNS NUMERIC AS $$

  DECLARE
      curs_B CURSOR FOR (SELECT * FROM BOOKINGS WHERE sdate + days <= edate1 AND sdate >= sdate1 ORDER BY brand, model);
      curs_C CURSOR FOR (SELECT * FROM carmodels);
      curs_H CURSOR FOR (SELECT * FROM hires);

      prev_B RECORD;
      curr_B RECORD;
      curr_C RECORD;
      curr_H RECORD;
      -- Calculate Hire revenue
      -- Track only the cars that have been assigned a car
      --rev NUMERIC := - (SELECT COUNT(*) FROM (SELECT DISTINCT (brand, model) FROM BOOKINGS WHERE sdate + days <= edate1 AND sdate >= sdate1)) * 100;
      rev NUMERIC := - (SELECT COUNT(*) FROM (SELECT DISTINCT (brand, model) FROM BOOKINGS LEFT JOIN ASSIGNS ON ASSIGNS.bid = BOOKINGS.bid WHERE sdate + days <= edate1 AND sdate >= sdate1 AND ASSIGNS.bid is not null)) * 100;
      daily NUMERIC;

  BEGIN
      RAISE NOTICE 'Car cost: %', rev;
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
          -- Caculate Booking revenue
          daily := curr_C.daily;
          rev := rev + (curr_B.days) * daily;
          prev_B := curr_B;
      end loop;
      RAISE NOTICE 'Bookings - Car cost: %', rev;
    CLOSE curs_B;

      OPEN curs_H;
      LOOP
          FETCH curs_H INTO curr_H;
          EXIT WHEN NOT FOUND;
          -- Calculate Hire revenue
          IF curr_H.fromdate >= sdate1 AND curr_H.todate <= edate1 THEN rev := rev + ((curr_H.todate - curr_H.fromdate + 1)*10);
          end if;
      end loop;
      CLOSE curs_H;
      RAISE NOTICE 'Bookings + hires - Car cost: %', rev;
      return rev;
  END;
$$ LANGUAGE plpgsql;