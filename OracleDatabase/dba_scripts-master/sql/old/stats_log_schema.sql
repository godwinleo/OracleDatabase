define schema=&1
col owner_name for a10
col table_name for a25
col estimate_percent for a10
col message for a60
col granularity for a15
col log_id for 9999999
col par for 99
select log_id,owner_name,table_name,estimate_percent,parallel_degree par,granularity,cascade_opt,ALL_partitions,FULL_month,clone_stats,message,systime,block_sample,method_opt
from DBADMIN.APP_MANUAL_STATS_LOG
where trunc(systime)=trunc(sysdate)
and owner_name like upper ('&schema')
order by log_id
/

