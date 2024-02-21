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
        check (bdate < sdate)
);

alter table p02.bookings
    owner to postgres;

