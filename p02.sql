--Ricco test Git Branch Push
create table p02.customers
(
    email   text    not null
        primary key,
    address text    not null,
    dob     date    not null
        constraint customers_dob_check
            check (dob < CURRENT_DATE),
    phone   text    not null
        unique,
    fsname  text,
    lsname  text    not null,
    name    text generated always as (((fsname || ' '::text) || lsname)) stored,
    age     integer not null
);

alter table p02.customers
    owner to postgres;

create table p02.locations
(
    zip   text not null,
    lname text not null,
    laddr text not null,
    primary key (zip, lname)
);

alter table p02.locations
    owner to postgres;

create table p02.employees
(
    eid    text not null
        primary key,
    ename  text not null,
    ephone text not null
);

alter table p02.employees
    owner to postgres;

create table p02.drivers
(
    eid  text not null,
    pdvl text not null,
    primary key (eid, pdvl)
);

alter table p02.drivers
    owner to postgres;

create table p02.carmodels
(
    brand    text    not null,
    model    text    not null,
    capacity integer not null
        constraint carmodels_capacity_check
            check (capacity > 0),
    deposit  integer not null
        constraint carmodels_deposit_check
            check (deposit >= 0),
    daily    integer not null
        constraint carmodels_daily_check
            check (daily > 0),
    primary key (brand, model)
);

alter table p02.carmodels
    owner to postgres;

create table p02.cardetails
(
    plate text    not null
        primary key,
    color text    not null,
    pyear integer not null
);

alter table p02.cardetails
    owner to postgres;

CREATE TABLE bookings(
    bid TEXT NOT NULL PRIMARY KEY,
    sdate DATE NOT NULL /*CONSTRAINT bookings_bdate_sdate_check*/ CHECK (sdate > bdate), -- not sure whether makes a diff but I thought should check sdate > bdate rather than bdate < sdate which is the same but more like the booking is "automatically" recorded and cannot be changed but sdate can 'amend' according to customer
    days INT NOT NULL /*CONSTRAINT bookings_days_check*/ CHECK (days >= 0),
    edate DATE GENERATED ALWAYS AS ((sdate + ((5)/*::double precision * '1 day'::interval*/))) STORED, 
    -- I dont think the double precision * '1 days' is required? I tried SELECT (CURRENT_DATE + ((SomeRandomNumber])::double precision * '1 day'::interval)); 
    -- and it's the same as without the typecasting * 1 day except it adds time too? Idk up to yall

    ccnum TEXT NOT NULL, -- Changed from BIGINT to TEXT in case ccnum starts w 0
    bdate DATE NOT NULL,

    -- ensure at most & at least 1 customer / total & key participation
    email TEXT NOT NULL REFERENCES customers (email), 

    -- 0/1 car detail; can be null customer only choose car model and assigning may not be immediate (based on availability)
    plate TEXT REFERENCES cardetails (plate),

    -- 1 car model
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    /*CONSTRAINT bookings_car*/ FOREIGN KEY (brand, model) REFERENCES carmodels (brand, model),

    -- 1 location...?? actually is this required? Since car detail has location
    zip TEXT,
    lname TEXT, -- why is lname part of the composite key in location wadafaq zip not enough?
    /*CONSTRAINT bookings_location*/ FOREIGN KEY (zip, lname) REFERENCES locations (zip, lname),

    -- 0/1 driver
    eid TEXT,
    pdvl TEXT,
    fromdate DATE CHECK (fromdate > sdate),
    todate DATE CHECK (todate < edate),
    /*CONSTRAINT bookings_driver*/ FOREIGN KEY (eid, pdvl) REFERENCES drivers (eid, pdvl),

    --Not null because might not know which employee?
    handovereid TEXT REFERENCES employees (eid), 
    returneid TEXT REFERENCES employees (eid), 

    --Not sure whether need to have cost as attribute?? idts right wadafaq but I just put
    deposit INT,
    daily INT,
    cost INT GENERATED ALWAYS AS (deposit + daily*days) STORED

    --Optional constraint for creditcard?
    ,CONSTRAINT bookings_cc_requirement CHECK (cost < 0)
);

alter table p02.bookings
    owner to postgres;

