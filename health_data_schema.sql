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
    start_day TIMESTAMP,
    stop_date TIMESTAMP,
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
CREATE TABLE hospital_demo_data (
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
-- Create patients table
CREATE TABLE patients (
    id UUID PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    birthdate DATE,
    ethnicity VARCHAR(50),
    race VARCHAR(50),
    gender CHAR(1),
    county VARCHAR(100),
    zip VARCHAR(10),
    flu_2022 BOOLEAN,
    covid BOOLEAN
);
-- Create encounters table
CREATE TABLE encounters (
    encounter_id UUID PRIMARY KEY,
    start TIMESTAMP,
    stop TIMESTAMP,
    encounterclass VARCHAR(50),
    enc_type VARCHAR(100),
    base_encounter_cost DECIMAL,
    total_claim_cost DECIMAL,
    organization UUID,
    enc_reason VARCHAR(255),
    payer VARCHAR(50),
    payer_category VARCHAR(50),
    patient_id UUID REFERENCES patients(id),
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
    org_state VARCHAR(100)
);

-- Create hospital ER table
CREATE TABLE hospital_er (
    date TIMESTAMP,
    patient_id UUID REFERENCES patients(id),
    patient_gender CHAR(1),
    patient_age INT,
    patient_sat_score INT,
    patient_first_initial CHAR(1),
    patient_last_name VARCHAR(100),
    patient_race VARCHAR(100),
    patient_admin_flag BOOLEAN,
    patient_waittime INT,
    department_referral VARCHAR(255)
);
    

CREATE TABLE patients AS
SELECT 
    f.id AS patient_id,
    f.first_name,
    f.last_name,
    f.county,
    f.race,
    f.ethnicity,
    f.gender,
    f.earliest_flu_shot_2022,
    f.zip,
    f.flu_shot_2022,
    h.start_day,
    h.stop_date,
    h.encounter_class,
    h.last_name AS encounter_last_name,
    hd.patient_gender AS hospital_patient_gender,
    hd.patient_age AS hospital_patient_age,
    hd.patient_sat_score,
    hd.patient_first_initial,
    hd.patient_last_name AS hospital_patient_last_name,
    hd.patient_race AS hospital_patient_race,
    hd.patient_admin_flag,
    hd.patient_waittime,
    hd.department_referral
FROM 
    flu_demo_data f
JOIN 
    healthcare_demo_data h
ON 
    f.id = h.patient_id
LEFT JOIN 
    hospital_er hd
ON 
    f.id = hd.patient_id::UUID;  -- Casting the patient_id from VARCHAR to UUID