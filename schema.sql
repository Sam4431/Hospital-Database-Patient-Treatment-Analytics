
-- ============================================================================
-- Project: Healthcare Data Analytics
-- Stage 1: Raw Data Import and Data Quality Audit
-- Database: hospital_db
--
-- Purpose:
--   1. Verify raw dataset sizes and case identifiers.
--   2. Check patient identifiers and train/test overlap.
--   3. Validate numerical field formats.
--   4. Inspect category distributions.
--   5. Check consistency of hospital identifiers.
--
-- Raw tables:
--   train_raw: 318,438 records; includes Stay.
--   test_raw:  137,057 records; does not include Stay.
--
-- NOTE:
--   The CSV columns were imported as TEXT. The raw tables are retained
--   unchanged during the audit.
-- ============================================================================

USE hospital_db;


-- ============================================================================
-- 1. DATASET SIZE AND CASE ID CHECKS
-- ============================================================================
-- COUNT(*) counts all records.
-- COUNT(DISTINCT case_id) counts unique case identifiers.
-- Matching counts indicate no duplicate case IDs among non-NULL values,
-- provided there are no missing case IDs.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT case_id) AS unique_case_ids,
    SUM(case_id IS NULL OR TRIM(case_id) = '') AS missing_case_ids
FROM train_raw;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT case_id) AS unique_case_ids,
    SUM(case_id IS NULL OR TRIM(case_id) = '') AS missing_case_ids
FROM test_raw;


-- ============================================================================
-- 2. PATIENT AND HOSPITAL IDENTIFIER CHECKS
-- ============================================================================
-- A patient may have multiple case records.
-- Hospital_code identifies a facility in the source dataset.

SELECT
    COUNT(*) AS total_cases,
    COUNT(DISTINCT patientid) AS unique_patients,
    SUM(patientid IS NULL OR TRIM(patientid) = '') AS missing_patient_ids,
    COUNT(DISTINCT Hospital_code) AS unique_hospitals,
    SUM(Hospital_code IS NULL OR TRIM(Hospital_code) = '')
        AS missing_hospital_codes
FROM train_raw;

SELECT
    COUNT(*) AS total_cases,
    COUNT(DISTINCT patientid) AS unique_patients,
    SUM(patientid IS NULL OR TRIM(patientid) = '') AS missing_patient_ids,
    COUNT(DISTINCT Hospital_code) AS unique_hospitals,
    SUM(Hospital_code IS NULL OR TRIM(Hospital_code) = '')
        AS missing_hospital_codes
FROM test_raw;


-- ============================================================================
-- 3. CHECK FOR PATIENT ID OVERLAP BETWEEN TRAIN AND TEST
-- ============================================================================
-- This counts distinct patient IDs present in both datasets.
-- Zero overlap was observed during the initial audit.

SELECT
    COUNT(DISTINCT t.patientid) AS patients_in_both_datasets
FROM train_raw AS t
INNER JOIN test_raw AS s
    ON t.patientid = s.patientid;


-- ============================================================================
-- 4. MISSING VALUES IN TEST DATA
-- ============================================================================
-- The CSV import may represent empty cells as empty strings instead of NULL.
-- Check both conditions.
-- Initial audit found missing bed grades and patient-city codes.

SELECT
    COUNT(*) AS total_rows,
    SUM(`Bed Grade` IS NULL OR TRIM(`Bed Grade`) = '')
        AS missing_bed_grade,
    SUM(City_Code_Patient IS NULL OR TRIM(City_Code_Patient) = '')
        AS missing_city_code_patient
FROM test_raw;


-- ============================================================================
-- 5. NUMERICAL FIELD FORMAT VALIDATION
-- ============================================================================
-- REGEXP checks whether values follow expected numeric formats.
-- These checks validate format, not whether values are clinically or
-- operationally reasonable.

-- Training dataset

