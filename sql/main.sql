
INSERT INTO appointment (time, refdoctor, refpet, refbill)
VALUES ('1999-01-08 04:05:06', 1, 1, 1);
INSERT INTO appointment (time, refdoctor, refpet, refbill)
VALUES ('1999-01-08 04:05:06', 2, 2, 2);
-- bad
-- доктор 1
-- тут у кардиолога специализация одна из списка по собакам
-- доктор 2 это стоматолог (для кошек - 2)
-- доктор 3 это терапевт для хомяка (3) и попугая (4)

INSERT INTO appointment (time, refdoctor, refpet, refbill)
VALUES ('2023-01-08 15:05:00', 3, 4, 3);

-- appointmentlist table:

-- общий анализ крови подходит всем питомцам (в servicepet - 4)
-- пока два питомца : собака и кошка
INSERT INTO appointmentlist (refappointment, refservice)
VALUES (1, 4);
-- для кошки (2 pet) определены только чистка зубов и анализ крови (5/4)
INSERT INTO appointmentlist (refappointment, refservice)
VALUES (2, 4);
-- хомяку или попугаю (3/4) можно только взять анализ крови (4)


SELECT d.iddoctor, d.second_name, sp.name, pt.idpettype, pt.nametype FROM doctor d
        JOIN specializationlist sl ON d.iddoctor = sl.refdoctor
        JOIN specializationpet sp ON sl.refpetspec = sp.idpetspec
        JOIN pettype pt ON pt.idpettype = sp.refpettype;

SELECT * FROM pet;
CALL select_doctor_for_pet(2, 'Стоматолог для кошек'::varchar, '2023-05-12 20:29:04'::timestamp);
SELECT add_client_and_pet('Андрей'::varchar, 'Андреевич'::varchar, 'Андреев'::varchar, '+79519390412'::varchar, '7025771954'::varchar, 'М'::char, 'Питбуля'::varchar, 'Собака'::varchar);
SELECT add_client_and_pet('Владимир'::varchar, 'Владимирович'::varchar, 'Владимиров'::varchar, '+79519390722'::varchar, '7025631954'::varchar, 'М'::char, 'Плюша'::varchar, 'Медведь'::varchar);
CALL select_doctor_for_pet(4, 'Онколог для медведей'::varchar, '2023-05-15 16:45:00'::timestamp);
CALL select_doctor_for_pet(3, 'Терапевт для хомяков'::varchar, '2023-05-15 16:45:00'::timestamp);
CALL select_doctor_for_pet(4, 'Терапевт для попугаев'::varchar, '2023-05-15 17:45:00'::timestamp); -- тут будет занят
CALL select_doctor_for_pet(4, 'Терапевт для попугаев'::varchar, '2023-05-18 16:15:00'::timestamp); 
SELECT add_client_and_pet('Мари'::varchar, 'Болотова'::varchar, 'Андреева'::varchar, '+79559390417'::varchar, '7024201954'::varchar, 'Ж'::char, 'Пташка'::varchar, 'Попугай'::varchar);