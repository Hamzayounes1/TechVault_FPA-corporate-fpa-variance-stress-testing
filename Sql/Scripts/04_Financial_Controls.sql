--PnL Creation
with PnL as (
select 
	Sum(case when a.is_revenue = true 
		then f.amount_usd
		else 0
		end) as revenue,
	Sum (case
		when a.is_cogs = true
		 then f.amount_usd
		else 0
	end ) as cogs,
	Sum (case
		when a.is_opex = true
		 then f.amount_usd
		else 0
	end) as opex,
	Sum (case
		when a.is_other_income
		 then f.amount_usd
		else 0
	end) as other_income
from
	core.fact_actuals f
inner join core.dim_account a on
	f.account_id = a.account_id

)

select
	revenue,
	cogs,
	revenue-cogs as gross_profit,
	opex,
	revenue -cogs-opex as operating_income,
	other_income,
	revenue-cogs-opex + other_income as net_income
from
	pnl;


--PnL By Year
select 
	d.year,
	Sum(case when a.is_revenue = true 
		then f.amount_usd
		else 0
		end) as revenue,
	Sum (case
		when a.is_cogs = true
		 then f.amount_usd
		else 0
	end ) as cogs,
	Sum (case
		when a.is_opex = true
		 then f.amount_usd
		else 0
	end) as opex,
	Sum (case
		when a.is_other_income
		 then f.amount_usd
		else 0
	end) as other_income
from
	core.fact_actuals f
inner join core.dim_account a on
	f.account_id = a.account_id
inner join core.dim_date d on f.date_id = d.date_id

group by d.year 
order by d.year 

--Year Margin Metrix
with yearly as(
select 
	d.year,
	Sum(case when a.is_revenue = true 
		then f.amount_usd
		else 0
		end) as revenue,
	Sum (case
		when a.is_cogs = true
		 then f.amount_usd
		else 0
	end ) as cogs,
	Sum (case
		when a.is_opex = true
		 then f.amount_usd
		else 0
	end) as opex,
	Sum (case
		when a.is_other_income
		 then f.amount_usd
		else 0
	end) as other_income
from
	core.fact_actuals f
inner join core.dim_account a on
	f.account_id = a.account_id
inner join core.dim_date d on f.date_id = d.date_id

group by d.year)

select
	year,
	revenue,
	cogs,
	revenue-cogs as gross_profit,
	(revenue-cogs)/nullif(revenue,0) as gross_margin,
	opex,
	revenue-cogs-opex as operating_income,
	(revenue-cogs-opex)/nullif(revenue,0) as operating_margin
	from yearly
	order by yearly
	
--Final P&L
with Final_PNL as (
select
	dd.year,
	sum(case when da.is_revenue = true
	then fa.amount_usd
	else 0
	end)as Revenue,
	sum(case when da.is_cogs = true
	then fa.amount_usd
	else 0
	end)as Cogs,
	sum(case when da.is_opex = true
	then fa.amount_usd
	else 0
	end) as Opex ,
	sum(case when da.is_other_income = true
	then fa.amount_usd
	else 0
	end) as other_income
from
	core.fact_actuals fa
inner join core.dim_account da on
	da.account_id = fa.account_id
inner join core.dim_date dd on
	dd.date_id = fa.date_id
group by
	dd.year
order by
	dd.year)
	
	
select
	year,
	round(pl.revenue / 1000000, 2)::text || ' M' as Revenue,
	round(pl.cogs / 1000000, 2) ::text || ' M' as Cogs,
	round((pl.revenue - pl.cogs)/ 1000000, 2) ::text || ' M' as gross_profit,
	round((pl.revenue - pl.cogs)/ nullif(pl.revenue, 0)* 100, 2) ::text || ' %' as gross_margin,
	round((pl.revenue-pl.cogs-pl.opex)/ 1000000, 2) ::text || ' M' as operating_margin,
	round((pl.revenue-pl.cogs-pl.opex)/ nullif(pl.revenue, 0)* 100, 2)::text || ' %' as operating_margin
from
	Final_PNL pl;

);


---------- Actual/Budget Engine ##

with actual_monthly as (
select
	dd.month,
	dd.year,
	fa.department_id,
	fa.account_id,
	sum (amount_usd) as Monthly_actual
from
	core.fact_actuals fa
inner join core.dim_date dd on
	dd.date_id = fa.date_id
group by
	dd.month,
	dd.year,
	fa.department_id,
	fa.account_id
order by
	dd.month,
	dd.year,
	fa.department_id,
	fa.account_id),
budgeted_monthly as (
select
	dd.month,
	dd.year,
	fb.department_id,
	fb.account_id,
	sum(budgeted_amount_usd) as Monthly_Budgeted
from
	core.fact_budget fb
inner join core.dim_date dd on
	dd.date_id = fb.date_id
group by
	dd.month,
	dd.year,
	fb.department_id,
	fb.account_id
order by
	dd.month,
	dd.year,
	fb.department_id,
	fb.account_id)

select
	coalesce (fa.year,
	fb.year) as year,
	coalesce(fa.month, fb.month) as month,
	coalesce( fa.department_id, fb.department_id) as department_id,
	coalesce(fa.account_id, fb.account_id) as account_id,
	coalesce(fa.Monthly_Actual, 0) as Actual,
	coalesce(fb. Monthly_Budgeted, 0) as budgeted
from actual_monthly fa
full outer join budgeted_monthly fb on fb.year = fa.year
and fb.month = fa.month
and fb.account_id = fb.account_id
and fb.department_id = fa.department_id;

	
	
	



