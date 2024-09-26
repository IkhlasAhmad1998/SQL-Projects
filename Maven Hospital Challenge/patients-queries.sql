CREATE TEMP TABLE temp_patients AS 
SELECT * FROM patients;

SELECT * FROM temp_patients;

-- Checking the data type
SELECT pg_typeof(birthdate)
FROM temp_patients;

-- Creating age column
ALTER TABLE temp_patients
ADD COLUMN age INT;

-- Updating the age column with the values
UPDATE temp_patients
SET age = EXTRACT(YEAR FROM AGE(birthdate));

-- Checking persons of particular age
SELECT age, COUNT(age)
FROM temp_patients
GROUP BY 1
ORDER BY 1 DESC;

-- Grouping ages
SELECT MAX(age) - MIN(age) AS range
FROM temp_patients;

-- Dividing into age groups
SELECT age,
CASE WHEN age <= 44 THEN 'Young'
WHEN age BETWEEN 45 AND 64 THEN 'Middle-Aged'
WHEN age > 64 THEN 'SENIOR'
ELSE 'Unknown'
END AS age_groups
FROM temp_patients;

-- Updating the table with calculated age-groups
ALTER TABLE temp_patients
ADD COLUMN age_groups VARCHAR(20);

UPDATE temp_patients
SET age_groups = CASE
WHEN age <= 35 THEN 'Young'
WHEN age BETWEEN 36 AND 55 THEN 'Middle-Aged'
WHEN age > 55 THEN 'SENIOR'
ELSE 'Unknown'
END;

-- Cleaning first and last name
SELECT first, REGEXP_REPLACE(first, '[^A-Za-z]+', '', 'g') AS cleaned_name
FROM temp_patients;

SELECT last, REGEXP_REPLACE(last, '[^A-Za-z]+', '', 'g') AS cleaned_name
FROM temp_patients;

-- Combining prefix first last and suffix into a single column name
SELECT TRIM(CONCAT(prefix, ' ', REGEXP_REPLACE(first, '[^A-Za-z]+', '', 'g'), ' ',
REGEXP_REPLACE(last, '[^A-Za-z]+', '', 'g'), ' ', suffix)) AS name,
LENGTH(TRIM(CONCAT(prefix, ' ', REGEXP_REPLACE(first, '[^A-Za-z]+', '', 'g'), ' ',
REGEXP_REPLACE(last, '[^A-Za-z]+', '', 'g'), ' ', suffix)))
FROM temp_patients
ORDER BY 2 DESC;

-- Updating the temp_patient table
ALTER TABLE temp_patients
ADD COLUMN name varchar(30);

UPDATE temp_patients
SET name = TRIM(CONCAT(prefix, ' ', REGEXP_REPLACE(first, '[^A-Za-z]+', '', 'g'), ' ',
REGEXP_REPLACE(last, '[^A-Za-z]+', '', 'g'), ' ', suffix));

-- Dropping prefix first last suffix and maiden
ALTER TABLE temp_patients
DROP prefix,
DROP first,
DROP last,
DROP suffix,
DROP maiden;

-- Inspecting marital stauts
SELECT gender
FROM temp_patients
WHERE gender IS NULL;

-- Checking for overall duplicates
SELECT id, COUNT(*)
FROM temp_patients
GROUP BY id
HAVING COUNT(*) > 1
ORDER BY id DESC;