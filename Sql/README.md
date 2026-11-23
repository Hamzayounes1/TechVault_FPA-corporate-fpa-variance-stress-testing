# Phase 2 — PostgreSQL: Trusted Financial Data, Variance Engine & P&L Marts

[Back to project overview](../README.md) · [Previous: Excel](../excel/README.md) · [Next: Power BI](../powerbi/README.md)

## Objective

Move controlled financial data into a relational model that supports **valid comparisons, reproducible financial statements and independent Power BI reconciliation**. The architecture is `stg → core → mart` in database `techvault_fpa`.

## Architecture and ownership

| Layer | Role | Representative objects |
|---|---|---|
| `stg` | Landing area for authoritative frozen CSV contents; keep enough detail to audit imports | `stg.fact_actuals`, `stg.fact_budget`, source dimensions |
| `core` | Properly typed, constrained facts and dimensions | `core.fact_actuals`, `core.fact_budget`, `core.dim_date`, `core.dim_account`, `core.dim_department`, others |
| `mart` | Tested, business-friendly aggregations and reconciliation views | `mart.vw_financial_variance_monthly`, `mart.vw_pnl_monthly_calculated`, `mart.vw_department_expense_variance` |

Source dimensions mentioned in the guide: `dim_date`, `dim_department`, `dim_account`, `dim_location`, `dim_cost_center`, `dim_product` and `dim_customer`; optional additional data products exist but are **not required** for the two-page flagship report.

### Recommended SQL file sequence

The guide proposes the following script locations. **Add your real, executed `.sql` scripts**; this documentation package intentionally does **not** fabricate implementation files.

```text
sql/
├── README.md
├── 00_create_schemas.sql
├── 01_create_core_tables.sql
├── 02_constraints_indexes.sql
├── 03_validation.sql
├── 04_financial_controls.sql
├── 05_monthly_variance_view.sql
├── 06_pnl_views.sql
└── 07_management_queries.sql
```

## Transformation sequence

### 1. Audit the imported staging tables

Check: row counts, source columns and types, duplicate surrogate keys, the actual natural key of each budget version, orphan foreign keys, status/scenario categories, non-null constraints and date bounds. Do **not** infer scenario names or column structures from an older conceptual blueprint; inspect the frozen source schema.

**Guide's expected whole-period controls**

| Table | Rows |
|---|---:|
| `fact_actuals` | 22,414 |
| `fact_budget` | 1,404 |
| `dim_date` | 1,096 |
| `dim_department` | 12 |
| `dim_account` | 38 |

Guide date bounds: actual postings approximately **2023-01-03 to 2025-12-30**, budgets **2023-01-01 to 2025-12-01**. The guide expects **no 2026** records. Key counts alone cannot verify sums, missing values or correct business classification.

### 2. Promote validated data to `core`

Load dimensions before facts, then add PKs/FKs and other constraints. Important dimensions: Date, Account and Department; additional foreign keys include Location and, where populated/present, Cost Center, Product and Customer. Confirm nullable keys before imposing `NOT NULL` or foreign-key expectations.

The guide also proposes selective single-column and composite indexes around the join/filter path (date, department, account), then PostgreSQL `ANALYZE`. On this relatively small dataset, say **well-structured query paths**, not “big data optimized.”

### 3. Reconcile staging-to-core

A valid copy is not only the same row count: compare row counts **and financial amounts** overall and by year/account/department. Confirm PK uniqueness, foreign-key integrity and absence of unmapped account classifications. Maintain an execution log or query result screenshots as proof.

### 4. Reconstruct an account-classified P&L

Classification comes from flags such as `is_revenue`, `is_cogs`, `is_opex`, `is_other` in `core.dim_account`. The guide's convention is Revenue, COGS and OPEX stored as positive values, with Net Other signed. Financial identities:

```text
Gross Profit      = Revenue - COGS
Operating Income = Gross Profit - OPEX
Net Income       = Operating Income + Net Other
```

