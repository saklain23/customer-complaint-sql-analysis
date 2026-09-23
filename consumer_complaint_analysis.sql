-- ============================================
-- CONSUMER COMPLAINTS — SQL ANALYSIS PROJECT
-- ============================================
-- Dataset : CFPB Consumer Complaints (Real data)

-- Create database
CREATE DATABASE consumer_complaints;
-- Create database
CREATE DATABASE consumer_complaints;

-- Create table (drop if exists)
DROP TABLE IF EXISTS consumer_complaints;
CREATE TABLE consumer_complaints (
    date_received                    DATE,
    product_name                     VARCHAR(255),
    sub_product                      VARCHAR(255),
    issue                            VARCHAR(255),
    sub_issue                        VARCHAR(255),
    consumer_complaint_narrative     TEXT,
    company_public_response          TEXT,
    company                          VARCHAR(255),
    state_name                       VARCHAR(100),
    zip_code                         VARCHAR(10),
    tags                             VARCHAR(255),
    consumer_consent_provided        VARCHAR(50),
    submitted_via                    VARCHAR(50),
    date_sent                        DATE,
    company_response_to_consumer     VARCHAR(255),
    timely_response                  VARCHAR(10),
    consumer_disputed                VARCHAR(10),
    complaint_id                     BIGINT PRIMARY KEY
);

-- Check table (empty)
SELECT * FROM consumer_complaints;

-- Upload CSV data
COPY consumer_complaints (date_received, product_name, sub_product, issue, sub_issue, consumer_complaint_narrative, company_public_response, company, state_name, zip_code, tags, consumer_consent_provided, submitted_via, date_sent, company_response_to_consumer, timely_response, consumer_disputed, complaint_id)
FROM 'ConsumerComplaints.csv' DELIMITER ',' CSV HEADER;

-- Check data after upload
SELECT * FROM consumer_complaints;

-- Check NULL values
SELECT COUNT(*) FILTER (WHERE product_name IS NULL) AS null_products,
       COUNT(*) FILTER (WHERE complaint_id IS NULL) AS null_complaint
FROM consumer_complaints;

-- Check duplicate complaint_id
SELECT complaint_id, COUNT(*)
FROM consumer_complaints
GROUP BY complaint_id
HAVING COUNT(*) > 1;

-- ============================================
-- BASIC QUERIES
-- ============================================

-- Q1: Total complaints
SELECT COUNT(*) FROM consumer_complaints;

-- Q2: Top 10 companies by complaints
SELECT company, COUNT(*) AS total
FROM consumer_complaints
GROUP BY company
ORDER BY total DESC LIMIT 10;

-- Q3: Product-wise breakdown
SELECT product_name, COUNT(*) AS total
FROM consumer_complaints
GROUP BY product_name
ORDER BY total DESC LIMIT 10;

-- Q4: Unique companies count
SELECT COUNT(DISTINCT company) AS total 
FROM consumer_complaints;

-- Q5: Unique states count
SELECT COUNT(DISTINCT state_name) FROM consumer_complaints;

-- Q6: Unique products count
SELECT COUNT(DISTINCT product_name) FROM consumer_complaints;

-- Q7: Top 10 states by complaints
SELECT state_name, COUNT(*) AS total
FROM consumer_complaints
GROUP BY state_name
ORDER BY total DESC LIMIT 10;

-- Q8: Count by submitted_via
SELECT submitted_via, COUNT(*) AS total
FROM consumer_complaints
GROUP BY submitted_via
ORDER BY total DESC LIMIT 10;

-- Q9: Top 10 issues
SELECT issue, COUNT(*) AS total
FROM consumer_complaints
GROUP BY issue
ORDER BY total DESC LIMIT 10;

-- Q10: Top 10 dates by complaints
SELECT date_received, COUNT(*) AS total
FROM consumer_complaints
GROUP BY date_received
ORDER BY total DESC LIMIT 10;

