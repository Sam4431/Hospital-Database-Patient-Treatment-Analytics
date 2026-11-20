# Hospital Database: Patient & Treatment Analytics

## Project Overview

This project analyzes hospital admissions across a multi-facility healthcare system using MySQL. It examines departmental length of stay, facility-level severity distribution, emergency admissions across age groups, and differences in facility workloads and recorded room availability.

The project transforms raw hospital admission data into a normalized relational database and uses SQL queries to identify patterns that may support operational planning and resource allocation.

## Business Challenge

Hospital administrators need reliable information about patient admission patterns, the distribution of illness severity across facilities, and differences in emergency admissions across age groups. They also need to understand how admission volumes, recorded room availability, and estimated lengths of stay vary between facilities.

This analysis uses SQL to explore these questions and present findings that can inform further investigation and operational decision-making.

## Tools & Technologies Used

- Database Management: MySQL Workbench
- Database Design: Relational database design, normalization, DDL, primary keys, foreign keys, and indexes
- SQL Analytics: Multi-table joins, aggregate functions, conditional aggregation, CASE expressions, and window functions (`OVER (PARTITION BY)`)
- Version Control: Git & GitHub

## Dataset Source

- Dataset: AV: Healthcare Analytics II
- Platform: Kaggle
- Uploader: Neha Prabhavalkar
- Source: [Kaggle Dataset](https://www.kaggle.com/datasets/nehaprabhavalkar/av-healthcare-analytics-ii)

The analysis uses the training dataset, which contains 318,438 hospital admission records. The dataset includes patient demographics, facility information, admission characteristics, severity of illness, and length-of-stay categories.

## Database Design

The original dataset was transformed into a normalized relational database consisting of four tables:

 patients - Stores patient identifiers, age groups, and patient city codes |
 facilities - Stores hospital identifiers and facility characteristics |
 departments - Stores unique department names |
 admissions - Stores individual admission records and their associated patient, facility, and department information |

Primary keys and foreign keys establish relationships between the tables. Indexes were added to frequently used foreign-key columns to support joins and improve query performance.

## Repository Structure

hospital-database-patient-treatment-analytics/
├── sql/
│   ├── schema.sql
│   └── analysis.sql
├── images/
│   └── query_results.png
└── README.md

schema.sql - contains the database creation, table definitions, relationships, and data preparation steps.
analysis.sql - contains the analytical queries used to answer the four business questions.
images- contains screenshots of selected query results.

## Business Questions & Key Findings

### 1. Which departments have the highest estimated average length of stay?

Approach: Used conditional aggregation with `CASE` expressions to assign numerical midpoints to the categorical length-of-stay ranges, then calculated the average by department.

Findings:
- Surgery recorded the highest estimated average stay at 37.41 days, across 1,201 admissions.
- Radiotherapy followed at 33.17 days, across 28,516 admissions.
- Anesthesia recorded the lowest estimated average at 30.00 days.

Recommendation: Hospital administrators could review discharge planning and patient transition processes in Surgery and Radiotherapy. The relatively small number of Surgery admissions should also be considered when interpreting its result.

### 2. How does the severity distribution vary across facilities?

Approach: Joined admissions with facility information and used a window function with `SUM() OVER (PARTITION BY)` to calculate each severity category's percentage share within its facility.

Findings:
- Moderate cases represented the largest share of admissions at every facility, ranging from 51.76% to 58.54%.
- Hospital 19 recorded the highest proportion of Extreme-severity admissions at 23.39%.
- Hospital 26 handled the largest absolute number of Extreme-severity admissions, with 6,690 cases, representing 20.23% of its admissions.

Recommendation: Administrators could investigate the differences in severity distribution across facilities, particularly at hospitals with high proportions or large numbers of Extreme cases. This could help inform further reviews of specialist availability and resource allocation.

### 3. Which age groups account for the highest proportion of emergency admissions?

Approach: Used conditional aggregation to calculate emergency admission counts, each age group's share of all emergency admissions, and the emergency admission rate within each age group.

Findings:
- The 41–50 - age group accounted for the largest share of all emergency admissions at 20.09%.
- The 31–40 - age group followed closely at 19.90%.
- The 91–100 - age group had the highest emergency admission rate within its own age group at 46.93%, followed by the 81–90 group at 44.99%.

These results distinguish the age groups contributing the largest number of emergency admissions from those with the highest proportion of emergency admissions within their own group.

Recommendation: Healthcare planners could consider these demographic patterns when reviewing emergency service demand and preventive care priorities. The high emergency rates among older age groups may warrant further investigation, while accounting for their smaller admission volumes.

### 4. How do admission volume, room availability, and estimated stay duration vary by facility?

Approach: Joined admissions with facility information and calculated total admissions, average available extra rooms, average bed grade, and estimated average length of stay for each hospital.

Findings:
- Hospital 26 recorded the highest admission volume, with 33,076 admissions and an average of 3.30 available extra rooms.
- Hospital 20 had the lowest average available extra rooms at 2.55, but recorded only 1,405 admissions.
- Hospital 2 recorded the highest estimated average length of stay at 40.03 days.

Recommendation: Administrators could examine differences in admission volumes, recorded room availability, and estimated stay duration to identify facilities that may benefit from further operational review. Actual occupancy and staffing data would be needed to assess capacity constraints more directly.

## Key Project Reflections

### 1. Database Design and Normalization

Transforming the original dataset into separate patient, facility, department, and admission tables helped reduce unnecessary duplication and establish clear relationships between records. Using primary and foreign keys also made the database structure more reliable and easier to query.

### 2. Data Quality and Validation

Data validation was an important part of the project. I checked numeric formats, missing values, identifiers, and relationships between tables. I also compared row counts before and after joins to ensure that records were not unintentionally lost or duplicated. Missing values were preserved as `NULL` rather than automatically converted to zero.

### 3. SQL Analysis and Interpretation

The project strengthened my ability to use joins, aggregate functions, conditional aggregation, CASE expressions, and window functions to answer practical business questions. It also reinforced the importance of interpreting metrics correctly—for example, distinguishing an age group's share of all emergency admissions from its emergency admission rate within that group.

## Limitations

- Length of stay is provided as categorical ranges rather than exact days. Midpoints were used to estimate average stay, including an assumed midpoint of 105 days for the category "More than 100 Days."
- Average available extra rooms do not represent actual bed occupancy or hospital capacity utilization.
- Average bed grade is an average of an ordinal category and should not be interpreted as a direct measure of facility quality or capacity.
- The analysis identifies patterns and associations but does not establish causal relationships.
- Further information, such as staffing levels, actual bed occupancy, patient outcomes, and facility capacity, would be needed for stronger operational conclusions.

## AI Disclosure

ChatGPT was used as a supporting tool for learning, SQL troubleshooting, and reviewing project documentation. The database work, query execution, validation, and interpretation of results were carried out and checked as part of the project workflow.
