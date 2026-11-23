--Dim_Department
CREATE TABLE core.dim_department (
    department_id INT PRIMARY KEY,
    department_code VARCHAR(20),
    department_name VARCHAR(100) NOT NULL,
    division VARCHAR(100),
    primary_location_id INT,
    manager_name VARCHAR(150),
    manager_title VARCHAR(150),
    department_created_date DATE,
    is_active BOOLEAN,
    department_closed_date DATE,
    budget_owner VARCHAR(100)
);

--Inserting Data 
INSERT INTO core.dim_department (
    department_id,
    department_code,
    department_name,
    division,
    primary_location_id,
    manager_name,
    manager_title,
    department_created_date,
    is_active,
    department_closed_date,
    budget_owner
)
SELECT
    department_id,
    TRIM(department_code),
    TRIM(department_name),
    TRIM(division),
    primary_location_id,
    TRIM(manager_name),
    TRIM(manager_title),
    NULLIF(TRIM(department_created_date), '')::DATE,
    is_active,
    NULLIF(TRIM(department_closed_date), '')::DATE,
    TRIM(budget_owner)
FROM stg.dim_department;


--Table Validation
select Count(*) as total_rows
from core.dim_department;

SELECT *
FROM core.dim_department
ORDER BY department_id;


--Dim_Date
CREATE TABLE core.dim_date (
    date_id INTEGER PRIMARY KEY,
    full_date DATE,
    year INTEGER,
    fiscal_year INTEGER,
    fiscal_quarter INTEGER,
    fiscal_month INTEGER,
    quarter VARCHAR,
    month INTEGER,
    month_name VARCHAR,
    day_of_month INTEGER,
    day_of_year INTEGER,
    day_of_week INTEGER,
    day_name VARCHAR,
    week_of_year INTEGER,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN,
    first_day_of_month DATE,
    last_day_of_month DATE,
    date_key VARCHAR
);

-- Inserting data
INSERT INTO core.dim_date (
    date_id, full_date, year, fiscal_year,
    fiscal_quarter, fiscal_month, quarter, month,
    month_name, day_of_month, day_of_year, day_of_week,
    day_name, week_of_year, is_weekend, is_holiday,
    first_day_of_month, last_day_of_month, date_key
)
SELECT
    date_id,
    NULLIF(TRIM(full_date), '')::DATE,
    year,
    fiscal_year,
    fiscal_quarter,
    fiscal_month,
    TRIM(quarter),
    month,
    TRIM(month_name),
    day_of_month,
    day_of_year,
    day_of_week,
    TRIM(day_name),
    week_of_year,
    is_weekend,
    is_holiday,
    NULLIF(TRIM(first_day_of_month), '')::DATE,
    NULLIF(TRIM(last_day_of_month), '')::DATE,
    TRIM(date_key)
FROM stg.dim_date;

-- Table validation
SELECT COUNT(*) AS total_rows
FROM core.dim_date;

SELECT *
FROM core.dim_date
ORDER BY date_id;

--Dim_Location
CREATE TABLE core.dim_location (
    location_id INTEGER PRIMARY KEY,
    location_code VARCHAR,
    location_name VARCHAR,
    city VARCHAR,
    state_province VARCHAR,
    country VARCHAR,
    country_code VARCHAR,
    region VARCHAR,
    office_type VARCHAR,
    currency_code VARCHAR,
    time_zone VARCHAR,
    cost_multiplier NUMERIC(12,6),
    headcount_capacity INTEGER,
    office_opened_date DATE,
    office_closed_date DATE,
    is_active BOOLEAN
);

-- Inserting data
INSERT INTO core.dim_location (
    location_id, location_code, location_name, city,
    state_province, country, country_code, region,
    office_type, currency_code, time_zone, cost_multiplier,
    headcount_capacity, office_opened_date,
    office_closed_date, is_active
)
SELECT
    location_id,
    TRIM(location_code),
    TRIM(location_name),
    TRIM(city),
    TRIM(state_province),
    TRIM(country),
    TRIM(country_code),
    TRIM(region),
    TRIM(office_type),
    TRIM(currency_code),
    TRIM(time_zone),
    cost_multiplier::NUMERIC(12,6),
    headcount_capacity,
    NULLIF(TRIM(office_opened_date), '')::DATE,
    NULLIF(TRIM(office_closed_date), '')::DATE,
    is_active
FROM stg.dim_location;

-- Table validation
SELECT COUNT(*) AS total_rows
FROM core.dim_location;

