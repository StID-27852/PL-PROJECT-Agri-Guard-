-- ========================================
-- AUDIT QUERIES FOR AGRIGUARD+
-- Compliance and Security Monitoring
-- ========================================

-- Query 1: Complete Audit Trail (Last 7 Days)
SELECT 
    audit_id,
    table_name,
    operation_type,
    operation_status,
    changed_by,
    session_user,
    TO_CHAR(change_date, 'DD-MON-YYYY HH24:MI:SS') AS change_timestamp,
    denial_reason,
    SUBSTR(new_value, 1, 100) AS value_preview
FROM AUDIT_LOG
WHERE change_date >= SYSDATE - 7
ORDER BY change_date DESC;

-- Query 2: Denied Operations by User
SELECT 
    changed_by,
    table_name,
    operation_type,
    COUNT(*) AS denial_count,
    MAX(change_date) AS last_denial,
    LISTAGG(DISTINCT denial_reason, '; ') WITHIN GROUP (ORDER BY denial_reason) AS denial_reasons
FROM AUDIT_LOG
WHERE operation_status = 'DENIED'
  AND change_date >= SYSDATE - 30
GROUP BY changed_by, table_name, operation_type
ORDER BY denial_count DESC;

-- Query 3: Successful Operations Summary
SELECT 
    TO_CHAR(change_date, 'YYYY-MM-DD') AS operation_date,
    table_name,
    operation_type,
    COUNT(*) AS successful_operations
FROM AUDIT_LOG
WHERE operation_status = 'SUCCESS'
  AND change_date >= SYSDATE - 30
GROUP BY TO_CHAR(change_date, 'YYYY-MM-DD'), table_name, operation_type
ORDER BY operation_date DESC, successful_operations DESC;

-- Query 4: User Activity Summary
SELECT 
    changed_by,
    COUNT(*) AS total_operations,
    SUM(CASE WHEN operation_status = 'SUCCESS' THEN 1 ELSE 0 END) AS successful,
    SUM(CASE WHEN operation_status = 'DENIED' THEN 1 ELSE 0 END) AS denied,
    MIN(change_date) AS first_activity,
    MAX(change_date) AS last_activity,
    COUNT(DISTINCT table_name) AS tables_accessed
FROM AUDIT_LOG
WHERE change_date >= SYSDATE - 30
GROUP BY changed_by
ORDER BY total_operations DESC;

-- Query 5: Weekend vs Weekday Activity
SELECT 
    CASE 
        WHEN TO_CHAR(change_date, 'D') IN ('1', '7') THEN 'WEEKEND'
        ELSE 'WEEKDAY'
    END AS day_type,
    operation_status,
    COUNT(*) AS operation_count
FROM AUDIT_LOG
WHERE change_date >= SYSDATE - 30
GROUP BY 
    CASE 
        WHEN TO_CHAR(change_date, 'D') IN ('1', '7') THEN 'WEEKEND'
        ELSE 'WEEKDAY'
    END,
    operation_status
ORDER BY day_type, operation_status;