-- Trigger 1: DISEASE_CASES - INSERT Restriction
CREATE OR REPLACE TRIGGER trg_disease_cases_insert
BEFORE INSERT ON DISEASE_CASES
FOR EACH ROW
DECLARE
    v_check_result VARCHAR2(500);
    v_audit_id NUMBER;
BEGIN
    -- Check if operation is allowed
    v_check_result := check_operation_allowed('INSERT');
    
    IF v_check_result != 'ALLOWED' THEN
        -- Log the denied attempt
        v_audit_id := log_audit_entry(
            p_table_name => 'DISEASE_CASES',
            p_operation => 'INSERT',
            p_record_id => NULL,
            p_old_value => NULL,
            p_new_value => 'Attempted to insert case_id: ' || :NEW.case_id,
            p_status => 'DENIED',
            p_denial_reason => v_check_result
        );
        
        -- Raise error to prevent the operation
        RAISE_APPLICATION_ERROR(-20100, v_check_result);
    ELSE
        -- Log successful operation
        v_audit_id := log_audit_entry(
            p_table_name => 'DISEASE_CASES',
            p_operation => 'INSERT',
            p_record_id => :NEW.case_id,
            p_old_value => NULL,
            p_new_value => 'Planting: ' || :NEW.planting_id || ', Disease: ' || :NEW.disease_id,
            p_status => 'SUCCESS',
            p_denial_reason => NULL
        );
    END IF;
END;
/

-- Trigger 2: DISEASE_CASES - UPDATE Restriction
CREATE OR REPLACE TRIGGER trg_disease_cases_update
BEFORE UPDATE ON DISEASE_CASES
FOR EACH ROW
DECLARE
    v_check_result VARCHAR2(500);
    v_audit_id NUMBER;
BEGIN
    v_check_result := check_operation_allowed('UPDATE');
    
    IF v_check_result != 'ALLOWED' THEN
        v_audit_id := log_audit_entry(
            p_table_name => 'DISEASE_CASES',
            p_operation => 'UPDATE',
            p_record_id => :OLD.case_id,
            p_old_value => 'Status: ' || :OLD.status,
            p_new_value => 'Attempted Status: ' || :NEW.status,
            p_status => 'DENIED',
            p_denial_reason => v_check_result
        );
        
        RAISE_APPLICATION_ERROR(-20101, v_check_result);
    ELSE
        v_audit_id := log_audit_entry(
            p_table_name => 'DISEASE_CASES',
            p_operation => 'UPDATE',
            p_record_id => :OLD.case_id,
            p_old_value => 'Status: ' || :OLD.status || ', Severity: ' || :OLD.severity,
            p_new_value => 'Status: ' || :NEW.status || ', Severity: ' || :NEW.severity,
            p_status => 'SUCCESS',
            p_denial_reason => NULL
        );
    END IF;
END;
/

-- Trigger 3: DISEASE_CASES - DELETE Restriction
CREATE OR REPLACE TRIGGER trg_disease_cases_delete
BEFORE DELETE ON DISEASE_CASES
FOR EACH ROW
DECLARE
    v_check_result VARCHAR2(500);
    v_audit_id NUMBER;
BEGIN
    v_check_result := check_operation_allowed('DELETE');
    
    IF v_check_result != 'ALLOWED' THEN
        v_audit_id := log_audit_entry(
            p_table_name => 'DISEASE_CASES',
            p_operation => 'DELETE',
            p_record_id => :OLD.case_id,
            p_old_value => 'Case: ' || :OLD.case_id || ', Disease: ' || :OLD.disease_id,
            p_new_value => NULL,
            p_status => 'DENIED',
            p_denial_reason => v_check_result
        );
        
        RAISE_APPLICATION_ERROR(-20102, v_check_result);
    ELSE
        v_audit_id := log_audit_entry(
            p_table_name => 'DISEASE_CASES',
            p_operation => 'DELETE',
            p_record_id => :OLD.case_id,
            p_old_value => 'Deleted case: ' || :OLD.case_id,
            p_new_value => NULL,
            p_status => 'SUCCESS',
            p_denial_reason => NULL
        );
    END IF;
END;
/

-- Trigger 4: TREATMENT_APPLICATIONS - INSERT Restriction
CREATE OR REPLACE TRIGGER trg_treatment_app_insert
BEFORE INSERT ON TREATMENT_APPLICATIONS
FOR EACH ROW
DECLARE
    v_check_result VARCHAR2(500);
    v_audit_id NUMBER;