SELECT *
FROM core.dim_location
ORDER BY location_id;

--Dim_Acoount
CREATE TABLE core.dim_account (
    account_id INTEGER PRIMARY KEY,
    account_code INTEGER,
    account_name VARCHAR,
    account_group VARCHAR,
    account_category VARCHAR,
    account_subcategory VARCHAR,
    p_and_l_classification VARCHAR,
    parent_account_id VARCHAR,
    is_revenue BOOLEAN,
    is_cogs BOOLEAN,
    is_opex BOOLEAN,
    is_other_income BOOLEAN,
    natural_balance VARCHAR,
    account_level INTEGER,
    account_created_date DATE,
    account_closed_date DATE,
    is_active BOOLEAN
);

-- Inserting data
INSERT INTO core.dim_account (
    account_id, account_code, account_name, account_group,
    account_category, account_subcategory,
    p_and_l_classification, parent_account_id,
    is_revenue, is_cogs, is_opex, is_other_income,
    natural_balance, account_level,
    account_created_date, account_closed_date, is_active
)
SELECT
    account_id,
    account_code,
    TRIM(account_name),
    TRIM(account_group),
    TRIM(account_category),
    TRIM(account_subcategory),
    TRIM(p_and_l_classification),
    TRIM(parent_account_id),
    is_revenue,
    is_cogs,
    is_opex,
    is_other_income,
    TRIM(natural_balance),
    account_level,
    NULLIF(TRIM(account_created_date), '')::DATE,
    NULLIF(TRIM(account_closed_date), '')::DATE,
    is_active
FROM stg.dim_account;

-- Table validation
SELECT COUNT(*) AS total_rows
FROM core.dim_account;

SELECT *
FROM core.dim_account
ORDER BY account_id;


--Dim_Cost_Center
CREATE TABLE core.dim_cost_center (
    cost_center_id INTEGER PRIMARY KEY,
    cost_center_code VARCHAR,
    cost_center_name VARCHAR,
    department_id INTEGER,
    location_id INTEGER,
    cost_center_type VARCHAR,
    manager_name VARCHAR,
    manager_email VARCHAR,
    budget_owner_name VARCHAR,
    cost_center_created_date DATE,
    cost_center_closed_date DATE,
    is_active BOOLEAN
);

-- Inserting data
INSERT INTO core.dim_cost_center (
    cost_center_id, cost_center_code, cost_center_name,
    department_id, location_id, cost_center_type,
    manager_name, manager_email, budget_owner_name,
    cost_center_created_date, cost_center_closed_date,
    is_active
)
SELECT
    cost_center_id,
    TRIM(cost_center_code),
    TRIM(cost_center_name),
    department_id,
    location_id,
    TRIM(cost_center_type),
    TRIM(manager_name),
    TRIM(manager_email),
    TRIM(budget_owner_name),
    NULLIF(TRIM(cost_center_created_date), '')::DATE,
    NULLIF(TRIM(cost_center_closed_date), '')::DATE,
    is_active
FROM stg.dim_cost_center;

-- Table validation
SELECT COUNT(*) AS total_rows
FROM core.dim_cost_center;

SELECT *
FROM core.dim_cost_center
ORDER BY cost_center_id;


--Dim_product 
CREATE TABLE core.dim_product (
    product_id INTEGER PRIMARY KEY,
    product_code VARCHAR,
    product_name VARCHAR,
    product_category VARCHAR,
    product_tier VARCHAR,
    business_unit VARCHAR,
    target_gross_margin_pct NUMERIC(12,6),
    revenue_account_id INTEGER,
    cogs_account_id INTEGER,
    product_launched_date DATE,
    product_discontinued_date DATE,
    is_active BOOLEAN,
    product_manager_name VARCHAR,
    description VARCHAR
);

-- Inserting data
INSERT INTO core.dim_product (
    product_id, product_code, product_name,
    product_category, product_tier, business_unit,
    target_gross_margin_pct, revenue_account_id,
    cogs_account_id, product_launched_date,
    product_discontinued_date, is_active,
    product_manager_name, description
)
SELECT
    product_id,
    TRIM(product_code),
    TRIM(product_name),
    TRIM(product_category),
    TRIM(product_tier),
    TRIM(business_unit),
    target_gross_margin_pct::NUMERIC(12,6),
    revenue_account_id,
    cogs_account_id,
    NULLIF(TRIM(product_launched_date), '')::DATE,
    NULLIF(TRIM(product_discontinued_date), '')::DATE,
    is_active,
    TRIM(product_manager_name),
    TRIM(description)
