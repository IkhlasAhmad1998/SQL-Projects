# Maven Hospital Challenge

## Table of Contents
- [Challenge Overview](#challenge-overview)
- [Objectives](#objectives)
- [Dataset Overview](#dataset-overview)
- [Technical Approach](#technical-approach)
- [Key Definitions](#key-definitions)
- [Insights](#insights)
  - [Encounters for Non-Admitted Patients](#encounters-for-non-admitted-patients)
  - [Length of Stay for Non-Admitted Patients](#length-of-stay-for-non-admitted-patients)
  - [Length of Stay for Each Encounter Class](#length-of-stay-for-each-encounter-class)
  - [Encounters for Admitted Patients](#encounters-for-admitted-patients)
  - [Death Analysis](#death-analysis)
  - [Procedure Analysis](#procedure-analysis)
  - [Payer Insights](#payer-insights)
- [Technologies Used](#technologies-used)
- [Files and ERD](#files-and-erd)

## Challenge Overview
The **Maven Hospital Challenge** involves working as an Analytics Consultant for Massachusetts General Hospital (MGH). The objective is to provide a high-level KPI report for the executive team based on a subset of patient records. This report aims to uncover key insights into hospital performance, patient admissions, costs, and procedure coverage.

## Objectives
The primary objectives of the challenge were to address the following questions:
- How many patients have been admitted or readmitted over time?
- What is the average length of hospital stay?
- How much is the average cost per visit?
- How many procedures are covered by insurance?

## Dataset Overview
The dataset contains synthetic data on approximately 1,000 patients from Massachusetts General Hospital between 2011 and 2022. It includes patient demographics, insurance details, medical encounters, and procedures.

[Dataset Link: Maven Hospital Challenge](https://mavenanalytics.io/challenges/maven-hospital-challenge/facee4d2-8369-4c87-a55e-e6c7ed2a42d8)

## Technical Approach
For this project, I extensively utilized **PostgreSQL** for data manipulation, cleaning, modeling, and analysis. The key steps involved:
- **Data Manipulation**: Using `CREATE`, `UPDATE`, and `DELETE` statements.
- **Data Modeling**: Adding primary and foreign keys to ensure data integrity.
- **Complex Queries**: Implementing joins, `UNION`, `UNION ALL`, and subqueries.
- **Control Structures**: Using cursors, loops, and conditional logic (`IF-ELSE`, `CASE`).
- **Temporary Structures**: Creating temporary tables, Common Table Expressions (CTEs), and views.
- **Aggregation and Analysis**: Applying aggregation functions, `GROUP BY`, window functions, and `ORDER BY`.
- **Data Cleaning**: Adding new columns, cleaning text using regular expressions, and handling null values.

After cleaning and transforming the data, I created a new table named `encounters_transformed` to manage patient encounters more efficiently. The relationships between tables were handled using a `relation.sql` file, and the ERD can be viewed [here](https://github.com/IkhlasAhmad1998/SQL-Projects/blob/b5ce2197140329ff1f5418ffacf064793738ffdc/Maven%20Hospital%20Challenge/images/erd.png).

## Key Definitions
To analyze the dataset, I established the following definitions for patient admissions:
- **Initial Admission**: The first admission for a patient or if the previous admission occurred more than 30 days ago.
- **Readmission**: Admission within 1 to 30 days of the previous admission, with a gap of at least 1 day but less than 30 days.
- **Continuous Admission**: Admission with no gap from the previous encounter.

These definitions helped in calculating key metrics such as total admissions, initial admissions, readmissions, and patients admitted at least once.

## Insights

### Encounters for Non-Admitted Patients
| **Metric**                        | **Value**          |
|-----------------------------------|--------------------|
| **Total Patients**                    | 974                |
| **Total Encounters**                  | 27,891             |
| **Admission Encounters**              | 760                |
| **Non-Admission Encounters**         | 26,739             |
| **Males**                            | 46.88%             |
| **Females**                          | 53.12%             |
| **Most Common Encounter Class**       | Ambulatory (46.87%)|
| **Average Cost Per Visit**            | $3,442             |

### Length of Stay for Non-Admitted Patients
| **Metric**                        | **Value**          |
|-----------------------------------|--------------------|
| **Under 15 minutes**     | 19,313               |
| **Under 30 minutes**     | 645                  |
| **Under 45 minutes**     | 476                  |
| **Under 1 hour**         | 3,376                |
| **Over 1 hour**          | 2,929                |

### Length of Stay for Each Encounter Class (in Minutes)
| **Metric**                        | **Value**          |
|-----------------------------------|--------------------|
| **Emergency**        | 61.03                      |
| **Ambulatory**       | 55.43                      |
| **Outpatient**       | 16.57                      |
| **Wellness**         | 15.00                      |
| **Urgent Care**      | 15.00                      |

### Encounters for Admitted Patients
| **Metric**                        | **Value**          |
|-----------------------------------|--------------------|
| **Total Patients**                    | 974        |
| **Total Admissions**                  | 623        |
| **Initial Admissions**                | 347        |
| **Readmissions**                      | 276        |
| **Patients Admitted at Least Once**   | 143        |
| **Patients Never Admitted**           | 831        |
| **Patients Readmitted**               | 20         |
| **Males**                             | 65.33%     |
| **Females**                           | 34.67%     |
| **Average Cost Per Visit**            | $11,630    |

### Death Analysis
| **Metric**                        | **Value**          |
|-----------------------------------|--------------------|
| **Total Deaths**                            | 41         |
| **Patients Died During Admissions**         | 10         |
| **Patients Died Within 30 Days of Admission** | 31       |

#### Deaths by Cause (Top Causes)
| Cause                                                   | Admitted Patients | Number of Deaths | Death Ratio |
|---------------------------------------------------------|-------------------|------------------|-------------|
| Alzheimer's disease (disorder)                          | 19                | 19               | 100.00%     |
| COVID-19                                                | 17                | 8                | 47.00%      |
| Chronic congestive heart failure (disorder)             | 14                | 3                | 21.00%      |
| Familial Alzheimer's disease of early onset (disorder)  | 2                 | 2                | 100.00%     |
| Primary small cell malignant neoplasm of lung (TNM 1)   | 53                | 1                | 1.00%       |

### Length of Stay for Admitted Patients
| **Metric**                        | **Value**          |
|-----------------------------------|--------------------|
| **1-day Admission**           | 585        |
| **Under 20 Days**             | 28         |
| **Over a Month**              | 13         |

### Procedure Analysis
- **Total Procedures**: 47,701
- **Procedures for Admitted Patients**: 2,377
- **Procedures for Non-Admitted Patients**: 44,546
- **Total Procedure Cost**: $105.52 million
- **Average Procedure Cost**: $2,212

| Cost Type            | Total Cost     | Payer Coverage | Payer Coverage (%) |
|----------------------|----------------|----------------|--------------------|
| Admission Procedures | $8.84 million  | $3.42 million  | 38.69%             |
| Non-Admission Procedures | $92.04 million | $27.40 million | 29.77%             |
  
- **Procedures Covered by Insurance**: 24,791 (51%)

### Payer Insights
- **Medicare** covered the highest amount in total claims, while **Anthem** paid none.

## Technologies Used
This analysis was entirely performed using **PostgreSQL**, which helped me showcase my SQL skills in:
- Data manipulation and modeling.
- Complex query handling and aggregation.
- Performance Analysis on large datasets.

## Files and ERD
- **Table Creation SQL**: [View here](https://github.com/IkhlasAhmad1998/SQL-Projects/blob/b5ce2197140329ff1f5418ffacf064793738ffdc/Maven%20Hospital%20Challenge/tabel-creation-sql.sql)
- **Transforming Patients**: [View here](https://github.com/IkhlasAhmad1998/SQL-Projects/blob/b5ce2197140329ff1f5418ffacf064793738ffdc/Maven%20Hospital%20Challenge/patients-queries.sql)
- **Transforming Encounters**: [View here](https://github.com/IkhlasAhmad1998/SQL-Projects/blob/b5ce2197140329ff1f5418ffacf064793738ffdc/Maven%20Hospital%20Challenge/encounters-queries.sql)
- **Relationship Management SQL**: [View here](https://github.com/IkhlasAhmad1998/SQL-Projects/blob/b5ce2197140329ff1f5418ffacf064793738ffdc/Maven%20Hospital%20Challenge/managing-relations.sql)
- **ERD Image**: [View ERD](https://github.com/IkhlasAhmad1998/SQL-Projects/blob/b5ce2197140329ff1f5418ffacf064793738ffdc/Maven%20Hospital%20Challenge/images/erd.png)
- **Analysis of Non-Admission Encounters**: [View here](https://github.com/IkhlasAhmad1998/SQL-Projects/blob/b5ce2197140329ff1f5418ffacf064793738ffdc/Maven%20Hospital%20Challenge/encounters-non-admission-analysis.sql)
-- **Analysis of Admission Encounters**: [View here](https://github.com/IkhlasAhmad1998/SQL-Projects/blob/b5ce2197140329ff1f5418ffacf064793738ffdc/Maven%20Hospital%20Challenge/encounters-admission-analysis.sql)
-- **Analysis of Procedures**: [View here](https://github.com/IkhlasAhmad1998/SQL-Projects/blob/b5ce2197140329ff1f5418ffacf064793738ffdc/Maven%20Hospital%20Challenge/procedures-analysis.sql)