SELECT
    SUM(
        TRIM(`Available Extra Rooms in Hospital`) = ''
        OR `Available Extra Rooms in Hospital` NOT REGEXP '^[0-9]+$'
    ) AS invalid_extra_rooms,

    SUM(
        TRIM(Admission_Deposit) = ''
        OR Admission_Deposit NOT REGEXP '^[0-9]+([.][0-9]+)?$'
    ) AS invalid_deposits,

    SUM(
        TRIM(`Visitors with Patient`) = ''
        OR `Visitors with Patient` NOT REGEXP '^[0-9]+$'
    ) AS invalid_visitors
FROM train_raw;


-- Test dataset

SELECT
    SUM(
        TRIM(`Available Extra Rooms in Hospital`) = ''
        OR `Available Extra Rooms in Hospital` NOT REGEXP '^[0-9]+$'
    ) AS invalid_extra_rooms,

    SUM(
        TRIM(Admission_Deposit) = ''
        OR Admission_Deposit NOT REGEXP '^[0-9]+([.][0-9]+)?$'
    ) AS invalid_deposits,

    SUM(
        TRIM(`Visitors with Patient`) = ''
        OR `Visitors with Patient` NOT REGEXP '^[0-9]+$'
    ) AS invalid_visitors
FROM test_raw;


-- ============================================================================
-- 6. NUMERICAL RANGES IN TRAINING DATA
-- ============================================================================
-- MIN and MAX provide an initial range check.
-- Values still require contextual interpretation.

SELECT
    MIN(CAST(`Available Extra Rooms in Hospital` AS SIGNED))
        AS min_extra_rooms,
    MAX(CAST(`Available Extra Rooms in Hospital` AS SIGNED))
        AS max_extra_rooms,
    MIN(CAST(Admission_Deposit AS DECIMAL(12,2)))
        AS min_deposit,
    MAX(CAST(Admission_Deposit AS DECIMAL(12,2)))
        AS max_deposit,
    MIN(CAST(`Visitors with Patient` AS SIGNED))
        AS min_visitors,
    MAX(CAST(`Visitors with Patient` AS SIGNED))
        AS max_visitors
FROM train_raw;


-- ============================================================================
-- 7. CATEGORY COUNTS IN TRAINING DATA
-- ============================================================================
-- COUNT(DISTINCT ...) counts different values in each column.

SELECT COUNT(DISTINCT Department) AS department_categories
FROM train_raw;

SELECT COUNT(DISTINCT `Type of Admission`) AS admission_type_categories
FROM train_raw;

SELECT COUNT(DISTINCT `Severity of Illness`) AS severity_categories
FROM train_raw;

SELECT COUNT(DISTINCT Age) AS age_categories
FROM train_raw;

SELECT COUNT(DISTINCT Stay) AS stay_categories
FROM train_raw;


-- ============================================================================
-- 8. STAY CATEGORY DISTRIBUTION
-- ============================================================================
-- Stay is categorical, not an exact number of days.
-- This query shows how many cases belong to each stay category.

SELECT
    Stay,
    COUNT(*) AS cases
FROM train_raw
GROUP BY Stay
ORDER BY cases DESC;


-- ============================================================================
-- 9. CATEGORY COUNTS IN TEST DATA
-- ============================================================================
-- The main categories are compared with the training dataset.
-- Stay is excluded because test_raw has no Stay column.

SELECT COUNT(DISTINCT Department) AS department_categories
FROM test_raw;

SELECT COUNT(DISTINCT `Type of Admission`) AS admission_type_categories
FROM test_raw;

SELECT COUNT(DISTINCT `Severity of Illness`) AS severity_categories
FROM test_raw;

SELECT COUNT(DISTINCT Age) AS age_categories
FROM test_raw;


-- ============================================================================
-- 10. HOSPITAL AND WARD CATEGORY COUNTS
-- ============================================================================
-- These fields describe facilities and ward/bed characteristics.

SELECT COUNT(DISTINCT Hospital_code) AS hospital_codes
FROM train_raw;

SELECT COUNT(DISTINCT Hospital_type_code) AS hospital_types
FROM train_raw;

SELECT COUNT(DISTINCT City_Code_Hospital) AS hospital_cities
FROM train_raw;

SELECT COUNT(DISTINCT Hospital_region_code) AS hospital_regions
FROM train_raw;

