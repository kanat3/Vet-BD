create table if not exists administrator(
   first_name varchar(45) not null,
   second_name varchar(45) not null,
   last_name varchar(45) not null,
   phone varchar(20) check (phone ~ '^(\s*)?(\+)?([- _():=+]?\d[- _():=+]?){10,14}(\s*)?$'),
   passport varchar (11) not null check (passport ~ '^(\d{4})\s*-?\s*(\d{6})'),
   snils varchar(14) not null check (snils ~ '^[0-9]{3}-[0-9]{3}-[0-9]{3} [0-9]{2}$'),
   inn varchar(12) not null check (inn ~ '^[0-9]{10}$|^[0-9]{12}$'),
   idadministrator serial primary key
);

create table if not exists registar(
   first_name varchar(45) not null,
   second_name varchar(45) not null,
   last_name varchar(45) not null,
   phone varchar(20) check (phone ~ '^(\s*)?(\+)?([- _():=+]?\d[- _():=+]?){10,14}(\s*)?$'),
   passport varchar (11) not null check (passport ~ '^(\d{4})\s*-?\s*(\d{6})'),
   snils varchar(14) not null check (snils ~ '^[0-9]{3}-[0-9]{3}-[0-9]{3} [0-9]{2}$'),
   inn varchar(12) not null check (inn ~ '^[0-9]{10}$|^[0-9]{12}$'),
   refadministrator integer,
   foreign key (refadministrator) references administrator (idadministrator),
   idregistar serial primary key
);

create table if not exists doctor(
   first_name varchar(45) not null,
   second_name varchar(45) not null,
   last_name varchar(45) not null,
   -- specialization varchar (30) not null,
   phone varchar(20) check (phone ~ '^(\s*)?(\+)?([- _():=+]?\d[- _():=+]?){10,14}(\s*)?$'),
   passport varchar (11) not null check (passport ~ '^(\d{4})\s*-?\s*(\d{6})'),
   education varchar(100) not null,
   specification varchar(160),
   snils varchar(14) not null check (snils ~ '^[0-9]{3}-[0-9]{3}-[0-9]{3} [0-9]{2}$'),
   inn varchar(12) not null check (inn ~ '^[0-9]{10}$|^[0-9]{12}$'),
   refadministrator integer,
   foreign key (refadministrator) references administrator (idadministrator),
   iddoctor serial primary key
);

create table if not exists specialization(
   name varchar(45) not null,
   idspecialization serial primary key
);

create table if not exists client(
   first_name varchar(45) not null,
   second_name varchar(45) not null,
   last_name varchar(45) not null,
   phone varchar(20) check (phone ~ '^(\s*)?(\+)?([- _():=+]?\d[- _():=+]?){10,14}(\s*)?$'),
   passport varchar(11) check (passport ~ '^(\d{4})\s*-?\s*(\d{6})'),
   sex char not null,
   refregistrar integer,
   foreign key (refregistrar) references registar (idregistar),
   idclient serial primary key
);

create table if not exists bill(
   price integer not null check (price >= 0),
   ispaid boolean not null,
   refclient integer,
   refregistrar integer,
   foreign key (refclient) references client (idclient),
   foreign key (refregistrar) references registar (idregistar),
   idbill serial primary key
);

create table if not exists pettype(
   nametype varchar(45) not null,
   specification varchar(160),
   namelatin varchar(45) check (namelatin ~  '^[A-Za-z]+$'),
   idpettype serial primary key
);

create table if not exists specializationpet(
   name varchar(45) not null,
   refspecialization integer,
   refpettype integer,
   foreign key (refspecialization) references specialization (idspecialization),
   foreign key (refpettype) references pettype (idpettype),
   idpetspec serial primary key
);

create table if not exists specializationlist(
   name varchar(45) not null,
   refdoctor integer,
   refpetspec integer,
   foreign key (refdoctor) references doctor (iddoctor),
   foreign key (refpetspec) references specializationpet (idpetspec),
   idspecializationlist serial primary key
);

create table if not exists pet(
   fullname varchar(45),
   -- pettype varchar(45) not null,
   age integer check (age >= 0),
   sex char,
   height integer check (height >= 0),
   weight integer check (weight >= 0),
   specification varchar(160),
   refclient integer,
   refpettype integer,
   foreign key (refclient) references client (idclient),
   foreign key (refpettype) references pettype (idpettype),
   idpet serial primary key
);

create table if not exists vaccine(
   name varchar(45) not null,
   indications varchar(160) not null,
   contraindications varchar(160) not null,
   engname varchar(45),
   idvaccine serial primary key
);

create table if not exists service(
   name varchar(45) not null,
   price integer not null check (price >= 0),
   refvaccine integer,
   refpetspec integer,
   foreign key (refvaccine) references vaccine (idvaccine),
   foreign key (refpetspec) references specializationpet (idpetspec),
   idservice serial primary key
);

create table if not exists servicepet(
   refpettype integer,
   refservice integer,
   foreign key (refpettype) references pettype (idpettype),
   foreign key (refservice) references service (idservice),
   idservicepet serial primary key
);

create table if not exists vaccinelist(
   refpet integer,
   refvaccine integer,
   foreign key (refpet) references pet (idpet),
   foreign key (refvaccine) references vaccine (idvaccine),
   idvaccinelist serial primary key
);

create table if not exists monitoring(
   value integer not null,
   date TIMESTAMP not null,
   refdoctor integer,
   refpet integer,
   foreign key (refpet) references pet (idpet),
   foreign key (refdoctor) references doctor (iddoctor),
   idmonitoring serial primary key
);

create table if not exists indicator(
   name varchar(45) not null,
   unit varchar(160),
   min varchar(15),
   max varchar(15),
   refmonitoring integer,
   foreign key (refmonitoring) references monitoring (idmonitoring),
   idindicator serial primary key
);


create table if not exists appointment(
   date timestamp not null,
   refdoctor integer,
   refpet integer,
   refbill integer,
   foreign key (refdoctor) references doctor (iddoctor),
   foreign key (refpet) references pet (idpet),
   foreign key (refbill) references bill (idbill),
   idappointment serial primary key
);

create table if not exists appointmentlist(
   refappointment integer,
   refservice integer,
   foreign key (refappointment) references appointment (idappointment),
   foreign key (refservice) references service (idservice),
   idappointmentlist serial primary key
);

create table if not exists recipe(
   specification varchar(160),
   name varchar(45),
   plan varchar(160) not null,
   refappointment integer,
   foreign key (refappointment) references appointment (idappointment),
   idrecipe serial primary key
);