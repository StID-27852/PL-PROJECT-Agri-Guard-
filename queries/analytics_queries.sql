-- ========================================
-- ANALYTICAL QUERIES FOR AGRIGUARD+
-- Advanced SQL for Business Intelligence
-- ========================================

-- ========================================
-- SECTION 1: DISEASE ANALYTICS
-- ========================================

-- Query 1: Disease Trend Analysis with Window Functions
SELECT 
    d.disease_name,
    d.disease_category,
    TO_CHAR(dc.detection_date, 'YYYY-MM') AS month,
    COUNT(*) AS case_count,
    -- Running total
    SUM(COUNT(*)) OVER (
        PARTITION BY d.disease_id 
        ORDER BY TO_CHAR(dc.detection_date, 'YYYY-MM')
    ) AS cumulative_cases,
    -- Month-over-month growth
    LAG(COUNT(*)) OVER (
        PARTITION BY d.disease_id 
        ORDER BY TO_CHAR(dc.detection_date, 'YYYY-MM')
    ) AS previous_month_cases,
    -- Growth rate
    ROUND((COUNT(*) - LAG(COUNT(*)) OVER (
        PARTITION BY d.disease_id 
        ORDER BY TO_CHAR(dc.detection_date, 'YYYY-MM')
    )) / NULLIF(LAG(COUNT(*)) OVER (
        PARTITION BY d.disease_id 
        ORDER BY TO_CHAR(dc.detection_date, 'YYYY-MM')
    ), 0) * 100, 2) AS growth_rate_pct
FROM DISEASE_CASES dc
JOIN DISEASES d ON dc.disease_id = d.disease_id
GROUP BY d.disease_name, d.disease_category, d.disease_id, TO_CHAR(dc.detection_date, 'YYYY-MM')
ORDER BY month DESC, case_count DESC;

-- Query 2: Top 10 Diseases by Severity Score
SELECT 
    d.disease_name,
    d.disease_category,
    COUNT(*) AS total_cases,
    SUM(CASE WHEN dc.severity = 'CRITICAL' THEN 1 ELSE 0 END) AS critical_cases,
    SUM(CASE WHEN dc.severity = 'HIGH' THEN 1 ELSE 0 END) AS high_cases,
    -- Weighted severity score
    ROUND(
        (SUM(CASE WHEN dc.severity = 'CRITICAL' THEN 4
              WHEN dc.severity = 'HIGH' THEN 3
              WHEN dc.severity = 'MEDIUM' THEN 2
              ELSE 1 END) / COUNT(*)), 2
    ) AS avg_severity_score,
    -- Average affected area
    ROUND(AVG(dc.affected_area_percentage), 2) AS avg_affected_area,
    -- Rank by severity
    RANK() OVER (ORDER BY 
        SUM(CASE WHEN dc.severity = 'CRITICAL' THEN 4
              WHEN dc.severity = 'HIGH' THEN 3
              WHEN dc.severity = 'MEDIUM' THEN 2
              ELSE 1 END) / COUNT(*) DESC
    ) AS severity_rank
FROM DISEASE_CASES dc
JOIN DISEASES d ON dc.disease_id = d.disease_id
GROUP BY d.disease_name, d.disease_category
ORDER BY avg_severity_score DESC
FETCH FIRST 10 ROWS ONLY;

