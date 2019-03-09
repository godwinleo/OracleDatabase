define hash=&1
set pages 200
set lines 185
set feed on
col sid for 9999
col serial# for 99999
col username for a20
col event for a30
col sql_text for a35
col remaining for a29
col object_name for a24 truncated
col PAR for 9999
col program for a35
set trims on
select s.username
,s.sid,s.serial#,pxs.qcsid PAR
, sw.event --, O.OBJECT_NAME
, trunc(sofar/totalwork*100,'2') comp --, numtodsinterval(time_remaining,'second') remaining
, sql.plan_hash_value 
--, sql.sql_text
, s.PREV_HASH_VALUE
from v$session s,v$session_wait sw, v$sql sql
, x$kgllk l
--, dba_objects o
, (select * from v$session_longops where sofar < totalwork) slo
, v$px_session pxs
where 
s.sid=sw.sid
and s.sql_hash_value=sql.hash_value (+)
and sql.child_address=l.kgllkhdl
and s.saddr=l.kgllkuse
and s.sid=slo.sid (+)
--and s.row_wait_obj#=o.object_id (+)
and s.sid=pxs.sid (+)
and sql.hash_value=&hash
order by s.username,s.program,sw.event
;
