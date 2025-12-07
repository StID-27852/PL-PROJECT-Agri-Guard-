# AgriGuard+ Data Dictionary
**Student:** Ineza Sonia (27852) | **Group:** Monday  
**Project:** AgriGuard+ Smart Agricultural Management System  
**Date:** December 7, 2025  
**Database:** mon_27852_sonia_AgriGuard_DB

---

## Table of Contents
1. [FARMERS](#1-farmers)
2. [FIELDS](#2-fields)
3. [CROPS](#3-crops)
4. [CROP_PLANTINGS](#4-crop_plantings)
5. [DISEASES](#5-diseases)
6. [DISEASE_CASES](#6-disease_cases)
7. [TREATMENTS](#7-treatments)
8. [DISEASE_TREATMENTS](#8-disease_treatments)
9. [CHEMICALS](#9-chemicals)
10. [STAFF](#10-staff)
11. [TREATMENT_APPLICATIONS](#11-treatment_applications)
12. [CHEMICAL_USAGE](#12-chemical_usage)
13. [AUDIT_LOG](#13-audit_log)
14. [PUBLIC_HOLIDAYS](#14-public_holidays)

---

## 1. FARMERS
**Purpose:** Stores information about farm owners and operators

**Business Rules:**
- Each farmer must have a unique identifier
- Phone numbers and emails must be unique if provided
- Farmers can own multiple fields
- Default status is ACTIVE

| Column Name | Data Type | Constraints | Description | Example |
|------------|-----------|-------------|-------------|---------|
| farmer_id | NUMBER(10) | PRIMARY KEY, GENERATED ALWAYS AS IDENTITY | Unique farmer identifier | 1, 2, 3... |
| farmer_name | VARCHAR2(100) | NOT NULL | Full name of the farmer | 'Jean Pierre MUGABO' |
| phone_number | VARCHAR2(15) | UNIQUE | Contact phone number | '0788123456' |
| email | VARCHAR2(100) | UNIQUE | Email address | 'jpmugabo@gmail.com' |
| location | VARCHAR2(200) | | Physical address/location | 'Kigali - Gasabo' |
| registration_date | DATE | DEFAULT SYSDATE | Date farmer was registered in system | 07-DEC-2025 |
| status | VARCHAR2(20) | DEFAULT 'ACTIVE', CHECK (status IN ('ACTIVE', 'INACTIVE')) | Current farmer account status | 'ACTIVE' |

**Indexes:**
- PRIMARY KEY on farmer_id (automatic)
- UNIQUE on phone_number
- UNIQUE on email

**Foreign Key References:**
- Referenced by: FIELDS (farmer_id)

**Sample Data:**
```sql
farmer_id: 25
farmer_name: 'Jean Pierre MUGABO'
phone_number: '0788123456'
email: 'jpmugabo@gmail.com'
location: 'Kigali - Gasabo'
registration_date: 05-DEC-2025
status: 'ACTIVE'
```

---

## 2. FIELDS
**Purpose:** Stores information about agricultural plots/sections owned by farmers

**Business Rules:**
- Each field must belong to a farmer
- Field size must be positive
- GPS coordinates are optional
- Default status is ACTIVE

| Column Name | Data Type | Constraints | Description | Example |
|------------|-----------|-------------|-------------|---------|
| field_id | NUMBER(10) | PRIMARY KEY, GENERATED ALWAYS AS IDENTITY | Unique field identifier | 1, 2, 3... |
| farmer_id | NUMBER(10) | FOREIGN KEY → FARMERS(farmer_id), NOT NULL | Owner of the field | 25 |
| field_name | VARCHAR2(100) | NOT NULL | Name/identifier of the field | 'Field_A_12' |
| size_hectares | NUMBER(8,2) | CHECK (size_hectares > 0) | Size of field in hectares | 2.50 |
| soil_type | VARCHAR2(50) | | Type of soil | 'Clay', 'Loam', 'Sandy' |
| location_gps | VARCHAR2(100) | | GPS coordinates | '-1.95, 29.87' |
| status | VARCHAR2(20) | DEFAULT 'ACTIVE', CHECK (status IN ('ACTIVE', 'FALLOW', 'INACTIVE')) | Current field status | 'ACTIVE' |

**Indexes:**
- PRIMARY KEY on field_id
- FOREIGN KEY on farmer_id

**Foreign Key References:**
- References: FARMERS (farmer_id)
- Referenced by: CROP_PLANTINGS (field_id)

**Sample Data:**
```sql
field_id: 101
farmer_id: 25
field_name: 'Field_A_12'
size_hectares: 2.50
soil_type: 'Clay-Loam'
location_gps: '-1.95, 29.87'
status: 'ACTIVE'
```

---

## 3. CROPS
**Purpose:** Master data table for crop types

**Business Rules:**
- Crop names must be unique
- Growth period must be positive
- This is a reference/lookup table

| Column Name | Data Type | Constraints | Description | Example |
|------------|-----------|-------------|-------------|---------|
| crop_id | NUMBER(10) | PRIMARY KEY, GENERATED ALWAYS AS IDENTITY | Unique crop type identifier | 1, 2, 3... |
| crop_name | VARCHAR2(100) | NOT NULL, UNIQUE | Name of the crop | 'Maize', 'Beans' |
| crop_type | VARCHAR2(50) | CHECK (crop_type IN ('CEREAL','VEGETABLE','FRUIT','LEGUME','ROOT','OTHER')) | Category of crop | 'CEREAL' |
| growth_period_days | NUMBER(4) | CHECK (growth_period_days > 0) | Days from planting to harvest | 120 |
| description | VARCHAR2(500) | | Additional information | 'Staple cereal crop' |

**Indexes:**
- PRIMARY KEY on crop_id
- UNIQUE on crop_name

**Foreign Key References:**
- Referenced by: CROP_PLANTINGS (crop_id)

**Sample Data:**
```sql
crop_id: 1
crop_name: 'Maize'
crop_type: 'CEREAL'
growth_period_days: 120
description: 'Staple cereal crop, widely grown across Rwanda'
```

---

## 4. CROP_PLANTINGS
**Purpose:** Records specific instances of crops planted in fields

**Business Rules:**
- Each planting must reference a valid field and crop
- Planting date is required
- Expected harvest date calculated from growth period
- Status tracks lifecycle: GROWING → HARVESTED/FAILED
- Quantities must be non-negative

| Column Name | Data Type | Constraints | Description | Example |
|------------|-----------|-------------|-------------|---------|
| planting_id | NUMBER(10) | PRIMARY KEY, GENERATED ALWAYS AS IDENTITY | Unique planting instance identifier | 1, 2, 3... |
| field_id | NUMBER(10) | FOREIGN KEY → FIELDS(field_id), NOT NULL | Field where crop is planted | 101 |
| crop_id | NUMBER(10) | FOREIGN KEY → CROPS(crop_id), NOT NULL | Type of crop planted | 1 |
| planting_date | DATE | NOT NULL | Date crop was planted | 15-SEP-2025 |
| expected_harvest_date | DATE | | Calculated/estimated harvest date | 13-JAN-2026 |
| actual_harvest_date | DATE | | Actual date of harvest (if completed) | 15-JAN-2026 |
| quantity_planted | NUMBER(10,2) | CHECK (quantity_planted >= 0) | Amount planted (kg/seeds) | 150.00 |
| quantity_harvested | NUMBER(10,2) | CHECK (quantity_harvested >= 0) | Amount harvested (kg) | 1200.50 |
| status | VARCHAR2(20) | DEFAULT 'GROWING', CHECK (status IN ('GROWING','HARVESTED','FAILED','ABANDONED')) | Current planting status | 'GROWING' |

**Indexes:**
- PRIMARY KEY on planting_id
- FOREIGN KEY on field_id
- FOREIGN KEY on crop_id

**Foreign Key References:**
- References: FIELDS (field_id), CROPS (crop_id)
- Referenced by: DISEASE_CASES (planting_id)

**Sample Data:**
```sql
planting_id: 1
field_id: 101
crop_id: 1
planting_date: 15-SEP-2025
expected_harvest_date: 13-JAN-2026
actual_harvest_date: NULL
quantity_planted: 150.00
quantity_harvested: NULL
status: 'GROWING'
```

---

## 5. DISEASES
**Purpose:** Master data catalog of agricultural diseases

**Business Rules:**
- Disease names must be unique
- Severity level indicates general threat level
- Categories help classify diseases by type
- This is a reference/lookup table

| Column Name | Data Type | Constraints | Description | Example |
|------------|-----------|-------------|-------------|---------|
| disease_id | NUMBER(10) | PRIMARY KEY, GENERATED ALWAYS AS IDENTITY | Unique disease identifier | 1, 2, 3... |
| disease_name | VARCHAR2(100) | NOT NULL, UNIQUE | Name of the disease | 'Late Blight', 'Rust' |
| disease_category | VARCHAR2(50) | CHECK (disease_category IN ('FUNGAL','BACTERIAL','VIRAL','PEST','NUTRITIONAL','ENVIRONMENTAL')) | Type/category of disease | 'FUNGAL' |
| symptoms | VARCHAR2(1000) | | Common symptoms to identify | 'Dark brown lesions on leaves' |
| severity_level | VARCHAR2(20) | DEFAULT 'MEDIUM', CHECK (severity_level IN ('LOW','MEDIUM','HIGH','CRITICAL')) | General severity level | 'CRITICAL' |
| description | CLOB | | Detailed information about disease | 'Devastating fungal disease...' |

**Indexes:**
- PRIMARY KEY on disease_id
- UNIQUE on disease_name

**Foreign Key References:**
- Referenced by: DISEASE_CASES (disease_id), DISEASE_TREATMENTS (disease_id)

**Sample Data:**
```sql
disease_id: 1
disease_name: 'Late Blight'
disease_category: 'FUNGAL'
symptoms: 'Dark brown lesions on leaves, white mold on underside, rapid spread'
severity_level: 'CRITICAL'
description: 'Devastating fungal disease affecting potatoes and tomatoes'
```

---

## 6. DISEASE_CASES
**Purpose:** Records actual disease occurrences detected on crops

**Business Rules:**
- Each case must reference a valid planting and disease
- Detection date defaults to current date
- Severity can differ from disease's general severity
- Affected area must be 0-100%
- Status tracks progression: DETECTED → TREATING → TREATED → RESOLVED/FAILED
- **Trigger-protected:** INSERT/UPDATE/DELETE only allowed on weekends

| Column Name | Data Type | Constraints | Description | Example |
|------------|-----------|-------------|-------------|---------|
| case_id | NUMBER(10) | PRIMARY KEY, GENERATED ALWAYS AS IDENTITY | Unique case identifier | 1, 2, 3... |
| planting_id | NUMBER(10) | FOREIGN KEY → CROP_PLANTINGS(planting_id), NOT NULL | Affected crop planting | 1 |
| disease_id | NUMBER(10) | FOREIGN KEY → DISEASES(disease_id), NOT NULL | Type of disease detected | 1 |
| detection_date | DATE | DEFAULT SYSDATE, NOT NULL | Date disease was detected | 05-DEC-2025 |
| severity | VARCHAR2(20) | CHECK (severity IN ('LOW','MEDIUM','HIGH','CRITICAL')) | Severity of this specific case | 'HIGH' |
| affected_area_percentage | NUMBER(5,2) | CHECK (affected_area_percentage BETWEEN 0 AND 100) | Percentage of crop affected | 45.50 |
| status | VARCHAR2(20) | DEFAULT 'DETECTED', CHECK (status IN ('DETECTED','TREATING','TREATED','RESOLVED','FAILED')) | Current case status | 'DETECTED' |
| notes | VARCHAR2(1000) | | Additional observations/notes | 'Rapid spread observed' |

**Indexes:**
- PRIMARY KEY on case_id
- FOREIGN KEY on planting_id
- FOREIGN KEY on disease_id

**Foreign Key References:**
- References: CROP_PLANTINGS (planting_id), DISEASES (disease_id)
- Referenced by: TREATMENT_APPLICATIONS (case_id)

**Triggers:**
- trg_disease_cases_insert (BEFORE INSERT)
- trg_disease_cases_update (BEFORE UPDATE)
- trg_disease_cases_delete (BEFORE DELETE)

**Sample Data:**
```sql
case_id: 5
planting_id: 1
disease_id: 1
detection_date: 05-DEC-2025
severity: 'HIGH'
affected_area_percentage: 45.50
status: 'DETECTED'
notes: 'Detected during routine inspection'
```

---

## 7. TREATMENTS
**Purpose:** Master data catalog of treatment protocols

**Business Rules:**
- Treatment names must be unique
- Duration must be positive
- Cost estimate helps in planning
- This is a reference/lookup table

| Column Name | Data Type | Constraints | Description | Example |
|------------|-----------|-------------|-------------|---------|
| treatment_id | NUMBER(10) | PRIMARY KEY, GENERATED ALWAYS AS IDENTITY | Unique treatment identifier | 1, 2, 3... |
| treatment_name | VARCHAR2(100) | NOT NULL, UNIQUE | Name of treatment protocol | 'Fungicide Spray - Mancozeb' |
| treatment_type | VARCHAR2(50) | CHECK (treatment_type IN ('CHEMICAL','ORGANIC','MECHANICAL','BIOLOGICAL','CULTURAL')) | Type of treatment approach | 'CHEMICAL' |
| application_method | VARCHAR2(100) | | How to apply the treatment | 'Foliar spray' |
| duration_days | NUMBER(3) | CHECK (duration_days > 0) | Treatment duration in days | 7 |
| cost_estimate | NUMBER(10,2) | CHECK (cost_estimate >= 0) | Estimated cost per application (RWF) | 15000.00 |
| description | VARCHAR2(1000) | | Detailed treatment information | 'Broad-spectrum fungicide' |

**Indexes:**
- PRIMARY KEY on treatment_id
- UNIQUE on treatment_name

**Foreign Key References:**
- Referenced by: DISEASE_TREATMENTS (treatment_id), TREATMENT_APPLICATIONS (treatment_id)

**Sample Data:**
```sql
treatment_id: 1
treatment_name: 'Fungicide Spray - Mancozeb'
treatment_type: 'CHEMICAL'
application_method: 'Foliar spray'
duration_days: 7
cost_estimate: 15000.00
description: 'Broad-spectrum fungicide for late blight, early blight'
```

---

## 8. DISEASE_TREATMENTS
**Purpose:** Junction table mapping diseases to their recommended treatments (M:M relationship)

**Business Rules:**
- Links diseases to appropriate treatment options
- One disease can have multiple treatment options
- One treatment can address multiple diseases
- Effectiveness rate must be 0-100%
- Priority indicates treatment preference (1=highest)
- Unique constraint prevents duplicate mappings

| Column Name | Data Type | Constraints | Description | Example |
|------------|-----------|-------------|-------------|---------|
| disease_treatment_id | NUMBER(10) | PRIMARY KEY, GENERATED ALWAYS AS IDENTITY | Unique mapping identifier | 1, 2, 3... |
| disease_id | NUMBER(10) | FOREIGN KEY → DISEASES(disease_id), NOT NULL | Disease being treated | 1 |
| treatment_id | NUMBER(10) | FOREIGN KEY → TREATMENTS(treatment_id), NOT NULL | Recommended treatment | 1 |
| effectiveness_rate | NUMBER(5,2) | CHECK (effectiveness_rate BETWEEN 0 AND 100) | Success rate percentage | 85.00 |
| recommended_dosage | VARCHAR2(200) | | Suggested dosage/application rate | '2.5 kg per hectare' |
| priority | NUMBER(1) | DEFAULT 1, CHECK (priority BETWEEN 1 AND 5) | Treatment priority (1=highest) | 1 |
| | | UNIQUE (disease_id, treatment_id) | Prevent duplicate mappings | |

**Indexes:**
- PRIMARY KEY on disease_treatment_id
- FOREIGN KEY on disease_id
- FOREIGN KEY on treatment_id
- UNIQUE on (disease_id, treatment_id)

**Foreign Key References:**
- References: DISEASES (disease_id), TREATMENTS (treatment_id)

**Sample Data:**
```sql
disease_treatment_id: 1
disease_id: 1 (Late Blight)
treatment_id: 1 (Mancozeb)
effectiveness_rate: 85.00
recommended_dosage: '2.5 kg per hectare'
priority: 1
```

---

## 9. CHEMICALS
**Purpose:** Inventory management for agricultural chemicals

**Business Rules:**
- Chemical names must be unique
- Stock quantity must be non-negative
- Reorder level triggers low stock alerts
- Status automatically updated based on stock level
- Expiry date tracking for compliance

| Column Name | Data Type | Constraints | Description | Example |
|------------|-----------|-------------|-------------|---------|
| chemical_id | NUMBER(10) | PRIMARY KEY, GENERATED ALWAYS AS IDENTITY | Unique chemical identifier | 1, 2, 3... |
| chemical_name | VARCHAR2(100) | NOT NULL, UNIQUE | Commercial name of chemical | 'Mancozeb 80% WP' |
| chemical_type | VARCHAR2(50) | CHECK (chemical_type IN ('PESTICIDE','FUNGICIDE','HERBICIDE','FERTILIZER','GROWTH_REGULATOR')) | Type of chemical | 'FUNGICIDE' |
| manufacturer | VARCHAR2(100) | | Manufacturer name | 'Bayer CropScience' |
| unit_of_measure | VARCHAR2(20) | DEFAULT 'LITERS' | Unit of measurement | 'KILOGRAMS', 'LITERS' |
| quantity_in_stock | NUMBER(10,2) | DEFAULT 0, CHECK (quantity_in_stock >= 0) | Current stock level | 150.00 |
| reorder_level | NUMBER(10,2) | DEFAULT 10, CHECK (reorder_level >= 0) | Minimum stock before reorder | 30.00 |
| unit_cost | NUMBER(10,2) | CHECK (unit_cost >= 0) | Cost per unit (RWF) | 8500.00 |
| expiry_date | DATE | | Expiration date | 30-JUN-2026 |
| status | VARCHAR2(20) | DEFAULT 'AVAILABLE', CHECK (status IN ('AVAILABLE','LOW_STOCK','OUT_OF_STOCK','EXPIRED')) | Current inventory status | 'AVAILABLE' |

**Indexes:**
- PRIMARY KEY on chemical_id
- UNIQUE on chemical_name

**Foreign Key References:**
- Referenced by: CHEMICAL_USAGE (chemical_id)

**Triggers:**
- trg_chemicals_compound (COMPOUND TRIGGER for all DML operations)

**Sample Data:**
```sql
chemical_id: 1
chemical_name: 'Mancozeb 80% WP'
chemical_type: 'FUNGICIDE'
manufacturer: 'Bayer CropScience'
unit_of_measure: 'KILOGRAMS'
quantity_in_stock: 150.00
reorder_level: 30.00
unit_cost: 8500.00
expiry_date: 30-JUN-2026
status: 'AVAILABLE'
```

---

## 10. STAFF
**Purpose:** Farm workers and personnel information

**Business Rules:**
- Staff members can have different roles
- Hire date defaults to current date
- Default status is ACTIVE
- Staff can perform multiple treatment applications

| Column Name | Data Type | Constraints | Description | Example |
|------------|-----------|-------------|-------------|---------|
| staff_id | NUMBER(10) | PRIMARY KEY, GENERATED ALWAYS AS IDENTITY | Unique staff identifier | 1, 2, 3... |
| staff_name | VARCHAR2(100) | NOT NULL | Full name of staff member | 'John MUGISHA' |
| role | VARCHAR2(50) | CHECK (role IN ('FARM_WORKER','SUPERVISOR','TECHNICIAN','MANAGER','AGRONOMIST')) | Job role/position | 'TECHNICIAN' |
| phone_number | VARCHAR2(15) | | Contact number | '0788111111' |
| hire_date | DATE | DEFAULT SYSDATE | Date hired | 01-JAN-2025 |
| status | VARCHAR2(20) | DEFAULT 'ACTIVE', CHECK (status IN ('ACTIVE','ON_LEAVE','TERMINATED')) | Employment status | 'ACTIVE' |

**Indexes:**
- PRIMARY KEY on staff_id

**Foreign Key References:**
- Referenced by: TREATMENT_APPLICATIONS (staff_id)

**Sample Data:**
```sql
staff_id: 1
staff_name: 'John MUGISHA'
role: 'TECHNICIAN'
phone_number: '0788111111'
hire_date: 01-JAN-2025
status: 'ACTIVE'
```

---

## 11. TREATMENT_APPLICATIONS
**Purpose:** Records actual treatment applications performed (main transaction table)

**Business Rules:**
- Must reference valid case, treatment, and staff
- Application date defaults to current date
- Area treated must be positive
- Cost must be non-negative
- **Trigger-protected:** INSERT only allowed on weekends

| Column Name | Data Type | Constraints | Description | Example |
|------------|-----------|-------------|-------------|---------|
| application_id | NUMBER(10) | PRIMARY KEY, GENERATED ALWAYS AS IDENTITY | Unique application identifier | 1, 2, 3... |
| case_id | NUMBER(10) | FOREIGN KEY → DISEASE_CASES(case_id), NOT NULL | Disease case being treated | 5 |
| treatment_id | NUMBER(10) | FOREIGN KEY → TREATMENTS(treatment_id), NOT NULL | Treatment protocol used | 1 |
| staff_id | NUMBER(10) | FOREIGN KEY → STAFF(staff_id), NOT NULL | Staff who applied treatment | 1 |
| application_date | DATE | DEFAULT SYSDATE, NOT NULL | Date treatment was applied | 07-DEC-2025 |
| application_time | TIMESTAMP | DEFAULT SYSTIMESTAMP | Exact timestamp of application | 07-DEC-25 09:30:00 |
| area_treated_hectares | NUMBER(8,2) | CHECK (area_treated_hectares > 0) | Area covered (hectares) | 2.50 |
| weather_condition | VARCHAR2(50) | | Weather during application | 'Sunny', 'Cloudy' |
| application_status | VARCHAR2(20) | DEFAULT 'PENDING', CHECK (application_status IN ('PENDING','COMPLETED','FAILED','CANCELLED')) | Application status | 'COMPLETED' |
| notes | VARCHAR2(1000) | | Application notes/observations | 'Application successful' |
| cost | NUMBER(10,2) | CHECK (cost >= 0) | Total cost of application (RWF) | 37500.00 |

**Indexes:**
- PRIMARY KEY on application_id
- FOREIGN KEY on case_id
- FOREIGN KEY on treatment_id
- FOREIGN KEY on staff_id

**Foreign Key References:**
- References: DISEASE_CASES (case_id), TREATMENTS (treatment_id), STAFF (staff_id)
- Referenced by: CHEMICAL_USAGE (application_id)

**Triggers:**
- trg_treatment_app_insert (BEFORE INSERT)

**Sample Data:**
```sql
application_id: 1
case_id: 5
treatment_id: 1
staff_id: 1
application_date: 07-DEC-2025
application_time: 07-DEC-25 09:30:00
area_treated_hectares: 2.50
weather_condition: 'Sunny'
application_status: 'COMPLETED'
notes: 'Treatment applied successfully'
cost: 37500.00
```

---

## 12. CHEMICAL_USAGE
**Purpose:** Junction table tracking chemicals used in treatment applications (M:M relationship)

**Business Rules:**
- Links treatment applications to chemicals used
- One application can use multiple chemicals
- One chemical can be used in multiple applications
- Quantity used must be positive
- Automatically reduces chemical inventory

| Column Name | Data Type | Constraints | Description | Example |
|------------|-----------|-------------|-------------|---------|
| usage_id | NUMBER(10) | PRIMARY KEY, GENERATED ALWAYS AS IDENTITY | Unique usage record identifier | 1, 2, 3... |
| application_id | NUMBER(10) | FOREIGN KEY → TREATMENT_APPLICATIONS(application_id), NOT NULL | Treatment application | 1 |
| chemical_id | NUMBER(10) | FOREIGN KEY → CHEMICALS(chemical_id), NOT NULL | Chemical used | 1 |
| quantity_used | NUMBER(10,2) | CHECK (quantity_used > 0), NOT NULL | Amount used | 2.50 |
| unit_of_measure | VARCHAR2(20) | NOT NULL | Unit of measurement | 'KILOGRAMS' |
| application_method | VARCHAR2(100) | | How chemical was applied | 'Foliar spray' |

**Indexes:**
- PRIMARY KEY on usage_id
- FOREIGN KEY on application_id
- FOREIGN KEY on chemical_id

**Foreign Key References:**
- References: TREATMENT_APPLICATIONS (application_id), CHEMICALS (chemical_id)

**Sample Data:**
```sql
usage_id: 1
application_id: 1
chemical_id: 1
quantity_used: 2.50
unit_of_measure: 'KILOGRAMS'
application_method: 'Foliar spray'
```

---

## 13. AUDIT_LOG
**Purpose:** Comprehensive audit trail for all database operations

**Business Rules:**
- All INSERT/UPDATE/DELETE operations are logged
- Autonomous transaction ensures logging even if main transaction fails
- User and session information captured
- Success/denial status tracked
- Cannot be modified or deleted (audit integrity)

| Column Name | Data Type | Constraints | Description | Example |
|------------|-----------|-------------|-------------|---------|
| audit_id | NUMBER(10) | PRIMARY KEY, GENERATED ALWAYS AS IDENTITY | Unique audit record identifier | 1, 2, 3... |
| table_name | VARCHAR2(50) | NOT NULL | Table where operation occurred | 'DISEASE_CASES' |
| operation_type | VARCHAR2(20) | CHECK (operation_type IN ('INSERT','UPDATE','DELETE')) | Type of operation | 'INSERT' |
| record_id | NUMBER(10) | | ID of affected record | 5 |
| old_value | CLOB | | Previous data (UPDATE/DELETE) | 'Status: DETECTED' |
| new_value | CLOB | | New data (INSERT/UPDATE) | 'Status: RESOLVED' |
| changed_by | VARCHAR2(100) | NOT NULL | User who made change | 'SONIA' |
| change_date | TIMESTAMP | DEFAULT SYSTIMESTAMP, NOT NULL | When change occurred | 07-DEC-25 09:48:27 |
| ip_address | VARCHAR2(50) | | IP address of user session | '192.168.1.100' |
| session_user | VARCHAR2(100) | | Oracle session user | 'SONIA' |
| osuser | VARCHAR2(100) | | Operating system user | 'sonia' |
| machine | VARCHAR2(100) | | Machine/hostname | 'LAPTOP-ABC123' |
| operation_status | VARCHAR2(20) | DEFAULT 'SUCCESS', CHECK (operation_status IN ('SUCCESS','DENIED','ERROR')) | Operation result | 'SUCCESS' |
| denial_reason | VARCHAR2(500) | | Reason if operation denied | 'DENIED: Operation not allowed on weekdays' |

**Indexes:**
- PRIMARY KEY on audit_id
- INDEX on table_name
- INDEX on change_date
- INDEX on changed_by

**Foreign Key References:**
- None (independent audit table)

**Sample Data:**
```sql
audit_id: 1
table_name: 'DISEASE_CASES'
operation_type: 'INSERT'
record_id: 341
old_value: NULL
new_value: 'Planting: 1, Disease: 1'
changed_by: 'SONIA'
change_date: 07-DEC-25 09:48:26
ip_address: NULL
session_user: 'SONIA'
osuser: 'sonia'
machine: 'LAPTOP-ABC123'
operation_status: 'SUCCESS'
denial_reason: NULL
```

---

## 14. PUBLIC_HOLIDAYS
**Purpose:** Calendar of public holidays for business rule enforcement

**Business Rules:**
- Holiday dates must be unique
- Used by triggers to block operations on holidays
- Supports upcoming months only (rolling window)
- Admin-maintained reference table

| Column Name | Data Type | Constraints | Description | Example |
|------------|-----------|-------------|-------------|---------|
| holiday_id | NUMBER(10) | PRIMARY KEY, GENERATED ALWAYS AS IDENTITY | Unique holiday identifier | 1, 2, 3... |
| holiday_date | DATE | NOT NULL, UNIQUE | Date of the holiday | 25-DEC-2025 |
| holiday_name | VARCHAR2(100) | NOT NULL | Name of the holiday | 'Christmas Day' |
| description | VARCHAR2(500) | | Additional information | 'Christian holiday' |
| created_date | DATE | DEFAULT SYSDATE | Date record was created | 07-DEC-2025 |

**Indexes:**
- PRIMARY KEY on holiday_id
- UNIQUE on holiday_date

**Foreign Key References:**
- None (independent reference table)

**Sample Data:**
```sql
holiday_id: 1
holiday_date: 25-DEC-2025
holiday_name: 'Christmas Day'
description: 'Christian holiday'
created_date: 07-DEC-2025
```

---

## Database Statistics

| Table Name | Row Count | Primary Key | Foreign Keys | Indexes |
|-----------|-----------|-------------|--------------|---------|
| FARMERS | 100 | ✓ | 0 | 3 |
| FIELDS | 200 | ✓ | 1 | 2 |
| CROPS | 30 | ✓ | 0 | 2 |
| CROP_PLANTINGS | 400 | ✓ | 2 | 3 |
| DISEASES | 40 | ✓ | 0 | 2 |
| DISEASE_CASES | 300+ | ✓ | 2 | 3 |
| TREATMENTS | 35 | ✓ | 0 | 2 |
| DISEASE_TREATMENTS | 80+ | ✓ | 2 | 4 |
| CHEMICALS | 50 | ✓ | 0 | 2 |
| STAFF | 40 | ✓ | 0 | 1 |
| TREATMENT_APPLICATIONS | 400+ | ✓ | 3 | 4 |
| CHEMICAL_USAGE | 500+ | ✓ | 2 | 3 |
| AUDIT_LOG | Dynamic | ✓ | 0 | 4 |
| PUBLIC_HOLIDAYS | 7 | ✓ | 0 | 2 |
| **TOTAL** | **2200+** | **14** | **14** | **40** |

---

## Relationships Summary

### One-to-Many Relationships
1. FARMERS (1) → FIELDS (M)
2. FIELDS (1) → CROP_PLANTINGS (M)
3. CROPS (1) → CROP_PLANTINGS (M)
4. CROP_PLANTINGS (1) → DISEASE_CASES (M)
5. DISEASES (1) → DISEASE_CASES (M)
6. TREATMENTS (1) → TREATMENT_APPLICATIONS (M)
7. DISEASE_CASES (1) → TREATMENT_APPLICATIONS (M)
8. STAFF (1) → TREATMENT_APPLICATIONS (M)

### Many-to-Many Relationships (via Junction Tables)
1. DISEASES (M) ↔ TREATMENTS (M) via DISEASE_TREATMENTS
2. TREATMENT_APPLICATIONS (M) ↔ CHEMICALS (M) via CHEMICAL_USAGE

---

## Naming Conventions

### Tables
- UPPERCASE
- Plural form (FARMERS, CROPS)
- Descriptive names (TREATMENT_APPLICATIONS)

### Columns
- lowercase_with_underscores
- Descriptive names (affected_area_percentage)
- ID suffix