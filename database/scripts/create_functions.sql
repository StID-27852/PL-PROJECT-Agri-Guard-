-- ========================================
-- PHASE VI: COMPLETE PL/SQL DEVELOPMENT
-- Student: Ineza Sonia (27852)
-- AgriGuard+ Project
-- ========================================

SET SERVEROUTPUT ON;

-- ========================================
-- SECTION 1: FUNCTIONS (5 Functions)
-- ========================================

-- FUNCTION 1: Calculate Treatment Cost
CREATE OR REPLACE FUNCTION calculate_treatment_cost (
    p_treatment_id IN NUMBER,
    p_area_hectares IN NUMBER
) RETURN NUMBER AS
    v_cost_estimate NUMBER;
    v_total_cost NUMBER;
BEGIN
    SELECT cost_estimate INTO v_cost_estimate
    FROM TREATMENTS
    WHERE treatment_id = p_treatment_id;
    
    v_total_cost := v_cost_estimate * p_area_hectares;
    
    RETURN v_total_cost;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN -1;
END calculate_treatment_cost;
/

-- FUNCTION 2: Get Disease Severity Score
CREATE OR REPLACE FUNCTION get_severity_score (
    p_severity VARCHAR2
) RETURN NUMBER AS
BEGIN
    RETURN CASE p_severity
        WHEN 'CRITICAL' THEN 4
        WHEN 'HIGH' THEN 3
        WHEN 'MEDIUM' THEN 2
        WHEN 'LOW' THEN 1
        ELSE 0
    END;
END get_severity_score;
/

-- FUNCTION 3: Check Chemical Availability
CREATE OR REPLACE FUNCTION check_chemical_available (
    p_chemical_id IN NUMBER,
    p_quantity_needed IN NUMBER
) RETURN VARCHAR2 AS
    v_stock NUMBER;
BEGIN
    SELECT quantity_in_stock INTO v_stock
    FROM CHEMICALS
    WHERE chemical_id = p_chemical_id;
    
    IF v_stock >= p_quantity_needed THEN
        RETURN 'AVAILABLE';
    ELSIF v_stock > 0 THEN
        RETURN 'INSUFFICIENT';
    ELSE
        RETURN 'OUT_OF_STOCK';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'NOT_FOUND';
    WHEN OTHERS THEN
        RETURN 'ERROR';
END check_chemical_available;
/

-- FUNCTION 4: Calculate Days to Harvest
CREATE OR REPLACE FUNCTION days_to_harvest (
    p_planting_id IN NUMBER
) RETURN NUMBER AS
    v_expected_date DATE;
    v_days_remaining NUMBER;
BEGIN
    SELECT expected_harvest_date INTO v_expected_date
    FROM CROP_PLANTINGS
    WHERE planting_id = p_planting_id;
    
    v_days_remaining := v_expected_date - SYSDATE;
    
    RETURN CASE 
        WHEN v_days_remaining < 0 THEN 0
        ELSE v_days_remaining
    END;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1;
    WHEN OTHERS THEN
        RETURN -999;
END days_to_harvest;
/

-- FUNCTION 5: Get Farmer Total Fields
CREATE OR REPLACE FUNCTION get_farmer_field_count (
    p_farmer_id IN NUMBER
) RETURN NUMBER AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM FIELDS
    WHERE farmer_id = p_farmer_id;
    
    RETURN v_count;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END get_farmer_field_count;
/
