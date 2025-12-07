-- ========================================
-- FIXED DATA INSERTION
-- ========================================

SET DEFINE OFF;

-- First, let's check what farmer IDs actually exist
SELECT MIN(farmer_id) AS min_id, MAX(farmer_id) AS max_id, COUNT(*) AS total 
FROM FARMERS;

-- ========================================
-- TABLE 7: FIELDS (200 rows) - FIXED
-- ========================================
BEGIN
    DECLARE
        v_min_farmer_id NUMBER;
        v_max_farmer_id NUMBER;
        v_farmer_id NUMBER;
    BEGIN
        -- Get actual farmer ID range
        SELECT MIN(farmer_id), MAX(farmer_id) 
        INTO v_min_farmer_id, v_max_farmer_id 
        FROM FARMERS;
        
        FOR i IN 1..200 LOOP
            -- Pick a random existing farmer
            SELECT farmer_id INTO v_farmer_id
            FROM (
                SELECT farmer_id FROM FARMERS 
                ORDER BY DBMS_RANDOM.VALUE
            ) WHERE ROWNUM = 1;
            
            INSERT INTO FIELDS (farmer_id, field_name, size_hectares, soil_type, location_gps) 
            VALUES (
                v_farmer_id,
                'Field_' || CHR(65 + MOD(i, 26)) || '_' || i,
                ROUND(DBMS_RANDOM.VALUE(0.5, 5), 2),
                CASE MOD(i, 4)
                    WHEN 0 THEN 'Clay'
                    WHEN 1 THEN 'Loam'
                    WHEN 2 THEN 'Sandy'
                    ELSE 'Clay-Loam'
                END,
                '-1.' || LPAD(TRUNC(DBMS_RANDOM.VALUE(90, 99)), 2, '0') || 
                ', 29.' || LPAD(TRUNC(DBMS_RANDOM.VALUE(70, 99)), 2, '0')
            );
        END LOOP;
        
        COMMIT;
    END;
END;
/

-- ========================================
-- TABLE 8: CROP_PLANTINGS (400 rows) - FIXED
-- ========================================
BEGIN
    FOR i IN 1..400 LOOP
        DECLARE
            v_planting_date DATE := SYSDATE - TRUNC(DBMS_RANDOM.VALUE(30, 365));
            v_field_id NUMBER;
            v_crop_id NUMBER;
            v_growth_days NUMBER;
        BEGIN
            -- Pick random existing field
            SELECT field_id INTO v_field_id
            FROM (SELECT field_id FROM FIELDS ORDER BY DBMS_RANDOM.VALUE)
            WHERE ROWNUM = 1;
            
            -- Pick random existing crop
            SELECT crop_id INTO v_crop_id
            FROM (SELECT crop_id FROM CROPS ORDER BY DBMS_RANDOM.VALUE)
            WHERE ROWNUM = 1;
            
            -- Get growth period
            SELECT growth_period_days INTO v_growth_days 
            FROM CROPS WHERE crop_id = v_crop_id;
            
            INSERT INTO CROP_PLANTINGS (
                field_id, crop_id, planting_date, 
                expected_harvest_date, quantity_planted, status
            ) VALUES (
                v_field_id,
                v_crop_id,
                v_planting_date,
                v_planting_date + v_growth_days,
                ROUND(DBMS_RANDOM.VALUE(50, 500), 2),
                CASE 
                    WHEN v_planting_date + v_growth_days < SYSDATE THEN 'HARVESTED'
                    ELSE 'GROWING'
                END
            );
        END;
    END LOOP;
    
    COMMIT;
END;
/

-- ========================================
-- TABLE 9: DISEASE_CASES (300 rows) - FIXED
-- ========================================
BEGIN
    FOR i IN 1..300 LOOP
        DECLARE
            v_planting_id NUMBER;
            v_disease_id NUMBER;
        BEGIN
            -- Pick random existing planting
            SELECT planting_id INTO v_planting_id
            FROM (SELECT planting_id FROM CROP_PLANTINGS ORDER BY DBMS_RANDOM.VALUE)
            WHERE ROWNUM = 1;
            
            -- Pick random existing disease
            SELECT disease_id INTO v_disease_id
            FROM (SELECT disease_id FROM DISEASES ORDER BY DBMS_RANDOM.VALUE)
            WHERE ROWNUM = 1;
            
            INSERT INTO DISEASE_CASES (
                planting_id, disease_id, detection_date, 
                severity, affected_area_percentage, status
            ) VALUES (
                v_planting_id,
                v_disease_id,
                SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1, 180)),
                CASE MOD(i, 4)
                    WHEN 0 THEN 'CRITICAL'
                    WHEN 1 THEN 'HIGH'
                    WHEN 2 THEN 'MEDIUM'
                    ELSE 'LOW'
                END,
                ROUND(DBMS_RANDOM.VALUE(5, 85), 2),
                CASE MOD(i, 5)
                    WHEN 0 THEN 'RESOLVED'
                    WHEN 1 THEN 'TREATED'
                    WHEN 2 THEN 'TREATING'
                    ELSE 'DETECTED'
                END
            );
        END;
    END LOOP;
    
    COMMIT;
