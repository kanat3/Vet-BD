-- administrator table:

INSERT INTO administrator (first_name, second_name, last_name, phone, passport, snils, inn)
VALUES ('Джон', 'Ди', 'Смит', '+1234567890', '1234-567890', '123-456-789 12', '123456789012');

-- registrar table:

INSERT INTO registar (first_name, second_name, last_name, phone, passport, snils, inn, refadministrator)
VALUES ('Жан', 'Дер', 'Вилсон', '+0987654321', '4321-098765', '987-654-321 98', '987654321012', 1);

-- doctor table:

INSERT INTO doctor (first_name, second_name, last_name, specialization, phone, passport, education, specification, snils, inn, refadministrator)
VALUES ('Алекс', 'Джонсон', 'Браун', 'Кардиолог', '+1122334455', '5678-123456', 'Московская государственная академия ветеринарной медицины и биотехнологии имени К.И. Скрябина', 'Специалист по сердцу (не разбитому)', '456-789-123 45', '123456789012', 1);
INSERT INTO doctor (first_name, second_name, last_name, specialization, phone, passport, education, specification, snils, inn, refadministrator)
VALUES ('Лина', 'Кайн', 'Ки', 'Терапевт', '+1122334113', '5678-123453', 'Московская государственная академия ветеринарной медицины и биотехнологии имени К.И. Скрябина', 'Общий специалист', '678-789-122 45', '999456789012', 1);
INSERT INTO doctor (first_name, second_name, last_name, specialization, phone, passport, education, specification, snils, inn, refadministrator)
VALUES ('Артем', 'Нат', 'Киров', 'Терапевт', '+1122334113', '5678-123453', 'Московская государственная академия ветеринарной медицины и биотехнологии имени К.И. Скрябина', 'Общий специалист', '156-789-452 45', '979456889012', 1);

-- specialization table:

INSERT INTO specialization (idspecialization)
VALUES (3);
INSERT INTO specialization (idspecialization)
VALUES (4);
INSERT INTO specialization (idspecialization)
VALUES (5);
INSERT INTO specialization (idspecialization)
VALUES (6);

-- client table:

INSERT INTO client (first_name, second_name, last_name, phone, passport, sex, refregistrar)
VALUES ('Сара', 'Тейлор', 'Паркер', '+9988776655', '8765-432109', 'Ж', 1);
INSERT INTO client (first_name, second_name, last_name, phone, passport, sex, refregistrar)
VALUES ('Райен', 'Гослинг', 'Паркер', '+9988776656', '8765-432139', 'М', 1);

-- bill table:

INSERT INTO bill (price, ispaid, refclient, refregistrar)
VALUES (1989, false, 2, 1);
INSERT INTO bill (price, ispaid, refclient, refregistrar)
VALUES (1500, false, 3, 1);
INSERT INTO bill (price, ispaid, refclient, refregistrar)
VALUES (1700, false, 3, 1);

-- pettype table:

INSERT INTO pettype (nametype, specification, namelatin, idpettype)
VALUES ('Собака', 'Золотой ретривер', 'Canislupusfamiliaris', 1);
INSERT INTO pettype (nametype, specification, namelatin, idpettype)
VALUES ('Кошка', 'Сиамская', 'Feliscatus', 2);
INSERT INTO pettype (nametype, specification, namelatin, idpettype)
VALUES ('Хомяк', 'Вислоухий боб', NULL, 3);
INSERT INTO pettype (nametype, specification, namelatin, idpettype)
VALUES ('Попугай', 'Говорящий', NULL, 4);

-- specializationpet table:

INSERT INTO specializationpet (name, refspecialization, refpettype)
VALUES ('Кардиолог', 3, 1);
INSERT INTO specializationpet (name, refspecialization, refpettype)
VALUES ('Дантист', 4, 3);
INSERT INTO specializationpet (name, refspecialization, refpettype)
VALUES ('Онколог', 5, 2);
INSERT INTO specializationpet (name, refspecialization, refpettype)
VALUES ('Терапевт', 6, 1);
INSERT INTO specializationpet (name, refspecialization, refpettype)
VALUES ('Терапевт', 6, 2);
INSERT INTO specializationpet (name, refspecialization, refpettype)
VALUES ('Терапевт', 6, 3);
-- specializationlist table:

INSERT INTO specializationlist (name, refdoctor, refpetspec)
VALUES ('Хирург-кардиолог', 2, 1);
INSERT INTO specializationlist (name, refdoctor, refpetspec)
VALUES ('Стоматолог-хирург', 1, 2);
INSERT INTO specializationlist (name, refdoctor, refpetspec)
VALUES ('Помощник стоматолога', 1, 1);

-- pet table:

