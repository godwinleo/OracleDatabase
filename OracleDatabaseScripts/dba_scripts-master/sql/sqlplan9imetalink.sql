-- Extract the plan for the a SID (v9i)

CLEAR COLUMN
COLUMN  sql_hash_value  NEW_VALUE sql_hash_value
COLUMN  sql_address     NEW_VALUE sql_address


SELECT  s.sql_hash_value, s.sql_address
FROM    v$session s
WHERE   sid = &1
/


COLUMN "Rows" FORMAT a6
COLUMN "Plan" FORMAT a68 wrap
COLUMN id FORMAT a4 justify right

SET PAGESIZE 500

WITH pt AS (
        SELECT  *
        FROM    v$sql_plan p
        WHERE   p.hash_value = '&sql_hash_value'
        AND     p.address = '&sql_address'
)
SELECT  xid AS id
,       plan AS "Plan"
,       rws AS "Rows"
FROM (
        SELECT  decode(access_predicates || filter_predicates, NULL, ' ', '*') ||
                lpad(id, 3, ' ') AS xid
        ,       lpad(' ',depth-1)||operation||' '|| options||' '||object_name
                || decode(partition_start, NULL, NULL, ' ' || partition_start || ':' || partition_stop)
                AS plan
        ,       lpad(
                        CASE
                                WHEN cardinality > 1000000
                                THEN to_char(trunc(cardinality/1000000)) || 'M'
                                WHEN cardinality > 1000
                                THEN to_char(trunc(cardinality/1000)) || 'K'
                                ELSE cardinality || ' '
                        END
                ,       6
                ,       ' '
                ) AS rws
        ,       id
        FROM    pt
        ORDER BY id
)
UNION ALL
SELECT  NULL
,       chr(10) || 'Access Predicates' || chr(10) || '------------------------'
,       NULL
FROM    dual
UNION ALL
SELECT  to_char(id)
,       access_predicates
,       NULL
FROM    pt
WHERE   access_predicates IS NOT NULL
UNION ALL
SELECT  NULL
,       chr(10) || 'Filter Predicates' || chr(10) || '------------------------'
,       NULL
FROM    dual
UNION ALL
SELECT  to_char(id)
,       filter_predicates
,       NULL
FROM    pt
WHERE   filter_predicates IS NOT NULL
/
