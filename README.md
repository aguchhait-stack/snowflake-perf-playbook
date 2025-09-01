# Snowflake TPC-DS Weekday-by-Country Performance Playbook

This repo captures a baseline query and a step-by-step optimization plan using:
- **Clustering** on the fact table
- A **Materialized View (MV)** pre-aggregated at `(ss_sold_date_sk, ss_customer_sk)`
- A **Dynamic Table (DT)** with time-based refresh
- Query profile checks to verify pruning/bytes scanned

> All scripts assume your writable copies live in `WORK_DB.TPCDS`. Adjust names as needed.

## Contents

- `sql/01_setup.sql` — Create DB/schema and copy sample tables.
- `sql/02_clustering.sql` — Add clustering & inspect clustering quality.
- `sql/03_mv.sql` — Create MV and run the MV-backed report.
- `sql/04_dt.sql` — Create DT and run the DT-backed report.
- `sql/05_reports.sql` — Baseline report using the original tables (your style).
- `sql/99_profile_checks.sql` — Turn result cache off and inspect Query Profile programmatically.

## Your Baseline Query (Original Style)

```sql
SELECT C_BIRTH_COUNTRY,
  SUM(CASE WHEN D_DAY_NAME='Monday'    THEN COALESCE(SS_NET_PROFIT,0) ELSE 0 END) AS Monday,
  SUM(CASE WHEN D_DAY_NAME='Tuesday'   THEN COALESCE(SS_NET_PROFIT,0) ELSE 0 END) AS Tuesday,
  SUM(CASE WHEN D_DAY_NAME='Wednesday' THEN COALESCE(SS_NET_PROFIT,0) ELSE 0 END) AS Wednesday,
  SUM(CASE WHEN D_DAY_NAME='Thursday'  THEN COALESCE(SS_NET_PROFIT,0) ELSE 0 END) AS Thursday,
  SUM(CASE WHEN D_DAY_NAME='Friday'    THEN COALESCE(SS_NET_PROFIT,0) ELSE 0 END) AS Friday,
  SUM(CASE WHEN D_DAY_NAME='Saturday'  THEN COALESCE(SS_NET_PROFIT,0) ELSE 0 END) AS Saturday,
  SUM(CASE WHEN D_DAY_NAME='Sunday'    THEN COALESCE(SS_NET_PROFIT,0) ELSE 0 END) AS Sunday
FROM WORK_DB.TPCDS.STORE_SALES s
LEFT JOIN WORK_DB.TPCDS.DATE_DIM d
  ON s.ss_sold_date_sk = d.d_date_sk
LEFT JOIN WORK_DB.TPCDS.CUSTOMER c 
  ON s.ss_customer_sk = c.c_customer_sk
WHERE d.d_year = 2000
  AND c.c_birth_country IS NOT NULL
GROUP BY C_BIRTH_COUNTRY;
```

## Quick Start

```bash
# (optional) create a new git repo and push to GitHub
git init
git add .
git commit -m "Snowflake perf playbook: clustering, MV, DT, profile checks"
# Create an empty repo on GitHub first, then:
git branch -M main
git remote add origin https://github.com/<your-username>/snowflake-perf-playbook.git
git push -u origin main
```

---

**Tip:** To measure real scans (not cache), run `sql/99_profile_checks.sql` first to disable cached results, then execute a report and inspect Query Profile in Snowsight.
