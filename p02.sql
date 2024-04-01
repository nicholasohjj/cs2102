DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS carmodels;
DROP TABLE IF EXISTS cardetails;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS handover;
DROP TABLE IF EXISTS returned;
DROP TABLE IF EXISTS works;
DROP TABLE IF EXISTS hires;

create table customers
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
    age     int
);

alter table customers
    owner to postgres;

create table locations
(
    zip   text,
    lname text not null unique,
    laddr text not null,
    primary key (zip)
);

alter table locations
    owner to postgres;

create table employees
(
    eid    text not null
        primary key,
    ename  text not null,
    ephone text not null
);

alter table employees
    owner to postgres;

create table drivers
(
    eid  text not null primary key references employees (eid),
    pdvl text not null,
    UNIQUE (pdvl)
);

alter table drivers
    owner to postgres;


/*
r/s with bookings implemented with key-total r/s:
- May be rented by at least 0 bookings: true, can add to carmodels without adding to 
bookings because they are seperate tables
- May be rented by more than 1 bookings: true, multiple rows in bookings can have the same
car models (foreign key values do not have to be unique)

note: car details can be understood as a car e.g. car model is volvo s60 
and there can be many of these cars in diff colours, with different license plates

r/s with car details implemented with key-total r/s: 
May have at least 0 car details:true, can add to carmodels without adding to 
cardetails because they are seperate tables
May have more than 1 car details:true, multiple rows in cardetails can have the same
car models (foreign key values do not have to be unique)
*/
create table carmodels
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

alter table carmodels
    owner to postgres;

/*
Must be a detail for exactly 1 car model: true, for every plate, both car_brand and car_model cannot be null
if a car model does not exist, the car cannot exist

Must be parked at exactly 1 location: true, as for every plate,both location_zip and location_lname cannot be null

*/
create table cardetails
(
    plate text    not null
        primary key,
    color text    not null,
    pyear integer not null
        constraint cardetails_pyear_check
            check (pyear > 0),
    car_brand text not null,
    car_model text not null,
    constraint fk_cardetails_carmodels foreign key(car_brand, car_model) references carmodels(brand, model)
        on update cascade on delete cascade,
    location_zip text not null,
    constraint fk_cardetails_locations foreign key(location_zip) references locations(zip)
);

alter table cardetails
    owner to postgres;

CREATE TABLE bookings(
    bid INT NOT NULL PRIMARY KEY,
    sdate DATE NOT NULL /*CONSTRAINT bookings_bdate_sdate_check*/ CHECK (sdate > bdate), -- not sure whether makes a diff but I thought should check sdate > bdate rather than bdate < sdate which is the same but more like the booking is "automatically" recorded and cannot be changed but sdate can 'amend' according to customer
    days INT NOT NULL /*CONSTRAINT bookings_days_check*/ CHECK (days >= 0),
    edate DATE GENERATED ALWAYS AS ((sdate + ((days)/*::double precision * '1 day'::interval*/))) STORED, 
    -- I dont think the double precision * '1 days' is required? I tried SELECT (CURRENT_DATE + ((SomeRandomNumber])::double precision * '1 day'::interval)); 
    -- and it's the same as without the typecasting * 1 day except it adds time too? Idk up to yall

    ccnum TEXT NOT NULL, -- Changed from BIGINT to TEXT in case ccnum starts w 0
    bdate DATE NOT NULL DEFAULT CURRENT_DATE,

    -- ensure at most & at least 1 customer / total & key participation
    email TEXT NOT NULL REFERENCES customers (email), 

    -- 1 car model
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    /*CONSTRAINT bookings_car*/ FOREIGN KEY (brand, model) REFERENCES carmodels (brand, model),

    -- 1 location...?? actually is this required? Since car detail has location
    zip TEXT NOT NULL REFERENCES locations (zip)
);

alter table bookings
    owner to postgres;

/*
to be an aggregate between bookings and cardetails + returned, handover
*/
create table assigns
(
    bid   integer primary key
        references p02.bookings(bid),
    plate text    not null
        references p02.cardetails(plate)
);

/*
no entry in handover before assigns: enforced with the foreign key constraint in handover.
note that assigns is implemented in bookings itself with the plate column.

same eid can handle different handovers with different bid: true, because primary key is bid

there cannot be 2 same eid doing the same handover: true, as bid is the primary key 

*/
create table handover
(
    bid   integer references bookings(bid),
    eid   text references employees(eid),
    primary key(bid),
    constraint fk_handover_assigns foreign key(bid) references assigns(bid)
);

alter table handover
    owner to postgres;

/*
can use different ccnum compared to booking: true, as no constraint on ccnum
can only be added after handover: enforced with foreign key constraint
*/
create table returned
(
    ccnum integer, 
    cost float not null,
    bid   integer references bookings(bid),
    eid   text references employees(eid),
    primary key(bid),
    constraint fk_returned_handover foreign key(bid) references handover(bid)
        on update cascade on delete cascade,
    constraint fk_returned_assigns foreign key(bid) references assigns(bid),
    CONSTRAINT return_ccnum_cost CHECK ((cost > 0 and ccnum IS NOT NULL) or (cost = 0))
);

alter table returned
    owner to postgres;

create table works(
    eid text primary key,
    zip text NOT NULL,
    FOREIGN KEY(eid) REFERENCES Employees(eid),
    FOREIGN KEY(zip) REFERENCES Locations(zip),
    unique(zip)    
);



CREATE TABLE Hires(
    bid INT PRIMARY KEY,
    eid TEXT NOT NULL,
    fromdate DATE NOT NULL,
    todate DATE NOT NULL,
    CHECK (todate >= fromdate),
    -- CHECK (
    --     fromdate > (
    --         SELECT
    --             sdate
    --         FROM
    --             bookings
    --         WHERE
    --             bid = Hires.bid
    --     )
    -- ),
    -- CHECK (
    --     todate < (
    --         SELECT
    --             edate
    --         FROM
    --             bookings
    --         WHERE
    --             bid = Hires.bid
    --     )
    -- ),
    ccnum TEXT NOT NULL,
    FOREIGN KEY(eid) REFERENCES Employees(eid),
    FOREIGN KEY(bid) REFERENCES Bookings(bid)
);