SELECT COUNT(DISTINCT Ward_Type) AS ward_types
FROM train_raw;

SELECT COUNT(DISTINCT Ward_Facility_Code) AS ward_facility_codes
FROM train_raw;

SELECT COUNT(DISTINCT `Bed Grade`) AS bed_grades
FROM train_raw;


-- ============================================================================
-- 11. HOSPITAL IDENTIFIER CONSISTENCY
-- ============================================================================
-- Each hospital code should map to one observed hospital type, city and region.
-- HAVING filters groups after aggregation.
-- Expected audit outcome: zero rows.

SELECT
    Hospital_code,
    COUNT(DISTINCT Hospital_type_code) AS hospital_types,
    COUNT(DISTINCT City_Code_Hospital) AS hospital_cities,
    COUNT(DISTINCT Hospital_region_code) AS hospital_regions
FROM train_raw
GROUP BY Hospital_code
HAVING
    COUNT(DISTINCT Hospital_type_code) > 1
    OR COUNT(DISTINCT City_Code_Hospital) > 1
    OR COUNT(DISTINCT Hospital_region_code) > 1;
    
-- ==========================================
--  NORMALIZED DATABASE SCHEMA
-- ==========================================

-- 1. Patients table
CREATE TABLE patients (
    patientid INT NOT NULL,
    Age VARCHAR(20),
    City_Code_Patient INT,
    PRIMARY KEY (patientid)
) ENGINE = InnoDB;


-- 2. Facilities table
CREATE TABLE facilities (
    Hospital_code INT NOT NULL,
    Hospital_type_code VARCHAR(10),
    City_Code_Hospital INT,
    Hospital_region_code VARCHAR(10),
    PRIMARY KEY (Hospital_code)
) ENGINE = InnoDB;


-- 3. Departments table
CREATE TABLE departments (
    department_id INT NOT NULL AUTO_INCREMENT,
    Department_Name VARCHAR(100) NOT NULL,
    PRIMARY KEY (department_id),
    UNIQUE KEY uq_department_name (Department_Name)
) ENGINE = InnoDB;


-- 4. Admissions table
CREATE TABLE admissions (
    case_id INT NOT NULL,
    patientid INT NOT NULL,
    Hospital_code INT NOT NULL,
    department_id INT NOT NULL,
    Available_Extra_Rooms INT,
    Ward_Type VARCHAR(10),
    Ward_Facility_Code VARCHAR(10),
    Bed_Grade INT,
    Type_of_Admission VARCHAR(30),
    Severity_of_Illness VARCHAR(30),
    Visitors_with_Patient INT,
    Admission_Deposit DECIMAL(12,2),
    Stay VARCHAR(30),

    PRIMARY KEY (case_id),

    CONSTRAINT fk_admission_patient
        FOREIGN KEY (patientid) REFERENCES patients(patientid),

    CONSTRAINT fk_admission_facility
        FOREIGN KEY (Hospital_code) REFERENCES facilities(Hospital_code),

    CONSTRAINT fk_admission_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id),

    INDEX idx_admissions_patient (patientid),
    INDEX idx_admissions_facility (Hospital_code),
    INDEX idx_admissions_department (department_id)
) ENGINE = InnoDB;


-- ==========================================
-- POPULATE NORMALIZED TABLES
-- ==========================================

-- 1. Populate patients
INSERT INTO patients (patientid, Age, City_Code_Patient)
SELECT DISTINCT
    CAST(patientid AS UNSIGNED),
    Age,
    CAST(NULLIF(TRIM(City_Code_Patient), '') AS DECIMAL(10,2))
FROM train_data;


-- 2. Populate facilities
INSERT INTO facilities (
    Hospital_code,
    Hospital_type_code,
    City_Code_Hospital,
    Hospital_region_code
)
SELECT DISTINCT
    CAST(Hospital_code AS UNSIGNED),
    Hospital_type_code,
    CAST(CAST(City_Code_Hospital AS DECIMAL(10,2)) AS UNSIGNED),
    Hospital_region_code
