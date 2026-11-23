create or replace
view mart.vw_financial_variance_monthly as 

with actual_monthly as (
select
	d.month,
	d.year,
	d.first_day_of_month,
	f.department_id,
	f.account_id,
	sum(f.amount_usd) as actual_amount_usd
from
	core.fact_actuals f
inner join core.dim_date d on
	f.date_id = d.date_id
group by
	d.month,
	d.year,
	d.first_day_of_month,
	f.department_id ,
	f.account_id),

 budget_monthly as (
select
	d.month,
	d.year,
	d.first_day_of_month,
	b.department_id,
	b.account_id,
	sum(budgeted_amount_usd) as budgeted_amount_usd
from
	core.fact_budget b
inner join core.dim_date d on
	b.date_id = d.date_id
group by
	d.year,
	d.month,
	d.first_day_of_month,
	b.account_id,
	b.department_id
 ),
 combined as(
 select
	coalesce(f.year, b.year) as year,
	coalesce(f.month, b.month)as month,
	coalesce(f.first_day_of_month, b.first_day_of_month )as Month_Start,
	coalesce(f.department_id, b.department_id) as Department_id,
	coalesce(f.account_id, b.account_id)as Account_id,
	coalesce(f.actual_amount_usd, 0 ) as Actual_amount_usd,
	coalesce(b.budgeted_amount_usd, 0) as Budget_amount_usd
from
	actual_monthly f
full outer join budget_monthly b on
	f.year = b.year
	and f.month = b.month
	and f.first_day_of_month = b.first_day_of_month
	and f.department_id = b.department_id
	and f.account_id = b.account_id
	)
	
SELECT
    c.year,
    c.month,
    c.month_start,

    c.department_id,
    d.department_name,

    c.account_id,
    a.account_name,

    a.is_revenue,
    a.is_cogs,
    a.is_opex,
    a.is_other_income,

    c.actual_amount_usd,
    c.budget_amount_usd,

	ROUND(
	    (c.actual_amount_usd - c.budget_amount_usd) / 1000000.0,
	    2
	) AS variance_amount_usd,
	
	ROUND(
	    (
	        (c.actual_amount_usd - c.budget_amount_usd)
	        / NULLIF(c.budget_amount_usd, 0)
	    ) * 100,
	    2
	) AS variance_percentage,

    CASE
        WHEN a.is_revenue = TRUE
             AND c.actual_amount_usd >= c.budget_amount_usd
        THEN 'Favorable'

        WHEN (a.is_cogs = TRUE OR a.is_opex = TRUE)
             AND c.actual_amount_usd <= c.budget_amount_usd
        THEN 'Favorable'

        WHEN a.is_other_income = TRUE
        THEN 'Review'

        ELSE 'Unfavorable'
    END AS variance_status

FROM combined c
INNER JOIN core.dim_account a
    ON c.account_id = a.account_id
INNER JOIN core.dim_department d
    ON c.department_id = d.department_id
order by year, month 




 