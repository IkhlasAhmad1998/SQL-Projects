-- Creating a view for admissions
CREATE VIEW enc_adm_view AS 
SELECT *
FROM encounters_transformed
WHERE admission_status IN ('initial admission', 'readmission', 'continuous admission')

-- Counting the total number of initial admission
SELECT COUNT(*) AS total_initial_admissions
FROM enc_adm_view
WHERE admission_status = 'initial admission'

-- Counting the total number of readmissions
SELECT COUNT(*) AS total_readmissions
FROM enc_adm_view
WHERE admission_status = 'readmission'

-- Counting the total number of admissions
SELECT COUNT(*) AS total_admissions
FROM enc_adm_view
WHERE admission_status = 'initial admission' OR admission_status = 'readmission'

-- Counting the total number of patients admitted
SELECT 
    COUNT(DISTINCT patient) AS admitted_patients_count
FROM 
    enc_adm_view;

-- Counting the total number of patients who have never been admitted.
SELECT 
    COUNT(DISTINCT patient) AS never_admitted_patients_count
FROM 
    encounters_transformed
WHERE 
    patient NOT IN (SELECT DISTINCT patient FROM enc_adm_view);


-- Counting the total number of patients who have been re-admitted.
WITH re_admitted_patients AS (
    SELECT 
        DISTINCT patient
    FROM 
        enc_adm_view
    WHERE 
        admission_status = 'readmission'
)
SELECT 
    p.gender, COUNT(DISTINCT patient) AS readmitted_patients
FROM 
    re_admitted_patients
JOIN patients p
ON re_admitted_patients.patient = p.id
GROUP BY 1
ORDER BY 2

-- Gender distribution for admissions
SELECT p.gender, COUNT(*),
ROUND(COUNT(*) * 100 / (SELECT COUNT(*)::NUMERIC FROM enc_adm_view WHERE admission_status <> 'continuous admission'), 2) AS Ratio_of_gender
FROM patients p
JOIN enc_adm_view ev
ON p.id = ev.patient AND ev.admission_status <> 'continuous admission'
GROUP BY 1
ORDER BY 2 DESC;

-- Gender distribution for initial admissions
SELECT p.gender, COUNT(*)
FROM patients p
JOIN enc_adm_view ev
ON p.id = ev.patient AND ev.admission_status = 'initial admission'
GROUP BY 1
ORDER BY 2 DESC;

-- Gender distribution for re-admissions
SELECT p.gender, COUNT(*)
FROM patients p
JOIN enc_adm_view ev
ON p.id = ev.patient AND ev.admission_status = 'readmission'
GROUP BY 1
ORDER BY 2 DESC;

-- admission by encounter description
SELECT ev.description, COUNT(*)
FROM patients p
JOIN enc_adm_view ev
ON p.id = ev.patient AND ev.admission_status = 'initial admission'
GROUP BY 1
ORDER BY 2 DESC;

-- admission by encounter reason
SELECT ev.reasondescription, COUNT(*)
FROM patients p
JOIN enc_adm_view ev
ON p.id = ev.patient AND ev.admission_status = 'initial admission'
GROUP BY 1
ORDER BY 2 DESC;

-- readmissions by encounter description
SELECT ev.description, COUNT(*)
FROM patients p
JOIN enc_adm_view ev
ON p.id = ev.patient AND ev.admission_status = 'readmission'
GROUP BY 1
ORDER BY 2 DESC;

-- readmissions by encounter reason
SELECT ev.reasondescription, COUNT(*)
FROM patients p
JOIN enc_adm_view ev
ON p.id = ev.patient AND ev.admission_status = 'readmission'
GROUP BY 1
ORDER BY 2 DESC;

-- Creating a view for patients died within 30 days of their admission
CREATE VIEW deaths_within_month AS

WITH latest_date AS (
SELECT patient, MAX(STOP) last_date 
FROM enc_adm_view
WHERE admitted_days >= 1
GROUP BY patient
)

