drop FUNCTION select_doctor_for_pet;

CREATE OR REPLACE PROCEDURE select_doctor_for_pet(
    IN pet_id INTEGER,
    IN specialization VARCHAR(45),
    IN appointment_date TIMESTAMP
) LANGUAGE plpgsql AS $$
DECLARE
    doctor_id INTEGER;
    refclient_id INTEGER;
    bill_id INTEGER;
BEGIN
    -- Проверяем, существуют ли врачи, подходящие по специализации и виду животных
    
    SELECT sl.refdoctor INTO doctor_id
    FROM specializationlist sl
    JOIN specializationpet sp ON sp.idpetspec = sl.refpetspec
    JOIN pet ON pet.idpet = $1 AND pet.refpettype = sp.refpettype
    WHERE sl.name = $2
    LIMIT 1;
    
    IF doctor_id IS NULL THEN
        RAISE EXCEPTION 'Нет подходящих докторов для питомца и специализации';
    END IF;
    
    -- Проверяем, свободен ли врач во время приема
    IF EXISTS (
        SELECT 1 FROM appointment
        WHERE refdoctor = doctor_id
        AND time BETWEEN appointment_date - INTERVAL '15 minutes' AND appointment_date + INTERVAL '15 minutes'
    ) THEN
        RAISE EXCEPTION 'Доктор занят';
    END IF;
    
    -- Если все проверки пройдены, выбираем врача

    SELECT iddoctor INTO doctor_id
    FROM doctor
    WHERE iddoctor = doctor_id
    LIMIT 1;


    IF doctor_id IS NULL THEN
        RAISE EXCEPTION 'Мы не смогли найти доктора :(';
    END IF;
    
    -- Если всё ок, формируем начальный чек

    SELECT refclient INTO refclient_id
    FROM pet
    WHERE idpet = pet_id
    LIMIT 1;
    
    INSERT INTO bill(price, ispaid, refclient, refregistrar)
      VALUES(0, false, refclient_id, 1)
      RETURNING idbill INTO bill_id;

    -- Добавляем новый приём

    INSERT INTO appointment(time, refdoctor, refpet, refbill)
      VALUES (appointment_date, doctor_id, pet_id, bill_id);
END;
$$;

drop FUNCTION add_client_and_pet;

CREATE OR REPLACE FUNCTION add_client_and_pet(
    client_first_name VARCHAR(45),
    client_second_name VARCHAR(45),
    client_last_name VARCHAR(45),
    client_phone VARCHAR(20),
    client_passport VARCHAR(11),
    client_sex CHAR,
    pet_fullname VARCHAR(45),
    pet_type VARCHAR(45)
)
RETURNS TABLE(name VARCHAR(45), price INTEGER) AS $$
DECLARE
    pet_type_id INTEGER;
    pet_spec_id INTEGER;
    pet_id INTEGER;
    client_id INTEGER;
BEGIN
    -- Получаем id типа питомца
    SELECT idpettype INTO pet_type_id FROM pettype WHERE nametype = pet_type;

    -- Добавляем запись о клиенте в таблицу client
    INSERT INTO client (first_name, second_name, last_name, phone, passport, sex, refregistrar)
    VALUES (client_first_name, client_second_name, client_last_name, client_phone, client_passport, client_sex, 1)
    RETURNING idclient INTO client_id;
    
    -- Добавляем запись о питомце в таблицу pet
    INSERT INTO pet (fullname, refclient, refpettype)
    VALUES (pet_fullname, client_id, pet_type_id)
    RETURNING idpet INTO pet_id;
    
    -- Получаем id специализации для данного вида питомца
    SELECT idpetspec INTO pet_spec_id FROM specializationpet WHERE refpettype = pet_type_id;
    
    -- Выводим название и стоимость доступных процедур для данного вида питомца
    RETURN QUERY SELECT s.name, s.price FROM service s WHERE refpetspec = pet_spec_id;
  

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'Тип питомца % не найден', pet_type;
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Ошибка при добавлении клиента и питомца: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;