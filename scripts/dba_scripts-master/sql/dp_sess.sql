set pages 200
set lines 190
col sess for a9
col username for a12
col event for a35 truncated
col sql_text for a35
col remaining for a19 truncated
col object_name for a35 truncated
col PAR for 9999
col module for a16 truncated
col comp for 99.99
col job for a42
col type for a8
set trims on
select 
s.sid||','||s.serial# sess
--,s.username
--,dps.job_name job
,dps.owner_name||'.'||dps.job_name job
, sw.event, o.owner||'.'||O.OBJECT_NAME||':'||o.subobject_name object_name
, trunc(sofar/totalwork*100,'2') comp, numtodsinterval(time_remaining,'second') remaining
--, nvl(slo.sql_id,sql.sql_id) sql_id --,sql.sql_text
, s.sql_id --,sql.sql_text
--, s.module
, round(s.last_call_et/60,2) min_lc
, session_type type
from v$session s
,v$session_wait sw
,v$sql sql
,dba_objects o
,dba_datapump_sessions dps
,(select * from v$session_longops where sofar < totalwork) slo
where 
s.sid=sw.sid
and s.status='ACTIVE'
and s.sql_id=sql.sql_id (+)
and s.sql_child_number=sql.child_number (+)
and s.row_wait_obj#=o.object_id (+)
and s.sid=slo.sid (+)
and s.saddr=dps.saddr
order by dps.job_name,dps.session_type,dps.saddr
;
