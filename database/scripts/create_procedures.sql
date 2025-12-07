-- ========================================
-- PROCEDURE 1: Record New Disease Case
-- ========================================
CREATE OR REPLACE PROCEDURE add_disease_case (
    p_planting_id       IN NUMBER,
    p_disease_id        IN NUMBER,
    p_severity          IN VARCHAR2,
    p_affected_area_pct IN NUMBER,
    p_notes             IN VARCHAR2 DEFAULT NULL,
    p_case_id           OUT NUMBER
) AS
    v_planting_exists NUMBER;
    v_disease_exists NUMBER;
    e_invalid_planting EXCEPTION;
    e_invalid_disease EXCEPTION;
    e_invalid_severity EXCEPTION;
    e_invalid_percentage EXCEPTION;
BEGIN
    -- Validate planting exists
    SELECT COUNT(*) INTO v_planting_exists 
    FROM CROP_PLANTINGS WHERE planting_id = p_planting_id;
    
    IF v_planting_exists = 0 THEN
        RAISE e_invalid_planting;
    END IF;
    
    -- Validate disease exists
    SELECT COUNT(*) INTO v_disease_exists 
    FROM DISEASES WHERE disease_id = p_disease_id;
    
    IF v_disease_exists = 0 THEN
        RAISE e_invalid_disease;
    END IF;
    
    -- Validate severity
    IF p_severity NOT IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') THEN
        RAISE e_invalid_severity;
    END IF;
    
    -- Validate percentage
    IF p_affected_area_pct < 0 OR p_affected_area_pct > 100 THEN
        RAISE e_invalid_percentage;
    END IF;
    
    -- Insert disease case
    INSERT INTO DISEASE_CASES (
        planting_id, disease_id, severity, 
        affected_area_percentage, status, notes
    ) VALUES (
        p_planting_id, p_disease_id, p_severity,
        p_affected_area_pct, 'DETECTED', p_notes
    ) RETURNING case_id INTO p_case_id;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Disease case ' || p_case_id || ' recorded successfully.');
    
EXCEPTION
    WHEN e_invalid_planting THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid planting ID: ' || p_planting_id);
    WHEN e_invalid_disease THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid disease ID: ' || p_disease_id);
    WHEN e_invalid_severity THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid severity. Must be LOW, MEDIUM, HIGH, or CRITICAL');
    WHEN e_invalid_percentage THEN
        RAISE_APPLICATION_ERROR(-20004, 'Affected area percentage must be between 0 and 100');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Error recording disease case: ' || SQLERRM);
END add_disease_case;
/