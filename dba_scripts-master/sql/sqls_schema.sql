define schema=&1
set pages 100
col cost for 99999999
col plan_hash for 9999999999
col sql_profile for a30
col execs for 999999999
col gets for 999999999
col reads for 999999999
col sql_profile for a20 
col min_x_exec for a10
col gets_x_exec for a10
col reads_x_exec for a10
col sql_text for a30 truncated

select 
sql_id
,plan_hash_value plan_hash
,optimizer_cost cost
,rows_processed rows_proc
,executions execs,fetches fetches
,buffer_gets gets,disk_reads reads
, decode(executions,0,'N/A',round(buffer_gets/executions/1000/1000/60,2)) gets_x_exec
, decode(executions,0,'N/A',round(disk_reads/executions/1000/1000/60,2)) reads_x_exec
,round(cpu_time/1000/1000/60,4) cpu_min,round(elapsed_time/1000/1000/60,4) elap_min
, decode(executions,0,'N/A',round(elapsed_time/executions/1000/1000/60,5)) min_x_exec
,sql_text
--, LAST_ACTIVE_TIME
--,sql_profile
from v$sql
where parsing_schema_name like upper('&schema')
and last_active_time > sysdate-(1/24/60*5)
order by reads,gets
/
