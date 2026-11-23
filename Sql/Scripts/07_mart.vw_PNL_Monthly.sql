create or replace view mart.vw_pnl_monthly as 

select 
	year,
	month,
	month_start,
	
	sum(case
		when is_revenue=true
		then actual_amount_usd
		else 0
	end
	) as actual_revenue,
	sum(case
		when is_revenue=true
		then budget_amount_usd
		else 0
	end
	) as budgeted_revenue,
	sum(case
		when is_cogs=true
		then actual_amount_usd
		else 0
	end
	) as actual_cogs,
	sum(case
		when is_cogs=true
		then budget_amount_usd
		else 0
	end
	) as budgeted_cogs,
	sum(case
		when is_opex=true
		then actual_amount_usd
		else 0
	end
	) as actual_opex,
	sum(case
		when is_opex=true
		then budget_amount_usd
		else 0
	end
	) as budgeted_opex,
	sum(case
		when is_other_income=true
		then actual_amount_usd
		else 0		
	end
	) as actual_other,
	sum(case
		when is_other_income
		then budget_amount_usd
		else 0
	end
	) as budgeted_other
	
	from mart.vw_financial_variance_monthly
	
	group by month,year,month_start;
	
	
	
	