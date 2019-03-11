define name=&1
set echo off
set feed on
col parsing_schema_name for a15 truncated
col plan_hash for 9999999999

select sql_id,plan_hash_value plan_hash,parsing_schema_name
,round(elapsed_time/1000/1000/60,2) elap_min ,round(cpu_time/1000/1000/60,2) cpu_min
,buffer_gets,disk_reads
,rows_processed,fetches,executions
,round(rows_processed/(elapsed_time/1000/1000),3) rows_x_sec
,optimizer_cost 
FROM TABLE(DBMS_SQLTUNE.select_sqlset ('&name'))
order by buffer_gets,disk_reads
/

