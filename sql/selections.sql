-- 1 - Получить отчет о приемах каждого врача на прошлой неделе

SELECT a.idappointment, d.first_name || ' ' || d.last_name AS doctor_name, c.first_name || ' ' || c.last_name AS client_name, 
p.fullname AS pet_name, p.refpettype as pet_id,
a.time, COALESCE(b.price, 0) as price, COALESCE(array_to_string(array_agg(s.name), ', '), '0') as services
FROM appointment a
JOIN doctor d ON a.refdoctor = d.iddoctor
JOIN pet p ON a.refpet = p.idpet
JOIN client c ON p.refclient = c.idclient
LEFT JOIN bill b ON a.refbill = b.idbill
LEFT JOIN appointmentlist al ON a.idappointment = al.refappointment
LEFT JOIN service s ON al.refservice = s.idservice
LEFT JOIN specializationpet sp ON s.refpetspec = sp.idpetspec
--JOIN pettype pt ON sp.refpettype = pt.idpettype
WHERE a.time BETWEEN NOW() - INTERVAL '1 WEEK' AND NOW()
GROUP BY a.idappointment, d.first_name, d.last_name, c.first_name, c.last_name, p.fullname, p.refpettype, a.time, b.price
ORDER BY doctor_name, a.time;

select * from specializationpet;

-- 2 - Получить статистику о приемах разных видов животных в разрезе по месяцам за прошлый год

WITH appointments_per_month AS (
    SELECT pettype.nametype AS animal_type,
           date_part('month', appointment.time) AS month,
           COUNT(*) AS m_count
    FROM appointment
    JOIN pet ON appointment.refpet = pet.idpet
    JOIN pettype ON pet.refpettype = pettype.idpettype
    WHERE date_part('year', appointment.time) = date_part('year', CURRENT_DATE) - 1
    GROUP BY pettype.nametype, date_part('month', appointment.time)
), 
appointment_stats AS (
    SELECT 
        date_part('month', a.time) AS month,
        COUNT(*) AS total_appointments,
        COALESCE(sum(b.price), 0) AS total_payments,
        count(DISTINCT p.refclient) AS num_pets,
        count(DISTINCT d.idclient) AS num_clients,
        mode() WITHIN GROUP (ORDER BY p.fullname) AS most_common_pet_type
    FROM 
        appointment a
        LEFT JOIN bill b ON a.refbill = b.idbill
        JOIN pet p ON a.refpet = p.idpet
        LEFT JOIN client d ON p.refclient = d.idclient
        WHERE 
        date_trunc('year', a.time) = date_trunc('year', CURRENT_DATE - INTERVAL '1 year')
    GROUP BY 
        date_part('month', a.time)
    ORDER BY 
        month
)
SELECT 
    appointments_per_month.animal_type,
    appointments_per_month.month,
    appointments_per_month.m_count,
    appointment_stats.total_appointments,
    appointment_stats.total_payments,
    appointment_stats.num_pets,
    appointment_stats.num_clients,
    appointment_stats.most_common_pet_type
FROM 
    appointments_per_month
    JOIN appointment_stats ON appointments_per_month.month = appointment_stats.month
ORDER BY 
    appointments_per_month.animal_type,
    appointments_per_month.month;