-- ============================================
-- WHERE / HAVING
-- ============================================

-- Q11: Timely response = Yes, top 10 companies
SELECT company, COUNT(*) AS total
FROM consumer_complaints
WHERE timely_response = 'Yes'
GROUP BY company
ORDER BY total DESC LIMIT 10;

-- Q12: Disputed complaints, product-wise
SELECT product_name, COUNT(*) AS total
FROM consumer_complaints
WHERE consumer_disputed = 'Yes'
GROUP BY product_name;

-- Q13: Complaints from California
SELECT COUNT(*) AS total
FROM consumer_complaints
WHERE state_name = 'CA';

-- Q14: Companies with more than 1000 complaints
SELECT company, COUNT(*) AS total
FROM consumer_complaints
GROUP BY company
HAVING COUNT(*) > 1000
ORDER BY total DESC;

-- ============================================
-- CASE WHEN
-- ============================================

-- Q15: Company-wise timely Yes/No count
SELECT company,
       SUM(CASE WHEN timely_response = 'Yes' THEN 1 ELSE 0 END) AS timely_response_yes,
       SUM(CASE WHEN timely_response = 'No' THEN 1 ELSE 0 END) AS timely_response_no
FROM consumer_complaints
GROUP BY company
ORDER BY company;

-- Q16: Product-wise disputed Yes/No count
SELECT product_name,
       SUM(CASE WHEN consumer_disputed = 'Yes' THEN 1 ELSE 0 END) AS c_disputed_yes,
       SUM(CASE WHEN consumer_disputed = 'No' THEN 1 ELSE 0 END) AS c_disputed_no
FROM consumer_complaints
GROUP BY product_name
ORDER BY product_name;

-- Q17: Company-wise disputed percentage
SELECT company,
       100.0 * SUM(CASE WHEN consumer_disputed = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) AS disputed_act
FROM consumer_complaints
GROUP BY company;

-- ============================================
-- DATE FUNCTIONS
-- ============================================

-- Q18: Year-wise complaints count
SELECT EXTRACT(YEAR FROM date_received) AS complaint_year,
       COUNT(*) AS total
FROM consumer_complaints
GROUP BY EXTRACT(YEAR FROM date_received)
ORDER BY complaint_year DESC;

-- Q19: Month-wise complaints count
SELECT TO_CHAR(DATE_TRUNC('MONTH', date_received), 'YYYY-MM') AS complaint_month,
       COUNT(*) AS total
FROM consumer_complaints
GROUP BY DATE_TRUNC('MONTH', date_received)
ORDER BY DATE_TRUNC('MONTH', date_received) DESC;

-- Q20: Day with most complaints
SELECT TO_CHAR(DATE_TRUNC('DAY', date_received), 'YYYY-DD') AS complaint_day,
       COUNT(*) AS total
FROM consumer_complaints
GROUP BY DATE_TRUNC('DAY', date_received)
ORDER BY complaint_day DESC LIMIT 1;

-- ============================================
-- PERCENTAGE
-- ============================================

-- Q21: Company-wise percentage of total
SELECT company,
       COUNT(*) AS total,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM consumer_complaints), 2) AS pct
FROM consumer_complaints
GROUP BY company
ORDER BY total DESC LIMIT 10;

-- Q22: Product-wise percentage of total
SELECT product_name,
       COUNT(*) AS total,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM consumer_complaints), 2) AS pct
FROM consumer_complaints
GROUP BY product_name
ORDER BY total DESC;

-- Q23: Top state percentage of total
SELECT state_name,
       COUNT(*) AS total,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM consumer_complaints), 2) AS pct
FROM consumer_complaints
GROUP BY state_name
ORDER BY total DESC LIMIT 1;

-- Q24: Timely response percentage
SELECT timely_response,
       COUNT(*) AS total,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM consumer_complaints), 2) AS pct
FROM consumer_complaints
GROUP BY timely_response
ORDER BY total DESC;

