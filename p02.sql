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

/*
Must be a detail for exactly 1 car model: true, as both car_brand and car_model cannot be null
if a car model does not exist, the car cannot exist

Must be parked at exactly 1 location: true, as both location_zip and location_lname cannot be null

*/
create table p02.cardetails
(
    plate text    not null
        primary key,
    color text    not null,
    pyear integer not null
        constraint cardetails_pyear_check
            check (pyear > 0),
    car_brand text not null,
    car_model text not null,
    foreign key(car_brand, car_model) references p02.carmodels(brand, model)
        on update cascade on delete cascade,
    location_zip text not null,
    location_lname text not null,
    foreign key(location_zip, location_lname) references p02.locations(zip, lname)
);

alter table p02.cardetails
    owner to postgres;


/*
must have exactly 1 carmodel: key-total r/s enforced as car_brand and car_model cannot be null. 
*/
create table p02.bookings
(
    bid   text    not null
        primary key,
    sdate date    not null,
    days  integer not null
        constraint bookings_days_check
            check (days >= 0),
    ccnum bigint  not null,
    bdate date    not null,
    cost  integer
        constraint bookings_cost_check
            check (cost >= 0),
    edate date generated always as ((sdate + ((days)::double precision * '1 day'::interval))) stored,
    constraint bookings_check
        check (bdate < sdate),
    car_brand text not null,
    car_model text not null,
    foreign key(car_brand, car_model) references p02.carmodels(brand, model)
);

alter table p02.bookings
    owner to postgres;