FROM train_data;


-- 3. Populate departments
INSERT INTO departments (Department_Name)
SELECT DISTINCT TRIM(Department)
FROM train_data
WHERE Department IS NOT NULL
  AND TRIM(Department) <> '';


-- 4. Populate admissions
INSERT INTO admissions (
    case_id, patientid, Hospital_code, department_id,
    Available_Extra_Rooms, Ward_Type, Ward_Facility_Code,
    Bed_Grade, Type_of_Admission, Severity_of_Illness,
    Visitors_with_Patient, Admission_Deposit, Stay
)
SELECT
    CAST(t.case_id AS UNSIGNED),
    CAST(t.patientid AS UNSIGNED),
    CAST(t.Hospital_code AS UNSIGNED),
    d.department_id,
    CAST(NULLIF(TRIM(t.`Available Extra Rooms in Hospital`), '') AS UNSIGNED),
    NULLIF(TRIM(t.Ward_Type), ''),
    NULLIF(TRIM(t.Ward_Facility_Code), ''),
    CAST(CAST(NULLIF(TRIM(t.`Bed Grade`), '') AS DECIMAL(10,2)) AS UNSIGNED),
    NULLIF(TRIM(t.`Type of Admission`), ''),
    NULLIF(TRIM(t.`Severity of Illness`), ''),
    CAST(NULLIF(TRIM(t.`Visitors with Patient`), '') AS UNSIGNED),
    CAST(NULLIF(TRIM(t.Admission_Deposit), '') AS DECIMAL(12,2)),
    NULLIF(TRIM(t.Stay), '')
FROM train_data t
JOIN departments d
    ON d.Department_Name = TRIM(t.Department);
    
-- ==========================================
-- DATA VALIDATION
-- ==========================================

-- 1. Verify table row counts
SELECT 'patients' AS table_name, COUNT(*) AS total_rows
FROM patients

UNION ALL

SELECT 'facilities', COUNT(*)
FROM facilities

UNION ALL

SELECT 'departments', COUNT(*)
FROM departments

UNION ALL

SELECT 'admissions', COUNT(*)
FROM admissions;


-- 2. Check duplicate admission IDs
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT case_id) AS unique_case_ids
FROM admissions;


-- 3. Check unmatched foreign keys
SELECT
    COUNT(*) AS unmatched_patients
FROM admissions a
LEFT JOIN patients p
    ON a.patientid = p.patientid
WHERE p.patientid IS NULL;

SELECT
    COUNT(*) AS unmatched_facilities
FROM admissions a
LEFT JOIN facilities f
    ON a.Hospital_code = f.Hospital_code
WHERE f.Hospital_code IS NULL;

SELECT
    COUNT(*) AS unmatched_departments
FROM admissions a
LEFT JOIN departments d
    ON a.department_id = d.department_id
WHERE d.department_id IS NULL;


-- 4. Check missing values
SELECT
    SUM(City_Code_Patient IS NULL) AS missing_patient_city_codes
FROM patients;

SELECT
    SUM(Bed_Grade IS NULL) AS missing_bed_grades,
    SUM(Available_Extra_Rooms IS NULL) AS missing_extra_rooms,
    SUM(Visitors_with_Patient IS NULL) AS missing_visitors,
    SUM(Admission_Deposit IS NULL) AS missing_deposits
FROM admissions;


-- ==========================================
-- DATABASE NORMALIZATION
-- ==========================================

/*
The database was organized into four related tables
to reduce data redundancy and improve data integrity.

1. patients:
   Stores patient-level information separately.
   Each patient is identified by patientid.

2. facilities:
   Stores hospital-level information.
   Each hospital is identified by Hospital_code.

3. departments:
   Stores unique department names.
   Each department receives a department_id.

4. admissions:
   Stores individual admission records and references
   the patients, facilities, and departments tables
   through foreign keys.

Primary keys uniquely identify records, while foreign
keys maintain relationships between the tables.
Indexes were added to the foreign-key columns to
support joins and data retrieval.

This structure separates descriptive information from
admission transactions and reduces repeated data.
*/