FROM stg.dim_product;

-- Table validation
SELECT COUNT(*) AS total_rows
FROM core.dim_product; 

SELECT *
FROM core.dim_product
ORDER BY product_id;


--Dim_Customer
CREATE TABLE core.dim_customer (
    customer_id INTEGER PRIMARY KEY,
    customer_code VARCHAR,
    customer_name VARCHAR,
    customer_segment_id INTEGER,
    industry VARCHAR,
    country VARCHAR,
    annual_revenue_usd BIGINT,
    account_executive_name VARCHAR,
    account_manager_name VARCHAR,
    acquired_date DATE,
    churn_date DATE,
    contract_start_date DATE,
    contract_end_date DATE,
    arr_usd NUMERIC(20,2),
    annual_contract_value_usd NUMERIC(20,2),
    is_active BOOLEAN,
    customer_health_score INTEGER,
    is_free_trial BOOLEAN,
    discount_percentage INTEGER
);

-- Inserting data
INSERT INTO core.dim_customer (
    customer_id, customer_code, customer_name,
    customer_segment_id, industry, country,
    annual_revenue_usd, account_executive_name,
    account_manager_name, acquired_date, churn_date,
    contract_start_date, contract_end_date, arr_usd,
    annual_contract_value_usd, is_active,
    customer_health_score, is_free_trial,
    discount_percentage
)
SELECT
    customer_id,
    TRIM(customer_code),
    TRIM(customer_name),
    customer_segment_id,
    TRIM(industry),
    TRIM(country),
    annual_revenue_usd,
    TRIM(account_executive_name),
    TRIM(account_manager_name),
    NULLIF(TRIM(acquired_date), '')::DATE,
    NULLIF(TRIM(churn_date), '')::DATE,
    NULLIF(TRIM(contract_start_date), '')::DATE,
    NULLIF(TRIM(contract_end_date), '')::DATE,
    arr_usd::NUMERIC(20,2),
    annual_contract_value_usd::NUMERIC(20,2),
    is_active,
    customer_health_score,
    is_free_trial,
    discount_percentage
FROM stg.dim_customer;

-- Table validation
SELECT COUNT(*) AS total_rows
FROM core.dim_customer;

SELECT *
FROM core.dim_customer
ORDER BY customer_id;

--Dim-Customer_Segment
CREATE TABLE core.dim_customer_segment (
    segment_id INTEGER PRIMARY KEY,
    segment_code VARCHAR,
    segment_name VARCHAR,
    segment_description VARCHAR,
    min_acv_usd INTEGER,
    max_acv_usd INTEGER,
    target_gross_margin_pct NUMERIC(12,6),
    churn_rate_annual_pct NUMERIC(12,6),
    nrr_target_pct NUMERIC(12,6),
    quota_influence_pct NUMERIC(12,6),
    is_active BOOLEAN
);

-- Inserting data
INSERT INTO core.dim_customer_segment (
    segment_id, segment_code, segment_name,
    segment_description, min_acv_usd, max_acv_usd,
    target_gross_margin_pct, churn_rate_annual_pct,
    nrr_target_pct, quota_influence_pct, is_active
)
SELECT
    segment_id,
    TRIM(segment_code),
    TRIM(segment_name),
    TRIM(segment_description),
    min_acv_usd,
    max_acv_usd,
    target_gross_margin_pct::NUMERIC(12,6),
    churn_rate_annual_pct::NUMERIC(12,6),
    nrr_target_pct::NUMERIC(12,6),
    quota_influence_pct::NUMERIC(12,6),
    is_active
FROM stg.dim_customer_segment;

-- Table validation
SELECT COUNT(*) AS total_rows
FROM core.dim_customer_segment;

SELECT *
FROM core.dim_customer_segment
ORDER BY segment_id;


--Fact_Actuals
CREATE TABLE core.fact_actuals (
    transaction_id INTEGER PRIMARY KEY,
    transaction_date DATE,
    posting_date DATE,
    date_id INTEGER,
    fiscal_year INTEGER,
    fiscal_month INTEGER,
    fiscal_quarter INTEGER,
    department_id INTEGER,
    cost_center_id INTEGER,
    account_id INTEGER,
    product_id INTEGER,
    customer_id INTEGER,
    location_id INTEGER,
    currency_code VARCHAR,
    exchange_rate_to_usd NUMERIC(18,8),
    local_amount NUMERIC(20,2),
    amount_usd NUMERIC(20,2),
    transaction_type VARCHAR,
    accounting_category VARCHAR,
    source_system VARCHAR,
    journal_source VARCHAR,
    description VARCHAR,
    invoice_reference VARCHAR,
    vendor_customer_name VARCHAR,
    payment_status VARCHAR,
    created_date DATE,
    created_by VARCHAR,
    modified_date DATE,
    modified_by VARCHAR
);

