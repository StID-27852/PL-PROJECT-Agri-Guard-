# Business Intelligence Requirements
## AgriGuard+ Analytics & Reporting

---

## 1. Executive Summary

AgriGuard+ BI provides data-driven insights for agricultural decision-making through real-time dashboards, predictive analytics, and comprehensive reporting.

---

## 2. Key Performance Indicators (KPIs)

### 2.1 Disease Management KPIs
| KPI | Formula | Target | Frequency |
|-----|---------|--------|-----------|
| Disease Detection Rate | Cases / 100 hectares | < 5 cases | Weekly |
| Treatment Success Rate | Resolved / Total Cases × 100 | > 85% | Monthly |
| Average Response Time | Avg(Treatment Date - Detection Date) | < 48 hours | Daily |
| Disease Recurrence Rate | Repeat Cases / Total Cases × 100 | < 15% | Monthly |

### 2.2 Inventory Management KPIs
| KPI | Formula | Target | Frequency |
|-----|---------|--------|-----------|
| Stock Availability | Available Items / Total Items × 100 | > 95% | Daily |
| Inventory Turnover | Annual Usage / Avg Stock | 4-6 cycles/year | Monthly |
| Stockout Incidents | Days Out of Stock | 0 days | Daily |
| Chemical Expiry Rate | Expired / Total × 100 | < 2% | Monthly |

### 2.3 Financial KPIs
| KPI | Formula | Target | Frequency |
|-----|---------|--------|-----------|
| Cost per Hectare | Total Cost / Total Hectares | Minimize | Monthly |
| Treatment ROI | (Yield Gain - Cost) / Cost × 100 | > 200% | Seasonal |
| Budget Variance | Actual - Budget | ±10% | Monthly |

### 2.4 Operational KPIs
| KPI | Formula | Target | Frequency |
|-----|---------|--------|-----------|
| Staff Productivity | Applications / Staff / Day | 8-12 | Weekly |
| Field Coverage | Treated Hectares / Total Hectares × 100 | 100% | Daily |
| Data Quality Score | Complete Records / Total × 100 | > 98% | Weekly |

---

## 3. Dashboard Requirements

### 3.1 Executive Dashboard
**Target Users:** Farm managers, Ministry of Agriculture  
**Update Frequency:** Daily at 6 AM  
**Key Metrics:**
- Total active disease cases (current)
- Treatment success rate (30-day rolling)
- Chemical inventory status (real-time)
- Cost trend (monthly comparison)
- Top 5 diseases by occurrence
- Staff performance summary

**Visual Elements:**
- KPI cards with trend indicators
- Line chart: Disease cases over time
- Pie chart: Disease distribution by category
- Bar chart: Treatment costs by type
- Heat map: Disease hotspots by region

### 3.2 Disease Management Dashboard
**Target Users:** Agronomists, Field supervisors  
**Update Frequency:** Real-time  
**Key Metrics:**
- Active cases by severity (CRITICAL/HIGH/MEDIUM/LOW)
- Disease spread rate
- Treatment effectiveness by disease type
- Average time to resolution
- Disease recurrence patterns

**Visual Elements:**
- Status cards: Critical, High, Medium, Low cases
- Timeline: Disease progression
- Map: Geographic distribution
- Sankey diagram: Disease → Treatment → Outcome flow
- Trend analysis: Seasonal patterns

### 3.3 Inventory Management Dashboard
**Target Users:** Inventory managers, Procurement  
**Update Frequency:** Real-time  
**Key Metrics:**
- Current stock levels vs. reorder points
- Chemicals nearing expiry (30/60/90 days)
- Usage velocity by chemical
- Stock-out risk alerts
- Purchase order recommendations

**Visual Elements:**
- Stock level gauges
- Expiry countdown timers
- Usage trend lines
- Alert notifications (red/yellow/green)
- Reorder suggestions table

### 3.4 Treatment Cost Analysis Dashboard
**Target Users:** Finance department, Farm managers  
**Update Frequency:** Daily  
**Key Metrics:**
- Total treatment expenditure (MTD/YTD)
- Cost per hectare treated
- Chemical cost breakdown
- Labor cost vs. material cost
- Budget vs. actual spending

**Visual Elements:**
- Cost trend line graph
- Pie chart: Cost distribution
- Budget variance bar chart
- Cumulative cost curve
- ROI calculator

### 3.5 Audit & Compliance Dashboard
**Target Users:** System administrators, Auditors  
**Update Frequency:** Real-time  
**Key Metrics:**
- Total operations logged (daily/weekly/monthly)
- Denied operation attempts
- User activity summary
- Compliance violations
- System access patterns

