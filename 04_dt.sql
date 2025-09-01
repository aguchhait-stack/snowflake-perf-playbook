-- sql/04_dt.sql
-- Create a Dynamic Table (time-based auto-refresh) for the same pre-agg,
-- then run the weekday-by-country report against the DT.

USE SCHEMA WORK_DB.TPCDS;

-- Replace YOUR_WH with an existing warehouse name
CREATE OR REPLACE DYNAMIC TABLE DT_SALES_PROFIT_BY_DATE_CUSTOMER
TARGET_LAG = '15 minutes'
WAREHOUSE  = YOUR_WH
AS
SELECT
  ss_sold_date_sk,
  ss_customer_sk,
  SUM(COALESCE(ss_net_profit, 0)) AS profit
FROM STORE_SALES
GROUP BY 1,2;

-- Report (year 2000), same shape as MV
SELECT 
  c.c_birth_country,
  SUM(CASE WHEN d.d_day_name='Monday'    THEN dt.profit ELSE 0 END) AS Monday,
  SUM(CASE WHEN d.d_day_name='Tuesday'   THEN dt.profit ELSE 0 END) AS Tuesday,
  SUM(CASE WHEN d.d_day_name='Wednesday' THEN dt.profit ELSE 0 END) AS Wednesday,
  SUM(CASE WHEN d.d_day_name='Thursday'  THEN dt.profit ELSE 0 END) AS Thursday,
  SUM(CASE WHEN d.d_day_name='Friday'    THEN dt.profit ELSE 0 END) AS Friday,
  SUM(CASE WHEN d.d_day_name='Saturday'  THEN dt.profit ELSE 0 END) AS Saturday,
  SUM(CASE WHEN d.d_day_name='Sunday'    THEN dt.profit ELSE 0 END) AS Sunday
FROM DT_SALES_PROFIT_BY_DATE_CUSTOMER dt
JOIN DATE_DIM d
  ON dt.ss_sold_date_sk = d.d_date_sk
 AND d.d_year = 2000
LEFT JOIN CUSTOMER c 
  ON dt.ss_customer_sk = c.c_customer_sk
WHERE c.c_birth_country IS NOT NULL
GROUP BY c.c_birth_country
ORDER BY c.c_birth_country;