Whole-period checks (approximate): Revenue **$303.37M**, COGS **$76.46M**, Gross Profit **$226.91M**, OPEX **$133.81M**, Operating Income **$93.10M**, Net Other **$1.16M**, Net Income **$94.26M**. The same aggregates should reconcile by year and at relevant month levels.

### 5. Build the actual-versus-budget monthly variance mart

**This is the key relational modeling decision.** Actuals are transaction-level; budget is already a monthly plan. Joining on only a department, account, or even month **before aggregation** risks a many-to-many row explosion and inflated results.

```text
Actual postings  ──► aggregate to (month, department, account)
Budget entries   ──► aggregate to (month, department, account)
                         ↓
                FULL OUTER JOIN on all 3 keys
                         ↓
           actual, budget, variance $, variance %,
                    favorable/unfavorable
```

The guide's `mart.vw_financial_variance_monthly` uses separate `actual_monthly` and `budget_monthly` CTEs and a **FULL OUTER JOIN** so an actual-only or budget-only combination does not silently disappear. `COALESCE` handles missing amounts for dollar comparison while a zero budget denominator should return `NULL`/N/A for percentage variance.

> **Scenario hazard:** If the budget source has multiple versions for the same month/account/department, choose the **approved scenario** *before* aggregation. Otherwise adding versions would inflate budget. Confirm this with the real `scenario` values and natural key. The guide shows how to check, but uploaded material does not independently prove the selected scenario.

**Business interpretation:** `variance_amount_usd = actual_amount_usd - budget_amount_usd`; expense overruns are unfavorable when costs are stored positive; revenue shortfalls are unfavorable when actual is below plan. Signed “other” accounts require appropriate review, not automatic uniform interpretation.

### 6. Publish analytical marts and diagnostics

Views described in the supplied SQL plan include:

- `mart.vw_financial_variance_monthly` — comparable actual and budget amount by month/department/account.
- `mart.vw_financial_variance_trends` — MoM/rolling comparisons or trend analysis.
- `mart.vw_pnl_monthly` / `mart.vw_pnl_monthly_calculated` — standard P&L lines and calculated statement totals.
- `mart.vw_department_expense_variance` — COGS/OPEX expense variance by department.

Management investigations: largest department dollar overspend, account-level drivers, months with the largest expense gap, changes in cost intensity, and net-income variance explained by P&L line.

### 7. Validate exceptional cases and reconcile with Excel

Department 7 / R&D is the documented cautionary case: **full-period expense actual ≈$76.66M versus budget ≈$74.92M**. A previously broken budget was dramatically overstated. Record which source version, year filter and classification yields the benchmark; do not equate this full-period number with a selected-year department visual.

Also validate: no duplicated natural budget grain, no orphan keys, no 2026 records, no missing categories, correct 2023/2024/2025 P&L totals, 2025 actual/budget waterfall, and final `stg`→`core` reconciliation.

## Illustrative query patterns (not the user's executed scripts)

**Check duplicates in the budget's assumed natural grain:**

```sql
-- Only correct if this matches the source's confirmed business grain.
SELECT budget_date, department_id, account_id, scenario, COUNT(*) AS row_count
FROM stg.fact_budget
GROUP BY budget_date, department_id, account_id, scenario
HAVING COUNT(*) > 1;
```

**A key-integrity check:**

```sql
SELECT COUNT(*) AS missing_department_keys
FROM stg.fact_actuals f
LEFT JOIN stg.dim_department d ON d.department_id = f.department_id
WHERE d.department_id IS NULL;
```

**Financial bridge identity (conceptual):**

```text
NI variance = Revenue variance − COGS variance − OPEX variance + Net Other variance
```

These snippets clarify approach only. Names, type casts, population filters, and joins must match the **real** database exports; runnable production scripts should come from the actual verified implementation.

## Handoff to Power BI

Connect Power BI to **`core`** star-schema tables; treat **`mart`** as an independent QA benchmark. Do not simultaneously connect a pre-aggregated mart and the contributing raw facts as additive sources in a single filter path. Reconcile DAX Revenue, COGS, OPEX, Net Other, Net Income, variance and department totals against SQL by the same year/slicer context.
