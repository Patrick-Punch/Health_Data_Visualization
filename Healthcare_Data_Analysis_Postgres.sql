-- How many encounters did we have before the year 2020?

SELECT COUNT(*)
FROM flu_demo_data
WHERE earliest_flu_shot_2022 < '2020-01-01';

SELECT COUNT(*)
FROM healthcare_demo_data 
WHERE start_day < '2020-01-01';

SELECT COUNT(*)
FROM hospital_er
WHERE date < '2020-01-01';

SELECT COUNT(*) 
FROM (
    SELECT 1 FROM healthcare_demo_data WHERE start_day < '2020-01-01'
    UNION ALL
    SELECT 1 FROM flu_demo_data WHERE earliest_flu_shot_2022 < '2020-01-01'
    UNION ALL
    SELECT 1 FROM hospital_er WHERE date < '2020-01-01'
) AS combined_counts;

-- How many distinct patients did we treat before the year 2020?

SELECT COUNT(DISTINCT patient_id)
FROM hospital_er
WHERE date < '2020-01-01';

-- How many distinct encounter classes are documented in the healthcare_demo_data table?
SELECT COUNT(DISTINCT encounter_class)
FROM healthcare_demo_data;

-- How many inpatient and ambulatory encounters did we have before 2022?
SELECT COUNT(*)
FROM healthcare_demo_data
WHERE start_day < '2022-01-01' AND encounter_class IN ('inpatient', 'ambulatory');

-- What is our patient mix by gender, race and ethnicity?
SELECT gender, race, ethnicity, COUNT(*) AS num
FROM flu_demo_data
GROUP BY gender, race, ethnicity;

-- What about age?
SELECT 
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) < 18 THEN '0-17'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 18 AND 34 THEN '18-34'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 35 AND 49 THEN '35-49'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 50 AND 64 THEN '50-64'
        ELSE '65+' 
    END AS age_group,
    COUNT(*) AS healthcare_patient_count
FROM healthcare_demo_data
GROUP BY age_group
ORDER BY age_group;

SELECT 
    CASE 
        WHEN age < 18 THEN '0-17'
        WHEN age BETWEEN 18 AND 34 THEN '18-34'
        WHEN age BETWEEN 35 AND 49 THEN '35-49'
        WHEN age BETWEEN 50 AND 64 THEN '50-64'
        ELSE '65+' 
    END AS age_group,
    COUNT(*) AS flu_patient_count
FROM flu_demo_data
GROUP BY age_group
ORDER BY age_group;

SELECT 
    CASE 
        WHEN patient_age < 18 THEN '0-17'
        WHEN patient_age BETWEEN 18 AND 34 THEN '18-34'
        WHEN patient_age BETWEEN 35 AND 49 THEN '35-49'
        WHEN patient_age BETWEEN 50 AND 64 THEN '50-64'
        ELSE '65+' 
    END AS age_group,
    COUNT(*) AS er_patient_count
FROM hospital_er
GROUP BY age_group
ORDER BY age_group;



SELECT 
    age_brackets.age_group,
    COALESCE(healthcare_data.healthcare_patient_count, 0) AS healthcare_patient_count,
    COALESCE(flu_data.flu_patient_count, 0) AS flu_patient_count,
    COALESCE(er_data.er_patient_count, 0) AS er_patient_count
FROM (
    SELECT '0-17' AS age_group UNION ALL
    SELECT '18-34' UNION ALL
    SELECT '35-49' UNION ALL
    SELECT '50-64' UNION ALL
    SELECT '65+' 
) AS age_brackets
LEFT JOIN (
    SELECT 
        CASE 
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) < 18 THEN '0-17'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 18 AND 34 THEN '18-34'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 35 AND 49 THEN '35-49'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 50 AND 64 THEN '50-64'
            ELSE '65+' 
        END AS age_group,
        COUNT(*) AS healthcare_patient_count
    FROM healthcare_demo_data
    GROUP BY age_group
) AS healthcare_data ON healthcare_data.age_group = age_brackets.age_group
LEFT JOIN (
    SELECT 
        CASE 
            WHEN age < 18 THEN '0-17'
            WHEN age BETWEEN 18 AND 34 THEN '18-34'
            WHEN age BETWEEN 35 AND 49 THEN '35-49'
            WHEN age BETWEEN 50 AND 64 THEN '50-64'
            ELSE '65+' 
        END AS age_group,
        COUNT(*) AS flu_patient_count
    FROM flu_demo_data
    GROUP BY age_group
) AS flu_data ON flu_data.age_group = age_brackets.age_group
LEFT JOIN (
    SELECT 
        CASE 
            WHEN patient_age < 18 THEN '0-17'
            WHEN patient_age BETWEEN 18 AND 34 THEN '18-34'
            WHEN patient_age BETWEEN 35 AND 49 THEN '35-49'
            WHEN patient_age BETWEEN 50 AND 64 THEN '50-64'
            ELSE '65+' 
        END AS age_group,
        COUNT(*) AS er_patient_count
    FROM hospital_er
    GROUP BY age_group
) AS er_data ON er_data.age_group = age_brackets.age_group
ORDER BY age_brackets.age_group;
-- How many states and zip codes do we treat patients from?