-- Inserting data
INSERT INTO core.fact_actuals (
    transaction_id, transaction_date, posting_date,
    date_id, fiscal_year, fiscal_month, fiscal_quarter,
    department_id, cost_center_id, account_id,
    product_id, customer_id, location_id, currency_code,
    exchange_rate_to_usd, local_amount, amount_usd,
    transaction_type, accounting_category, source_system,
    journal_source, description, invoice_reference,
    vendor_customer_name, payment_status, created_date,
    created_by, modified_date, modified_by
)
SELECT
    transaction_id,
    NULLIF(TRIM(transaction_date), '')::DATE,
    NULLIF(TRIM(posting_date), '')::DATE,
    date_id,
    fiscal_year,
    fiscal_month,
    fiscal_quarter,
    department_id,
    cost_center_id,
    account_id,
    product_id::INTEGER,
    customer_id::INTEGER,
    location_id,
    TRIM(currency_code),
    exchange_rate_to_usd::NUMERIC(18,8),
    local_amount::NUMERIC(20,2),
    amount_usd::NUMERIC(20,2),
    TRIM(transaction_type),
    TRIM(accounting_category),
    TRIM(source_system),
    TRIM(journal_source),
    TRIM(description),
    TRIM(invoice_reference),
    TRIM(vendor_customer_name),
    TRIM(payment_status),
    NULLIF(TRIM(created_date), '')::DATE,
    TRIM(created_by),
    NULLIF(TRIM(modified_date), '')::DATE,
    TRIM(modified_by)
FROM stg.fact_actuals;

-- Table validation
SELECT COUNT(*) AS total_rows
FROM core.fact_actuals;

SELECT *
FROM core.fact_actuals
ORDER BY transaction_id
LIMIT 10;


--Fact_Budget
CREATE TABLE core.fact_budget (
    budget_id INTEGER PRIMARY KEY,
    budget_scenario VARCHAR,
    budget_date DATE,
    date_id INTEGER,
    fiscal_year INTEGER,
    fiscal_month INTEGER,
    fiscal_quarter INTEGER,
    department_id INTEGER,
    cost_center_id INTEGER,
    account_id INTEGER,
    product_id INTEGER,
    location_id INTEGER,
    budgeted_amount_usd NUMERIC(20,2),
    budgeted_quantity VARCHAR,
    budget_notes VARCHAR,
    prepared_date DATE,
    prepared_by VARCHAR,
    approved_date DATE,
    approved_by VARCHAR,
    budget_version INTEGER,
    currency_code VARCHAR,
    is_approved BOOLEAN,
    created_date DATE
);

-- Inserting data
INSERT INTO core.fact_budget (
    budget_id, budget_scenario, budget_date, date_id,
    fiscal_year, fiscal_month, fiscal_quarter,
    department_id, cost_center_id, account_id,
    product_id, location_id, budgeted_amount_usd,
    budgeted_quantity, budget_notes, prepared_date,
    prepared_by, approved_date, approved_by,
    budget_version, currency_code, is_approved,
    created_date
)
SELECT
    budget_id,
    TRIM(budget_scenario),
    NULLIF(TRIM(budget_date), '')::DATE,
    date_id,
    fiscal_year,
    fiscal_month,
    fiscal_quarter,
    department_id,
    cost_center_id,
    account_id,
    product_id::INTEGER,
    location_id,
    budgeted_amount_usd::NUMERIC(20,2),
    TRIM(budgeted_quantity),
    TRIM(budget_notes),
    NULLIF(TRIM(prepared_date), '')::DATE,
    TRIM(prepared_by),
    NULLIF(TRIM(approved_date), '')::DATE,
    TRIM(approved_by),
    budget_version,
    TRIM(currency_code),
    is_approved,
    NULLIF(TRIM(created_date), '')::DATE
FROM stg.fact_budget;

-- Table validation
SELECT COUNT(*) AS total_rows
FROM core.fact_budget;

SELECT *
FROM core.fact_budget
ORDER BY budget_id
LIMIT 10;

