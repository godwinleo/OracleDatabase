set pages 200
set lines 185
col sess for a10
col username for a20
col event for a29 truncated
col sql_text for a35
col remaining for a29
col object_name for a25 truncated
col PAR for 9999
col module for a25 truncated
col comp for 99.99
set trims on
select s.username,s.sid||','||s.serial# sess,pxs.qcsid PAR, sw.event
, O.OBJECT_NAME, o.subobject_name
, trunc(sofar/totalwork*100,'2') comp --, numtodsinterval(time_remaining,'second') remaining
--, nvl(slo.sql_id,sql.sql_id) sql_id --,sql.sql_text
, s.sql_id --,sql.sql_text
, s.module
, round(s.last_call_et/60,2) min_lc
from v$session s
,v$session_wait sw
,v$px_session pxs
,v$sql sql
,dba_objects o
,(select * from v$session_longops where sofar < totalwork) slo
where 
s.sid=sw.sid
and s.status='ACTIVE'
and s.sid=pxs.sid (+)
and s.sql_id=sql.sql_id (+)
and s.sql_child_number=sql.child_number (+)
and s.row_wait_obj#=o.object_id (+)
and s.sid=slo.sid (+)
--and s.username is not null
--and s.paddr not in (select PADDR from V$BGPROCESS)
and s.type!='BACKGROUND'
order by s.username,pxs.qcsid,s.program,sw.event,o.object_name
;