SELECT COUNT(DISTINCT state)
FROM flu_demo_data;

SELECT COUNT(DISTINCT zip)
FROM flu_demo_data;

SELECT DISTINCT zip, COUNT(*)
FROM flu_demo_data
GROUP BY zip;

-- Which county had the highest number of patients?

SELECT county, COUNT(*) AS num
FROM flu_demo_data
GROUP BY county
ORDER BY COUNT(*) DESC;

-- What is our patient mix for patients who had an inpatient encounter in 2019?

SELECT gender, race, ethnicity, COUNT(*) AS num
FROM healthcare_demo_data E
JOIN flu_demo_data P ON E.encounter_id = P.id
WHERE E.start_day >= '2019-01-01' AND E.start_day < '2020-01-01' AND E.encounter_class = 'inpatient'
GROUP BY gender, race, ethnicity;

-- How many inpatient encounters did we have in the entire dataset where the patient was at least 21 years old at the time of the encounter start?

SELECT COUNT(*) AS num
FROM healthcare_demo_data E
JOIN er_data P ON E.encounter_id = P.id
WHERE encounterclass = 'inpatient' AND FLOOR(EXTRACT(DAY FROM start - birthdate) / 365) >= 21;

-- How many emergency encounters did we have in 2019?

SELECT COUNT(*) AS er_num
FROM hospital_er
WHERE date >= '2019-01-01' AND date < '2020-01-01';

SELECT COUNT(*) AS er_num
FROM healthcare_demo_data
WHERE start_day >= '2019-01-01' AND start_day < '2020-01-01' AND encounter_class = 'emergency';

-- What conditions were treated in those encounters?

SELECT C.description, COUNT(*) AS num
FROM Healthcare.encounters E
LEFT JOIN Healthcare.conditions C ON E.id = C.encounter
WHERE E.start >= '2019-01-01' AND E.start < '2020-01-01' AND encounterclass = 'emergency'
GROUP BY C.description
ORDER BY num DESC;

-- What was the emergency throughput and how did that vary by condition treated?

SELECT description, AVG(throughput_in_min) AS thr_avg
FROM
(
    SELECT E.id, C.description, EXTRACT(MINUTE FROM (E.stop - E.start)) AS throughput_in_min
    FROM Healthcare.encounters E
    LEFT JOIN Healthcare.conditions C ON E.id = C.encounter
    WHERE E.start >= '2019-01-01' AND E.start < '2020-01-01' AND encounterclass = 'emergency'
) T
GROUP BY description;

-- How many emergency encounters did we have before 2020?

SELECT COUNT(*) AS er_num
FROM Healthcare.encounters
WHERE start < '2020-01-01' AND encounterclass = 'emergency';

-- Other than nulls (where no condition was documented), which condition was most documented for emergency encounters before 2020?

SELECT C.description, COUNT(*) AS num
FROM Healthcare.encounters E
LEFT JOIN Healthcare.conditions C ON E.id = C.encounter
WHERE E.start < '2020-01-01' AND encounterclass = 'emergency'
GROUP BY C.description
ORDER BY num DESC;

-- How many conditions for emergency encounters before 2020 had average ER throughputs above 100 minutes?

SELECT COUNT(*) AS num
FROM
(
    SELECT description, AVG(throughput_in_min) AS thr_avg
    FROM
    (
        SELECT E.id, C.description, EXTRACT(MINUTE FROM (E.stop - E.start)) AS throughput_in_min
        FROM Healthcare.encounters E
        LEFT JOIN Healthcare.conditions C ON E.id = C.encounter
        WHERE E.start < '2020-01-01' AND encounterclass = 'emergency'
    ) T1
    GROUP BY description
    HAVING AVG(throughput_in_min) > 100
) T2;

-- What is total claim cost for each encounter in 2019?

