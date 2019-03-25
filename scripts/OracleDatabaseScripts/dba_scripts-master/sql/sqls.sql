set pages 185
set pages 70
set feed off
col sql_text for a30 truncated
col gets_x_ex for 999,999,999.99
col users for 999
col BUFFER_GETS for 999,999,999,999
col plan_hash for 9999999999
col PCT_CPU for 999.99
col prs_schema for a12
select sql_id
,parsing_Schema_name prs_schema ,PLAN_HASH_VALUE plan_hash
,cpu_time
,round(ratio_to_report(cpu_time) over ()*100,2) PCT_CPU
,USERS_EXECUTING users,EXECUTIONS
,BUFFER_GETS
,BUFFER_GETS/EXECUTIONS gets_x_ex
,DISK_READS
,sql_text
,FIRST_LOAD_TIME
from v$sql
where USERS_EXECUTING > 0 and EXECUTIONS > 0
order by cpu_time
;
