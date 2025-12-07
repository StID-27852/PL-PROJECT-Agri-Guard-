SELECT 
    d.disease_name,
    dc.severity,
    COUNT(*) as case_count,
    AVG(dc.affected_area_percentage) as avg_affected_area
FROM DISEASE_CASES dc
JOIN DISEASES d ON dc.disease_id = d.disease_id
WHERE dc.status IN ('DETECTED', 'TREATING')
GROUP BY d.disease_name, dc.severity
ORDER BY case_count DESC;

SELECT 
    t.treatment_name,
    COUNT(ta.application_id) as total_applications,
    SUM(ta.cost) as total_cost,
    AVG(ta.cost) as avg_cost_per_application
FROM TREATMENT_APPLICATIONS ta
JOIN TREATMENTS t ON ta.treatment_id = t.treatment_id
WHERE ta.application_date >= ADD_MONTHS(SYSDATE, -3)
GROUP BY t.treatment_name
ORDER BY total_cost DESC;

SELECT 
    chemical_name,
    chemical_type,
    quantity_in_stock,
    reorder_level,
    (reorder_level - quantity_in_stock) as shortage
FROM CHEMICALS
WHERE quantity_in_stock <= reorder_level
ORDER BY shortage DESC;

SELECT 
    disease_name,
    COUNT(*) as recent_cases,
    agriguard_management.get_disease_outbreak_status(disease_id, 30) as outbreak_status
FROM DISEASE_CASES dc
JOIN DISEASES d ON dc.disease_id = d.disease_id
WHERE detection_date >= SYSDATE - 30
GROUP BY disease_name, disease_id
HAVING COUNT(*) >= 3
ORDER BY recent_cases DESC;