--fact_customer_monthly
CREATE TABLE core.fact_customer_monthly (
    customer_id INTEGER,
    date_id INTEGER,
    fiscal_year INTEGER,
    fiscal_month INTEGER,
    fiscal_quarter INTEGER,
    beginning_arr NUMERIC(20,2),
    ending_arr NUMERIC(20,2),
    new_arr NUMERIC(20,2),
    expansion_arr NUMERIC(20,2),
    contraction_arr NUMERIC(20,2),
    churn_arr NUMERIC(20,2),
    recognized_revenue NUMERIC(20,2),

    PRIMARY KEY (customer_id, date_id)
);

-- Inserting data
INSERT INTO core.fact_customer_monthly (
    customer_id, date_id, fiscal_year, fiscal_month,
    fiscal_quarter, beginning_arr, ending_arr, new_arr,
    expansion_arr, contraction_arr, churn_arr,
    recognized_revenue
)
SELECT
    customer_id,
    date_id,
    fiscal_year,
    fiscal_month,
    fiscal_quarter,
    beginning_arr::NUMERIC(20,2),
    ending_arr::NUMERIC(20,2),
    new_arr::NUMERIC(20,2),
    expansion_arr::NUMERIC(20,2),
    contraction_arr::NUMERIC(20,2),
    churn_arr::NUMERIC(20,2),
    recognized_revenue::NUMERIC(20,2)
FROM stg.fact_customer_monthly;

-- Table validation
SELECT COUNT(*) AS total_rows
FROM core.fact_customer_monthly;

SELECT *
FROM core.fact_customer_monthly
ORDER BY customer_id, date_id
LIMIT 100;

--Fact_Headcount
CREATE TABLE core.fact_headcount (
    headcount_id INTEGER PRIMARY KEY,
    employee_id VARCHAR,
    employee_name VARCHAR,
    department_id INTEGER,
    location_id INTEGER,
    job_title VARCHAR,
    employment_type VARCHAR,
    job_level VARCHAR,
    headcount_date DATE,
    date_id INTEGER,
    fiscal_year INTEGER,
    fiscal_month INTEGER,
    hire_date DATE,
    termination_date DATE,
    is_active BOOLEAN,
    base_salary_annual NUMERIC(20,2),
    bonus_target_percent INTEGER,
    benefits_cost_annual NUMERIC(20,2),
    equity_grant_value_annual INTEGER,
    currency_code VARCHAR,
    cost_center_id VARCHAR,
    manager_employee_id VARCHAR,
    salary_effective_date DATE,
    created_date DATE
);

-- Inserting data
INSERT INTO core.fact_headcount (
    headcount_id, employee_id, employee_name,
    department_id, location_id, job_title,
    employment_type, job_level, headcount_date,
    date_id, fiscal_year, fiscal_month, hire_date,
    termination_date, is_active, base_salary_annual,
    bonus_target_percent, benefits_cost_annual,
    equity_grant_value_annual, currency_code,
    cost_center_id, manager_employee_id,
    salary_effective_date, created_date
)
SELECT
    headcount_id,
    TRIM(employee_id),
    TRIM(employee_name),
    department_id,
    location_id,
    TRIM(job_title),
    TRIM(employment_type),
    TRIM(job_level),
    NULLIF(TRIM(headcount_date), '')::DATE,
    date_id,
    fiscal_year,
    fiscal_month,
    NULLIF(TRIM(hire_date), '')::DATE,
    NULLIF(TRIM(termination_date), '')::DATE,
    is_active,
    base_salary_annual::NUMERIC(20,2),
    bonus_target_percent,
    benefits_cost_annual::NUMERIC(20,2),
    equity_grant_value_annual,
    TRIM(currency_code),
    TRIM(cost_center_id),
    TRIM(manager_employee_id),
    NULLIF(TRIM(salary_effective_date), '')::DATE,
    NULLIF(TRIM(created_date), '')::DATE
FROM stg.fact_headcount;

-- Table validation
SELECT COUNT(*) AS total_rows
FROM core.fact_headcount;

SELECT *
FROM core.fact_headcount
ORDER BY headcount_id
LIMIT 10;


----------- Fact_Actuals.Foreign_Keys_Constraints ##
ALTER TABLE core.fact_actuals
ADD CONSTRAINT fk_actual_date
FOREIGN KEY (date_id)
REFERENCES core.dim_date(date_id);

alter table core.fact_actuals
add constraint fk_actual_department
foreign key (department_id)
references core.dim_department 