BEGIN
    v_check_result := check_operation_allowed('INSERT');
    
    IF v_check_result != 'ALLOWED' THEN
        v_audit_id := log_audit_entry(
            p_table_name => 'TREATMENT_APPLICATIONS',
            p_operation => 'INSERT',
            p_record_id => NULL,
            p_old_value => NULL,
            p_new_value => 'Case: ' || :NEW.case_id || ', Treatment: ' || :NEW.treatment_id,
            p_status => 'DENIED',
            p_denial_reason => v_check_result
        );
        
        RAISE_APPLICATION_ERROR(-20103, v_check_result);
    ELSE
        v_audit_id := log_audit_entry(
            p_table_name => 'TREATMENT_APPLICATIONS',
            p_operation => 'INSERT',
            p_record_id => :NEW.application_id,
            p_old_value => NULL,
            p_new_value => 'Case: ' || :NEW.case_id || ', Staff: ' || :NEW.staff_id,
            p_status => 'SUCCESS',
            p_denial_reason => NULL
        );
    END IF;
END;
/

DBMS_OUTPUT.PUT_LINE('Simple triggers created for DISEASE_CASES and TREATMENT_APPLICATIONS.');

CREATE OR REPLACE TRIGGER trg_chemicals_compound
FOR INSERT OR UPDATE OR DELETE ON CHEMICALS
COMPOUND TRIGGER
    
    -- Collection to store audit information
    TYPE t_audit_rec IS RECORD (
        operation VARCHAR2(20),
        chemical_id NUMBER,
        old_stock NUMBER,
        new_stock NUMBER,
        old_status VARCHAR2(20),
        new_status VARCHAR2(20)
    );
    TYPE t_audit_tab IS TABLE OF t_audit_rec INDEX BY PLS_INTEGER;
    
    v_audit_data t_audit_tab;
    v_index PLS_INTEGER := 0;
    
    -- BEFORE STATEMENT
    BEFORE STATEMENT IS
    BEGIN
        v_index := 0;
        v_audit_data.DELETE;
        DBMS_OUTPUT.PUT_LINE('=== COMPOUND TRIGGER: BEFORE STATEMENT ===');
    END BEFORE STATEMENT;
    
    -- BEFORE EACH ROW
    BEFORE EACH ROW IS
        v_check_result VARCHAR2(500);
    BEGIN
        -- Check restriction for INSERT/UPDATE/DELETE
        IF INSERTING THEN
            v_check_result := check_operation_allowed('INSERT');
        ELSIF UPDATING THEN
            v_check_result := check_operation_allowed('UPDATE');
        ELSIF DELETING THEN
            v_check_result := check_operation_allowed('DELETE');
        END IF;
        
        IF v_check_result != 'ALLOWED' THEN
            RAISE_APPLICATION_ERROR(-20104, v_check_result);
        END IF;
        
        -- Store data for logging
        v_index := v_index + 1;
        
        IF INSERTING THEN
            v_audit_data(v_index).operation := 'INSERT';
            v_audit_data(v_index).chemical_id := :NEW.chemical_id;
            v_audit_data(v_index).new_stock := :NEW.quantity_in_stock;
            v_audit_data(v_index).new_status := :NEW.status;
        ELSIF UPDATING THEN
            v_audit_data(v_index).operation := 'UPDATE';
            v_audit_data(v_index).chemical_id := :OLD.chemical_id;
            v_audit_data(v_index).old_stock := :OLD.quantity_in_stock;
            v_audit_data(v_index).new_stock := :NEW.quantity_in_stock;
            v_audit_data(v_index).old_status := :OLD.status;
            v_audit_data(v_index).new_status := :NEW.status;
        ELSIF DELETING THEN
            v_audit_data(v_index).operation := 'DELETE';
            v_audit_data(v_index).chemical_id := :OLD.chemical_id;
            v_audit_data(v_index).old_stock := :OLD.quantity_in_stock;
            v_audit_data(v_index).old_status := :OLD.status;
        END IF;
    END BEFORE EACH ROW;
    
    -- AFTER STATEMENT
    AFTER STATEMENT IS
        v_audit_id NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== COMPOUND TRIGGER: AFTER STATEMENT ===');
        DBMS_OUTPUT.PUT_LINE('Total operations: ' || v_audit_data.COUNT);
        
        -- Log all operations in batch
        FOR i IN 1..v_audit_data.COUNT LOOP
            v_audit_id := log_audit_entry(
                p_table_name => 'CHEMICALS',
                p_operation => v_audit_data(i).operation,
                p_record_id => v_audit_data(i).chemical_id,
                p_old_value => 'Stock: ' || v_audit_data(i).old_stock || ', Status: ' || v_audit_data(i).old_status,
                p_new_value => 'Stock: ' || v_audit_data(i).new_stock || ', Status: ' || v_audit_data(i).new_status,
                p_status => 'SUCCESS',
                p_denial_reason => NULL
            );
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('All operations logged successfully.');
    END AFTER STATEMENT;
    
