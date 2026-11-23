# Phase 1 — Excel: Financial Understanding, Budget Planning & Controls

[Back to project overview](../README.md) · [Next: SQL](../sql/README.md)

## Objective

Excel is the **finance control and planning environment**, not an accidental second data warehouse. The phase is designed to interpret the raw financial records, reconstruct the P&L, inspect the approved budget, calculate variances, build an educational driver-based budget, and create benchmarks for PostgreSQL and Power BI.

**Source of truth:** Frozen CSVs stay **read-only**. Import with **Power Query**; do not manually alter or overwrite the authoritative exports.

## Inputs and business grain

| Dataset | Business meaning | Grain / role |
|---|---|---|
| `fact_actuals.csv` | Recorded P&L postings | **One posting/transaction per row**; 22,414 rows are the whole-period guide target |
| `fact_budget.csv` | Financial plan | A **month × department × account × scenario** amount; check any additional natural-key fields in the real file; 1,404 rows target |
| `dim_date.csv` | Time attributes | A dated lookup supporting years/months |
| `dim_department.csv` | Organization ownership | 12 departments target |
| `dim_account.csv` | Revenue, COGS, OPEX, signed other classification | 38 accounts target |
| Other dimensions | Location, cost center, product, customer | Reference/extended analysis where present |

Inspect date and numeric types, status/category codes, currency, exchange rates, account flags, unique identifiers and whether a transaction is in the reporting population. Use the classifications from `dim_account`, not guesswork based on an amount's sign.

## Workbook structure

Suggested source workbook (add the **actual** workbook after final verification): `TechVault_FP&A_Excel_Model.xlsx`.

| Worksheet | Purpose | QA / deliverable |
|---|---|---|
| `README` | Data provenance, grain, reporting period, conventions and refresh instructions | Clear definitions and handoff |
| `Actuals_Check` | Pivot-based income statement and annual composition | Revenue → net income identities |
| `Budget_Check` | Actual vs. Budget by year, major P&L line and department | Variance $ and % with interpretation |
| `Budget_Assumptions` | Explicit assumptions for planning exercise | Named, reviewable cost drivers |
| `Budget_Model` | Driver-based budget illustration | Seasonality, costs and payroll rules |
| `Control_Checks` | Row counts, missing keys, duplicates, statement reconciliation | PASS/FAIL evidence |

Power Query connections: `Fact_Actuals`, `Fact_Budget`, `Dim_Date`, `Dim_Department`, `Dim_Account` and relevant optional dimensions. Load large fact queries as **connection / data model** when possible, rather than copying thousands of rows between sheets.

## Workflow — what each step contributes

### 1. Protect and inspect the raw exports

- Keep authoritative CSV files frozen, organized and unchanged.
- Import through **Data → Get Data → Text/CSV → Transform Data**.
- Validate semantic types: IDs (whole number), dates, amounts (decimal/fixed decimal), FX rates and text statuses.
- Ask the first modeling question: **What does one row represent?** Actuals are postings; budget is planned values at a coarser grain.

### 2. Classify actuals and reproduce the P&L

Use the account dimension to label revenue, direct costs, operating expenses and signed other activity. Make PivotTables by account category and year. Then reconcile:

```text
Gross Profit      = Revenue - COGS
Operating Income = Gross Profit - OPEX
Net Income       = Operating Income + Net Other
```

Guide benchmarks **for all 2023–2025**:

| P&L check | Approximate amount |
|---|---:|
| Revenue | $303.37M |
| COGS | $76.46M |
| Gross profit | $226.91M |
| OPEX | $133.81M |
| Operating income | $93.10M |
| Net income | $94.26M |

Annual revenue: about $44.4M (2023), $106.1M (2024), $152.8M (2025). If results do not reconcile, stop and investigate classification, exclusions, signs or duplicates **before** proceeding.

### 3. Understand the official budget — without rewriting it

Inspect every `scenario` value before choosing a budget. A budget row is not comparable with a posting until both use a common reporting period/account/department grain. Budgeted revenue, COGS and OPEX must be classified with the *same account rules* as actuals.

### 4. Calculate Actual vs. Budget correctly

```excel
=Actual-Budget
=IFERROR((Actual-Budget)/Budget,0)
```

The formula above reflects the training guide. **Production note:** `IFERROR(...,0)` can conceal an undefined percentage if Budget=0; explicitly display **N/A** or blank and flag the zero-budget line for separate review. Do **not** silently imply zero variance.

| Classification | `Actual - Budget > 0` | `Actual - Budget < 0` |
|---|---|---|
| Revenue / income | Generally favorable | Generally unfavorable |
| COGS / OPEX (stored positive) | Generally unfavorable | Generally favorable |

Report **both dollar impact and relative %**. A small percentage on a huge expense base may matter more than a high percentage on an immaterial account.

### 5. Review departmental spend and the R&D control

Compare **actual expense** to **budget expense** by department; do **not** call it departmental net profit. The supplied guides use Department 7 / R&D as a crucial historical reconciliation check: **~$76.66M actual expense** versus **~$74.92M budget expense** for the referenced full-period control. An earlier erroneous budget was dramatically overstated; the lesson is to reconcile before presenting. These whole-period figures are **not** the same filter context as the 2025 departmental chart.

### 6. Build a separate, driver-based planning exercise

The official `fact_budget.csv` stays official. An Excel **learning model** explains *how a planner could calculate a budget*, not how the authoritative file was necessarily created.

| Driver (illustrative guide assumption) | Value |
|---|---:|
| Revenue growth target | 10.0% |
| Hosting / payment / delivery / third-party rates | 14.0% / 2.5% / 4.5% / 3.0% |
| Sales commission / campaign rate | 5.5% / 6.0% |
| Cost inflation | 4.0% |

Other examples: seasonality-adjusted monthly revenue, COGS tied to planned revenue, payroll planning, commission rates and inflation-sensitive operating expenses. Centralize assumptions in a named table such as `tblBudgetAssumptions`, rather than hiding percentages inside formulas.

```excel
'Conceptual table-based formula
=[@[Prior Revenue]]*(1+[@Growth])*[@Seasonality]

'Illustrative direct cost plan
=BudgetRevenue*(HostingRate+PaymentProcessingRate+DeliveryRate+ThirdPartyRate)
```

These are *planning assumptions*, not empirical business driver estimates or a forecast quality claim.

### 7. Build repeatable control checks

Record expected vs. actual checks for row counts, source totals, P&L reconciliation, account classification, duplicate IDs, budget natural keys, period coverage, zero-budget ratios, and department expense. For each check maintain `Check | Expected | Observed | Status | Notes / owner`. Preserve run date and filter context.

## Key decisions and lessons

- Frozen raw inputs protect reproducibility and reduce accidental corruption.
- **Account classification** matters more than the raw numeric sign.
- Budget can legitimately use a different grain from transaction actuals.
- Variance arithmetic is universal, but favorable/unfavorable interpretation is business-dependent.
- A budget forecast exercise is not a replacement for the official baseline.
- Reconciliation is a control, not formatting polish.

