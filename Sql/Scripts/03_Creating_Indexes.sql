--Actual Indexes
create index ix_actual_date
on core.fact_actuals(date_id);

create index ix_actual_department
on core.fact_actuals(department_id);

create index ix_actual_account
on core.fact_actuals(account_id);

--Budget Indexes
create index ix_budget_date
on core.fact_budget(date_id);

create index ix_budget_department
on core.fact_budget(department_id);

create index ix_budget_account
on core.fact_budget(account_id);

--Analysis Indexes
create index ix_actual_monthly_analysis
on core.fact_actuals(date_id,department_id,account_id);

create index ix_budget_monthly_analysis
on core.fact_budget(date_id,department_id,account_id);


--Stg vs Core
select
(select count(*) from stg.fact_actuals) as staging_rows,
(select count(*) from core.fact_actuals)as core_rows;

select
(select count(*) from stg.fact_budget) as staging_rows,
(select count(*) from core.fact_budget)as core_rows;




