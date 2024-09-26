-- Inspecting the procedure table
SELECT *
FROM procedures;

-- Counting the total number of procedures for admssions and non-admissions
WITH non_adm_proc AS(
SELECT COUNT(*) Non_Adm
FROM procedures proc
JOIN enc_non_adm_view ev
ON proc.encounter = ev.id),

adm_proc AS (
SELECT COUNT(*) Adm
FROM procedures proc
JOIN enc_adm_view ev -- view for admissions
ON proc.encounter = ev.id
)

SELECT 
(SELECT COUNT(*) Total_Procedures FROM procedures),
(SELECT Non_Adm FROM non_adm_proc),
(SELECT Adm FROM adm_proc)

-- Total Procedure cost
SELECT CONCAT('$', (SUM(base_cost)/1000000)::numeric(10,2), ' M') total_procedure_cost, AVG(base_cost)::numeric(10, 2) average_procedure_cost
FROM procedures

-- Procedure cost vs procedure description
SELECT description, COUNT(*) number_of_procedures_performed, (SUM(base_cost)/1000000)::numeric(10,2) total_procedure_cost_in_million,
(SUM(base_cost)/COUNT(*))::numeric(10,2) avg_procedure_cost_in_million
FROM procedures
GROUP BY 1
ORDER BY 3 DESC

-- Total procedure cost for encounter class
SELECT et.encounterclass, (SUM(proc.base_cost)/1000000)::numeric(10,2) total_procedure_cost_in_million
FROM encounters_transformed et
JOIN procedures proc
ON et.id = proc.encounter
GROUP BY 1
ORDER BY 2 DESC

-- Analysing procedure cost between admissions and non-admissions
WITH adm_proc AS (
SELECT CONCAT('$', (SUM(proc.base_cost) / 1000000)::numeric(8,2), ' M') admission_procedures_cost
FROM procedures proc
JOIN enc_adm_view ev
ON proc.encounter = ev.id
),

non_adm_proc AS (
SELECT CONCAT('$', (SUM(proc.base_cost) / 1000000)::numeric(8,2), ' M') non_admissions_procedures_cost
FROM procedures proc
JOIN enc_non_adm_view ev
ON proc.encounter = ev.id
)

SELECT (SELECT CONCAT('$', (SUM(base_cost) / 1000000)::numeric(8,2), ' M') FROM procedures) totalprocedurescost,
ad.admission_procedures_cost, nd.non_admissions_procedures_cost
FROM adm_proc ad, non_adm_proc nd

-- Analyzing payer coverage between admissions and not admissions
WITH adm_cost AS (
SELECT 'Admitted' AS admission_status,
CONCAT('$', (SUM(total_claim_cost) / 1000000)::numeric(8,2), ' M') procedures_cost,
(SUM(total_claim_cost) / 1000000)::numeric(8,2) procedures_cost_value,
CONCAT('$', (SUM(payer_coverage) / 1000000)::numeric(8,2), ' M') payer_coverage,
(SUM(payer_coverage) / 1000000)::numeric(8,2) payer_coverage_value
FROM enc_adm_view ev
),

non_adm_cost AS (
SELECT 'Non-Admitted' AS admission_status,
CONCAT('$', (SUM(total_claim_cost) / 1000000)::numeric(8,2), ' M') procedures_cost,
(SUM(total_claim_cost) / 1000000)::numeric(8,2) procedures_cost_value,
CONCAT('$', (SUM(payer_coverage) / 1000000)::numeric(8,2), ' M') payer_coverage,
(SUM(payer_coverage) / 1000000)::numeric(8,2) payer_coverage_value
FROM enc_non_adm_view ev
)

SELECT admission_status, procedures_cost, payer_coverage,
(payer_coverage_value * 100 / procedures_cost_value)::numeric(8,2) coverage_ratio FROM adm_cost
UNION
SELECT admission_status, procedures_cost, payer_coverage,
(payer_coverage_value * 100 / procedures_cost_value)::numeric(8,2) coverage_ratio FROM non_adm_cost

-- How many procedures are covered by insurance
WITH proc_count as (
SELECT COUNT(*) total_procedures
FROM procedures)

SELECT (SELECT total_procedures FROM proc_count) Total_Procedures, COUNT(*) Procedures_Covered_by_Insurance,
(COUNT(*) * 100 / (SELECT total_procedures FROM proc_count))::numeric(10, 2) Percent_of_Total
FROM encounters_transformed et
JOIN procedures proc
ON et.id = proc.encounter AND et.patient = proc.patient
WHERE payer_coverage > 0

-- Number of procedures for each gender
SELECT p.gender, COUNT(proc.*) total_procedures, (COUNT(proc.*) * 100 /(SELECT COUNT(*) FROM procedures))::numeric(10,2) percent_of_total,
SUM(proc.base_cost) total_cost, (SUM(proc.base_cost) * 100/(SELECT SUM(base_cost) FROM procedures))::numeric(10,2) percent_of_total_cost
FROM patients p
JOIN procedures proc
ON p.id = proc.patient
GROUP BY 1
ORDER BY 2 DESC

-- which payer pays the most
SELECT p.name, SUM(et.payer_coverage)
FROM payers p
JOIN encounters_transformed et
ON p.id = et.payer
GROUP BY 1
ORDER BY 2 DESC
