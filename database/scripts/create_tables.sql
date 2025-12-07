-- ========================================
-- AGRIGUARD+ DATABASE - TABLE CREATION
-- Student: Sonia Mugisha (27852)
-- Group: Monday
-- Date: November 2025
-- ========================================

-- TABLE 1: FARMERS
CREATE TABLE FARMERS (
    farmer_id            NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    farmer_name          VARCHAR2(100) NOT NULL,
    phone_number         VARCHAR2(15) UNIQUE,
    email                VARCHAR2(100) UNIQUE,
    location             VARCHAR2(200),
    registration_date    DATE DEFAULT SYSDATE,
    status               VARCHAR2(20) DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

-- TABLE 2: FIELDS
CREATE TABLE FIELDS (
    field_id         NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    farmer_id        NUMBER(10) NOT NULL,
    field_name       VARCHAR2(100) NOT NULL,
    size_hectares    NUMBER(8,2) CHECK (size_hectares > 0),
    soil_type        VARCHAR2(50),
    location_gps     VARCHAR2(100),
    status           VARCHAR2(20) DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'FALLOW', 'INACTIVE')),
    
    CONSTRAINT fk_fields_farmer
        FOREIGN KEY (farmer_id) REFERENCES FARMERS(farmer_id)
);

-- TABLE 3: CROPS
CREATE TABLE CROPS (
    crop_id             NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    crop_name           VARCHAR2(100) NOT NULL UNIQUE,
    crop_type           VARCHAR2(50)
        CHECK (crop_type IN ('CEREAL','VEGETABLE','FRUIT','LEGUME','ROOT','OTHER')),
    growth_period_days  NUMBER(4) CHECK (growth_period_days > 0),
    description         VARCHAR2(500)
);

-- TABLE 4: CROP_PLANTINGS
CREATE TABLE CROP_PLANTINGS (
    planting_id           NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    field_id              NUMBER(10) NOT NULL,
    crop_id               NUMBER(10) NOT NULL,
    planting_date         DATE NOT NULL,
    expected_harvest_date DATE,
    actual_harvest_date   DATE,
    quantity_planted      NUMBER(10,2) CHECK (quantity_planted >= 0),
    quantity_harvested    NUMBER(10,2) CHECK (quantity_harvested >= 0),
    status                VARCHAR2(20) DEFAULT 'GROWING'
        CHECK (status IN ('GROWING','HARVESTED','FAILED','ABANDONED')),
    
    CONSTRAINT fk_plant_field
        FOREIGN KEY (field_id) REFERENCES FIELDS(field_id),
    CONSTRAINT fk_plant_crop
        FOREIGN KEY (crop_id) REFERENCES CROPS(crop_id)
);