**Visual Elements:**
- Operation count cards
- Denial rate trend
- User activity heat map
- Compliance score gauge
- Alert log table

---

## 4. Report Requirements

### 4.1 Scheduled Reports

#### Daily Reports
1. **Disease Detection Report** (6 AM)
   - New cases detected in last 24 hours
   - Severity distribution
   - Affected crops and locations
   - Recommended immediate actions

2. **Low Stock Alert** (7 AM)
   - Chemicals below reorder level
   - Expected stockout date
   - Recommended purchase quantities

#### Weekly Reports
1. **Treatment Effectiveness Report** (Monday 8 AM)
   - Success rate by treatment type
   - Resolution time analysis
   - Cost effectiveness comparison

2. **Staff Performance Report** (Friday 5 PM)
   - Applications completed per staff
   - Quality metrics
   - Workload distribution

#### Monthly Reports
1. **Executive Summary** (1st of month)
   - KPI dashboard snapshot
   - Month-over-month comparisons
   - Key achievements and challenges
   - Recommendations

2. **Financial Performance** (5th of month)
   - Total expenditure breakdown
   - Budget variance analysis
   - Cost optimization opportunities

### 4.2 Ad-Hoc Reports
- Custom date range analysis
- Specific disease outbreak investigation
- Farmer-specific performance
- Chemical usage patterns
- Audit trail exports

---

## 5. Data Sources

### 5.1 Operational Tables
- DISEASE_CASES (real-time disease data)
- TREATMENT_APPLICATIONS (treatment execution)
- CHEMICALS (inventory status)
- AUDIT_LOG (all operations)

### 5.2 Analytical Views
- disease_case_analytics (window functions)
- treatment_performance_analytics (cost analysis)

### 5.3 External Data (Future)
- Weather API (temperature, rainfall)
- Market prices (chemical costs)
- Government databases (crop statistics)

---

## 6. Technical Requirements

### 6.1 Data Refresh
- **Real-time:** Direct database queries for dashboards
- **Scheduled:** Nightly ETL for historical analysis
- **On-demand:** User-triggered report generation

### 6.2 Data Retention
- **Hot data:** Last 3 months (operational database)
- **Warm data:** 3-12 months (indexed, compressed)
- **Cold data:** 1-7 years (archived, audit compliance)

### 6.3 Performance Targets
- Dashboard load time: < 3 seconds
- Query response: < 5 seconds
- Report generation: < 30 seconds
- Data refresh: < 1 minute

---

## 7. User Access & Security

### 7.1 Role-Based Access
| Role | Access Level | Dashboards |
|------|--------------|------------|
| System Admin | Full access | All |
| Farm Manager | Read/Write | Executive, Disease, Inventory |
| Agronomist | Read/Write | Disease, Treatment |
| Inventory Manager | Read/Write | Inventory |
| Finance | Read-only | Cost Analysis |
| Auditor | Read-only | Audit & Compliance |

### 7.2 Data Privacy
- Personal farmer information redacted in shared reports
- Sensitive cost data restricted by role
- Audit logs access controlled
- Export capabilities limited by role

---

## 8. Implementation Priorities

### Phase 1 (Current - MVP)
- Analytical SQL queries
- Window function views
- Basic KPI calculations
- Sample dashboard mockups

### Phase 2 (Next 3 months)
- Oracle APEX dashboards
- Automated report generation
- Email alerting system
- Mobile-responsive views

### Phase 3 (6-12 months)
- Advanced predictive analytics
- Machine learning integration
- Real-time streaming dashboards
- External data integration

---

## 9. Success Metrics

### 9.1 User Adoption
- Target: 80% daily active users within 3 months
- Metric: Dashboard views per user per day
- Goal: > 3 dashboard views per user

### 9.2 Decision Impact
- Target: 25% reduction in crop loss
- Metric: Yield improvement year-over-year
- Goal: Data-driven decisions > 90% of cases

### 9.3 Operational Efficiency
- Target: 30% reduction in response time
- Metric: Hours from detection to treatment
- Goal: < 24 hours average

---

## 10. Stakeholder Sign-Off

| Stakeholder | Role | Approval Date |
|-------------|------|---------------|
| Eric Maniraguha | Project Supervisor | [Date] |
| Ineza Sonia | Developer | December 7, 2025 |
| [Name] | Farm Manager Representative | [Date] |
| [Name] | IT Department | [Date] |

---

**Document Version:** 1.0  
**Last Updated:** December 7, 2025  
**Next Review:** March 7, 2026

---
