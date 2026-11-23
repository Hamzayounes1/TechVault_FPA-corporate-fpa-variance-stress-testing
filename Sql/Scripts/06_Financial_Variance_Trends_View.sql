create or replace
view mart.vw_financial_variance_trends as 

select
	*,
	lag(actual_amount_usd) over (partition by account_id,
	department_id
order by
	month_start) as previous_month_actual,
	actual_amount_usd -lag(actual_amount_usd) over (partition by account_id,
	department_id
order by
	month_start) as mom_change_amount,
	avg(actual_amount_usd) over (partition by account_id,
	department_id
order by
	month_start rows between 11 preceding and current row) as rolling_12_observation_avg
from
	mart.vw_financial_variance_monthly
	
	
---Trend_Rolling_Performance
SELECT
    department_name,
    month_start,
    actual_amount_usd,
    rolling_12_observation_avg,
    actual_amount_usd - rolling_12_observation_avg AS deviation,
    CASE
        WHEN actual_amount_usd - rolling_12_observation_avg*1.20 > 0 THEN 'above trend'
        WHEN actual_amount_usd - rolling_12_observation_avg*0.80 < 0 THEN 'below trend'
        ELSE 'with trend'
    END AS trend_status
FROM mart.vw_financial_variance_trends;