-- ============================================
-- SUBQUERY IN FROM
-- ============================================

-- Q25: Top 10 states — combined total and %
SELECT SUM(total) AS top10_total,
       ROUND(SUM(pct), 2) AS top10_pct
FROM (
    SELECT state_name,
           COUNT(*) AS total,
           ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM consumer_complaints), 2) AS pct
    FROM consumer_complaints
    GROUP BY state_name
    ORDER BY total DESC
    LIMIT 10
) AS sub;

-- Q26: Top 10 states — combined % (cleaner)
SELECT SUM(total) AS top10_total,
       ROUND(100.0 * SUM(total) / (SELECT COUNT(*) FROM consumer_complaints), 2) AS top10_pct
FROM (
    SELECT state_name, COUNT(*) AS total
    FROM consumer_complaints
    GROUP BY state_name
    ORDER BY total DESC
    LIMIT 10
) AS sub;

-- Q27: Top 5 products — combined %
SELECT SUM(total) AS top5_total,
       ROUND(100.0 * SUM(total) / (SELECT COUNT(*) FROM consumer_complaints), 2) AS top5_pct
FROM (
    SELECT product_name, COUNT(*) AS total
    FROM consumer_complaints
    GROUP BY product_name
    ORDER BY total DESC
    LIMIT 5
) AS sub;

-- Q28: Overall summary — 4 counts in one query
SELECT COUNT(*) AS total_complaints,
       COUNT(DISTINCT state_name) AS total_states,
       COUNT(DISTINCT company) AS total_companies,
       COUNT(DISTINCT product_name) AS total_products
FROM consumer_complaints;

-- Q29: Overall summary — 8 counts in one query
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT state_name) AS states,
       COUNT(DISTINCT company) AS companies,
       COUNT(DISTINCT product_name) AS products,
       COUNT(DISTINCT issue) AS issues,
       COUNT(DISTINCT submitted_via) AS channels,
       COUNT(DISTINCT timely_response) AS timely_options,
       COUNT(DISTINCT consumer_disputed) AS dispute_options
FROM consumer_complaints;

-- ============================================
-- CTE (WITH clause)
-- ============================================

-- Q30: Top 10 companies with dispute percentage (CTE)
WITH complaint_stats AS (
    SELECT company,
           COUNT(*) AS total_complaint,
           SUM(CASE WHEN consumer_disputed = 'Yes' THEN 1 ELSE 0 END) AS disputed_count
    FROM consumer_complaints
    GROUP BY company
)
SELECT company,
       total_complaint,
       disputed_count,
       ROUND(100.0 * disputed_count / total_complaint, 2) AS total_pct
FROM complaint_stats
ORDER BY total_complaint DESC
LIMIT 10;

-- Q31: Product-wise timely No percentage (CTE)
WITH product_stats AS (
    SELECT product_name,
           COUNT(*) AS total_complaint,
           SUM(CASE WHEN timely_response = 'No' THEN 1 ELSE 0 END) AS timely_response_count
    FROM consumer_complaints
    GROUP BY product_name
)
SELECT product_name,
       total_complaint,
       timely_response_count,
       ROUND(100.0 * timely_response_count / total_complaint, 2) AS total_pct
FROM product_stats
ORDER BY total_complaint DESC
LIMIT 10;

-- Q32: Submitted_via percentage (CTE)
WITH submitted_stats AS (
    SELECT submitted_via,
           COUNT(*) AS total_complaint
    FROM consumer_complaints
    GROUP BY submitted_via
)
SELECT submitted_via,
       total_complaint,
       ROUND(100.0 * total_complaint / (SELECT COUNT(*) FROM consumer_complaints), 2) AS submitted_pct
FROM submitted_stats
ORDER BY total_complaint DESC
LIMIT 10;

