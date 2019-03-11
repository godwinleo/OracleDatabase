define sqlid=&1
set pages 100
col plan_hash for 9999999999
col begin_interval_time for a17 truncated
col end_interval_time for a17 truncated
col sql_profile for a15 truncated
col execs for 999999999
col gets for 9999999999
col reads for 9999999999
col cpu_min for 99999999
col elap_min for 99999999
col elap_min_delta for 99999999
col max_minutes for 99999999
col rows_x_sec for 999999.99
col end_of_fet for 9999999
col prs_schema for a20

select 'HIST' source, snap_id, plan_hash , prs_schema, gets, reads
, execs, fetches, rows_proc --, end_of_fet
,begin_interval_time,end_interval_time,sql_profile
--,cpu_min
,elap_min
, rows_x_sec
from
(
	select plan_hash_value plan_hash
	,parsing_schema_name prs_schema
	, snap.snap_id
	--,optimizer_cost
	,buffer_gets_total gets,disk_reads_total reads,executions_total execs,fetches_total fetches,rows_processed_total rows_proc 
	,END_OF_FETCH_COUNT_TOTAL end_of_fet
	,begin_interval_time,end_interval_time,sql_profile
	--,to_date(begin_interval_time,'YYYY-MON-DD HH24:MI:SS'),end_interval_time,sql_profile
	,cpu_time_total/1000/1000/60 cpu_min, elapsed_time_total/1000/1000/60 elap_min
	,MAX(elapsed_time_total/1000/1000/60) KEEP (DENSE_RANK LAST ORDER BY elapsed_time_total) OVER (PARTITION BY plan_hash_value,trunc(BEGIN_INTERVAL_TIME)) max_minutes
	--,elapsed_time_delta/1000/1000/60 elap_min_delta
	--,decode(elapsed_time_total,0,'N/A',round(rows_processed_total/(elapsed_time_total/1000/1000),3)) rows_x_sec
	,round(rows_processed_total/(elapsed_time_total/1000/1000),3) rows_x_sec
	from dba_hist_sqlstat sql, dba_hist_snapshot snap
	where 
	sql.snap_id=snap.snap_id
	and sql_id='&sqlid'
	--and begin_interval_time > sysdate-45
	--and END_OF_FETCH_COUNT_TOTAL > 0
	and elapsed_time_total >= elapsed_time_delta
	and buffer_gets_total!=0
	order by snap.snap_id
)
where max_minutes = elap_min
union all
select 'CURRENT' source, 0 snap_id
,plan_hash_value plan_hash ,PARSING_SCHEMA_NAME prs_schema, buffer_gets gets ,disk_reads reads
,executions execs ,fetches fetches, rows_processed rows_proc --, end_of_fet
, sysdate begin_interval_time, sysdate end_interval_time, sql_profile
--,cpu_min
--,cpu_time/1000/1000/60 cpu_min
,elapsed_time/1000/1000/60 elap_min
--, decode(executions,0,'N/A',round(elapsed_time/executions/1000/1000/60,5)) min_x_ex
,round(rows_processed/(elapsed_time/1000/1000),3) rows_x_sec 
from v$sql
where sql_id='&sqlid'
/