alter table core.fact_actuals 
add constraint fk_actual_account
foreign key (account_id)
references core.dim_account

alter table core.fact_actuals 
add constraint fk_actual_location
foreign key (location_id)
references core.dim_location

alter table core.fact_actuals 
add constraint fk_actual_cost_center
foreign key (cost_center_id)
references core.dim_cost_center

alter table core.fact_actuals
add constraint fk_actual_product
foreign key (product_id)
references  core.dim_product

alter table core.fact_actuals 
add constraint fk_actual_customer
foreign key (customer_id)
references  core.dim_customer;

----------- Fact_Budget.Foreign Keys Constraints ##
ALTER TABLE core.fact_budget
ADD CONSTRAINT fk_budget_date
FOREIGN KEY (date_id)
REFERENCES core.dim_date(date_id);

ALTER TABLE core.fact_budget
ADD CONSTRAINT fk_budget_department
FOREIGN KEY (department_id)
REFERENCES core.dim_department(department_id);

ALTER TABLE core.fact_budget
ADD CONSTRAINT fk_budget_account
FOREIGN KEY (account_id)
REFERENCES core.dim_account(account_id);

ALTER TABLE core.fact_budget
ADD CONSTRAINT fk_budget_product
FOREIGN KEY (product_id)
REFERENCES core.dim_product(product_id);

----------- Validating_Core_Layer ## Status=True
WITH audit AS (
    SELECT 'dim_date' AS table_name, 1096 AS expected,
        (SELECT COUNT(*) FROM stg.dim_date) AS staging,
        (SELECT COUNT(*) FROM core.dim_date) AS core
    UNION ALL
    SELECT 'dim_location', 6,
        (SELECT COUNT(*) FROM stg.dim_location),
        (SELECT COUNT(*) FROM core.dim_location)
    UNION ALL
    SELECT 'dim_department', 12,
        (SELECT COUNT(*) FROM stg.dim_department),
        (SELECT COUNT(*) FROM core.dim_department)
    UNION ALL
    SELECT 'dim_account', 38,
        (SELECT COUNT(*) FROM stg.dim_account),
        (SELECT COUNT(*) FROM core.dim_account)
    UNION ALL
    SELECT 'dim_customer_segment', 5,
        (SELECT COUNT(*) FROM stg.dim_customer_segment),
        (SELECT COUNT(*) FROM core.dim_customer_segment)
    UNION ALL
    SELECT 'dim_cost_center', 20,
        (SELECT COUNT(*) FROM stg.dim_cost_center),
        (SELECT COUNT(*) FROM core.dim_cost_center)
    UNION ALL
    SELECT 'dim_product', 6,
        (SELECT COUNT(*) FROM stg.dim_product),
        (SELECT COUNT(*) FROM core.dim_product)
    UNION ALL
    SELECT 'dim_customer', 285,
        (SELECT COUNT(*) FROM stg.dim_customer),
        (SELECT COUNT(*) FROM core.dim_customer)
    UNION ALL
    SELECT 'fact_actuals', 22414,
        (SELECT COUNT(*) FROM stg.fact_actuals),
        (SELECT COUNT(*) FROM core.fact_actuals)
    UNION ALL
    SELECT 'fact_budget', 1404,
        (SELECT COUNT(*) FROM stg.fact_budget),
        (SELECT COUNT(*) FROM core.fact_budget)
    UNION ALL
    SELECT 'fact_customer_monthly', 5377,
        (SELECT COUNT(*) FROM stg.fact_customer_monthly),
        (SELECT COUNT(*) FROM core.fact_customer_monthly)
    UNION ALL
    SELECT 'fact_headcount', 5197,
        (SELECT COUNT(*) FROM stg.fact_headcount),
        (SELECT COUNT(*) FROM core.fact_headcount)
)
SELECT
    table_name,
    expected,
    staging,
    core,
    CASE
        WHEN expected = staging AND staging = core
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation
FROM audit
ORDER BY table_name;


----------- Actual_Budget_Sum_Check## Status=True
SELECT
    'Actuals' AS dataset,
    (SELECT SUM(amount_usd::NUMERIC(20,2))
     FROM stg.fact_actuals) AS staging_total,
    (SELECT SUM(amount_usd)
     FROM core.fact_actuals) AS core_total

UNION ALL

SELECT
    'Budget',
    (SELECT SUM(budgeted_amount_usd::NUMERIC(20,2))
     FROM stg.fact_budget),
    (SELECT SUM(budgeted_amount_usd)
     FROM core.fact_budget);