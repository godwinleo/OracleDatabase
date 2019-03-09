define schema=&1
define tab=&2
col tab for a35
col estimate_percent for a10
col message for a55 word_wrapped
col granularity for a20
col job_id for 99999
col par for 99
select owner_name||'.'||table_name tab,process_id
,estimate_percent,parallel_degree par ,granularity,cascade_opt,ALL_partitions,FULL_month,clone_stats
block_sample,method_opt
,options
from DBADMIN.APP_MANUAL_STATS
where owner_name like upper ('&schema')
and table_name like upper ('&tab')
/

