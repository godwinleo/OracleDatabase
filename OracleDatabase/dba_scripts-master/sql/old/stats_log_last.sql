define schema=&1
define tab=&2
col tab for a30
col estimate_percent for a10
col message for a55 word_wrapped
col granularity for a15
col job_id for 99999
col par for 99
select job_id,owner_name||'.'||table_name tab,estimate_percent,parallel_degree par,granularity,cascade_opt,ALL_partitions,FULL_month,clone_stats,message,to_char(systime,'YYYY-MON-DD HH24:MI:SS') systime,block_sample,method_opt
from DBADMIN.APP_MANUAL_STATS_LOG
--where trunc(systime)=trunc(sysdate)
where owner_name like upper ('&schema')
and table_name like upper ('&tab')
and job_id= (select max(job_id) from DBADMIN.APP_MANUAL_STATS_LOG
				where owner_name like upper ('&schema')
				and table_name like upper ('&tab'))
order by log_id
/

