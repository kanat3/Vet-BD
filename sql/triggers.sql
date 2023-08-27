-- Триггер 1: Проверка наличия доктора с соответсвующей специализацией для питомца, добавляемого/обновляемого на прием
CREATE OR REPLACE FUNCTION check_specialization() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM doctor d
        JOIN specializationlist sl ON d.iddoctor = sl.refdoctor
        JOIN specializationpet sp ON sl.refpetspec = sp.idpetspec
        JOIN pettype pt ON pt.idpettype = sp.refpettype
        JOIN pet p ON p.refpettype = pt.refpettype
        WHERE d.iddoctor = NEW.refdoctor AND p.idpettype = NEW.refpet
    ) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Доктор не имеет специализации для животного того же типа!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER doctor_specialization_trigger
    BEFORE UPDATE OR INSERT ON appointment
    FOR EACH ROW
    EXECUTE FUNCTION check_specialization();

-- Триггер 2: Проверка услуги при добавлении на соответсвие типу животного на приеме
CREATE OR REPLACE FUNCTION check_service() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM servicepet sp
        JOIN service s ON s.idservice = sp.refservice
        JOIN pet p ON p.refpettype = sp.refpettype
        JOIN appointment a ON a.refpet = p.idpet
        WHERE a.idappointment = NEW.refappointment AND s.idservice = NEW.refservice AND a.refpet = p.idpet AND sp.refpettype = p.refpettype
    ) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Услуга не для вашего питомца!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER service_pettype_trigger
    BEFORE INSERT ON appointmentlist
    FOR EACH ROW
    EXECUTE FUNCTION check_service();