-- 3 Получить отчет по популярности животных тех или иных видов за последние три года
WITH pet_counts AS (
    SELECT
    pettype.nametype AS pet_type,
    date_trunc('year', appointment.time) AS appointment_year,
    COUNT(DISTINCT appointment.refpet) AS unique_pets
    FROM appointment
    JOIN pet ON appointment.refpet = pet.idpet
    JOIN pettype ON pet.refpettype = pettype.idpettype
    WHERE date_part('year', appointment.time) >= date_part('year', CURRENT_DATE) - 3
    GROUP BY pettype.nametype, appointment_year
),
year_counts AS (
    SELECT
    date_trunc('year', appointment.time) AS appointment_year,
    COUNT(appointment.refpet) AS total_pets
    FROM appointment
    WHERE date_part('year', appointment.time) >= date_part('year', CURRENT_DATE) - 3
    GROUP BY appointment_year
)
SELECT
    pet_counts.pet_type,
    date_part('year', year_counts.appointment_year) AS year,
    COALESCE(sum(pet_counts.unique_pets), 0) AS unique_pets,

    COALESCE(ROUND(100.0 * (unique_pets - lag(unique_pets, 1) OVER (
        PARTITION BY pet_counts.pet_type
        ORDER BY pet_counts.appointment_year
    )) / NULLIF(lag(unique_pets, 1) OVER (
        PARTITION BY pet_counts.pet_type
        ORDER BY pet_counts.appointment_year
    ), 0), 3),0) AS pets_change_prev_year,

    COALESCE(ROUND(100.0 * unique_pets / year_counts.total_pets, 3), 0) AS general_pets_per_year,
    year_counts.total_pets,

    COALESCE(ROUND((COALESCE(ROUND(100.0 * unique_pets / year_counts.total_pets, 3), 0) - lag(COALESCE(ROUND(100.0 * unique_pets / year_counts.total_pets, 3), 0), 1)
    over (partition by pet_counts.pet_type order by pet_counts.appointment_year)), 2), 0) as total_pets_change_prev_year
    -- по последнему столбцу хз
FROM pet_counts
JOIN year_counts ON pet_counts.appointment_year = year_counts.appointment_year
GROUP BY pet_counts.pet_type, year_counts.appointment_year, pet_counts.unique_pets, year_counts.total_pets, pet_counts.appointment_year
ORDER BY pet_counts.pet_type, year;

-- проверить количество уникальных животных за 3 года
SELECT a.refpet, a.time, p.fullname
FROM appointment AS a
JOIN pet AS p ON p.idpet = a.refpet
JOIN pettype AS pt ON pt.idpettype= p.refpettype
WHERE pt.nametype = 'Попугай' AND a.time >= '2022-01-01' 
ORDER BY a.time;

-- 4 - Вывести информацию по врачам, которые провели больше всех приемов за прошлый месяц
-- посмотреть оказанные услуги докторами
-- Сам запрос

