set pages 200
set lines 185
col sid for 9999
col serial# for 99999
col username for a20
col event for a29
col sql_text for a35
col remaining for a29
col object_name for a23
col PAR for 9999
col program for a35
set trims on
select s.username,s.sid,s.serial#,pxs.qcsid PAR, sw.event, O.OBJECT_NAME
, trunc(sofar/totalwork*100,'2') comp --, numtodsinterval(time_remaining,'second') remaining
, sql.sql_id --,sql.sql_text
, s.program
from v$session s,v$session_wait sw, v$sql sql, dba_objects o
, (select * from v$session_longops where sofar < totalwork) slo
, v$px_session pxs
where 
s.sid=sw.sid
and s.sql_id=sql.sql_id (+)
and s.sql_child_number=sql.child_number (+)
and s.sid=slo.sid (+)
and s.row_wait_obj#=o.object_id (+)
and s.sid=pxs.sid (+)
and s.status='ACTIVE'
and s.username is not null
order by s.username,pxs.qcsid,s.program,sw.event,o.object_name
;
