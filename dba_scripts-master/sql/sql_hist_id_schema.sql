define sqlid=&1
define schema=&2
set pages 100
col plan_hash for 9999999999
col begin_interval_time for a15 truncated
col end_interval_time for a15 truncated
col sql_profile for a15 truncated
col execs for 999999999
col gets for 9999999999
col reads for 9999999999
col cpu_min for 99999999
col elap_min for 99999999
col rows_x_sec for 999999.99
col end_of_fet for 9999999
col prs_schema for a12

select plan_hash_value plan_hash
,parsing_schema_name prs_schema
--,optimizer_cost
,buffer_gets_total gets,disk_reads_total reads,executions_total execs,fetches_total fetches,rows_processed_total rows_proc 
,END_OF_FETCH_COUNT_TOTAL end_of_fet
,begin_interval_time,end_interval_time,sql_profile
,cpu_time_total/1000/1000/60 cpu_min, elapsed_time_total/1000/1000/60 elap_min
--,decode(elapsed_time_total,0,'N/A',round(rows_processed_total/(elapsed_time_total/1000/1000),3)) rows_x_sec
,round(rows_processed_total/(elapsed_time_total/1000/1000),3) rows_x_sec
from dba_hist_sqlstat sql, dba_hist_snapshot snap
where 
  sql.snap_id=snap.snap_id
  and sql_id='&sqlid'
  --and begin_interval_time > sysdate-30
  --and END_OF_FETCH_COUNT_TOTAL > 0
  and buffer_gets_total!=0
  and parsing_schema_name like upper('&schema')
order by snap.snap_id
/
