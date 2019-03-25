set feed off verify off
define sqlid=&1.
rem prompt enter start and end times in format DD/MM/YYYY [HH24:MI]
  
column sample_end format a21
select to_char(min(s.end_interval_time),'DD/MM/YYYY DY HH24:MI') sample_end
, q.sql_id
, q.plan_hash_value
, sum(q.EXECUTIONS_DELTA) "execs"
, round(sum(DISK_READS_delta)/greatest(sum(executions_delta),1),0) "pio/exec"
, round(sum(BUFFER_GETS_delta)/greatest(sum(executions_delta),1),0) "lio/exec"
, round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1000),0) "msecs/exec"
from dba_hist_sqlstat q, dba_hist_snapshot s
where q.SQL_ID=trim('&sqlid.')
and s.snap_id = q.snap_id
and s.dbid = q.dbid
and s.instance_number = q.instance_number
--and s.end_interval_time >= to_date(trim('&-start_time.'),'dd/mm/yyyy hh24:mi')
--and s.begin_interval_time <= to_date(trim('&-end_time.'),'dd/mm/yyyy hh24:mi')
--and substr(to_char(s.end_interval_time,'DD/MM/YYYY DY HH24:MI'),13,2) like '%&-hr24_filter.%'
and s.end_interval_time >= TRUNC(SYSDATE)-2
and s.begin_interval_time <= TRUNC(SYSDATE)+1
group by s.snap_id
, q.sql_id
, q.plan_hash_value
having sum(q.EXECUTIONS_DELTA) > 0
order by s.snap_id, q.sql_id, q.plan_hash_value
/

undefine 1 sqlid