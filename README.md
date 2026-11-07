# Oracle SQL Query Optimization — P-004

A measured Oracle SQL experiment comparing function-based date filtering against a half-open date range in a monthly sales aggregation.

## Workload

Oracle Database Free, `FREEPDB1`, schema `P004`. Synthetic tables: `SALES` (500,000 rows), `CUSTOMERS` (10,000), `PRODUCTS` (1,000). The query joins the three tables and calculates January 2025 revenue by product category and customer province. The 2025 January query processes 21,233 sales rows and returns 20 groups.

**Data-generation limitation:** The original dataset was created in an earlier session and its generation script is unavailable. This repository preserves the queries, measurement protocol, observed plans and results, but does **not** claim that the original dataset can be regenerated exactly. A new generator would need independent validation before any reproducibility claim.

## Hypothesis

`EXTRACT(YEAR/MONTH FROM sale_date)` makes the filter less amenable to ordinary date-index range access and can impair cardinality estimates. A half-open date range expresses the same January 2025 filter without functions on the column. We also tested an index `IDX_SALES_DATE` on `SALES(SALE_DATE)`; Oracle still selected a full table scan.

## Measured results

| Metric | Baseline | Optimized |
|---|---:|---:|
| Estimated sales rows | 50 | 21,947 |
| Actual sales rows | 21,233 | 21,233 |
| Logical buffers (query) | 2,394 | 2,394 |
| Access to SALES | Full scan | Full scan |
| Pass 1 median (baseline first) | 350 ms | 80 ms |
| Pass 2 median (optimized first) | 250 ms | 60 ms |

Control pass median speedup: **4.17×** (250 / 60), or **76%** lower elapsed time. Both passes favored the date-range query, though timings varied and `DBMS_UTILITY.GET_TIME` measures in 10 ms increments. This is a result for this dataset and environment, not a general Oracle performance guarantee. The unchanged buffer count means the observed difference is not evidence of reduced logical I/O. SQL text, execution plans, and benchmark wrapper also differ, so do not attribute all timing difference to one isolated low-level cause.

Bidirectional `MINUS` validation returned **0 differences in either direction**. Both versions returned 20 groups and total revenue of 16,370,260.85.

## Files

- `sql/02_baseline.sql`: original query and actual plan inspection.
- `sql/03_optimized.sql`: rewritten query and index DDL (commented).
- `sql/04_validation.sql`: exact set comparison in both directions.
- `sql/05_benchmark.sql`: repeatable two-pass PL/SQL timing harness.
- `evidence/execution_plans.txt`: transcribed actual plan statistics from the original run.
- `evidence/benchmark_results.csv`: all 20 original measurements.

## How to repeat on an existing dataset

Connect to a schema with the three tables and columns referenced in the SQL files. Run the baseline and optimized SQL separately to inspect actual plans (access to the underlying Oracle dynamic performance views may be required). Run validation, then the benchmark harness via SQL Developer **F5 / Run Script**. For independent replication, create a comparable dataset first and record its generation method; the original data generator is not available.
