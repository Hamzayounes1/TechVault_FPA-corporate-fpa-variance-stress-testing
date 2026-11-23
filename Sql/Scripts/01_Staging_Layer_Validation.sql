----------- Row_Count_Validation vs Excel_Counts  ## Status=True
SELECT 'fact_actuals' AS table_name, COUNT(*) AS row_count
FROM stg.fact_actuals

UNION ALL

SELECT 'fact_budget', COUNT(*)
FROM stg.fact_budget

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM stg.dim_date

UNION ALL

SELECT 'dim_department', COUNT(*)
FROM stg.dim_department

----------- Inspecting_Staging_Schema  ##
select 
column_name,
data_type,
ordinal_position
from information_schema.columns
where table_schema ='stg'
and table_name ='fact_actuals';

SELECT
    column_name,
    data_type,
    ordinal_position
FROM information_schema.columns
WHERE table_schema = 'stg'
  AND table_name = 'fact_budget'
ORDER BY ordinal_position;

SELECT
    column_name,
    data_type,
    ordinal_position
FROM information_schema.columns
WHERE table_schema = 'stg'
  AND table_name = 'dim_account'
ORDER BY ordinal_position;

SELECT
    column_name,
    data_type,
    ordinal_position
FROM information_schema.columns
WHERE table_schema = 'stg'
  AND table_name = 'dim_department'
ORDER BY ordinal_position;  

SELECT column_name,
       data_type
FROM information_schema.columns c
WHERE table_schema = 'stg'
  AND table_name = 'dim_account'
  AND column_name IN ('is_revenue', 'is_cogs', 'is_opex','is_other');


SELECT 
    table_name,
    column_name,
    data_type,
    ordinal_position
FROM information_schema.columns
WHERE table_schema = 'stg'
ORDER BY table_name, ordinal_position;


	
----------- Primary_keys_validation ## Status=True
--Fact_Actual
select Count (*) as Row_Counts,
count (distinct transaction_id) as Unique_Transactions
from stg.fact_actuals fa 

select Count(*),
transaction_id
from stg.fact_actuals
group by transaction_id
having count(*)>1

--Fact_Budget
select count(*) as row_counts,
count(distinct budget_id) as unique_id
from stg.fact_budget fb 

select count(*),
budget_id
from stg.fact_budget fb 
group by budget_id 
having count(*)>1

--Fact_Headcount
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT headcount_id) AS unique_ids
FROM stg.fact_headcount;

SELECT
    employee_id,
    headcount_date,
    COUNT(*) AS row_count
FROM stg.fact_headcount
GROUP BY
    employee_id,
    headcount_date
HAVING COUNT(*) > 1;

SELECT
    customer_id,
    fiscal_year,
    fiscal_month,
    COUNT(*) AS row_count
FROM stg.fact_customer_monthly
GROUP BY
    customer_id,
    fiscal_year,
    fiscal_month
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS customer_monthly_customer_orphans
FROM stg.fact_customer_monthly f
LEFT JOIN stg.dim_customer c
    ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

--Dim_Date 
SELECT
    date_id,
    COUNT(*) AS duplicate_count
FROM stg.dim_date
GROUP BY date_id
HAVING COUNT(*) > 1;

--Dim_Department
select department_id,
    COUNT(*) AS duplicate_count
FROM stg.dim_department
GROUP BY department_id
HAVING COUNT(*) > 1;

--Dim_Acoount
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT account_id) AS unique_ids
FROM stg.dim_account;

 SELECT
    account_id,
    COUNT(*) AS duplicate_count
FROM stg.dim_account
GROUP BY account_id
HAVING COUNT(*) > 1;

--Dim_Location
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT location_id) AS unique_ids
FROM stg.dim_location;

select date_id,
Count(*) as Duplicated_Rows
from core.dim_date dd
group by dd.date_id
having count(*)>1


--Dim_Cost_Center
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT cost_center_id) AS unique_ids
FROM stg.dim_cost_center;

SELECT
    cost_center_id,
    COUNT(*) AS duplicate_count
FROM stg.dim_cost_center
GROUP BY cost_center_id
HAVING COUNT(*) > 1;

--Dim_Product
select
	Count(*) as row_count,
	Count(distinct Product_id) as unique_ids
	from stg.dim_product;
select 
	product_id,
	Count(*) as duplicate_count
from stg.dim_product
group by product_id 
having count(*)>1

--Dim_Customer 
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT customer_id) AS unique_ids
FROM stg.dim_customer;

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM stg.dim_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

--Date Validation
select min(posting_date) as start,
max(posting_date) as end 
from stg.fact_actuals;

select count(*) as twntsix
from stg.fact_actuals 
where posting_date>='2026-01-01';

SELECT
    MIN(budget_date),
    MAX(budget_date)
FROM stg.fact_budget;

SELECT COUNT(*)
FROM stg.fact_budget
WHERE budget_date >= '2026-01-01';


