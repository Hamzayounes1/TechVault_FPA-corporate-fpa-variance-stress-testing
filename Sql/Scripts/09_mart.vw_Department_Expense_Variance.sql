--Manegement Queries

--creating_department_expense_view
create or replace view mart.vw_department_expense_variance as 
select
year,
department_id,
department_name,
sum(case when is_cogs=true or is_opex=true 
	 then actual_amount_usd
	 else 0
end) as actual_department_expense,
sum(case when is_cogs=true or is_opex=true
	 then budget_amount_usd
	 else 0
end) as budgeted_department_expense
from mart.vw_financial_variance_monthly
group by year,department_id,department_name;

--Department_expense_variance
select *,
actual_department_expense - budgeted_department_expense as expense_variance,
(actual_department_expense - budgeted_department_expense)/nullif(budgeted_department_expense,0)*100 as expense_variance_pct
from mart.vw_department_expense_variance
order by year,expense_variance

--Department 7 expense check
SELECT
    department_id,
    department_name,

    SUM(actual_department_expense)
        AS actual__expense,

    SUM(budgeted_department_expense)
        AS budget_expense

FROM mart.vw_department_expense_variance

WHERE department_id = 7

GROUP BY
    department_id,
    department_name;

--which departments overspend?
select department_name,
sum(actual_amount_usd) as actual_expense,
sum(budget_amount_usd) as budget_expense,
sum(actual_amount_usd-budget_amount_usd) as variance
from mart.vw_financial_variance_monthly
where is_cogs=true or is_opex=true 
group by department_name
order by variance desc;

--which accounts caused the overspend?
select department_name,
account_name,
sum(actual_amount_usd) as actual_expense,
sum(budget_amount_usd) as budget_expense,
sum(actual_amount_usd-budget_amount_usd) as variance
from mart.vw_financial_variance_monthly
where is_cogs=true or is_opex=true 
group by department_name,account_name
order by variance desc;

--Which months had the largest unfavorable expense variance?
select month_start,
sum(actual_amount_usd) as actual_expense,
sum(budget_amount_usd) as budget_expense,
sum(actual_amount_usd-budget_amount_usd) as variance
from mart.vw_financial_variance_monthly
where is_cogs=true or is_opex=true 
group by month_start
order by variance desc;