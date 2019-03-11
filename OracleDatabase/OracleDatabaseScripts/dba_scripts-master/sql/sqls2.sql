set pages 185
set pages 70
set feed off
col sql_text for a27 truncated
col gets_x_ex for 999,999,999.99
col users for 999
col BUFFER_GETS for 999,999,999,999
col plan_hash for 9999999999
col PCT_CPU for 99.99
col COST for 9,999
select *
from (
select hash_value,PLAN_HASH_VALUE plan_hash
,cpu_time
,round(ratio_to_report(cpu_time) over ()*100,2) PCT_CPU
,USERS_EXECUTING users,EXECUTIONS
,BUFFER_GETS
,BUFFER_GETS/EXECUTIONS gets_x_ex
,DISK_READS
,OPTIMIZER_COST COST
,sql_text
,LAST_LOAD_TIME
from v$sql
where USERS_EXECUTING > 0 and EXECUTIONS > 0
) sqls
where PCT_CPU > 2
order by cpu_time
;