INSERT INTO pet (fullname, pettype, age, sex, height, weight, specification, refclient, refpettype)
VALUES ('Макс', 'Собака', 3, 'М', 50, 20, 'Золотой ретривер', 2, 1);
INSERT INTO pet (fullname, pettype, age, sex, height, weight, specification, refclient, refpettype)
VALUES ('Люси', 'Кошка', 2, 'Ж', 30, 5, 'Сиамская', 2, 2);
INSERT INTO pet (fullname, pettype, age, sex, height, weight, specification, refclient, refpettype)
VALUES ('Бадди', 'Хомяк', 5, 'М', 60, 25, NULL, 3, 3);
INSERT INTO pet (fullname, pettype, age, sex, height, weight, specification, refclient, refpettype)
VALUES ('Говорун', 'Попугай', 7, 'М', 40, 2, NULL, 3, 4);


-- vaccine table:

INSERT INTO vaccine (name, indications, contraindications, engname)
VALUES ('Rabies', 'Prevents rabies in pets', 'Can cause allergic reactions in some pets', 'Rabies');
INSERT INTO vaccine (name, indications, contraindications, engname)
VALUES ('Distemper', 'Prevents distemper in dogs', 'Can cause fever and loss of appetite in some dogs', 'Distemper');
INSERT INTO vaccine (name, indications, contraindications, engname)
VALUES ('Feline leukemia', 'Prevents feline leukemia in cats', 'Can cause lethargy in some cats', 'Feline leukemia');


-- service table:

INSERT INTO service (name, price, refvaccine, refpetspec)
VALUES ('Вакцинация Rabies', 500, 1, 4);
INSERT INTO service (name, price, refvaccine, refpetspec)
VALUES ('Вакцинация Distemper', 500, 2, 5);
INSERT INTO service (name, price, refvaccine, refpetspec)
VALUES ('Вакцинация Feline leukemia', 500, 3, 6);
INSERT INTO service (name, price, refvaccine, refpetspec)
VALUES ('Общий анализ крови', 1900, NULL, NULL);
INSERT INTO service (name, price, refvaccine, refpetspec)
VALUES ('Чистка зубов', 7570, NULL, 2);

-- servicepet table:

INSERT INTO servicepet (refpettype, refservice)
VALUES (1, 1);
INSERT INTO servicepet (refpettype, refservice)
VALUES (1, 4);
INSERT INTO servicepet (refpettype, refservice)
VALUES (1, 5);
INSERT INTO servicepet (refpettype, refservice)
VALUES (2, 5);
INSERT INTO servicepet (refpettype, refservice)
VALUES (2, 4);
INSERT INTO servicepet (refpettype, refservice)
VALUES (2, 5);
INSERT INTO servicepet (refpettype, refservice)
VALUES (4, 4);


-- vaccinelist table:

INSERT INTO vaccinelist (refpet, refvaccine)
VALUES (1, 1);


-- monitoring table:

INSERT INTO monitoring (value, date, refdoctor, refpet)
VALUES ('В норме', '2022-01-01', 2, 1);
INSERT INTO monitoring (value, date, refdoctor, refpet)
VALUES ('Выше среднего', '2022-01-02', 2, 2);
INSERT INTO monitoring (value, date, refdoctor, refpet)
VALUES ('В норме', '2022-01-03', 1, 3);


-- indicator table:

INSERT INTO indicator (name, pettype, unit, min, max, refmonitoring)
VALUES ('Температура', 'Собака', 'Fahrenheit', '98', '102', 1);
INSERT INTO indicator (name, pettype, unit, min, max, refmonitoring)
VALUES ('Сердцебиение', 'Кошка', 'BPM', '120', '160', 2);
INSERT INTO indicator (name, pettype, unit, min, max, refmonitoring)
VALUES ('Давление', 'Хомяк', 'mmHg', '80/120', '90/140', 5);

-- appointment table:

INSERT INTO appointment (time, refdoctor, refpet, refbill)
VALUES ('1999-01-08 04:05:06', 1, 1, 1);
INSERT INTO appointment (time, refdoctor, refpet, refbill)
VALUES ('1999-01-08 04:05:06', 2, 2, 2);

INSERT INTO appointment (time, refdoctor, refpet, refbill)
VALUES ('2023-01-08 15:05:00', 3, 4, 3);

-- appointmentlist table:

INSERT INTO appointmentlist (refappointment, refservice)
VALUES (1, 4);
INSERT INTO appointmentlist (refappointment, refservice)
VALUES (2, 4);


-- recipe table:

INSERT INTO recipe (specification, name, plan, refappointment)
VALUES ('Feed twice a day', 'Dog food', '1 cup in the morning, 1 cup in the evening', 1);
INSERT INTO recipe (specification, name, plan, refappointment)
VALUES ('Apply ointment to wound', 'Antibiotic ointment', 'Apply a pea-sized amount to wound twice a day', 2);