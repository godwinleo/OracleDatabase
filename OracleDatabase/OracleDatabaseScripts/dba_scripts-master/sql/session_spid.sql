define spid=&1
set pages 200
set lines 185
col sid for 9999
col serial# for 99999
col username for a20
col event for a27
col sql_text for a35
col object_name for a23
col subobject_name for a18
col comp for 99.99
set trims on
select s.username,s.sid,s.serial#,sw.event
, O.OBJECT_NAME, O.SUBOBJECT_NAME
, sql.sql_text
from v$session s,v$session_wait sw, v$sql sql, dba_objects o
, v$process p
where 
s.sid=sw.sid
and s.sql_Address=sql.address (+)
and s.row_wait_obj#=o.object_id (+)
and s.paddr=p.addr
and p.spid=&spid
;