-- TABLE 5: DISEASES
CREATE TABLE DISEASES (
    disease_id        NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    disease_name      VARCHAR2(100) NOT NULL UNIQUE,
    disease_category  VARCHAR2(50)
        CHECK (disease_category IN ('FUNGAL','BACTERIAL','VIRAL','PEST','NUTRITIONAL','ENVIRONMENTAL')),
    symptoms          VARCHAR2(1000),
    severity_level    VARCHAR2(20) DEFAULT 'MEDIUM'
        CHECK (severity_level IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    description       CLOB
);

-- TABLE 6: DISEASE_CASES
CREATE TABLE DISEASE_CASES (
    case_id                   NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    planting_id               NUMBER(10) NOT NULL,
    disease_id                NUMBER(10) NOT NULL,
    detection_date            DATE DEFAULT SYSDATE NOT NULL,
    severity                  VARCHAR2(20)
        CHECK (severity IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    affected_area_percentage  NUMBER(5,2)
        CHECK (affected_area_percentage BETWEEN 0 AND 100),
    status                    VARCHAR2(20) DEFAULT 'DETECTED'
        CHECK (status IN ('DETECTED','TREATING','TREATED','RESOLVED','FAILED')),
    notes                     VARCHAR2(1000),
    
    CONSTRAINT fk_case_planting
        FOREIGN KEY (planting_id) REFERENCES CROP_PLANTINGS(planting_id),
    CONSTRAINT fk_case_disease
        FOREIGN KEY (disease_id) REFERENCES DISEASES(disease_id)
);

-- TABLE 7: TREATMENTS
CREATE TABLE TREATMENTS (
    treatment_id        NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    treatment_name      VARCHAR2(100) NOT NULL UNIQUE,
    treatment_type      VARCHAR2(50)
        CHECK (treatment_type IN ('CHEMICAL','ORGANIC','MECHANICAL','BIOLOGICAL','CULTURAL')),
    application_method  VARCHAR2(100),
    duration_days       NUMBER(3) CHECK (duration_days > 0),
    cost_estimate       NUMBER(10,2) CHECK (cost_estimate >= 0),
    description         VARCHAR2(1000)
);

-- TABLE 8: DISEASE_TREATMENTS
CREATE TABLE DISEASE_TREATMENTS (
    disease_treatment_id  NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    disease_id            NUMBER(10) NOT NULL,
    treatment_id          NUMBER(10) NOT NULL,
    effectiveness_rate    NUMBER(5,2) CHECK (effectiveness_rate BETWEEN 0 AND 100),
    recommended_dosage    VARCHAR2(200),
    priority              NUMBER(1) DEFAULT 1 CHECK (priority BETWEEN 1 AND 5),
    
    CONSTRAINT fk_dt_disease
        FOREIGN KEY (disease_id) REFERENCES DISEASES(disease_id),
    CONSTRAINT fk_dt_treatment
        FOREIGN KEY (treatment_id) REFERENCES TREATMENTS(treatment_id),
    
    CONSTRAINT uq_dt UNIQUE (disease_id, treatment_id)
);

-- TABLE 9: CHEMICALS
CREATE TABLE CHEMICALS (
    chemical_id        NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    chemical_name      VARCHAR2(100) NOT NULL UNIQUE,
    chemical_type      VARCHAR2(50)
        CHECK (chemical_type IN ('PESTICIDE','FUNGICIDE','HERBICIDE','FERTILIZER','GROWTH_REGULATOR')),
    manufacturer       VARCHAR2(100),
    unit_of_measure    VARCHAR2(20) DEFAULT 'LITERS',
    quantity_in_stock  NUMBER(10,2) DEFAULT 0 CHECK (quantity_in_stock >= 0),
    reorder_level      NUMBER(10,2) DEFAULT 10 CHECK (reorder_level >= 0),
    unit_cost          NUMBER(10,2) CHECK (unit_cost >= 0),
    expiry_date        DATE,
    status             VARCHAR2(20) DEFAULT 'AVAILABLE'
        CHECK (status IN ('AVAILABLE','LOW_STOCK','OUT_OF_STOCK','EXPIRED'))
);

-- TABLE 10: STAFF
CREATE TABLE STAFF (
    staff_id       NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    staff_name     VARCHAR2(100) NOT NULL,
    role           VARCHAR2(50)
        CHECK (role IN ('FARM_WORKER','SUPERVISOR','TECHNICIAN','MANAGER','AGRONOMIST')),
    phone_number   VARCHAR2(15),
    hire_date      DATE DEFAULT SYSDATE,
    status         VARCHAR2(20) DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE','ON_LEAVE','TERMINATED'))
);

-- TABLE 11: TREATMENT_APPLICATIONS
CREATE TABLE TREATMENT_APPLICATIONS (
    application_id        NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    case_id               NUMBER(10) NOT NULL,
    treatment_id          NUMBER(10) NOT NULL,
    staff_id              NUMBER(10) NOT NULL,
    application_date      DATE DEFAULT SYSDATE NOT NULL,
    application_time      TIMESTAMP DEFAULT SYSTIMESTAMP,
    area_treated_hectares NUMBER(8,2) CHECK (area_treated_hectares > 0),
    weather_condition     VARCHAR2(50),
    application_status    VARCHAR2(20) DEFAULT 'PENDING'
        CHECK (application_status IN ('PENDING','COMPLETED','FAILED','CANCELLED')),
    notes                 VARCHAR2(1000),
    cost                  NUMBER(10,2) CHECK (cost >= 0),
    
    CONSTRAINT fk_app_case
        FOREIGN KEY (case_id) REFERENCES DISEASE_CASES(case_id),
    CONSTRAINT fk_app_treatment
        FOREIGN KEY (treatment_id) REFERENCES TREATMENTS(treatment_id),
    CONSTRAINT fk_app_staff
        FOREIGN KEY (staff_id) REFERENCES STAFF(staff_id)
);

-- TABLE 12: CHEMICAL_USAGE
CREATE TABLE CHEMICAL_USAGE (
    usage_id           NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    application_id     NUMBER(10) NOT NULL,
    chemical_id        NUMBER(10) NOT NULL,
    quantity_used      NUMBER(10,2) CHECK (quantity_used > 0),
    unit_of_measure    VARCHAR2(20) NOT NULL,
    application_method VARCHAR2(100),

    CONSTRAINT fk_usage_app
        FOREIGN KEY (application_id) REFERENCES TREATMENT_APPLICATIONS(application_id),
    CONSTRAINT fk_usage_chemical
        FOREIGN KEY (chemical_id) REFERENCES CHEMICALS(chemical_id)
);

-- TABLE 13: AUDIT_LOG
CREATE TABLE AUDIT_LOG (
    audit_id        NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name      VARCHAR2(50) NOT NULL,
    operation_type  VARCHAR2(20) CHECK (operation_type IN ('INSERT','UPDATE','DELETE')),
    record_id       NUMBER(10),
    old_value       CLOB,
    new_value       CLOB,
    changed_by      VARCHAR2(100) NOT NULL,
    change_date     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    ip_address      VARCHAR2(50)
);

-- Verification Query
SELECT table_name FROM user_tables ORDER BY table_name;