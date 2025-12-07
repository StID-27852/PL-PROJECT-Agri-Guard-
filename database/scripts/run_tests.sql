-- ========================================
-- SECTION 5: TESTING SCRIPTS
-- ========================================

-- Test Script 1: Test All Functions
PROMPT ========================================
PROMPT TESTING FUNCTIONS
PROMPT ========================================

SET SERVEROUTPUT ON;

DECLARE
    v_cost NUMBER;
    v_score NUMBER;
    v_availability VARCHAR2(20);
    v_days NUMBER;
    v_field_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== FUNCTION TESTS ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 1: Calculate treatment cost
    v_cost := calculate_treatment_cost(1, 2.5);
    DBMS_OUTPUT.PUT_LINE('1. Treatment cost for 2.5 hectares: RWF ' || v_cost);
    
    -- Test 2: Severity score
    v_score := get_severity_score('CRITICAL');
    DBMS_OUTPUT.PUT_LINE('2. Severity score for CRITICAL: ' || v_score);
    
    -- Test 3: Chemical availability
    v_availability := check_chemical_available(1, 50);
    DBMS_OUTPUT.PUT_LINE('3. Chemical availability: ' || v_availability);
    
    -- Test 4: Days to harvest
    v_days := days_to_harvest(1);
    DBMS_OUTPUT.PUT_LINE('4. Days to harvest for planting 1: ' || v_days);
    
    -- Test 5: Farmer field count
    v_field_count := get_farmer_field_count(1);
    DBMS_OUTPUT.PUT_LINE('5. Fields owned by farmer 1: ' || v_field_count);
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('All function tests completed!');
END;
/

-- Test Script 2: Test Procedures
PROMPT ========================================
PROMPT TESTING PROCEDURES
PROMPT ========================================

DECLARE
    v_case_id NUMBER;
    v_planting_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PROCEDURE TESTS ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test: Plant new crop
    DBMS_OUTPUT.PUT_LINE('Test 1: Planting new crop...');
    plant_crop(
        p_field_id => 1,
        p_crop_id => 1,
        p_quantity_planted => 100,
        p_planting_id => v_planting_id
    );
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('All procedure tests completed!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Test Script 3: Test Cursors
PROMPT ========================================
PROMPT TESTING CURSORS
PROMPT ========================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 1: Processing active cases...');
    DBMS_OUTPUT.PUT_LINE('');
    process_active_cases;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Test 2: Generating low stock report...');
    DBMS_OUTPUT.PUT_LINE('');
    generate_low_stock_report;
END;
/

-- Test Script 4: Test Package
PROMPT ========================================
PROMPT TESTING PACKAGE
PROMPT ========================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 1: Monthly summary report...');
    agriguard_management.monthly_summary_report;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Test 2: Active cases count...');
    DBMS_OUTPUT.PUT_LINE('Active cases: ' || agriguard_management.get_active_cases_count);
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Test 3: Farmer report...');
    agriguard_management.generate_farmer_report(1);
END;
/

-- Test Script 5: Window Functions Query
PROMPT ========================================
PROMPT TESTING WINDOW FUNCTIONS
PROMPT ========================================

SELECT 
    disease_name,
    severity,
    case_sequence,
    severity_rank_by_category,
    overall_severity_rank,
    days_since_previous,
    cumulative_cases
FROM disease_case_analytics
WHERE ROWNUM <= 10
ORDER BY case_sequence;
