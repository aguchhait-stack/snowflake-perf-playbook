-- sql/02_clustering.sql
-- Add a clustering key and inspect clustering quality.

USE SCHEMA WORK_DB.TPCDS;

-- Cluster by the date surrogate key (aligns with date filters via DATE_DIM)
ALTER TABLE STORE_SALES CLUSTER BY (SS_SOLD_DATE_SK);

-- Inspect clustering statistics (JSON)
SELECT SYSTEM$CLUSTERING_INFORMATION('WORK_DB.TPCDS.STORE_SALES','(SS_SOLD_DATE_SK)') AS CLUSTER_REPORT;
