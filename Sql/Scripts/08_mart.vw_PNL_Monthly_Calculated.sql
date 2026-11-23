create or replace
view mart.vw_pnl_monthly_calculated as 

select 
	*,
	actual_revenue-actual_cogs as actual_gross_profit,
	budgeted_revenue-budgeted_cogs as budgeted_gross_profit,
	actual_revenue-actual_cogs-actual_opex as actual_operating_income,
	budgeted_revenue-budgeted_cogs-budgeted_opex as budgeted_operating_income,
	actual_revenue-actual_cogs-actual_opex + actual_other as actual_net_income,
	budgeted_revenue-budgeted_cogs-budgeted_opex + budgeted_other as budgeted_net_income
from
	mart.vw_pnl_monthly
	
	
	
	
-- Compare actual profitability metrics against budgeted targets
-- and classify performance as Favorable, Unfavorable, or On Budget
SELECT *,
    actual_gross_profit - budgeted_gross_profit AS gross_profit_variance,

    CASE
        WHEN actual_gross_profit - budgeted_gross_profit > 0
            THEN 'Favorable'
        WHEN actual_gross_profit - budgeted_gross_profit < 0
            THEN 'Unfavorable'
        ELSE 'On Budget'
    END AS gross_profit_status,

    actual_operating_income - budgeted_operating_income AS operating_income_variance,

    CASE
        WHEN actual_operating_income - budgeted_operating_income > 0
            THEN 'Favorable'
        WHEN actual_operating_income - budgeted_operating_income < 0
            THEN 'Unfavorable'
        ELSE 'On Budget'
    END AS operating_income_status,

    actual_net_income - budgeted_net_income AS net_income_variance,

    CASE
        WHEN actual_net_income - budgeted_net_income > 0
            THEN 'Favorable'
        WHEN actual_net_income - budgeted_net_income < 0
            THEN 'Unfavorable'
        ELSE 'On Budget'
    END AS net_income_status

FROM mart.vw_pnl_monthly_calculated
ORDER BY net_income_variance DESC;

