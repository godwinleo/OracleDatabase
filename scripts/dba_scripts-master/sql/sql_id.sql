define sqlid=&1
set pages 100
col plan_hash for 9999999999
col sql_profile for a19 word_wrapped
col execs for 999999999
col gets for 999999999
col reads for 999999999
col min_x_ex for a8
col rows_x_sec for 9999999.99
col p_schema for a12 truncated
col inv for 999
col last_load for a17
col last_active for a17

select plan_hash_value plan_hash
, PARSING_SCHEMA_NAME p_schema
--,optimizer_cost
,buffer_gets gets,disk_reads reads
,executions execs,fetches fetches
,rows_processed rows_proc
--, to_char(FIRST_LOAD_TIME,'YYYY-MON-DD HH24:MI') first_load
, to_char(to_date(last_LOAD_TIME,'YYYY-MM-DD/HH24:MI:SS'),'YYYY-MON-DD HH24:MI') last_load
, to_char(LAST_ACTIVE_TIME,'YYYY-MON-DD HH24:MI') last_active
, invalidations inv
,sql_profile
,cpu_time/1000/1000/60 cpu_min,elapsed_time/1000/1000/60 elap_min
, decode(executions,0,'N/A',round(elapsed_time/executions/1000/1000/60,5)) min_x_ex
,round(rows_processed/(elapsed_time/1000/1000),3) rows_x_sec
from v$sql
where sql_id='&sqlid'
/