SELECT SUM(total_claim_cost) AS total_for_2019, AVG(total_claim_cost) AS avg_for_2019
FROM Healthcare.encounters
WHERE start >= '2019-01-01' AND start < '2020-01-01';

-- What is total payer coverage for each encounter in 2019?

SELECT SUM(payer_coverage) AS total_for_2019, AVG(payer_coverage) AS avg_for_2019
FROM Healthcare.encounters
WHERE start >= '2019-01-01' AND start < '2020-01-01';

-- Which encounter types had the highest cost?

SELECT encounterclass, SUM(total_claim_cost) AS total_for_2019, AVG(total_claim_cost) AS avg_for_2019
FROM Healthcare.encounters
WHERE start >= '2019-01-01' AND start < '2020-01-01'
GROUP BY encounterclass
ORDER BY total_for_2019 DESC;

-- Which encounter types had the highest cost covered by payers?

SELECT payer, encounterclass, SUM(total_claim_cost) - SUM(payer_coverage) AS cover_for_2019
FROM Healthcare.encounters
WHERE start >= '2019-01-01' AND start < '2020-01-01'
GROUP BY payer, encounterclass
ORDER BY cover_for_2019 DESC;

-- Which payer had the highest claim coverage percentage (total payer coverage/ total claim cost) for encounters before 2020?

SELECT E.payer, P.name, SUM(payer_coverage) / SUM(total_claim_cost) AS cover_perc_for_2019
FROM Healthcare.encounters E
JOIN Healthcare.payers P ON E.payer = P.id
WHERE start < '2020-01-01'
GROUP BY E.payer, P.name
ORDER BY cover_perc_for_2019 DESC;

-- Which payer had the highest claim coverage percentage (total payer coverage / total claim cost) for ambulatory encounters before 2020?

SELECT E.payer, P.name, SUM(payer_coverage) / SUM(total_claim_cost) AS cover_perc_for_2019
FROM Healthcare.encounters E
JOIN Healthcare.payers P ON E.payer = P.id
WHERE start < '2020-01-01' AND encounterclass = 'ambulatory'
GROUP BY E.payer, P.name
ORDER BY cover_perc_for_2019 DESC;

-- How many different types of procedures did we perform in 2019?

SELECT COUNT(DISTINCT description) AS total_procs
FROM Healthcare.procedures
WHERE date >= '2019-01-01' AND date < '2020-01-01';

-- How many procedures were performed across each care setting (inpatient/ambulatory)?

SELECT E.encounterclass, COUNT(*) AS total_procs_for_class
FROM Healthcare.procedures P
JOIN Healthcare.encounters E ON P.encounter = E.id
WHERE date >= '2019-01-01' AND date < '2020-01-01'
GROUP BY E.encounterclass;

-- Which organizations performed the most inpatient procedures in 2019?

SELECT E.organization, COUNT(*) AS total_procs_for_org
FROM Healthcare.procedures P
JOIN Healthcare.encounters E ON P.encounter = E.id
JOIN Healthcare.organizations O ON E.organization = O.id
WHERE date >= '2019-01-01' AND date < '2020-01-01' AND E.encounterclass = 'inpatient'
GROUP BY E.organization;

-- How many Colonoscopy procedures were performed before 2020?

SELECT COUNT(*) AS cnt_colonoscopy
FROM Healthcare.procedures 
WHERE date < '2020-01-01' AND description = 'Colonoscopy';

-- Compare our total number of procedures in 2018 to 2019. Did we perform more procedures in 2019 or less?

SELECT COUNT(*)
FROM
(
    SELECT description, COUNT(*) AS total_procs
    FROM Healthcare.procedures
    WHERE date >= '2018-01-01' AND date < '2019-01-01'
    GROUP BY description
) T;

-- Which organizations performed the most Auscultation of the fetal heart procedures before 2020? Give answer with Organization ID.

SELECT E.organization, COUNT(*)
FROM Healthcare.procedures P
JOIN Healthcare.encounters E ON P.encounter = E.id
JOIN Healthcare.organizations O ON E.organization = O.id
WHERE date < '2020-01-01' AND P.description = 'Auscultation of the fetal heart'
GROUP BY E.organization
ORDER BY COUNT(*) DESC;

-- Which race had the highest number of procedures done in 2019?

SELECT race, COUNT(*) AS total_procs
FROM Healthcare.procedures P
JOIN Healthcare.encounters E ON P.encounter = E.id
JOIN Healthcare.patients P2 ON E.patient = P2.id
WHERE date >= '2019-01-01' AND date < '2020-01-01'
GROUP BY race
ORDER BY total_procs DESC;