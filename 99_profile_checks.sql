-- sql/99_profile_checks.sql
-- Force a real scan (disable result cache), run a query, and inspect profile.

-- 1) Disable cached results for this session
ALTER SESSION SET USE_CACHED_RESULT = FALSE;

-- 2) Example: run a report query (paste one here), then re-enable cache
-- ... your query here ...

-- 3) Re-enable cached results
ALTER SESSION UNSET USE_CACHED_RESULT;

-- 4) Programmatic profile parsing by query id (replace <QUERY_ID>)
WITH p AS (
  SELECT PARSE_JSON(SYSTEM$GET_QUERY_PROFILE('<QUERY_ID>')) j
)
SELECT
  t.value:objectName::string        AS table_name,
  t.value:partitionsScanned::number AS partitions_scanned,
  t.value:partitionsTotal::number   AS partitions_total,
  t.value:bytesRead::number         AS bytes_read
FROM p, LATERAL FLATTEN(input => j:tables) t
ORDER BY bytes_read DESC;
