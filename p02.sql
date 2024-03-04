create table customers
(
    email   varchar not null
        primary key,
    fsname  varchar,
    lsname  varchar not null,
    address varchar not null,
    dob     date    not null
        constraint customers_dob_check
            check (dob < CURRENT_DATE),
    phone   varchar not null
);

alter table customers
    owner to postgres;

create table locations
(
    zip   varchar not null
        primary key,
    lname varchar not null
        unique,
    laddr varchar not null
);

alter table locations
    owner to postgres;

create table employees
(
    eid          serial
        primary key,
    ename        varchar not null,
    ephone       varchar not null,
    location_zip varchar not null
        references locations
);

alter table employees
    owner to postgres;

create table drivers
(
    eid  integer not null
        primary key
        references employees
            on delete cascade,
    pdvl varchar not null
        unique
);

alter table drivers
    owner to postgres;

create table carmodels
(
    brand    varchar not null,
    model    varchar not null,
    capacity integer not null,
    deposit  numeric not null,
    daily    numeric not null,
    primary key (brand, model)
);

alter table carmodels
    owner to postgres;

create table cardetails
(
    plate        varchar not null
        primary key,
    color        varchar not null,
    pyear        integer not null,
    model_brand  varchar not null,
    model_model  varchar not null,
    location_zip varchar not null
        references locations,
    foreign key (model_brand, model_model) references carmodels
        on delete cascade
);

alter table cardetails
    owner to postgres;

create table bookings
(
    bid            serial
        primary key,
    sdate          date    not null,
    days           integer not null,
    ccnum          varchar not null,
    bdate          date    not null,
    cost           numeric
        constraint lol
            check (cost >= (0)::numeric),
    edate          date generated always as ((sdate + ((days)::double precision * '1 day'::interval))) stored,
    customer_email varchar not null
        references customers,
    location_zip   varchar not null
        references locations,
    car_plate      varchar
        references cardetails,
    handover_eid   integer
        references employees,
    employee_eid   integer
        references employees,
    driver_eid     integer
        references drivers,
    constraint bookings_check
        check (bdate < sdate)
);

alter table bookings
    owner to postgres;

