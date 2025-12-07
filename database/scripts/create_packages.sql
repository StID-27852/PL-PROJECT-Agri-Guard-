-- ========================================
-- SECTION 4: PACKAGE (Group Related Procedures/Functions)
-- ========================================

-- Package Specification
CREATE OR REPLACE PACKAGE agriguard_management AS
    -- Public procedures
    PROCEDURE record_disease_and_treat (
        p_planting_id IN NUMBER,
        p_disease_id IN NUMBER,
        p_severity IN VARCHAR2,
        p_treatment_id IN NUMBER,
        p_staff_id IN NUMBER
    );
    
    PROCEDURE generate_farmer_report (
        p_farmer_id IN NUMBER
    );
    
    PROCEDURE monthly_summary_report;
    
    -- Public functions
    FUNCTION get_active_cases_count RETURN NUMBER;
    
    FUNCTION get_total_treatment_cost (
        p_start_date IN DATE,
        p_end_date IN DATE
    ) RETURN NUMBER;
    
    FUNCTION get_disease_outbreak_status (
        p_disease_id IN NUMBER,
        p_days_back IN NUMBER DEFAULT 30
    ) RETURN VARCHAR2;
END agriguard_management;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY agriguard_management AS
    
    -- Record disease and immediately apply treatment
    PROCEDURE record_disease_and_treat (
        p_planting_id IN NUMBER,
        p_disease_id IN NUMBER,
        p_severity IN VARCHAR2,
        p_treatment_id IN NUMBER,
        p_staff_id IN NUMBER
    ) AS
        v_case_id NUMBER;
        v_application_id NUMBER;
    BEGIN
        -- Record disease case
        add_disease_case(
            p_planting_id => p_planting_id,
            p_disease_id => p_disease_id,
            p_severity => p_severity,
            p_affected_area_pct => 50,
            p_notes => 'Auto-recorded with immediate treatment',
            p_case_id => v_case_id
        );
        
        -- Apply treatment
        apply_treatment(
            p_case_id => v_case_id,
            p_treatment_id => p_treatment_id,
            p_staff_id => p_staff_id,
            p_area_treated => 2.5,
            p_application_id => v_application_id
        );
        
        DBMS_OUTPUT.PUT_LINE('Disease recorded and treatment applied successfully.');
        DBMS_OUTPUT.PUT_LINE('Case ID: ' || v_case_id || ', Application ID: ' || v_application_id);
    END record_disease_and_treat;
    
    -- Generate comprehensive farmer report
    PROCEDURE generate_farmer_report (
        p_farmer_id IN NUMBER
    ) AS
        v_farmer_name VARCHAR2(100);
        v_field_count NUMBER;
        v_total_area NUMBER;
        v_active_plantings NUMBER;
        v_disease_cases NUMBER;
    BEGIN
        -- Get farmer info
        SELECT farmer_name INTO v_farmer_name
        FROM FARMERS WHERE farmer_id = p_farmer_id;
        
        -- Get statistics
        SELECT COUNT(*), NVL(SUM(size_hectares), 0)
        INTO v_field_count, v_total_area
        FROM FIELDS WHERE farmer_id = p_farmer_id;
        
        SELECT COUNT(*)
        INTO v_active_plantings
        FROM CROP_PLANTINGS cp
        JOIN FIELDS f ON cp.field_id = f.field_id
        WHERE f.farmer_id = p_farmer_id AND cp.status = 'GROWING';
        
        SELECT COUNT(*)
        INTO v_disease_cases
        FROM DISEASE_CASES dc
        JOIN CROP_PLANTINGS cp ON dc.planting_id = cp.planting_id
        JOIN FIELDS f ON cp.field_id = f.field_id
        WHERE f.farmer_id = p_farmer_id;
        
        -- Print report
        DBMS_OUTPUT.PUT_LINE('=== FARMER REPORT ===');
        DBMS_OUTPUT.PUT_LINE('Farmer: ' || v_farmer_name);
        DBMS_OUTPUT.PUT_LINE('Total Fields: ' || v_field_count);
        DBMS_OUTPUT.PUT_LINE('Total Area: ' || v_total_area || ' hectares');
        DBMS_OUTPUT.PUT_LINE('Active Plantings: ' || v_active_plantings);
        DBMS_OUTPUT.PUT_LINE('Disease Cases: ' || v_disease_cases);
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Farmer ID ' || p_farmer_id || ' not found.');
    END generate_farmer_report;
    
    -- Monthly summary
    PROCEDURE monthly_summary_report AS
        v_total_cases NUMBER;
        v_resolved_cases NUMBER;
        v_treatments NUMBER;
        v_total_cost NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total_cases
        FROM DISEASE_CASES
        WHERE TRUNC(detection_date, 'MM') = TRUNC(SYSDATE, 'MM');
        
        SELECT COUNT(*) INTO v_resolved_cases
        FROM DISEASE_CASES
        WHERE TRUNC(detection_date, 'MM') = TRUNC(SYSDATE, 'MM')
        AND status = 'RESOLVED';
        
        SELECT COUNT(*), NVL(SUM(cost), 0)
        INTO v_treatments, v_total_cost
        FROM TREATMENT_APPLICATIONS
        WHERE TRUNC(application_date, 'MM') = TRUNC(SYSDATE, 'MM');
        
        DBMS_OUTPUT.PUT_LINE('=== MONTHLY SUMMARY ===');
        DBMS_OUTPUT.PUT_LINE('Month: ' || TO_CHAR(SYSDATE, 'MONTH YYYY'));
        DBMS_OUTPUT.PUT_LINE('Total Disease Cases: ' || v_total_cases);
        DBMS_OUTPUT.PUT_LINE('Resolved Cases: ' || v_resolved_cases);
        DBMS_OUTPUT.PUT_LINE('Treatment Applications: ' || v_treatments);
        DBMS_OUTPUT.PUT_LINE('Total Treatment Cost: RWF ' || TO_CHAR(v_total_cost, '999,999,999'));
    END monthly_summary_report;
    
    -- Get active cases count
    FUNCTION get_active_cases_count RETURN NUMBER AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM DISEASE_CASES
        WHERE status IN ('DETECTED', 'TREATING');
        RETURN v_count;
    END get_active_cases_count;
    
    -- Get total treatment cost for period
    FUNCTION get_total_treatment_cost (
        p_start_date IN DATE,
        p_end_date IN DATE
    ) RETURN NUMBER AS
        v_total NUMBER;
    BEGIN
        SELECT NVL(SUM(cost), 0) INTO v_total
        FROM TREATMENT_APPLICATIONS
        WHERE application_date BETWEEN p_start_date AND p_end_date;
        RETURN v_total;
    END get_total_treatment_cost;
    
    -- Check for disease outbreak
    FUNCTION get_disease_outbreak_status (
        p_disease_id IN NUMBER,
        p_days_back IN NUMBER DEFAULT 30
    ) RETURN VARCHAR2 AS
        v_count NUMBER;
        v_threshold NUMBER := 5;  -- 5 cases in period = outbreak
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM DISEASE_CASES
        WHERE disease_id = p_disease_id
        AND detection_date >= SYSDATE - p_days_back;
        
        IF v_count >= v_threshold THEN
            RETURN 'OUTBREAK';
        ELSIF v_count >= 3 THEN
            RETURN 'WARNING';
        ELSE
            RETURN 'NORMAL';
        END IF;
    END get_disease_outbreak_status;
    
END agriguard_management;
/
