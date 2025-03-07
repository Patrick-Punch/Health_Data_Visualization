-- Drop tables if they exist to ensure a fresh start
DROP TABLE IF EXISTS flu_demo_data CASCADE;
DROP TABLE IF EXISTS healthcare_demo_data CASCADE;
DROP TABLE IF EXISTS hospital_er CASCADE;
-- DROP TABLE IF EXISTS patient_data CASCADE;

-- Table for flu vaccination data
CREATE TABLE flu_demo_data (
    age INT,
    id UUID PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    county VARCHAR(100),
    race VARCHAR(50),
    ethnicity VARCHAR(50),
    gender CHAR(1),
    earliest_flu_shot_2022 TIMESTAMP,
    zip VARCHAR(10),
    flu_shot_2022 BOOLEAN
);

-- Table for healthcare encounters
CREATE TABLE healthcare_demo_data (
    encounter_id UUID PRIMARY KEY,
    start_day DATE,
    stop_date DATE,
    encounter_class VARCHAR(50),
    enc_type VARCHAR(255),
    base_encounter_cost NUMERIC(10,2),
    total_claim_cost NUMERIC(10,2),
    organization UUID,
    enc_reason TEXT,
    payer VARCHAR(100),
    payer_category VARCHAR(100),
    patient_id UUID,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    birthdate DATE,
    ethnicity VARCHAR(50),
    race VARCHAR(50),
    zip VARCHAR(10),
    flu_2022 BOOLEAN,
    covid BOOLEAN,
    org_name VARCHAR(255),
    org_zip VARCHAR(10),
    org_city VARCHAR(100),
    org_state VARCHAR(2)
);

-- Table for hospital ER visits
CREATE TABLE hospital_er (
    date TIMESTAMP,
    patient_id VARCHAR(20) PRIMARY KEY,
    patient_gender CHAR(2),
    patient_age INT,
    patient_sat_score INT,
    patient_first_initial CHAR(1),
    patient_last_name VARCHAR(100),
    patient_race VARCHAR(100),
    patient_admin_flag BOOLEAN,
    patient_waittime INT,
    department_referral VARCHAR(255)
);
--CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create a combined table with all attributes from the three tables
-- CREATE TABLE patient_data AS
-- SELECT 
--     -- Fields from flu_demo_data
--     f.age AS flu_age,
--     f.id AS flu_id,
--     f.first_name AS flu_first_name,
--     f.last_name AS flu_last_name,
--     f.county AS flu_county,
--     f.race AS flu_race,
--     f.ethnicity AS flu_ethnicity,
--     f.gender AS flu_gender,
--     f.earliest_flu_shot_2022,
--     f.zip AS flu_zip,
--     f.flu_shot_2022,

--     -- Fields from healthcare_demo_data
--     h.encounter_id,
--     h.start_day,
--     h.stop_date,
--     h.encounter_class,
--     h.enc_type,
--     h.base_encounter_cost,
--     h.total_claim_cost,
--     h.organization,
--     h.enc_reason,
--     h.payer,
--     h.payer_category,
--     h.patient_id AS healthcare_patient_id,
--     h.first_name AS healthcare_first_name,
--     h.last_name AS healthcare_last_name,
--     h.birthdate,
--     h.ethnicity AS healthcare_ethnicity,
--     h.race AS healthcare_race,
--     h.zip AS healthcare_zip,
--     h.flu_2022,
--     h.covid,
--     h.org_name,
--     h.org_zip,
--     h.org_city,
--     h.org_state,

--     -- Fields from hospital_er
--     e.patient_gender,
--     e.patient_age,
--     e.patient_sat_score,
--     e.patient_first_initial,
--     e.patient_last_name AS er_patient_last_name,
--     e.patient_race AS er_patient_race,
--     e.patient_admin_flag,
--     e.patient_waittime,
--     e.department_referral

-- FROM 
--     flu_demo_data f
-- -- Join healthcare_demo_data with flu_demo_data on patient ID
-- LEFT JOIN healthcare_demo_data h 
--     ON f.id = h.patient_id

-- -- Join hospital_er with both flu_demo_data and healthcare_demo_data on patient_id
-- LEFT JOIN hospital_er e 
--     ON f.id = uuid_generate_v5(uuid_nil(), e.patient_id::text);