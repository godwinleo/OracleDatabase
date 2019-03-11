define sid=&1
set pages 200
set lines 185
col sid for 9999
col serial# for 99999
col event for a27
col sql_text for a35
col remaining for a29
col object_name for a23
col subobject_name for a18
col comp for 99.99
set trims on
select s.sid,s.serial#,sw.event
, O.OBJECT_NAME, O.SUBOBJECT_NAME
, trunc(sofar/totalwork*100,'2') comp, numtodsinterval(time_remaining,'second') remaining
, sql.sql_text
from v$session s,v$session_wait sw, v$sqlarea sql, dba_objects o
, (select * from v$session_longops where sofar < totalwork) slo
where 
s.sid=sw.sid
and s.sql_Address=sql.address (+)
and s.sid=slo.sid (+)
and s.row_wait_obj#=o.object_id (+)
and s.sid=&sid
;