------------ Foreign_keys_validation  ## Status=True

--Department orphan rows
select Count(*) as Orphan_Rows
from stg.fact_actuals fa 
left join stg.dim_department dd 
on dd.department_id =fa.department_id
where dd.department_id is null;

SELECT COUNT(*) AS department_budget_orphan_rows
FROM stg.fact_budget b
LEFT JOIN stg.dim_department d
    ON d.department_id = b.department_id
WHERE d.department_id IS NULL;

--Acoount orphan rows
select Count(*) as Orphan_Rows
from stg.fact_actuals fa 
left join stg.dim_account da 
on da.account_id = fa.account_id 
where da.account_id is null;

SELECT COUNT(*) AS account_budget_orphan_rows
FROM stg.fact_budget b
LEFT JOIN stg.dim_account a
    ON a.account_id = b.account_id
WHERE a.account_id IS NULL;

-- Date orphan rows
SELECT COUNT(*) AS orphan_rows
FROM stg.fact_actuals f
LEFT JOIN stg.dim_date d ON d.date_id  = f.date_id 
WHERE d.date_id IS NULL;

SELECT COUNT(*) AS orphan_rows
FROM stg.fact_budget b
LEFT JOIN stg.dim_date d ON d.date_id = b.date_id 
WHERE d.date_id IS NULL;

-- Cost Center orphan rows
SELECT COUNT(*) AS orphan_rows
FROM stg.fact_actuals f
LEFT JOIN stg.dim_cost_center c
    ON c.cost_center_id = f.cost_center_id
WHERE f.cost_center_id IS NOT NULL
  AND c.cost_center_id IS NULL;

SELECT COUNT(*) AS orphan_rows
FROM stg.fact_budget b
LEFT JOIN stg.dim_cost_center c ON c.cost_center_id = b.cost_center_id
WHERE b.cost_center_id is not null and c.cost_center_id IS NULL;

-- Location orphan rows
SELECT COUNT(*) AS orphan_rows
FROM stg.fact_actuals f
LEFT JOIN stg.dim_location l ON l.location_id = f.location_id
WHERE l.location_id IS NULL;

SELECT COUNT(*) AS orphan_rows
FROM stg.fact_budget b
LEFT JOIN stg.dim_location l ON l.location_id = b.location_id
WHERE l.location_id IS NULL;

-- Product orphan rows
SELECT COUNT(*) AS product_actuals_orphan_rows
FROM stg.fact_actuals fa
LEFT JOIN stg.dim_product dp
    ON dp.product_id = fa.product_id
WHERE fa.product_id IS NOT NULL
  AND dp.product_id IS NULL;

SELECT COUNT(*) AS product_budget_orphan_rows
FROM stg.fact_budget b
LEFT JOIN stg.dim_product p
    ON p.product_id = b.product_id
WHERE b.product_id IS NOT NULL
  AND p.product_id IS NULL;

-- Customer orphan rows
SELECT COUNT(*) AS customer_actuals_orphan_rows
FROM stg.fact_actuals f
LEFT JOIN stg.dim_customer c
    ON c.customer_id = f.customer_id
WHERE f.customer_id IS NOT NULL
  AND c.customer_id IS NULL;

--Cost Center orphan rows
SELECT COUNT(*) AS department_cost_center_mismatches
FROM stg.fact_actuals f
inner JOIN stg.dim_cost_center cc
    ON f.cost_center_id = cc.cost_center_id
WHERE f.department_id <> cc.department_id;

--dim_customer_segment
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT segment_id) AS unique_ids
FROM stg.dim_customer_segment;

SELECT COUNT(*) AS customer_segment_orphans
FROM stg.dim_customer c
LEFT JOIN stg.dim_customer_segment s
    ON c.customer_segment_id = s.segment_id
WHERE c.customer_segment_id IS NOT NULL
  AND s.segment_id IS NULL;



----------- Grains_Validation ## Status=True
-- DIMENSIONS

-- Dim_Date:
-- One row per calendar day.

-- Dim_Location:
-- One row per company office/location.

-- Dim_Department:
-- One row per organizational department.

-- Dim_Cost_Center:
-- One row per cost center.

-- Dim_Account:
-- One row per General Ledger (GL) account.

-- Dim_Product:
-- One row per product.

-- Dim_Customer_Segment:
-- One row per customer segment.

-- Dim_Customer:
-- One row per individual customer/company.


-- FACT TABLES

-- Fact_Actuals:
-- One row per financial/GL posting, such as a revenue line,
-- payroll line, AP invoice line, or month-end adjustment.

-- Fact_Budget:
-- One row per department × account × month × scenario.
-- Represents one monthly planned financial amount.

-- Fact_Headcount:
-- One row per employee × month.
-- Represents an individual employee's monthly snapshot.

-- Fact_Customer_Monthly:
-- One row per customer × month.
-- Represents a customer's monthly ARR movement and activity.











