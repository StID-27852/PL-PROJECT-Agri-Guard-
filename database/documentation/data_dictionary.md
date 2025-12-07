# AgriGuard+ Data Dictionary
**Student:** Sonia Ineza (27852) | **Group:** Monday  
**Project:** AgriGuard + Smart Agricultural Management System  
**Date:** November 2025

---

## 1. FARMERS
**Purpose:** Stores farmer/farm owner information

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| farmer_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique farmer identifier |
| farmer_name | VARCHAR2(100) | NOT NULL | Full name of farmer |
| phone_number | VARCHAR2(15) | UNIQUE | Contact phone number |
| email | VARCHAR2(100) | UNIQUE | Email address |
| location | VARCHAR2(200) | | Physical address/location |
| registration_date | DATE | DEFAULT SYSDATE | Date farmer registered |
| status | VARCHAR2(20) | DEFAULT 'ACTIVE', CHECK (status IN ('ACTIVE', 'INACTIVE')) | Account status |

---

## 2. FIELDS
**Purpose:** Stores information about farm fields/plots

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| field_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique field identifier |
| farmer_id | NUMBER(10) | FOREIGN KEY → FARMERS(farmer_id), NOT NULL | Owner of the field |
| field_name | VARCHAR2(100) | NOT NULL | Name/identifier of field |
| size_hectares | NUMBER(8,2) | NOT NULL, CHECK (size_hectares > 0) | Size of field in hectares |
| soil_type | VARCHAR2(50) | | Type of soil (clay, loam, sandy, etc.) |
| location_gps | VARCHAR2(100) | | GPS coordinates if available |
| status | VARCHAR2(20) | DEFAULT 'ACTIVE', CHECK (status IN ('ACTIVE', 'FALLOW', 'INACTIVE')) | Current field status |

---

## 3. CROPS
**Purpose:** Master data for crop types

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| crop_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique crop type identifier |
| crop_name | VARCHAR2(100) | NOT NULL, UNIQUE | Name of crop (Maize, Beans, etc.) |
| crop_type | VARCHAR2(50) | CHECK (crop_type IN ('CEREAL', 'VEGETABLE', 'FRUIT', 'LEGUME', 'ROOT', 'OTHER')) | Category of crop |
| growth_period_days | NUMBER(4) | NOT NULL, CHECK (growth_period_days > 0) | Average days from planting to harvest |
| description | VARCHAR2(500) | | Additional information about crop |

---

## 4. CROP_PLANTINGS
**Purpose:** Records specific crop planting instances

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| planting_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique planting identifier |
| field_id | NUMBER(10) | FOREIGN KEY → FIELDS(field_id), NOT NULL | Field where crop is planted |
| crop_id | NUMBER(10) | FOREIGN KEY → CROPS(crop_id), NOT NULL | Type of crop planted |
| planting_date | DATE | NOT NULL | Date crop was planted |
| expected_harvest_date | DATE | | Calculated/estimated harvest date |
| actual_harvest_date | DATE | | Actual date of harvest |
| quantity_planted | NUMBER(10,2) | CHECK (quantity_planted >= 0) | Amount planted (kg/seeds) |
| quantity_harvested | NUMBER(10,2) | CHECK (quantity_harvested >= 0) | Amount harvested (kg) |
| status | VARCHAR2(20) | DEFAULT 'GROWING', CHECK (status IN ('GROWING', 'HARVESTED', 'FAILED', 'ABANDONED')) | Current planting status |

---