-- Q33: State-wise percentage (CTE)
WITH state_stats AS (
    SELECT state_name,
           COUNT(*) AS total_complaint
    FROM consumer_complaints
    GROUP BY state_name
)
SELECT state_name,
       total_complaint,
       ROUND(100.0 * total_complaint / (SELECT COUNT(*) FROM consumer_complaints), 2) AS state_pct
FROM state_stats
ORDER BY total_complaint DESC
LIMIT 10;

-- Q34: New column — complaint category based on issue
SELECT complaint_id,
       issue,
       CASE 
           WHEN issue LIKE '%Managing the loan or lease%' THEN 'Managing Loan'
           WHEN issue LIKE '%Billing disputes%' THEN 'Billing disputes'
           WHEN issue LIKE '%communication tactics%' THEN 'Communication'
           ELSE 'Other'
       END AS category
FROM consumer_complaints;

-- ============================================
-- ROW_NUMBER()
-- ============================================

-- Q35: Basic row number
SELECT complaint_id,
       company,
       ROW_NUMBER() OVER (ORDER BY complaint_id ASC) AS row_num
FROM consumer_complaints
LIMIT 10;

-- Q36: Row number per company
SELECT company,
       date_received,
       complaint_id,
       ROW_NUMBER() OVER (PARTITION BY company ORDER BY date_received) AS row_num
FROM consumer_complaints
WHERE company = 'State Farm Bank'
LIMIT 10;

-- Q37: Row number per company (no filter)
SELECT company,
       date_received,
       complaint_id,
       ROW_NUMBER() OVER (PARTITION BY company ORDER BY date_received) AS row_num
FROM consumer_complaints
LIMIT 20;

-- Q38: Row number per company (latest first)
SELECT company,
       date_received,
       complaint_id,
       ROW_NUMBER() OVER (PARTITION BY company ORDER BY date_received DESC) AS row_num
FROM consumer_complaints
WHERE company = 'Equifax'
LIMIT 10;

-- Q39: Latest complaint per company
SELECT company, date_received, complaint_id
FROM (
    SELECT company,
           date_received,
           complaint_id,
           ROW_NUMBER() OVER (PARTITION BY company ORDER BY date_received DESC) AS row_num
    FROM consumer_complaints
) AS sub
WHERE row_num = 1
ORDER BY company
LIMIT 10;

