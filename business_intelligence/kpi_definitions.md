# KPI Definitions & Calculations
## AgriGuard+ Key Performance Indicators

---

## 1. Disease Management KPIs

### 1.1 Disease Detection Rate
**Definition:** Number of disease cases detected per 100 hectares of cultivated land.

**Formula:**
```sql
SELECT 
    (COUNT(dc.case_id) / SUM(f.size_hectares) * 100) AS detection_rate_per_100ha
FROM DISEASE_CASES dc
JOIN CROP_PLANTINGS cp ON dc.planting_id = cp.planting_id
JOIN FIELDS f ON cp.field_id = f.field_id
WHERE dc.detection_date >= ADD_MONTHS(SYSDATE, -1);
```

**Target:** < 5 cases per 100 hectares  
**Frequency:** Weekly  
**Owner:** Agronomist Team

---

### 1.2 Treatment Success Rate
**Definition:** Percentage of disease cases successfully resolved after treatment.

**Formula:**
```sql
SELECT 
    ROUND((SUM(CASE WHEN status = 'RESOLVED' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS success_rate
FROM DISEASE_CASES
WHERE detection_date >= ADD_MONTHS(SYSDATE, -1);
```

**Target:** > 85%  
**Frequency:** Monthly  
**Owner:** Treatment Team

---

### 1.3 Average Response Time
**Definition:** Average time (in hours) from disease detection to first treatment application.

**Formula:**
```sql
SELECT 
    ROUND(AVG((ta.application_date - dc.detection_date) * 24), 2) AS avg_response_hours
FROM DISEASE_CASES dc
JOIN TREATMENT_APPLICATIONS ta ON dc.case_id = ta.case_id
WHERE dc.detection_date >= ADD_MONTHS(SYSDATE, -1);
```

**Target:** < 48 hours  
**Frequency:** Daily  
**Owner:** Operations Manager

---

### 1.4 Disease Outbreak Status
**Definition:** Classification of disease severity based on recent case frequency.

**Formula:**
```sql
SELECT 
    d.disease_name,
    COUNT(*) as case_count,
    CASE 
        WHEN COUNT(*) >= 5 THEN 'OUTBREAK'
        WHEN COUNT(*) >= 3 THEN 'WARNING'
        ELSE 'NORMAL'
    END as outbreak_status
FROM DISEASE_CASES dc
JOIN DISEASES d ON dc.disease_id = d.disease_id
WHERE dc.detection_date >= SYSDATE - 30
GROUP BY d.disease_name;
```

**Levels:** NORMAL / WARNING / OUTBREAK  
**Frequency:** Daily  
**Owner:** Disease Surveillance Team

---

## 2. Inventory Management KPIs

### 2.1 Stock Availability Rate
**Definition:** Percentage of chemicals currently available (not out of stock).

**Formula:**
```sql
SELECT 
    ROUND((SUM(CASE WHEN status IN ('AVAILABLE', 'LOW_STOCK') THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS availability_rate
FROM CHEMICALS;
```

**Target:** > 95%  
**Frequency:** Daily  
**Owner:** Inventory Manager

---

### 2.2 Inventory Turnover Ratio
**Definition:** How many times inventory is used and replenished annually.

**Formula:**
```sql
SELECT 
    c.chemical_name,
    (SUM(cu.quantity_used) * 12 / AVG(c.quantity_in_stock)) AS annual_turnover
FROM CHEMICALS c
JOIN CHEMICAL_USAGE cu ON c.chemical_id = cu.chemical_id
WHERE cu.application_id IN (
    SELECT application_id FROM TREATMENT_APPLICATIONS 
    WHERE application_date >= ADD_MONTHS(SYSDATE, -1)
)
GROUP BY c.chemical_name;
```

**Target:** 4-6 turnovers per year  
**Frequency:** Monthly  
**Owner:** Supply Chain Manager

---

### 2.3 Stock-Out Days
**Definition:** Total days with zero stock for any critical chemical.

**Formula:**
```sql
-- This would require daily stock snapshots
-- Simplified version:
SELECT 
    chemical_name,
    CASE 
        WHEN quantity_in_stock = 0 THEN 1
        ELSE 0
    END as is_stockout
FROM CHEMICALS
WHERE chemical_type IN ('FUNGICIDE', 'PESTICIDE');
```

**Target:** 0 days  
**Frequency:** Daily  
**Owner:** Procurement Team

---

### 2.4 Expiry Rate
**Definition:** Percentage of chemicals that expired before use.