--EXPLAIN ANALYZE
WITH appointments_by_doctor AS (
    SELECT refdoctor, COUNT(*) AS appointment_count, 
            SUM((SELECT COUNT(*) FROM servicepet WHERE refpettype = pet.refpettype AND refservice = service.idservice)) AS services_count, 
            ROUND(AVG((SELECT COUNT(*) FROM servicepet WHERE refpettype = pet.refpettype AND refservice = service.idservice)), 3) AS avg_services_count,
            MAX(appointment.time) AS last_appointment_date, 
            COALESCE(SUM(bill.price), 0) AS total_price,
            COALESCE(ROUND(AVG(bill.price), 3), 0) AS avg_price
    FROM appointment
    JOIN pet ON pet.idpet = appointment.refpet
    LEFT JOIN bill ON bill.idbill = appointment.refbill
    JOIN doctor ON doctor.iddoctor = appointment.refdoctor
    LEFT JOIN servicepet ON servicepet.refpettype = pet.refpettype
    LEFT JOIN service ON service.idservice = servicepet.refservice
    WHERE appointment.time >= CURRENT_DATE - INTERVAL '1 month'  AND appointment.time <= CURRENT_DATE
    GROUP BY refdoctor
), 
doctor_count AS (
    SELECT d.first_name, d.last_name, d.iddoctor,
            COALESCE(COUNT(a.refdoctor), 0) AS appoint_count
    FROM doctor AS d
    JOIN appointment AS a ON a.refdoctor = d.iddoctor
    WHERE a.time >= CURRENT_DATE - INTERVAL '1 month'  AND a.time <= CURRENT_DATE
    GROUP BY d.first_name, d.last_name, d.iddoctor
),
service_count AS (
    SELECT  d.iddoctor,
            COALESCE(COUNT(DISTINCT s.name), 0) AS service_count
    FROM doctor AS d
    JOIN appointment AS a ON a.refdoctor = d.iddoctor
    INNER JOIN appointmentlist AS al ON al.refappointment = a.idappointment
    INNER JOIN service AS s ON s.idservice = al.refservice
    WHERE a.time >= CURRENT_DATE - INTERVAL '1 month'  AND a.time <= CURRENT_DATE
    GROUP BY d.iddoctor
)
SELECT doctor.first_name || ' ' || doctor.last_name AS doctor_name, 
    dc.appoint_count,
    sc.service_count,
    COALESCE(ROUND((100.0 * sc.service_count / dc.appoint_count / 100.0), 3), 0) as avg_services_count,
    ARRAY(SELECT DISTINCT specialization.name FROM specializationlist JOIN specializationpet 
    ON specializationpet.idpetspec = specializationlist.refpetspec 
    JOIN specialization ON specialization.idspecialization = specializationpet.refspecialization 
    WHERE specializationlist.refdoctor = doctor.iddoctor) AS specializations, 
    appointments_by_doctor.last_appointment_date, 
    (SELECT pet.fullname FROM pet WHERE pet.idpet = (SELECT appointment.refpet 
    FROM appointment WHERE appointment.refdoctor = doctor.iddoctor 
    AND appointment.time = appointments_by_doctor.last_appointment_date)) AS last_pet_name, 
    (SELECT bill.price FROM appointment LEFT JOIN bill ON bill.idbill = appointment.refbill 
    WHERE appointment.refdoctor = doctor.iddoctor AND appointment.time = appointments_by_doctor.last_appointment_date) AS last_appointment_price, 
    SUM(appointments_by_doctor.total_price) AS total_price,
    appointments_by_doctor.avg_price
    FROM doctor
    JOIN doctor_count AS dc ON dc.iddoctor = doctor.iddoctor
    JOIN service_count AS sc ON sc.iddoctor = doctor.iddoctor
    JOIN appointments_by_doctor ON appointments_by_doctor.refdoctor = doctor.iddoctor
    GROUP BY doctor.iddoctor, dc.appoint_count, sc.service_count, 
        avg_services_count, appointments_by_doctor.last_appointment_date, appointments_by_doctor.avg_price;
  
-- проверить количество врачей и их приемы за прошлый месяц
SELECT a.time, a.idappointment, d.first_name, d.last_name, array_agg(s.name), p.fullname, b.idbill, b.price
FROM appointment AS a
JOIN doctor AS d ON d.iddoctor = a.refdoctor
JOIN pet AS p ON p.idpet = a.refpet
JOIN specializationpet AS sp ON sp.refpettype = p.refpettype
LEFT JOIN bill AS b ON b.idbill = a.refbill
LEFT JOIN appointmentlist AS al ON al.refappointment = a.idappointment
LEFT JOIN service AS s ON s.refpetspec = sp.idpetspec AND s.idservice = al.refservice
WHERE a.time >= CURRENT_DATE - INTERVAL '1 month'  AND a.time <= CURRENT_DATE
GROUP BY a.time, d.first_name, d.last_name, p.fullname, b.idbill, b.price, a.idappointment
ORDER BY a.time;
--
-- 5 - Вывести серию показателей для конкретного питомца, упорядоченную по дате
WITH pet_monitoring AS (
    SELECT idmonitoring, value, date, name, unit,
        COALESCE(LAG(value, 1) over (PARTITION BY idindicator ORDER BY date), 0) AS prev_value,
        COALESCE(AVG(value::numeric) OVER (PARTITION BY idindicator), 0) AS avg_value
    FROM monitoring
    JOIN pet ON pet.idpet = monitoring.refpet
    JOIN indicator ON monitoring.refindicator = indicator.idindicator
    ORDER BY date
)
SELECT date AS time, unit, value,
    CASE WHEN prev_value IS NOT NULL THEN value::numeric - prev_value::numeric END AS diff_value,
    CASE WHEN prev_value IS NOT NULL AND prev_value::numeric <> 0 THEN ROUND((value::numeric - prev_value::numeric) / prev_value::numeric * 100, 3) END AS percent_change,
    CASE WHEN value::numeric > avg_value THEN 'increases' WHEN value::numeric < avg_value THEN 'decreases' ELSE 'unchanged' END AS trend
