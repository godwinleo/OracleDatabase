define user=&1
set pages 200
set lines 185
col sid for 9999
col serial# for 99999
col username for a20
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
, sql.hash_value
, t.used_ublk
, su.BLOCKS
from v$session s,v$session_wait sw, v$sqlarea sql, dba_objects o, v$transaction t
, (select * from v$session_longops where sofar < totalwork) slo
, v$sort_usage su
where 
s.sid=sw.sid
and s.sql_Address=sql.address (+)
and s.taddr=t.addr (+)
and s.sid=slo.sid (+)
and s.sid=su.SESSION_NUM (+)
and s.row_wait_obj#=o.object_id (+)
and s.saddr=su.session_addr (+)
and s.username=upper('&user')
order by remaining 
;
