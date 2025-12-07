# AgriGuard+ Database Design Assumptions
**Student:** Sonia Ineza (27852) | **Group:** Monday  
**Project:** AgriGuard+ Smart Agricultural Management System  
**Date:** November 2025

---

## 1. BUSINESS ASSUMPTIONS

### 1.1 Farm Management
- A single farmer can own multiple fields
- Fields are treated as separate operational units
- Each field can have multiple crop plantings over time (crop rotation)
- Multiple crops can be planted in the same field in different seasons

### 1.2 Disease Management
- A single crop planting can be affected by multiple diseases simultaneously
- Each disease case is tracked separately even if the same disease appears multiple times
- Disease severity can change over time (tracked through status updates)
- Historical disease data is retained for analysis and pattern recognition

### 1.3 Treatment Process
- A disease case can receive multiple treatment applications
- Each treatment application is performed by one staff member
- Treatments can use multiple chemicals in combination
- Treatment effectiveness varies by disease type and severity

### 1.4 Inventory Management
- Chemical inventory is centralized (not per-field)
- Stock levels are automatically reduced after treatment applications
- System alerts when stock falls below reorder level
- Expired chemicals are flagged but retained for audit purposes

---

## 2. DATA ASSUMPTIONS

### 2.1 Data Quality
- Farmer phone numbers and emails are optional but encouraged
- GPS coordinates for fields are optional (many small farms lack GPS)
- Weather conditions during treatment are recorded when available
- All monetary values are in Rwandan Francs (RWF)

### 2.2 Date/Time Handling
- All dates use Oracle DATE datatype (format: DD-MON-YYYY)
- Treatment application times use TIMESTAMP for precision
- Expected harvest dates are calculated based on crop growth period
- System uses SYSDATE/SYSTIMESTAMP for automatic timestamping

### 2.3 Measurement Units
- Field sizes measured in hectares
- Chemical quantities in liters or kilograms (specified per chemical)
- Crop quantities in kilograms
- Treatment areas in hectares
- Percentages stored as decimals (0-100 scale)

---

## 3. TECHNICAL ASSUMPTIONS

### 3.1 Normalization Approach
- Database designed to **3rd Normal Form (3NF)** minimum
- Junction tables (DISEASE_TREATMENTS, CHEMICAL_USAGE) resolve many-to-many relationships
- No repeating groups in any table
- No partial or transitive dependencies
- Controlled redundancy only for audit trail purposes

### 3.2 Primary Keys
- All primary keys use NUMBER(10) datatype
- Primary keys are system-generated (sequences recommended)
- Natural keys (like farmer names) not used as primary keys due to potential duplicates
- Composite keys avoided in favor of surrogate keys for simplicity

### 3.3 Foreign Keys
- All foreign key relationships enforced at database level
- Cascading deletes NOT used to preserve data integrity
- Soft deletes preferred (status = 'INACTIVE') over hard deletes
- Referential integrity maintained through constraints

### 3.4 Data Integrity
- CHECK constraints enforce valid values (status, severity, categories)
- NOT NULL constraints on critical fields only
- UNIQUE constraints on business-critical fields (email, chemical_name, etc.)
- DEFAULT values provided for common fields (dates, status)

---

## 4. SECURITY ASSUMPTIONS

### 4.1 Access Control
- Admin user (sonia) has full database access
- Application users will have role-based access (implemented in Phase VII)
- Sensitive operations (DELETE, UPDATE) tracked in audit log
- IP addresses recorded for accountability

### 4.2 Audit Trail
- ALL insert, update, delete operations logged in AUDIT_LOG table
- Old and new values stored as CLOB (JSON format recommended)
- Audit records NEVER deleted
- Audit log reviewed for compliance and troubleshooting

---

## 5. BUSINESS RULES ASSUMPTIONS

### 5.1 Treatment Restrictions
- Treatments can only be applied on weekends (enforced via triggers in Phase VII)
- Treatments blocked on public holidays (enforced via triggers)
- This simulates real-world labor availability constraints
- Emergency override mechanism planned for critical situations

### 5.2 Inventory Rules
- Treatment applications automatically deduct chemicals from inventory
- Applications blocked if insufficient chemical stock
- Low stock alerts generated when quantity < reorder_level
- Expired chemicals cannot be used in new applications

### 5.3 Workflow Rules
- Disease cases must be detected before treatments applied
- Treatment applications link to specific disease cases
- Crop plantings must exist before disease cases can be recorded
- Fields must be assigned to farmers before crop plantings

---

## 6. SCALABILITY ASSUMPTIONS

