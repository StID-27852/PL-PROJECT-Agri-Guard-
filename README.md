# PL-PROJECT-Agri-Guard-
# PHASE VIII: FINAL DOCUMENTATION PACKAGE
### Student: Ineza Sonia (27852)
### Group: Monday
### Project: AgriGuard+ Smart Agricultural Management System

---

# AgriGuard+ Smart Agricultural Management System

**Student:** Ineza Sonia  
**Student ID:** 27852  
**Group:** Monday  
**Course:** Database Development with PL/SQL (INSY 8311)  
**Institution:** Adventist University of Central Africa (AUCA)  
**Submission Date:** December 7, 2025  
**Database:** mon_27852_sonia_AgriGuard_DB

---

## Project Overview

AgriGuard+ is a PL/SQL-powered agricultural disease management system designed to modernize farming operations in Rwanda by automating disease detection, treatment management, inventory control, and decision support through comprehensive data analytics.

### Problem Statement
Small-scale farmers in Rwanda face significant crop losses due to late disease detection, manual record-keeping errors, and lack of data-driven decision support. AgriGuard+ addresses these challenges by providing an automated, intelligent database system that tracks disease cases, manages treatments, monitors chemical inventory, and generates actionable insights.

### Key Objectives
- Automate disease case recording and treatment workflows
- Implement smart inventory management with automatic alerts
- Track complete crop lifecycle from planting to harvest
- Provide comprehensive audit trails for all farm operations
- Enable data-driven decision making through BI analytics
- Enforce business rules (weekend/holiday operation restrictions)

---

## Database Architecture

### Database Information
- **PDB Name:** mon_27852_sonia_AgriGuard_DB
- **Admin User:** sonia
- **Oracle Version:** 21c Express Edition
- **Normalization Level:** 3NF (Third Normal Form)

### Entity Summary (13 Tables)
1. **FARMERS** - Farm owners and operators (100 records)
2. **FIELDS** - Agricultural plots/sections (200 records)
3. **CROPS** - Crop type master data (30 records)
4. **CROP_PLANTINGS** - Planting instances (400 records)
5. **DISEASES** - Disease catalog (40 records)
6. **DISEASE_CASES** - Disease occurrences (300+ records)
7. **TREATMENTS** - Treatment protocols (35 records)
8. **DISEASE_TREATMENTS** - Disease-treatment mapping (80+ records)
9. **CHEMICALS** - Inventory management (50 records)
10. **STAFF** - Farm workers (40 records)
11. **TREATMENT_APPLICATIONS** - Treatment execution (400+ records)
12. **CHEMICAL_USAGE** - Chemical consumption tracking (500+ records)
13. **AUDIT_LOG** - Complete audit trail (all operations logged)
14. **PUBLIC_HOLIDAYS** - Holiday calendar (7 holidays)

---

## Quick Start Guide

### Prerequisites
- Oracle Database 21c Express Edition
- SQL Developer or SQL*Plus
- Oracle instant client (for remote connections)

### Installation Steps

1. **Clone the Repository**
```bash
git clone https://github.com/yourusername/agriguard-plus.git
cd agriguard-plus
```

2. **Connect to Oracle**
```sql
sqlplus sys as sysdba
-- Enter your password
```

3. **Create the Pluggable Database**
```sql
@database/scripts/01_create_database.sql
```

4. **Create Tables**
```sql
CONNECT sonia/Sonia@mon_27852_sonia_AgriGuard_DB
@database/scripts/02_create_tables.sql
```

5. **Insert Test Data**
```sql
@database/scripts/03_insert_data.sql
```

6. **Create PL/SQL Objects**
```sql
@database/scripts/04_create_procedures.sql
@database/scripts/05_create_functions.sql
@database/scripts/06_create_packages.sql
```

7. **Create Triggers**
```sql
@database/scripts/07_create_triggers.sql
```

8. **Run Tests**
```sql
@database/scripts/08_run_tests.sql
```

---

## Project Structure
````
agriguard-plus/
├── README.md (this file)
├── database/
│   ├── scripts/
│   │   ├── 01_create_database.sql
│   │   ├── 02_create_tables.sql
│   │   ├── 03_insert_data.sql
│   │   ├── 04_create_procedures.sql
│   │   ├── 05_create_functions.sql
│   │   ├── 06_create_packages.sql
│   │   ├── 07_create_triggers.sql
│   │   └── 08_run_tests.sql
│   └── documentation/
│       ├── data_dictionary.md
│       ├── ER_diagram.png
│       └── assumptions.md
├── queries/
│   ├── data_retrieval.sql
│   ├── analytics_queries.sql
│   └── audit_queries.sql
├── business_intelligence/
│   ├── bi_requirements.md
│   ├── dashboards.md
│   └── kpi_definitions.md
├── screenshots/
│   ├── database_objects/
│   ├── test_results/
│   └── audit_logs/
└── presentation/
    └── mon_27852_sonia_AgriGuard_Presentation.pptx
