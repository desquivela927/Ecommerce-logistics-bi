# E-Commerce Logistics BI Analysis

## Business Context
An international e-commerce company specializing in electronics is experiencing 
critical delivery performance issues. This project analyzes 10,999 shipments to 
identify the root causes of delays and provide actionable recommendations for both 
Operations and Commercial leadership.

**Central business question:**
> What operational and commercial factors explain delivery delays, and what concrete 
> decisions should the company make?

---

## Tools & Technologies
- **SQL** - Data extraction and business intelligence queries (DB Browser for SQLite)
- **Python** - Exploratory analysis, visualizations and automated PDF report (Pandas, Matplotlib, Seaborn, fpdf2)
- **Power BI** - Executive dashboard with dual business perspective

---

## Project Structure
```
ecommerce-logistics-bi/
├── Data/
│   └── data_source.md
├── PowerBI/
│   └── logistics_dashboard.pbix
├── Python/
│   ├── E_commerce_exploratory_analysis.ipynb
│   ├── generate_report.py
│   ├── correlation_matrix.png
│   ├── delay_by_discount.png
│   ├── delay_by_weight.png
│   ├── delay_importance_shipment.png
│   └── executive_dashboard.png
├── Reports/
│   └── executive_report.pdf
├── SQL/
│   └── operations_analysis.sql
└── README.md
```

---

## Key Findings

### Operations Perspective
| Factor | Finding |
|--------|---------|
| Warehouse blocks | All blocks show similar delay rates (58.6% - 60.2%) — systemic issue confirmed |
| Shipment mode | Road, Ship and Flight perform almost identically - mode does not explain delays |
| Product weight | 2.5-4kg range shows 99.9% delay rate vs 43.1% for Heavy (4-6kg) |
| Discount policy | **Every order with discount above 10% has 100% delay rate** |

### Commercial Perspective
| Factor | Finding |
|--------|---------|
| Customer calls | More calls = fewer delays - informal prioritization detected |
| Product importance | High importance products show worst delay rate (64.98%) |
| Customer loyalty | Frequent buyers receive same service level as new customers |
| Warehouse ranking | Warehouse A performs best - marginal difference across all blocks |

---

## Strategic Recommendations

🔴 **IMMEDIATE** - Cap discounts at 10% or build operational capacity before offering higher discounts. Current policy guarantees delivery failure.

🟠 **SHORT TERM** - Investigate 2.5-4kg weight range for packaging or routing issues. This segment shows near-total delivery failure.

🟠 **SHORT TERM** - Integrate product importance flag into dispatch workflow. High importance products must trigger operational priority.

🔵 **MEDIUM TERM** - Implement loyalty service tiers. Frequent buyers should receive measurable service advantages.

🔵 **MEDIUM TERM** - Replace informal call-based prioritization with a formal rule-based system.

---

## Executive Dashboard

### Operations Overview
![Operations Dashboard](PowerBI/Operations%20overview.png)

### Customer Intelligence
![Customer Intelligence](PowerBI/Customer%20intelligence.png)

---

## Automated Report
This project includes a Python script that automatically generates a full executive 
PDF report combining KPIs, findings and recommendations.

```bash
python generate_report.py
```

---

## Dataset
- **Source:** [E-Commerce Shipping Data — Kaggle](https://www.kaggle.com/datasets/prachi13/customer-analytics)
- **Records:** 10,999 shipments
- **Columns:** 12 variables (warehouse, shipment mode, weight, discount, customer rating, etc.)

---

*Project by Daniel Esquivel | BI Analyst Portfolio*
*Tools: SQL - Python - Power BI*