END;
/

-- ========================================
-- TABLE 11: TREATMENT_APPLICATIONS (400 rows) - FIXED
-- ========================================
BEGIN
    FOR i IN 1..400 LOOP
        DECLARE
            v_case_id NUMBER;
            v_treatment_id NUMBER;
            v_staff_id NUMBER;
        BEGIN
            -- Pick random existing case
            SELECT case_id INTO v_case_id
            FROM (SELECT case_id FROM DISEASE_CASES ORDER BY DBMS_RANDOM.VALUE)
            WHERE ROWNUM = 1;
            
            -- Pick random existing treatment
            SELECT treatment_id INTO v_treatment_id
            FROM (SELECT treatment_id FROM TREATMENTS ORDER BY DBMS_RANDOM.VALUE)
            WHERE ROWNUM = 1;
            
            -- Pick random existing staff
            SELECT staff_id INTO v_staff_id
            FROM (SELECT staff_id FROM STAFF ORDER BY DBMS_RANDOM.VALUE)
            WHERE ROWNUM = 1;
            
            INSERT INTO TREATMENT_APPLICATIONS (
                case_id, treatment_id, staff_id,
                application_date, area_treated_hectares,
                weather_condition, application_status, cost
            ) VALUES (
                v_case_id,
                v_treatment_id,
                v_staff_id,
                SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1, 150)),
                ROUND(DBMS_RANDOM.VALUE(0.5, 4), 2),
                CASE MOD(i, 5)
                    WHEN 0 THEN 'Sunny'
                    WHEN 1 THEN 'Cloudy'
                    WHEN 2 THEN 'Light Rain'
                    WHEN 3 THEN 'Windy'
                    ELSE 'Clear'
                END,
                CASE MOD(i, 4)
                    WHEN 0 THEN 'COMPLETED'
                    WHEN 1 THEN 'COMPLETED'
                    WHEN 2 THEN 'PENDING'
                    ELSE 'FAILED'
                END,
                ROUND(DBMS_RANDOM.VALUE(10000, 50000), 0)
            );
        END;
    END LOOP;
    
    COMMIT;
END;
/

-- ========================================
-- TABLE 12: CHEMICAL_USAGE (500 rows) - FIXED
-- ========================================
BEGIN
    FOR i IN 1..500 LOOP
        DECLARE
            v_application_id NUMBER;
            v_chemical_id NUMBER;
        BEGIN
            -- Pick random existing application
            SELECT application_id INTO v_application_id
            FROM (SELECT application_id FROM TREATMENT_APPLICATIONS ORDER BY DBMS_RANDOM.VALUE)
            WHERE ROWNUM = 1;
            
            -- Pick random existing chemical
            SELECT chemical_id INTO v_chemical_id
            FROM (SELECT chemical_id FROM CHEMICALS ORDER BY DBMS_RANDOM.VALUE)
            WHERE ROWNUM = 1;
            
            INSERT INTO CHEMICAL_USAGE (
                application_id, chemical_id,
                quantity_used, unit_of_measure, application_method
            ) VALUES (
                v_application_id,
                v_chemical_id,
                ROUND(DBMS_RANDOM.VALUE(0.5, 10), 2),
                CASE MOD(i, 3)
                    WHEN 0 THEN 'KILOGRAMS'
                    WHEN 1 THEN 'LITERS'
                    ELSE 'GRAMS'
                END,
                CASE MOD(i, 4)
                    WHEN 0 THEN 'Foliar Spray'
                    WHEN 1 THEN 'Soil Drench'
                    WHEN 2 THEN 'Seed Treatment'
                    ELSE 'Broadcasting'
                END
            );
        END;
    END LOOP;
    
    COMMIT;
END;
/

SET DEFINE ON;

-- ========================================
-- FINAL VERIFICATION
-- ========================================
SELECT 'FARMERS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM FARMERS
UNION ALL
SELECT 'FIELDS', COUNT(*) FROM FIELDS
UNION ALL
SELECT 'CROPS', COUNT(*) FROM CROPS
UNION ALL
SELECT 'CROP_PLANTINGS', COUNT(*) FROM CROP_PLANTINGS
UNION ALL
SELECT 'DISEASES', COUNT(*) FROM DISEASES
UNION ALL
SELECT 'DISEASE_CASES', COUNT(*) FROM DISEASE_CASES
UNION ALL
SELECT 'TREATMENTS', COUNT(*) FROM TREATMENTS
UNION ALL
SELECT 'DISEASE_TREATMENTS', COUNT(*) FROM DISEASE_TREATMENTS
UNION ALL
SELECT 'CHEMICALS', COUNT(*) FROM CHEMICALS
UNION ALL
SELECT 'STAFF', COUNT(*) FROM STAFF
UNION ALL
SELECT 'TREATMENT_APPLICATIONS', COUNT(*) FROM TREATMENT_APPLICATIONS
UNION ALL
SELECT 'CHEMICAL_USAGE', COUNT(*) FROM CHEMICAL_USAGE
ORDER BY 1;