### 6.1 Volume Estimates
- Expected 100-500 farmers initially
- 500-2000 fields total
- 1000-5000 crop plantings per season
- 500-2000 disease cases per season
- 1000-10000 treatment applications per year
- 50-200 chemical SKUs in inventory
- 20-100 staff members

### 6.2 Growth Planning
- Database designed to handle 10x growth without restructuring
- Indexes planned on foreign keys and frequently queried fields
- Partitioning considered for AUDIT_LOG table (future phase)
- Archive strategy planned for historical data beyond 5 years

---

## 7. INTEGRATION ASSUMPTIONS

### 7.1 External Systems
- Mobile app interface planned for farmers (future phase)
- SMS alerts for low stock and treatment reminders (future integration)
- Weather API integration possible via external table (future)
- Government reporting module planned (Phase VIII BI)

### 7.2 Data Import/Export
- Bulk data import supported via SQL*Loader or PL/SQL procedures
- CSV export capability for reporting
- API-ready structure for third-party integrations
- Backup and recovery procedures follow Oracle best practices

---

## 8. REPORTING & BI ASSUMPTIONS

### 8.1 Analytics Requirements
- Disease trend analysis requires at least 6 months of historical data
- Treatment effectiveness calculated as (resolved cases / total cases) * 100
- Chemical consumption forecasting based on historical usage patterns
- Yield predictions require complete planting-to-harvest cycle data

### 8.2 Dashboard Requirements
- Real-time inventory status dashboard
- Disease outbreak early warning system (3+ cases same disease within 7 days)
- Treatment compliance tracking (applications vs. recommended schedules)
- Cost analysis (chemical usage vs. budget)
- Performance metrics (staff productivity, field productivity)

---

## 9. LIMITATIONS & FUTURE ENHANCEMENTS

### 9.1 Current Limitations
- No multi-language support (English only initially)
- No mobile-optimized interface (Phase I focuses on database)
- Weather data manual entry (future API integration planned)
- Single currency support (RWF only)

### 9.2 Planned Enhancements
- **Phase VI+:** Advanced PL/SQL packages for automated recommendations
- **Phase VII:** Comprehensive trigger-based business rules
- **Phase VIII:** Full BI dashboard implementation
- **Post-Project:** Mobile app, IoT sensor integration, ML-based predictions

---

## 10. COMPLIANCE & STANDARDS

### 10.1 Naming Conventions
- Table names: UPPERCASE, plural form (FARMERS, CROPS)
- Column names: lowercase_with_underscores
- Primary keys: tablename_id format (farmer_id, crop_id)
- Foreign keys: same name as referenced primary key
- Indexes: idx_tablename_columnname format

### 10.2 Database Standards
- Oracle 21c Express Edition
- SQL standards compliance (ANSI SQL where possible)
- PL/SQL for all business logic
- Stored procedures preferred over application-level logic
- Transaction management using COMMIT/ROLLBACK explicitly

---

## 11. JUSTIFICATION FOR KEY DESIGN DECISIONS

### 11.1 Why Junction Tables?
**DISEASE_TREATMENTS** and **CHEMICAL_USAGE** implement many-to-many relationships:
- A disease can have multiple treatment options
- A treatment can address multiple diseases
- A treatment application can use multiple chemicals
- A chemical can be used in multiple applications

**Alternative considered:** Storing comma-separated values
**Rejected because:** Violates 1NF, makes queries complex, breaks referential integrity

### 11.2 Why Separate CROP_PLANTINGS from CROPS?
**CROPS** is master data (crop types: Maize, Beans)
**CROP_PLANTINGS** is transactional data (Maize planted in Field 5 on Jan 1, 2025)

**Reasoning:** Enables tracking multiple plantings of same crop over time and seasons

### 11.3 Why CLOB for Audit Log Values?
- Flexible storage for any data type
- Can store complex JSON structures
- Future-proof for schema changes
- Supports unlimited text length

### 11.4 Why Soft Deletes (Status Fields)?
- Preserves historical data for analytics
- Enables "undo" operations
- Maintains audit trail completeness
- Complies with data retention policies

---

## CONCLUSION

This database design balances:
- **Normalization** (data integrity) vs. **Performance** (query efficiency)
- **Flexibility** (future changes) vs. **Simplicity** (maintainability)
- **Security** (audit trails) vs. **Usability** (ease of access)
- **Scalability** (growth) vs. **Current needs** (Phase I requirements)

The design is production-ready, follows Oracle best practices, and meets all Phase III requirements for the INSY 8311 capstone project.

---

**Prepared by:** Sonia Mugisha (27852)  
**Reviewed:** November 2025  
**Version:** 1.0