SELECT ev.*
FROM enc_adm_view ev
JOIN patients p
ON p.id = ev.patient AND p.deathdate > ev.stop AND p.deathdate <= (ev.stop + INTERVAL '30 days')
JOIN latest_date
ON ev.patient = latest_date.patient AND ev.stop = latest_date.last_date

-- total number of patients died with 30 days of their previous admission
SELECT COUNT(patient)
FROM deaths_within_month

-- Whats their encounter reason
SELECT description, COUNT(*)
FROM deaths_within_month
GROUP BY 1
ORDER BY 2 DESC

-- Whats their disease
SELECT reasondescription, COUNT(*)
FROM deaths_within_month
GROUP BY 1
ORDER BY 2 DESC

-- VIEW for patients dies during admission in hospital
CREATE VIEW deaths_during_admission AS

SELECT patient, description, reasondescription
FROM enc_adm_view ev
JOIN patients p
ON ev.patient = p.id AND p.deathdate BETWEEN ev.start AND ev.stop

-- Total number of patient died during admission
SELECT COUNT(*)
FROM deaths_during_admission

-- Whats their encounter reason
SELECT description, COUNT(*)
FROM deaths_during_admission
GROUP BY 1
ORDER BY 2 DESC

-- Whats their disease
SELECT reasondescription, COUNT(*)
FROM deaths_during_admission
GROUP BY 1
ORDER BY 2 DESC

-- total deaths during admssion or within 30 days from last discharge
SELECT 
(SELECT COUNT(*) FROM deaths_within_month dm) + 
(SELECT COUNT(*) FROM deaths_during_admission) AS total_deaths

-- We have inspected individually for boht death cases now inspecting overall
-- view to handle that
CREATE VIEW total_deaths AS
(
SELECT patient, description, reasondescription FROM deaths_within_month
UNION ALL
SELECT patient, description, reasondescription FROM deaths_during_admission
)

-- Gender Distribution of deaths
SELECT p.gender, COUNT(*) deaths
FROM patients p
JOIN total_deaths td
ON p.id = td.patient
GROUP BY 1
ORDER BY 2 DESC

-- desciption for most deaths
SELECT description, COUNT(*)
FROM total_deaths
GROUP BY 1
ORDER BY 2 DESC

-- Reason for most deaths
SELECT reasondescription, COUNT(*)
FROM total_deaths
GROUP BY 1
ORDER BY 2 DESC

-- Number of patients died vs admitted patients for the same disease
WITH adm AS (
SELECT reasondescription, COUNT(*) admitted_patients
FROM enc_adm_view
WHERE admission_status <> 'continuous admission'
GROUP BY 1
),

dead AS (
SELECT reasondescription, COUNT(*) died_patients
FROM total_deaths
GROUP BY 1
)

SELECT a.reasondescription, a.admitted_patients, d.died_patients, (d.died_patients * 100 / a.admitted_patients)::numeric(8,2) ratio_of_death
FROM adm a
JOIN dead d
ON a.reasondescription = d.reasondescription
ORDER BY 3 DESC

-- Average length of stay for admitted patients
WITH stay AS(
SELECT id, (EXTRACT(DAY FROM (stop-start))) los
FROM enc_adm_view
WHERE admission_status <>'continuous admission' OR admitted_days > 1),

grouped_los AS (
SELECT id, CASE
WHEN los = 1 THEN '1 day admission'
WHEN los <= 15 THEN 'Under 20 days'
WHEN los <= 30 THEN 'Under a month'
ELSE 'Over an month'
END length_of_stay
FROM stay
)

SELECT length_of_stay, COUNT(id)
FROM grouped_los
GROUP BY 1
ORDER BY 2 DESC;

-- How much on average per visit costs for admitted patients
SELECT CONCAT('$', (AVG(total_claim_cost))::numeric(10, 2)) Average_Cost_per_Visit
FROM enc_adm_view