FROM pet_monitoring;

-- Оптимизация 4-ого
--EXPLAIN ANALYZE
WITH appointments_by_doctor AS (
    SELECT appointment.refdoctor, COUNT(*) AS appointment_count, 
         SUM(CASE WHEN servicepet.refpettype = pet.refpettype AND servicepet.refservice = service.idservice THEN 1 ELSE 0 END) AS services_count, 
         ROUND(AVG(CASE WHEN servicepet.refpettype = pet.refpettype AND servicepet.refservice = service.idservice THEN 1 ELSE 0 END), 3) AS avg_services_count,
         MAX(appointment.time) AS last_appointment_date, 
         COALESCE(SUM(bill.price), 0) AS total_price,
         COALESCE(ROUND(AVG(bill.price), 3), 0) AS avg_price
    FROM appointment
    JOIN pet ON pet.idpet = appointment.refpet
    JOIN bill ON bill.idbill = appointment.refbill
    JOIN doctor ON doctor.iddoctor = appointment.refdoctor
    LEFT JOIN servicepet ON servicepet.refpettype = pet.refpettype
    LEFT JOIN service ON service.idservice = servicepet.refservice
    WHERE appointment.time >= CURRENT_DATE - INTERVAL '1 month'  AND appointment.time <= CURRENT_DATE
    GROUP BY appointment.refdoctor
), 
doctor_count AS (
    SELECT d.first_name, d.last_name, d.iddoctor,
            COALESCE(COUNT(a.refdoctor), 0) AS appoint_count
    FROM doctor AS d
    JOIN appointment AS a ON a.refdoctor = d.iddoctor
    WHERE a.time >= CURRENT_DATE - INTERVAL '1 month'  AND a.time <= CURRENT_DATE
    GROUP BY d.first_name, d.last_name, d.iddoctor
),
service_count AS (
    SELECT  d.iddoctor,
            COALESCE(COUNT(DISTINCT s.name), 0) AS service_count
    FROM doctor AS d
    JOIN appointment AS a ON a.refdoctor = d.iddoctor
    INNER JOIN appointmentlist AS al ON al.refappointment = a.idappointment
    INNER JOIN service AS s ON s.idservice = al.refservice
    WHERE a.time >= CURRENT_DATE - INTERVAL '1 month'  AND a.time <= CURRENT_DATE
    GROUP BY d.iddoctor
)
SELECT doctor.first_name || ' ' || doctor.last_name AS doctor_name, 
       dc.appoint_count,
       sc.service_count,
       COALESCE(ROUND((100.0 * sc.service_count / dc.appoint_count / 100.0), 3), 0) as avg_services_count,
       ARRAY(SELECT DISTINCT specialization.name FROM specializationlist JOIN specializationpet 
       ON specializationpet.idpetspec = specializationlist.refpetspec 
       JOIN specialization ON specialization.idspecialization = specializationpet.refspecialization 
       WHERE specializationlist.refdoctor = doctor.iddoctor) AS specializations, 
       appointments_by_doctor.last_appointment_date, 
       pet.fullname AS last_pet_name, 
       bill.price AS last_appointment_price, 
       SUM(appointments_by_doctor.total_price) AS total_price,
       appointments_by_doctor.avg_price
  FROM doctor
  JOIN doctor_count AS dc ON dc.iddoctor = doctor.iddoctor
  JOIN service_count AS sc ON sc.iddoctor = doctor.iddoctor
  JOIN appointments_by_doctor ON appointments_by_doctor.refdoctor = doctor.iddoctor
  LEFT JOIN appointment ON appointment.refdoctor = doctor.iddoctor AND appointment.time = appointments_by_doctor.last_appointment_date
  LEFT JOIN pet ON pet.idpet = appointment.refpet
  LEFT JOIN bill ON bill.idbill = appointment.refbill 
 GROUP BY doctor.iddoctor, dc.appoint_count, sc.service_count, pet.fullname, bill.price,
        avg_services_count, appointments_by_doctor.last_appointment_date, appointments_by_doctor.avg_price;