-- Q40: Compare ROW_NUMBER, RANK, DENSE_RANK
SELECT company,
       COUNT(*) AS total,
       ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS row_num,
       RANK()       OVER (ORDER BY COUNT(*) DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS dense_rnk
FROM consumer_complaints
GROUP BY company
ORDER BY total DESC
LIMIT 15;

-- Q41: Top 3 companies per product
SELECT product_name, company, total, row_num
FROM (
    SELECT product_name,
           company,
           COUNT(*) AS total,
           ROW_NUMBER() OVER (PARTITION BY product_name ORDER BY COUNT(*) DESC) AS row_num
    FROM consumer_complaints
    GROUP BY product_name, company
) AS sub
WHERE row_num <= 3
ORDER BY product_name, row_num;

-- ============================================
-- SUM() OVER — RUNNING TOTAL
-- ============================================

-- Q42: Basic running total (month-wise)
SELECT DATE_TRUNC('month', date_received) AS month,
       COUNT(*) AS monthly_total,
       SUM(COUNT(*)) OVER (ORDER BY DATE_TRUNC('month', date_received)) AS running_total
FROM consumer_complaints
GROUP BY month
ORDER BY month;

-- Q43: Running total per product
SELECT product_name,
       DATE_TRUNC('month', date_received) AS month,
       COUNT(*) AS monthly_total,
       SUM(COUNT(*)) OVER (PARTITION BY product_name 
	   ORDER BY DATE_TRUNC('month', date_received)) AS running_total
FROM consumer_complaints
GROUP BY product_name, month
ORDER BY product_name, month;

-- Q44: Running total per company
SELECT company,
       DATE_TRUNC('month', date_received) AS month,
       COUNT(*) AS monthly_total,
       SUM(COUNT(*)) OVER (PARTITION BY company ORDER BY DATE_TRUNC('month', date_received)) AS running_total
FROM consumer_complaints
WHERE company = 'State Farm Bank'
GROUP BY company, month
ORDER BY company, month;

-- Q45: Running total with yearly reset
SELECT EXTRACT(YEAR FROM date_received) AS year,
       DATE_TRUNC('month', date_received) AS month,
       COUNT(*) AS monthly_total,
       SUM(COUNT(*)) OVER (PARTITION BY EXTRACT(YEAR FROM date_received)
                           ORDER BY DATE_TRUNC('month', date_received)) AS running_total
FROM consumer_complaints
GROUP BY year, month
ORDER BY year, month;

-- Q46: Running total + running %
SELECT DATE_TRUNC('month', date_received)::DATE AS month,
       COUNT(*) AS monthly_total,
       SUM(COUNT(*)) OVER (ORDER BY DATE_TRUNC('month', date_received)::DATE) AS running_total,
       ROUND(100.0 * SUM(COUNT(*)) OVER (ORDER BY DATE_TRUNC('month', date_received)::DATE)
             / (SELECT COUNT(*) FROM consumer_complaints), 2) AS total_pct
FROM consumer_complaints
GROUP BY month
ORDER BY month;

-- ============================================
-- LAG() — PREVIOUS ROW
-- ============================================

-- Q47: Previous complaint_id
SELECT complaint_id,
       LAG(complaint_id) OVER (ORDER BY complaint_id) AS previous_id
FROM consumer_complaints;

-- Q48: Previous date
SELECT date_received,
       LAG(date_received) OVER (ORDER BY date_received) AS previous_date
FROM consumer_complaints
LIMIT 5;

-- Q49: Previous complaint_id (with LIMIT)
SELECT complaint_id,
       LAG(complaint_id) OVER (ORDER BY complaint_id) AS prev_complaint
FROM consumer_complaints
ORDER BY complaint_id ASC
LIMIT 5;

-- Q50: Previous complaint_id per company
SELECT company,
       complaint_id,
       LAG(complaint_id) OVER (PARTITION BY company ORDER BY complaint_id) AS previous_complaint
FROM consumer_complaints
LIMIT 10;

-- Q51: 2 rows back
SELECT complaint_id,
       LAG(complaint_id, 2) OVER (ORDER BY complaint_id) AS previous_id
FROM consumer_complaints
LIMIT 10;

-- Q52: Month-wise complaints with previous month
SELECT TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM') AS month,
       COUNT(*) AS monthly_total,
       LAG(COUNT(*)) OVER (ORDER BY TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM')) AS previous_month
FROM consumer_complaints
GROUP BY month
ORDER BY month;

-- ============================================
-- LEAD() — NEXT ROW
-- ============================================

-- Q53: Next complaint_id (DESC — NULL dikhega)
SELECT complaint_id,
       LEAD(complaint_id) OVER (ORDER BY complaint_id) AS next_complaint
FROM consumer_complaints
ORDER BY complaint_id DESC LIMIT 5;

-- Q54: Next date (DESC — NULL dikhega)
SELECT date_received,
       LEAD(date_received) OVER (ORDER BY date_received) AS next_date
FROM consumer_complaints
ORDER BY date_received DESC
LIMIT 10;

-- Q55: Next complaint_id per company (DESC)
SELECT company,
       complaint_id,
       LEAD(complaint_id) OVER (PARTITION BY company ORDER BY complaint_id) AS next_complaint
FROM consumer_complaints
ORDER BY complaint_id DESC
LIMIT 10;

-- Q56: 2 rows ahead (DESC)
SELECT complaint_id,
       LEAD(complaint_id, 2) OVER (ORDER BY complaint_id) AS next_complaint
FROM consumer_complaints
ORDER BY complaint_id DESC
LIMIT 10;

-- Q57: LAG + LEAD side by side (same direction)
SELECT complaint_id,
       LAG(complaint_id)  OVER (ORDER BY complaint_id ASC) AS prev_complaint,
       LEAD(complaint_id) OVER (ORDER BY complaint_id ASC) AS next_complaint
FROM consumer_complaints
LIMIT 6;


-- ============================================
-- DISTINCT CHECKS (values verify)
-- ============================================

-- Q58: Check distinct timely_response values
SELECT DISTINCT timely_response FROM consumer_complaints;

-- Q59: Check distinct consumer_disputed values
SELECT DISTINCT consumer_disputed FROM consumer_complaints;

-- Q60: Check distinct submitted_via values
SELECT DISTINCT submitted_via FROM consumer_complaints;

-- Q61: Check max complaint_id
SELECT MAX(complaint_id) FROM consumer_complaints;

-- Q62: Check total rows
SELECT COUNT(*) FROM consumer_complaints;

-- ============================================
-- LAG — ADVANCED
-- ============================================

-- Q63: LAG with default value (NULL ki jagah 0)
SELECT TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM') AS month,
       COUNT(*) AS monthly_total,
       LAG(COUNT(*), 1, 0) OVER (ORDER BY TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM')) AS prev_month,
       COUNT(*) - LAG(COUNT(*), 1, 0) OVER (ORDER BY TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM')) AS diff
FROM consumer_complaints
GROUP BY month
ORDER BY month;

-- Q64: Biggest spike (sabse zyada badha)
SELECT month, monthly_total, prev_month, diff
FROM (
    SELECT TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM') AS month,
           COUNT(*) AS monthly_total,
           LAG(COUNT(*), 1, 0) OVER (ORDER BY TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM')) AS prev_month,
           COUNT(*) - LAG(COUNT(*), 1, 0) OVER (ORDER BY TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM')) AS diff
    FROM consumer_complaints
    GROUP BY month
) AS sub
ORDER BY diff DESC
LIMIT 3;

-- Q65: Biggest drop (sabse zyada ghata)
SELECT month, monthly_total, prev_month, diff
FROM (
    SELECT TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM') AS month,
           COUNT(*) AS monthly_total,
           LAG(COUNT(*), 1, 0) OVER (ORDER BY TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM')) AS prev_month,
           COUNT(*) - LAG(COUNT(*), 1, 0) OVER (ORDER BY TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM')) AS diff
    FROM consumer_complaints
    GROUP BY month
) AS sub
ORDER BY diff ASC
LIMIT 3;

-- Q66: Growth vs Decline months count
SELECT 
    SUM(CASE WHEN diff > 0 THEN 1 ELSE 0 END) AS growth_months,
    SUM(CASE WHEN diff < 0 THEN 1 ELSE 0 END) AS decline_months
FROM (
    SELECT COUNT(*) - LAG(COUNT(*), 1, 0) OVER (ORDER BY TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM')) AS diff
    FROM consumer_complaints
    GROUP BY TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM')
) AS sub;

-- Q67: Percentage change (month-over-month)
SELECT month,
       monthly_total,
       prev_month,
       ROUND(100.0 * (monthly_total - prev_month) / NULLIF(prev_month, 0), 2) AS pct_change
FROM (
    SELECT TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM') AS month,
           COUNT(*) AS monthly_total,
           LAG(COUNT(*), 1, 0) OVER (ORDER BY TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM')) AS prev_month
    FROM consumer_complaints
    GROUP BY month
) AS sub
ORDER BY month;

-- ============================================
-- LEAD — COMPLETE
-- ============================================

-- Q68: LEAD + ASC + LIMIT (no NULL)
SELECT complaint_id,
       LEAD(complaint_id) OVER (ORDER BY complaint_id) AS next_complaint
FROM consumer_complaints
ORDER BY complaint_id ASC
LIMIT 5;

-- Q69: LEAD + DESC + LIMIT (NULL aayega)
SELECT complaint_id,
       LEAD(complaint_id) OVER (ORDER BY complaint_id) AS next_complaint
FROM consumer_complaints
ORDER BY complaint_id DESC
LIMIT 5;

-- Q70: LAG + ASC + LIMIT (NULL aayega)
SELECT complaint_id,
       LAG(complaint_id) OVER (ORDER BY complaint_id) AS prev_complaint
FROM consumer_complaints
ORDER BY complaint_id ASC
LIMIT 5;

-- Q71: LAG + DESC + LIMIT (no NULL)
SELECT complaint_id,
       LAG(complaint_id) OVER (ORDER BY complaint_id) AS prev_complaint
FROM consumer_complaints
ORDER BY complaint_id
LIMIT 5;

-- Q72: LAG + LEAD mixed direction
SELECT complaint_id,
       LAG(complaint_id) OVER (ORDER BY complaint_id ASC) AS prev_complaint,
       LEAD(complaint_id) OVER (ORDER BY complaint_id DESC) AS next_complaint
FROM consumer_complaints
LIMIT 6;

-- ============================================
-- CTE — MORE PRACTICE
-- ============================================

-- Q73: Company-wise timely breakdown (CTE)
WITH company_timely AS (
    SELECT company,
           COUNT(*) AS total_complaint,
           SUM(CASE WHEN timely_response = 'Yes' THEN 1 ELSE 0 END) AS timely_yes,
           SUM(CASE WHEN timely_response = 'No' THEN 1 ELSE 0 END) AS timely_no
    FROM consumer_complaints
    GROUP BY company
)
SELECT company,
       total_complaint,
       timely_yes,
       timely_no,
       ROUND(100.0 * timely_yes / total_complaint, 2) AS timely_yes_pct,
       ROUND(100.0 * timely_no / total_complaint, 2) AS timely_no_pct
FROM company_timely
ORDER BY total_complaint DESC
LIMIT 10;

-- Q74: Product-wise dispute breakdown (CTE)
WITH product_dispute AS (
    SELECT product_name,
           COUNT(*) AS total,
           SUM(CASE WHEN consumer_disputed = 'Yes' THEN 1 ELSE 0 END) AS disputed
    FROM consumer_complaints
    GROUP BY product_name
)
SELECT product_name,
       total,
       disputed,
       ROUND(100.0 * disputed / total, 2) AS dispute_pct
FROM product_dispute
ORDER BY total DESC;

-- Q75: Year-wise timely response % (CTE)
WITH yearly_timely AS (
    SELECT EXTRACT(YEAR FROM date_received) AS year,
           COUNT(*) AS total,
           SUM(CASE WHEN timely_response = 'Yes' THEN 1 ELSE 0 END) AS timely_yes
    FROM consumer_complaints
    GROUP BY EXTRACT(YEAR FROM date_received)
)
SELECT year,
       total,
       timely_yes,
       ROUND(100.0 * timely_yes / total, 2) AS timely_pct
FROM yearly_timely
ORDER BY year;

-- Q76: Company-wise monthly trend (CTE)
WITH company_month AS (
    SELECT company,
           TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM') AS month,
           COUNT(*) AS total
    FROM consumer_complaints
    GROUP BY company, TO_CHAR(DATE_TRUNC('month', date_received), 'YYYY-MM')
)
SELECT company, month, total
FROM company_month
ORDER BY company, month;

-- ============================================
-- WINDOW FUNCTIONS — MORE
-- ============================================

-- Q77: Top 3 companies per product (RANK version)
SELECT product_name, company, total, rnk
FROM (
    SELECT product_name,
           company,
           COUNT(*) AS total,
           RANK() OVER (PARTITION BY product_name ORDER BY COUNT(*) DESC) AS rnk
    FROM consumer_complaints
    GROUP BY product_name, company
) AS sub
WHERE rnk <= 3
ORDER BY product_name, rnk;

-- Q78: Top 3 companies per product (DENSE_RANK version)
SELECT product_name, company, total, dense_rnk
FROM (
    SELECT product_name,
           company,
           COUNT(*) AS total,
           DENSE_RANK() OVER (PARTITION BY product_name ORDER BY COUNT(*) DESC) AS dense_rnk
    FROM consumer_complaints
    GROUP BY product_name, company
) AS sub
WHERE dense_rnk <= 3
ORDER BY product_name, dense_rnk;


-- Q79: Rank companies by total complaints using DENSE_RANK. Show top 15.
SELECT company,
       COUNT(*) AS total_cnt,
	   DENSE_RANK() OVER (ORDER BY COUNT(*)) AS dense_ranks
	   FROM consumer_complaints
	   GROUP BY company
	   ORDER BY total_cnt
	   LIMIT 15;


--Q80 Compare ROW_NUMBER, RANK, and DENSE_RANK side by side.
SELECT company,
COUNT(*) AS total,
ROW_NUMBER() OVER (ORDER BY COUNT(*)) AS row_num,
RANK() OVER (ORDER BY COUNT(*)) AS ranks,
DENSE_RANK() OVER (ORDER BY COUNT(*)) dense_ranks
FROM consumer_complaints
GROUP BY company
ORDER BY total DESC
LIMIT 15;


-- Q81 For each company, show each complaint's date and the first (earliest) complaint date of that company.
SELECT company,
       date_received,
	   FIRST_VALUE(date_received) OVER (PARTITION BY company ORDER BY date_received) AS first_date
	   FROM consumer_complaints
	   LIMIT 20;

SELECT company,
        date_received,
		FIRST_VALUE(date_received) OVER (PARTITION BY company ORDER BY date_received) AS first_date
		FROM consumer_complaints
		WHERE company = 'Bank of America'
		LIMIT 20;
--Q82 For each company, show each complaint's date and the last (latest) complaint date of that company.		
SELECT company,
       date_received,
	   LAST_VALUE(date_received) OVER (PARTITION BY company ORDER BY date_received ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	   AS last_date
FROM consumer_complaints;


SELECT company,
       date_received,
	   LAST_VALUE(date_received) OVER (PARTITION BY company ORDER BY date_received ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
	   AS last_date
	   FROM consumer_complaints
	   WHERE company = 'Bank of America'
	   LIMIT 10;

	   
	   


SELECT MIN(date_received) AS min_date
FROM consumer_complaints
WHERE company = 'Bank of America';


SELECT MAX(date_received) AS last_date
FROM consumer_complaints
WHERE company = 'Bank of America';

SELECT MIN(date_received) AS min_date
FROM consumer_complaints;
-- Final check — full table
SELECT * FROM consumer_complaints;


-- Find out how many complaints were received and sent on the same day
SELECT COUNT(*) AS same_day_count
FROM consumer_complaints
WHERE date_received = date_sent;


SELECT 
    COUNT(*) AS total,
    SUM(CASE WHEN date_received = date_sent THEN 1 ELSE 0 END) AS same_day,
    ROUND(100.0 * SUM(CASE WHEN date_received = date_sent THEN 1 ELSE 0 END) / COUNT(*), 2) AS percentage
FROM consumer_complaints;

-- Count complaints where the received date and sent date are the same
SELECT COUNT(*) AS same_day_count
FROM consumer_complaints
WHERE date_received = date_sent;


-- Retrieve all complaints from the state of New York (NY)
SELECT * FROM consumer_complaints
WHERE state_name = 'NY';


-- Retrieve all complaints from New York (NY) or California (CA)
SELECT * FROM consumer_complaints
WHERE state_name = 'NY' OR  state_name = 'CA';


-- Retrieve all complaints where the product name contains the word 'Credit'
SELECT * FROM consumer_complaints
WHERE product_name ILIKE '%Credit%';


-- Retrieve all complaints where the issue contains the word 'Late'
SELECT * FROM consumer_complaints
WHERE issue LIKE '%Late%';
