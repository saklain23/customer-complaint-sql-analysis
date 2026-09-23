# Consumer Complaints SQL Analysis

End-to-end SQL analysis on the **CFPB Consumer Complaints** dataset (real data) — covering basic aggregations, CASE WHEN, date functions, subqueries, CTEs, and advanced window functions (ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, FIRST_VALUE, LAST_VALUE).

---

## Overview

This project demonstrates a wide range of SQL skills — from basic `SELECT` and `GROUP BY` to advanced window functions and CTEs. The dataset contains real consumer complaints filed against financial companies.

**Tools:** PostgreSQL, Git & GitHub

---

## Dataset

Table `consumer_complaints` with the following columns:

| Column | Description |
|--------|-------------|
| complaint_id | Unique complaint ID (Primary Key) |
| date_received | Date complaint was received |
| product_name | Financial product category |
| sub_product | Sub-category of product |
| issue | Complaint issue |
| sub_issue | Sub-category of issue |
| consumer_complaint_narrative | Complaint description |
| company_public_response | Company's response |
| company | Company name |
| state_name | US state |
| zip_code | ZIP code |
| tags | Complaint tags |
| consumer_consent_provided | Consent flag |
| submitted_via | Channel (Web, Email, Fax, etc.) |
| date_sent | Date sent to company |
| company_response_to_consumer | Response type |
| timely_response | Whether response was timely (Yes/No) |
| consumer_disputed | Whether consumer disputed (Yes/No) |

---

## Analysis Covered (82 Queries)

### Basic Queries
- Total complaints count
- Top 10 companies by complaints
- Product-wise breakdown
- Unique companies, states, products counts
- Top 10 states, issues, dates

### WHERE / HAVING
- Timely response filtered
- Disputed complaints by product
- State-specific complaints
- Companies with over 1000 complaints

### CASE WHEN
- Company-wise timely response Yes/No
- Product-wise dispute Yes/No
- Disputed percentage per company

### Date Functions
- Year-wise complaints
- Month-wise complaints
- Day with most complaints

### Percentage Analysis
- Company-wise percentage
- Product-wise percentage
- Timely response percentage

### Subqueries (FROM)
- Top 10 states combined percentage
- Top 5 products combined percentage
- Overall summary counts

### CTEs (WITH clause)
- Top companies with dispute percentage
- Product-wise timely response
- State-wise percentages

### Window Functions
- ROW_NUMBER / RANK / DENSE_RANK
- Top N per group
- Running totals
- LAG / LEAD (previous/next rows)
- FIRST_VALUE / LAST_VALUE
- Month-over-month percentage change

---

## SQL Skills Demonstrated

| Skill | Usage |
|-------|-------|
| Aggregations (COUNT, SUM, MIN, MAX) | Statistics |
| GROUP BY + HAVING | Segmentation |
| CASE WHEN | Conditional logic |
| Date Functions (EXTRACT, DATE_TRUNC, TO_CHAR) | Time analysis |
| Subqueries | Derived tables |
| CTEs (WITH) | Readable complex queries |
| ROW_NUMBER, RANK, DENSE_RANK | Ranking |
| LAG, LEAD | Row comparison |
| FIRST_VALUE, LAST_VALUE | Window analytics |
| SUM() OVER | Running totals |
| ILIKE / LIKE | Pattern matching |

---

## Key Insights

- Total complaints analyzed across multiple companies and products
- Top 10 companies account for significant complaint volume
- Most complaints are submitted via Web
- Timely response rate is measurable per company
- Certain products have higher dispute rates
- Month-over-month trends reveal complaint patterns

---

## Files

| File | Description |
|------|-------------|
| `README.md` | Project documentation |
| `consumer_complaints_analysis.sql` | All 82 SQL queries |
| `ConsumerComplaints.csv` | Dataset (CFPB real data) |

---

## How to Use

1. Create the database and table using `consumer_complaints_analysis.sql`
2. Load the dataset from `ConsumerComplaints.csv`
3. Run the analysis queries

---

## Author

**Saklain Alam**  
Data Analyst | SQL | PostgreSQL | Python | Power BI | Tableau
