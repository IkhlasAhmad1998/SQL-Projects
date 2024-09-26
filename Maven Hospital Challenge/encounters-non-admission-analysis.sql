-- Total Number of Patients
SELECT COUNT(DISTINCT id) Total_Number_of_Patients
FROM patients

-- Creating a view for non-admissions
CREATE VIEW enc_non_adm_view AS 
SELECT *
FROM encounters_transformed
WHERE (admission_status IS NULL OR admission_status = 'visited') AND encounterclass <> 'inpatient'

-- Creating a view for non-admission total encounters to use it multiple times
CREATE VIEW total_enc_view AS
SELECT COUNT(id) AS total_encounters
FROM enc_non_adm_view;

-- Total number of encounters vs admission and non-admission encounters
SELECT
(SELECT COUNT(id) TotalEncounters FROM encounters_transformed), 
(SELECT COUNT(id) FROM enc_adm_view) admission_encounters, 
(SELECT total_encounters FROM total_enc_view) non_adm_encounters

-- Non-admissions by gender
SELECT p.gender, COUNT(*) total_encounters, ROUND(COUNT(*) * 100 / (SELECT total_encounters::NUMERIC FROM total_enc_view), 2) AS Ratio_of_gender
FROM patients p
JOIN enc_non_adm_view et
ON p.id = et.patient
GROUP BY 1;

-- Number of encounters by encounter class splitted by gender
SELECT ev.encounterclass, p.gender, COUNT(*) numberofencounters, ROUND(COUNT(*) *100 / (SELECT total_encounters::NUMERIC FROM total_enc_view), 2) AS Ratio_of_total
FROM enc_non_adm_view ev
JOIN patients p
ON ev.patient = p.id
GROUP BY 1, 2
ORDER BY 3 DESC;

-- Number of encounters by encounter class
SELECT ev.encounterclass, COUNT(*) numberofencounters, ROUND(COUNT(*) *100 / (SELECT total_encounters::NUMERIC FROM total_enc_view), 2) AS Ratio_of_total
FROM enc_non_adm_view ev
GROUP BY 1
ORDER BY 3 DESC;

-- Number of encounters by encounter description
SELECT description, COUNT(*)
FROM enc_non_adm_view
GROUP BY 1
ORDER BY 2 DESC

-- Number of encounters by encounter reason
SELECT reasondescription, COUNT(*)
FROM enc_non_adm_view
GROUP BY 1
ORDER BY 2 DESC

-- Procedures by encounter class
SELECT encounterclass, COUNT(*) total_procedures, CONCAT('$', ROUND(AVG(proc.base_cost), 2)) average_procedure_cost
FROM enc_non_adm_view ev
JOIN procedures proc
ON ev.id = proc.encounter
GROUP BY 1
ORDER BY 2 DESC
-- highest number of patients are of ambulatory class whereas the higest avg procedure cost is of urgentcare

-- Inspecting different costs
SELECT ev.encounterclass, CONCAT('$', ROUND(AVG(ev.base_encounter_cost), 1)) avg_base_cost, 
CONCAT('$', ROUND(AVG(proc.base_cost), 1)) avg_proc_cost, CONCAT('$', ROUND(AVG(ev.total_claim_cost), 1)) avg_total_cost
FROM enc_non_adm_view ev
JOIN procedures proc
ON ev.id = proc.encounter
GROUP BY 1

-- Inspecting payer cost
SELECT encounterclass, CONCAT('$', SUM(total_claim_cost)) TotalCost, CONCAT('$', SUM(payer_coverage)) PayerCoverage,
CONCAT(ROUND(SUM(payer_coverage) * 100 / SUM(total_claim_cost), 2), ' %') Ratio_of_coverage
FROM enc_non_adm_view
GROUP BY 1
ORDER BY 4 DESC

-- Inspecting average length of stay in mins for non-admission by encounter class
SELECT encounterclass, CONCAT(AVG(EXTRACT(EPOCH FROM (stop - start)) / 60)::numeric(10, 2), ' min') AS lengthofst
FROM enc_non_adm_view
GROUP BY 1
ORDER BY 2 DESC;

-- Inspecting most non-admitted patients length of stay
WITH stay AS(
SELECT id, (EXTRACT(EPOCH FROM (stop-start)) / 60)::numeric(10, 2) los
FROM enc_non_adm_view),

grouped_los AS (
SELECT id, CASE
WHEN los <= 15.00 THEN 'Under 15 mins'
WHEN los <= 30.00 THEN 'Under 30 mins'
WHEN los <= 45.00 THEN 'Under 45 mins'
WHEN los <= 60.00 THEN 'Under an Hour'
ELSE 'Over an Hour'
END length_of_stay
FROM stay
)

SELECT length_of_stay, COUNT(id)
FROM grouped_los
GROUP BY 1
ORDER BY 2 DESC;

-- How much on average per visit costs
SELECT CONCAT('$', (AVG(total_claim_cost))::numeric(10, 2)) Average_Cost_per_Visit
FROM encounters_transformed

-- How much on average per visit costs for non-admitted patients
SELECT CONCAT('$', (AVG(total_claim_cost))::numeric(10, 2)) Average_Cost_per_Visit
FROM enc_non_adm_view