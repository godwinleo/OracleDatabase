define sid=&1
set pages 200
set lines 185
col sid for 9999
col serial# for 99999
col event for a30
col osuser for a20
col machine for a30
col program for a30
set trims on
select s.sid,s.serial#,sw.event
, s.osuser, s.program, s.module, s.machine
, sql.address, sql.hash_value
from v$session s,v$session_wait sw, v$sql sql
where 
s.sid=sw.sid
and s.sql_Address=sql.address (+)
and s.sid=&sid
;