**Formula:**
```sql
SELECT 
    ROUND((SUM(CASE WHEN status = 'EXPIRED' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS expiry_rate
FROM CHEMICALS
WHERE created_date >= ADD_MONTHS(SYSDATE, -12);
```

**Target:** < 2%  
**Frequency:** Monthly  
**Owner:** Inventory Manager

---

## 3. Financial KPIs

### 3.1 Cost Per Hectare Treated
**Definition:** Average cost to treat one hectare of land.

**Formula:**
```sql
SELECT 
    ROUND(SUM(ta.cost) / SUM(ta.area_treated_hectares), 2) AS cost_per_hectare
FROM TREATMENT_APPLICATIONS ta
WHERE ta.application_date >= ADD_MONTHS(SYSDATE, -1);
```

**Target:** Minimize (benchmark: RWF 15,000/ha)  
**Frequency:** Monthly  
**Owner:** Finance Manager

---

### 3.2 Treatment Cost Distribution
**Definition:** Breakdown of costs by treatment type.

**Formula:**
```sql
SELECT 
    t.treatment_type,
    SUM(ta.cost) as total_cost,
    ROUND((SUM(ta.cost) / (SELECT SUM(cost) FROM TREATMENT_APPLICATIONS WHERE application_date >= ADD_MONTHS(SYSDATE, -1))) * 100, 2) AS percentage
FROM TREATMENT_APPLICATIONS ta
JOIN TREATMENTS t ON ta.treatment_id = t.treatment_id
WHERE ta.application_date >= ADD_MONTHS(SYSDATE, -1)
GROUP BY t.treatment_type
ORDER BY total_cost DESC;
```

**Target:** Balanced distribution  
**Frequency:** Monthly  
**Owner:** Cost Controller

---

### 3.3 Budget Variance
**Definition:** Difference between budgeted and actual spending.

**Formula:**
```sql
-- Assumes budget table exists
SELECT 
    budget_period,
    budgeted_amount,
    actual_amount,
    (actual_amount - budgeted_amount) as variance,
    ROUND(((actual_amount - budgeted_amount) / budgeted_amount) * 100, 2) as variance_percentage
FROM (
    SELECT 
        TO_CHAR(application_date, 'YYYY-MM') as budget_period,
        50000000 as budgeted_amount, -- Example: 50M RWF monthly budget
        SUM(cost) as actual_amount
    FROM TREATMENT_APPLICATIONS
    WHERE application_date >= TRUNC(SYSDATE, 'YEAR')
    GROUP BY TO_CHAR(application_date, 'YYYY-MM')
);
```

**Target:** ±10% variance  
**Frequency:** Monthly  
**Owner:** Finance Director

---

## 4. Operational KPIs

### 4.1 Staff Productivity
**Definition:** Average number of treatment applications per staff member per day.

**Formula:**
```sql
SELECT 
    s.staff_name,
    s.role,
    COUNT(ta.application_id) as total_applications,
    ROUND(COUNT(ta.application_id) / COUNT(DISTINCT TRUNC(ta.application_date)), 2) as avg_applications_per_day
FROM STAFF s
JOIN TREATMENT_APPLICATIONS ta ON s.staff_id = ta.staff_id
WHERE ta.application_date >= ADD_MONTHS(SYSDATE, -1)
GROUP BY s.staff_name, s.role
ORDER BY avg_applications_per_day DESC;
```

**Target:** 8-12 applications per day  
**Frequency:** Weekly  
**Owner:** HR Manager

---

### 4.2 Field Coverage Rate
**Definition:** Percentage of total farm area receiving treatment when needed.

**Formula:**
```sql
SELECT 
    ROUND((SUM(DISTINCT ta.area_treated_hectares) / 
           (SELECT SUM(size_hectares) FROM FIELDS)) * 100, 2) AS coverage_rate
FROM TREATMENT_APPLICATIONS ta
WHERE ta.application_date >= ADD_MONTHS(SYSDATE, -1);
```

**Target:** 100% (when disease detected)  
**Frequency:** Daily  
**Owner:** Operations Manager

---

### 4.3 Data Completeness Score
**Definition:** Percentage of records with all required fields populated.

**Formula:**
```sql
SELECT
'DISEASE_CASES' as table_name,
ROUND((SUM(CASE 
    WHEN planting_id IS NOT NULL 
    AND disease_id IS NOT NULL 
    AND severity IS NOT NULL 
    AND affected_area_percentage IS NOT NULL 
    THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as completeness_score