## 5. DISEASES
**Purpose:** Master data for disease types

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| disease_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique disease identifier |
| disease_name | VARCHAR2(100) | NOT NULL, UNIQUE | Name of disease (Blight, Rust, etc.) |
| disease_category | VARCHAR2(50) | CHECK (disease_category IN ('FUNGAL', 'BACTERIAL', 'VIRAL', 'PEST', 'NUTRITIONAL', 'ENVIRONMENTAL')) | Type of disease |
| symptoms | VARCHAR2(1000) | | Common symptoms to look for |
| severity_level | VARCHAR2(20) | DEFAULT 'MEDIUM', CHECK (severity_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')) | General severity level |
| description | CLOB | | Detailed information about disease |

---

## 6. DISEASE_CASES
**Purpose:** Records actual disease occurrences on crops

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| case_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique case identifier |
| planting_id | NUMBER(10) | FOREIGN KEY → CROP_PLANTINGS(planting_id), NOT NULL | Affected crop planting |
| disease_id | NUMBER(10) | FOREIGN KEY → DISEASES(disease_id), NOT NULL | Type of disease detected |
| detection_date | DATE | DEFAULT SYSDATE, NOT NULL | Date disease was detected |
| severity | VARCHAR2(20) | CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')) | Severity of this case |
| affected_area_percentage | NUMBER(5,2) | CHECK (affected_area_percentage BETWEEN 0 AND 100) | Percentage of crop affected |
| status | VARCHAR2(20) | DEFAULT 'DETECTED', CHECK (status IN ('DETECTED', 'TREATING', 'TREATED', 'RESOLVED', 'FAILED')) | Case status |
| notes | VARCHAR2(1000) | | Additional observations |

---

## 7. TREATMENTS
**Purpose:** Master data for treatment protocols

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| treatment_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique treatment identifier |
| treatment_name | VARCHAR2(100) | NOT NULL, UNIQUE | Name of treatment |
| treatment_type | VARCHAR2(50) | CHECK (treatment_type IN ('CHEMICAL', 'ORGANIC', 'MECHANICAL', 'BIOLOGICAL', 'CULTURAL')) | Type of treatment |
| application_method | VARCHAR2(100) | | How to apply (spray, drench, etc.) |
| duration_days | NUMBER(3) | CHECK (duration_days > 0) | Treatment duration |
| cost_estimate | NUMBER(10,2) | CHECK (cost_estimate >= 0) | Estimated cost per application |
| description | VARCHAR2(1000) | | Treatment details |

---

## 8. DISEASE_TREATMENTS
**Purpose:** Links diseases to their recommended treatments (M:M junction table)

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| disease_treatment_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique mapping identifier |
| disease_id | NUMBER(10) | FOREIGN KEY → DISEASES(disease_id), NOT NULL | Disease being treated |
| treatment_id | NUMBER(10) | FOREIGN KEY → TREATMENTS(treatment_id), NOT NULL | Recommended treatment |
| effectiveness_rate | NUMBER(5,2) | CHECK (effectiveness_rate BETWEEN 0 AND 100) | Success rate percentage |
| recommended_dosage | VARCHAR2(200) | | Suggested dosage/application rate |
| priority | NUMBER(1) | DEFAULT 1, CHECK (priority BETWEEN 1 AND 5) | Treatment priority (1=highest) |
| | | UNIQUE (disease_id, treatment_id) | Prevent duplicate mappings |

---

## 9. CHEMICALS
**Purpose:** Inventory of chemicals/pesticides

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| chemical_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique chemical identifier |
| chemical_name | VARCHAR2(100) | NOT NULL, UNIQUE | Commercial name of chemical |
| chemical_type | VARCHAR2(50) | CHECK (chemical_type IN ('PESTICIDE', 'FUNGICIDE', 'HERBICIDE', 'FERTILIZER', 'GROWTH_REGULATOR')) | Type of chemical |
| manufacturer | VARCHAR2(100) | | Manufacturer name |
| unit_of_measure | VARCHAR2(20) | DEFAULT 'LITERS' | Unit (liters, kg, etc.) |
| quantity_in_stock | NUMBER(10,2) | DEFAULT 0, CHECK (quantity_in_stock >= 0) | Current stock level |
| reorder_level | NUMBER(10,2) | DEFAULT 10, CHECK (reorder_level >= 0) | Minimum stock before reorder |
| unit_cost | NUMBER(10,2) | CHECK (unit_cost >= 0) | Cost per unit |
| expiry_date | DATE | | Expiration date |
| status | VARCHAR2(20) | DEFAULT 'AVAILABLE', CHECK (status IN ('AVAILABLE', 'LOW_STOCK', 'OUT_OF_STOCK', 'EXPIRED')) | Inventory status |

---

## 10. STAFF
**Purpose:** Farm workers and staff information

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| staff_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique staff identifier |
| staff_name | VARCHAR2(100) | NOT NULL | Full name of staff member |
| role | VARCHAR2(50) | CHECK (role IN ('FARM_WORKER', 'SUPERVISOR', 'TECHNICIAN', 'MANAGER', 'AGRONOMIST')) | Job role |
| phone_number | VARCHAR2(15) | | Contact number |
| hire_date | DATE | DEFAULT SYSDATE | Date hired |
| status | VARCHAR2(20) | DEFAULT 'ACTIVE', CHECK (status IN ('ACTIVE', 'ON_LEAVE', 'TERMINATED')) | Employment status |

---

## 11. TREATMENT_APPLICATIONS
**Purpose:** Records actual treatment applications (main transaction table)

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| application_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique application identifier |
| case_id | NUMBER(10) | FOREIGN KEY → DISEASE_CASES(case_id), NOT NULL | Disease case being treated |
| treatment_id | NUMBER(10) | FOREIGN KEY → TREATMENTS(treatment_id), NOT NULL | Treatment protocol used |
| staff_id | NUMBER(10) | FOREIGN KEY → STAFF(staff_id), NOT NULL | Staff who applied treatment |
| application_date | DATE | DEFAULT SYSDATE, NOT NULL | Date treatment was applied |
| application_time | TIMESTAMP | DEFAULT SYSTIMESTAMP | Exact time of application |
| area_treated_hectares | NUMBER(8,2) | CHECK (area_treated_hectares > 0) | Area covered |
| weather_condition | VARCHAR2(50) | | Weather during application |
| application_status | VARCHAR2(20) | DEFAULT 'PENDING', CHECK (application_status IN ('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED')) | Status |
| notes | VARCHAR2(1000) | | Application notes |
| cost | NUMBER(10,2) | CHECK (cost >= 0) | Total cost of application |

---

## 12. CHEMICAL_USAGE
**Purpose:** Links treatment applications to chemicals used (M:M junction table)

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| usage_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique usage record identifier |
| application_id | NUMBER(10) | FOREIGN KEY → TREATMENT_APPLICATIONS(application_id), NOT NULL | Treatment application |
| chemical_id | NUMBER(10) | FOREIGN KEY → CHEMICALS(chemical_id), NOT NULL | Chemical used |
| quantity_used | NUMBER(10,2) | NOT NULL, CHECK (quantity_used > 0) | Amount used |
| unit_of_measure | VARCHAR2(20) | NOT NULL | Unit (liters, kg, etc.) |
| application_method | VARCHAR2(100) | | How chemical was applied |

---

## 13. AUDIT_LOG
**Purpose:** Comprehensive audit trail for all database changes

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| audit_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique audit record identifier |
| table_name | VARCHAR2(50) | NOT NULL | Table where change occurred |
| operation_type | VARCHAR2(20) | CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')) | Type of operation |
| record_id | NUMBER(10) | | ID of affected record |
| old_value | CLOB | | Previous data (for UPDATE/DELETE) |
| new_value | CLOB | | New data (for INSERT/UPDATE) |
| changed_by | VARCHAR2(100) | NOT NULL | User who made change |
| change_date | TIMESTAMP | DEFAULT SYSTIMESTAMP, NOT NULL | When change occurred |
| ip_address | VARCHAR2(50) | | IP address of user |

---

## Business Intelligence Considerations

### Fact Tables (Transaction Data):
- **TREATMENT_APPLICATIONS** - Main fact table for analytics
- **CHEMICAL_USAGE** - Chemical consumption analysis
- **DISEASE_CASES** - Disease occurrence patterns

### Dimension Tables (Reference Data):
- **FARMERS** - Who dimension
- **FIELDS** - Where dimension
- **CROPS** - What dimension
- **DISEASES** - Problem dimension
- **TREATMENTS** - Solution dimension
- **CHEMICALS** - Resource dimension
- **STAFF** - Personnel dimension
- **TIME** - When dimension (derived from dates)

### Key Metrics (KPIs):
- Disease occurrence rate by crop/season
- Treatment effectiveness percentage
- Chemical consumption and cost
- Crop yield per field/farmer
- Response time (detection to treatment)
- Staff productivity
- Inventory turnover rate