-- Query 3: Disease Resolution Performance
SELECT 
    d.disease_name,
    COUNT(*) AS total_cases,
    SUM(CASE WHEN dc.status = 'RESOLVED' THEN 1 ELSE 0 END) AS resolved_cases,
    ROUND((SUM(CASE WHEN dc.status = 'RESOLVED' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS resolution_rate,
    ROUND(AVG(CASE 
        WHEN dc.status = 'RESOLVED' 
        THEN (SELECT MIN(ta.application_date) - dc.detection_date 
              FROM TREATMENT_APPLICATIONS ta 
              WHERE ta.case_id = dc.case_id) * 24
        ELSE NULL 
    END), 2) AS avg_resolution_hours
FROM DISEASE_CASES dc
JOIN DISEASES d ON dc.disease_id = d.disease_id
GROUP BY d.disease_name
HAVING COUNT(*) >= 5
ORDER BY resolution_rate DESC;

-- ========================================
-- SECTION 2: TREATMENT ANALYTICS
-- ========================================

-- Query 4: Treatment Effectiveness Analysis
SELECT 
    t.treatment_name,
    t.treatment_type,
    COUNT(ta.application_id) AS total_applications,
    -- Success metrics
    SUM(CASE WHEN ta.application_status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN ta.application_status = 'FAILED' THEN 1 ELSE 0 END) AS failed,
    ROUND((SUM(CASE WHEN ta.application_status = 'COMPLETED' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS success_rate,
    -- Cost metrics
    SUM(ta.cost) AS total_cost,
    ROUND(AVG(ta.cost), 2) AS avg_cost_per_application,
    -- Efficiency metrics
    SUM(ta.area_treated_hectares) AS total_area_treated,
    ROUND(SUM(ta.cost) / SUM(ta.area_treated_hectares), 2) AS cost_per_hectare,
    -- Ranking
    DENSE_RANK() OVER (ORDER BY 
        (SUM(CASE WHEN ta.application_status = 'COMPLETED' THEN 1 ELSE 0 END) / COUNT(*)) DESC
    ) AS effectiveness_rank
FROM TREATMENTS t
JOIN TREATMENT_APPLICATIONS ta ON t.treatment_id = ta.treatment_id
GROUP BY t.treatment_name, t.treatment_type
ORDER BY success_rate DESC, total_applications DESC;

-- Query 5: Treatment Cost Trend Analysis
SELECT 
    TO_CHAR(ta.application_date, 'YYYY-MM') AS month,
    t.treatment_type,
    COUNT(*) AS applications,
    SUM(ta.cost) AS total_cost,
    ROUND(AVG(ta.cost), 2) AS avg_cost,
    -- Moving average (3 month)
    ROUND(AVG(SUM(ta.cost)) OVER (
        PARTITION BY t.treatment_type
        ORDER BY TO_CHAR(ta.application_date, 'YYYY-MM')
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_cost_3m,
    -- Cumulative cost
    SUM(SUM(ta.cost)) OVER (
        PARTITION BY t.treatment_type
        ORDER BY TO_CHAR(ta.application_date, 'YYYY-MM')
    ) AS cumulative_cost
FROM TREATMENT_APPLICATIONS ta
JOIN TREATMENTS t ON ta.treatment_id = t.treatment_id
GROUP BY TO_CHAR(ta.application_date, 'YYYY-MM'), t.treatment_type
ORDER BY month DESC, treatment_type;

-- ========================================
-- SECTION 3: INVENTORY ANALYTICS
-- ========================================

-- Query 6: Chemical Usage and Stock Analysis
SELECT 
    c.chemical_name,
    c.chemical_type,
    c.quantity_in_stock,
    c.reorder_level,
    c.unit_cost,
    -- Usage metrics
    NVL(usage.total_used, 0) AS total_used_last_30_days,
    NVL(usage.applications, 0) AS times_used,
    -- Stock status
    CASE 
        WHEN c.quantity_in_stock = 0 THEN 'OUT_OF_STOCK'
        WHEN c.quantity_in_stock <= c.reorder_level THEN 'LOW_STOCK'
        WHEN c.expiry_date <= SYSDATE + 30 THEN 'EXPIRING_SOON'
        ELSE 'ADEQUATE'
    END AS stock_status,
    -- Days until stockout (estimated)
    CASE 
        WHEN NVL(usage.total_used, 0) = 0 THEN NULL
        ELSE ROUND(c.quantity_in_stock / (NVL(usage.total_used, 0) / 30))
    END AS estimated_days_to_stockout,
    -- Reorder quantity recommendation
    GREATEST(c.reorder_level * 2 - c.quantity_in_stock, 0) AS recommended_reorder_qty
FROM CHEMICALS c
LEFT JOIN (
    SELECT 
        cu.chemical_id,
        SUM(cu.quantity_used) AS total_used,
        COUNT(DISTINCT cu.application_id) AS applications
    FROM CHEMICAL_USAGE cu
    JOIN TREATMENT_APPLICATIONS ta ON cu.application_id = ta.application_id
    WHERE ta.application_date >= SYSDATE - 30
    GROUP BY cu.chemical_id
) usage ON c.chemical_id = usage.chemical_id
ORDER BY 
    CASE 
        WHEN c.quantity_in_stock = 0 THEN 1
        WHEN c.quantity_in_stock <= c.reorder_level THEN 2
        WHEN c.expiry_date <= SYSDATE + 30 THEN 3
        ELSE 4
    END,
    c.chemical_name;

-- Query 7: Chemical Cost Analysis
SELECT 
    c.chemical_type,
    COUNT(DISTINCT c.chemical_id) AS chemical_count,
    SUM(c.quantity_in_stock * c.unit_cost) AS inventory_value,
    -- Usage and cost
    NVL(SUM(usage.total_used), 0) AS total_quantity_used,
    NVL(SUM(usage.total_used * c.unit_cost), 0) AS total_cost_consumed,
    -- Average per application
    ROUND(AVG(usage.avg_per_application), 2) AS avg_qty_per_application,
    -- ROI indicator
    ROUND(NVL(SUM(usage.total_used * c.unit_cost), 0) / 
          NULLIF(SUM(c.quantity_in_stock * c.unit_cost), 0) * 100, 2) AS turnover_rate_pct
FROM CHEMICALS c
LEFT JOIN (
    SELECT 
        cu.chemical_id,
        SUM(cu.quantity_used) AS total_used,
        AVG(cu.quantity_used) AS avg_per_application
    FROM CHEMICAL_USAGE cu
    JOIN TREATMENT_APPLICATIONS ta ON cu.application_id = ta.application_id
    WHERE ta.application_date >= SYSDATE - 90
    GROUP BY cu.chemical_id
) usage ON c.chemical_id = usage.chemical_id
GROUP BY c.chemical_type
ORDER BY total_cost_consumed DESC;

-- ========================================
-- SECTION 4: FARM PERFORMANCE ANALYTICS
-- ========================================

-- Query 8: Farmer Performance Dashboard
SELECT 
    f.farmer_name,
    COUNT(DISTINCT fld.field_id) AS total_fields,
    ROUND(SUM(fld.size_hectares), 2) AS total_area_hectares,
    -- Planting metrics
    COUNT(DISTINCT cp.planting_id) AS total_plantings,
    COUNT(DISTINCT CASE WHEN cp.status = 'GROWING' THEN cp.planting_id END) AS active_plantings,
    -- Disease metrics
    NVL(disease_data.total_cases, 0) AS disease_cases,
    NVL(disease_data.critical_cases, 0) AS critical_cases,
    -- Treatment metrics
    NVL(treatment_data.applications, 0) AS treatments_applied,
    NVL(treatment_data.total_cost, 0) AS treatment_cost,
    -- Efficiency
    ROUND(NVL(treatment_data.total_cost, 0) / NULLIF(SUM(fld.size_hectares), 0), 2) AS cost_per_hectare
FROM FARMERS f
LEFT JOIN FIELDS fld ON f.farmer_id = fld.farmer_id
LEFT JOIN CROP_PLANTINGS cp ON fld.field_id = cp.field_id
LEFT JOIN (
    SELECT 
        f2.farmer_id,
        COUNT(*) AS total_cases,
        SUM(CASE WHEN dc.severity = 'CRITICAL' THEN 1 ELSE 0 END) AS critical_cases
    FROM FARMERS f2
    JOIN FIELDS fld2 ON f2.farmer_id = fld2.farmer_id
    JOIN CROP_PLANTINGS cp2 ON fld2.field_id = cp2.field_id
    JOIN DISEASE_CASES dc ON cp2.planting_id = dc.planting_id
    GROUP BY f2.farmer_id
) disease_data ON f.farmer_id = disease_data.farmer_id
LEFT JOIN (
    SELECT 
        f3.farmer_id,
        COUNT(*) AS applications,
        SUM(ta.cost) AS total_cost
    FROM FARMERS f3
    JOIN FIELDS fld3 ON f3.farmer_id = fld3.farmer_id
    JOIN CROP_PLANTINGS cp3 ON fld3.field_id = cp3.field_id
    JOIN DISEASE_CASES dc3 ON cp3.planting_id = dc3.planting_id
    JOIN TREATMENT_APPLICATIONS ta ON dc3.case_id = ta.case_id
    GROUP BY f3.farmer_id
) treatment_data ON f.farmer_id = treatment_data.farmer_id
GROUP BY f.farmer_name, f.farmer_id, disease_data.total_cases, 
         disease_data.critical_cases, treatment_data.applications, treatment_data.total_cost
HAVING COUNT(DISTINCT fld.field_id) > 0
ORDER BY total_area_hectares DESC;

-- Query 9: Crop Health Analysis
SELECT 
    c.crop_name,
    c.crop_type,
    COUNT(cp.planting_id) AS total_plantings,
    -- Status distribution
    SUM(CASE WHEN cp.status = 'GROWING' THEN 1 ELSE 0 END) AS growing,
    SUM(CASE WHEN cp.status = 'HARVESTED' THEN 1 ELSE 0 END) AS harvested,
    SUM(CASE WHEN cp.status = 'FAILED' THEN 1 ELSE 0 END) AS failed,
    -- Disease incidence
    NVL(disease_stats.case_count, 0) AS disease_cases,
    ROUND(NVL(disease_stats.case_count, 0) / NULLIF(COUNT(cp.planting_id), 0) * 100, 2) AS disease_incidence_pct,
    -- Productivity metrics
    ROUND(AVG(cp.quantity_harvested / NULLIF(cp.quantity_planted, 0)), 2) AS avg_yield_ratio,
    -- Time metrics
    ROUND(AVG(cp.actual_harvest_date - cp.planting_date)) AS avg_growth_days
FROM CROPS c
LEFT JOIN CROP_PLANTINGS cp ON c.crop_id = cp.crop_id
LEFT JOIN (
    SELECT 
        c2.crop_id,
        COUNT(DISTINCT dc.case_id) AS case_count
    FROM CROPS c2
    JOIN CROP_PLANTINGS cp2 ON c2.crop_id = cp2.crop_id
    JOIN DISEASE_CASES dc ON cp2.planting_id = dc.planting_id
    GROUP BY c2.crop_id
) disease_stats ON c.crop_id = disease_stats.crop_id
GROUP BY c.crop_name, c.crop_type, c.crop_id, disease_stats.case_count
HAVING COUNT(cp.planting_id) > 0
ORDER BY total_plantings DESC;

-- ========================================
-- SECTION 5: STAFF PERFORMANCE ANALYTICS
-- ========================================

-- Query 10: Staff Productivity Analysis
SELECT 
    s.staff_name,
    s.role,
    -- Application metrics
    COUNT(ta.application_id) AS total_applications,
    ROUND(COUNT(ta.application_id) / 
          NULLIF(COUNT(DISTINCT TRUNC(ta.application_date)), 0), 2) AS avg_applications_per_day,
    -- Area coverage
    ROUND(SUM(ta.area_treated_hectares), 2) AS total_area_treated,
    ROUND(AVG(ta.area_treated_hectares), 2) AS avg_area_per_application,
    -- Success metrics
    SUM(CASE WHEN ta.application_status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN ta.application_status = 'FAILED' THEN 1 ELSE 0 END) AS failed,
    ROUND((SUM(CASE WHEN ta.application_status = 'COMPLETED' THEN 1 ELSE 0 END) / 
           NULLIF(COUNT(*), 0)) * 100, 2) AS success_rate,
    -- Cost metrics
    ROUND(SUM(ta.cost), 2) AS total_cost_handled,
    -- Ranking
    RANK() OVER (ORDER BY COUNT(ta.application_id) DESC) AS productivity_rank
FROM STAFF s
LEFT JOIN TREATMENT_APPLICATIONS ta ON s.staff_id = ta.staff_id
WHERE ta.application_date >= SYSDATE - 90
GROUP BY s.staff_name, s.role, s.staff_id
HAVING COUNT(ta.application_id) > 0
ORDER BY total_applications DESC;

-- ========================================
-- SECTION 6: AUDIT & COMPLIANCE ANALYTICS
-- ========================================

-- Query 11: Operation Audit Summary
SELECT 
    TO_CHAR(change_date, 'YYYY-MM-DD') AS operation_date,
    table_name,
    operation_type,
    operation_status,
    COUNT(*) AS operation_count,
    COUNT(DISTINCT changed_by) AS unique_users
FROM AUDIT_LOG
WHERE change_date >= SYSDATE - 30
GROUP BY TO_CHAR(change_date, 'YYYY-MM-DD'), table_name, operation_type, operation_status
ORDER BY operation_date DESC, operation_count DESC;

-- Query 12: Denied Operations Report
SELECT 
    table_name,
    operation_type,
    denial_reason,
    COUNT(*) AS denial_count,
    MIN(change_date) AS first_denial,
    MAX(change_date) AS last_denial,
    COUNT(DISTINCT changed_by) AS affected_users
FROM AUDIT_LOG
WHERE operation_status = 'DENIED'
  AND change_date >= SYSDATE - 30
GROUP BY table_name, operation_type, denial_reason
ORDER BY denial_count DESC;

-- ========================================
-- SECTION 7: PREDICTIVE ANALYTICS
-- ========================================

-- Query 13: Disease Forecast (Simple Linear Trend)
WITH monthly_cases AS (
    SELECT 
        d.disease_id,
        d.disease_name,
        TO_CHAR(dc.detection_date, 'YYYY-MM') AS month,
        COUNT(*) AS case_count,
        ROW_NUMBER() OVER (PARTITION BY d.disease_id ORDER BY TO_CHAR(dc.detection_date, 'YYYY-MM')) AS month_number
    FROM DISEASE_CASES dc
    JOIN DISEASES d ON dc.disease_id = d.disease_id
    WHERE dc.detection_date >= ADD_MONTHS(SYSDATE, -6)
    GROUP BY d.disease_id, d.disease_name, TO_CHAR(dc.detection_date, 'YYYY-MM')
)
SELECT 
    disease_name,
    month,
    case_count AS actual_cases,
    ROUND(AVG(case_count) OVER (
        PARTITION BY disease_id 
        ORDER BY month_number 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 0) AS moving_average_3m,
    -- Simple trend indicator
    CASE 
        WHEN case_count > LAG(case_count, 1) OVER (PARTITION BY disease_id ORDER BY month_number) 
        THEN 'INCREASING'
        WHEN case_count < LAG(case_count, 1) OVER (PARTITION BY disease_id ORDER BY month_number)
        THEN 'DECREASING'
        ELSE 'STABLE'
    END AS trend
FROM monthly_cases
ORDER BY disease_id, month DESC;

-- ========================================
-- END OF ANALYTICAL QUERIES
-- ========================================