END trg_chemicals_compound;
/

DBMS_OUTPUT.PUT_LINE('Compound trigger created for CHEMICALS table.');


-- Test 1: Check current day
SELECT 
    TO_CHAR(SYSDATE, 'DAY') AS current_day,
    TO_CHAR(SYSDATE, 'DD-MON-YYYY') AS current_date,
    check_operation_allowed('INSERT') AS operation_status
FROM DUAL;

-- Test 2: View holidays
SELECT * FROM PUBLIC_HOLIDAYS ORDER BY holiday_date;

-- Test 3: Try INSERT on DISEASE_CASES (will succeed on weekend, fail on weekday)
PROMPT Test 3: Attempting to insert disease case...
DECLARE
    v_case_id NUMBER;
    v_planting_id NUMBER;
BEGIN
    SELECT planting_id INTO v_planting_id FROM CROP_PLANTINGS WHERE ROWNUM = 1;
    
    INSERT INTO DISEASE_CASES (planting_id, disease_id, severity, affected_area_percentage, status)
    VALUES (v_planting_id, 1, 'HIGH', 60, 'DETECTED')
    RETURNING case_id INTO v_case_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Disease case inserted. Case ID: ' || v_case_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('DENIED: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Test 4: Try UPDATE on DISEASE_CASES
PROMPT Test 4: Attempting to update disease case...
DECLARE
    v_case_id NUMBER;
BEGIN
    SELECT case_id INTO v_case_id FROM DISEASE_CASES WHERE ROWNUM = 1;
    
    UPDATE DISEASE_CASES 
    SET status = 'RESOLVED'
    WHERE case_id = v_case_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Disease case updated. Case ID: ' || v_case_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('DENIED: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Test 5: Try DELETE on DISEASE_CASES
PROMPT Test 5: Attempting to delete disease case...
DECLARE
    v_case_id NUMBER;
BEGIN
    SELECT case_id INTO v_case_id FROM DISEASE_CASES WHERE status = 'RESOLVED' AND ROWNUM = 1;
    
    DELETE FROM DISEASE_CASES WHERE case_id = v_case_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Disease case deleted. Case ID: ' || v_case_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('DENIED: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Test 6: Try INSERT on TREATMENT_APPLICATIONS
PROMPT Test 6: Attempting to insert treatment application...
DECLARE
    v_application_id NUMBER;
    v_case_id NUMBER;
    v_treatment_id NUMBER;
    v_staff_id NUMBER;
BEGIN
    SELECT case_id INTO v_case_id FROM DISEASE_CASES WHERE ROWNUM = 1;
    SELECT treatment_id INTO v_treatment_id FROM TREATMENTS WHERE ROWNUM = 1;
    SELECT staff_id INTO v_staff_id FROM STAFF WHERE ROWNUM = 1;
    
    INSERT INTO TREATMENT_APPLICATIONS (case_id, treatment_id, staff_id, area_treated_hectares, application_status)
    VALUES (v_case_id, v_treatment_id, v_staff_id, 2.5, 'COMPLETED')
    RETURNING application_id INTO v_application_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Treatment applied. Application ID: ' || v_application_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('DENIED: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Test 7: Test compound trigger on CHEMICALS
PROMPT Test 7: Testing compound trigger on CHEMICALS...
DECLARE
    v_chemical_id NUMBER;
BEGIN
    SELECT chemical_id INTO v_chemical_id FROM CHEMICALS WHERE ROWNUM = 1;
    
    UPDATE CHEMICALS
    SET quantity_in_stock = quantity_in_stock - 5
    WHERE chemical_id = v_chemical_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Chemical stock updated.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('DENIED: ' || SQLERRM);
        ROLLBACK;
END;
/
