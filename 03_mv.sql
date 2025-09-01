-- sql/03_mv.sql
-- Create a Materialized View to pre-aggregate profit at (date_sk, customer_sk),
-- then run your weekday-by-country report against the MV.

USE SCHEMA WORK_DB.TPCDS;

CREATE OR REPLACE MATERIALIZED VIEW MV_SALES_PROFIT_BY_DATE_CUSTOMER AS
SELECT
  ss_sold_date_sk,
  ss_customer_sk,
  SUM(COALESCE(ss_net_profit, 0)) AS profit
FROM STORE_SALES
GROUP BY 1,2;

-- Report (year 2000), using your CASE + (no extra COALESCE) style
SELECT 
  c.c_birth_country,
  SUM(CASE WHEN d.d_day_name='Monday'    THEN s.profit ELSE 0 END) AS Monday,
  SUM(CASE WHEN d.d_day_name='Tuesday'   THEN s.profit ELSE 0 END) AS Tuesday,
  SUM(CASE WHEN d.d_day_name='Wednesday' THEN s.profit ELSE 0 END) AS Wednesday,
  SUM(CASE WHEN d.d_day_name='Thursday'  THEN s.profit ELSE 0 END) AS Thursday,
  SUM(CASE WHEN d.d_day_name='Friday'    THEN s.profit ELSE 0 END) AS Friday,
  SUM(CASE WHEN d.d_day_name='Saturday'  THEN s.profit ELSE 0 END) AS Saturday,
  SUM(CASE WHEN d.d_day_name='Sunday'    THEN s.profit ELSE 0 END) AS Sunday
FROM MV_SALES_PROFIT_BY_DATE_CUSTOMER s
JOIN DATE_DIM d
  ON s.ss_sold_date_sk = d.d_date_sk
 AND d.d_year = 2000
LEFT JOIN CUSTOMER c 
  ON s.ss_customer_sk = c.c_customer_sk
WHERE c.c_birth_country IS NOT NULL
GROUP BY c.c_birth_country
ORDER BY c.c_birth_country;
