define sid=&1
set pages 200
set lines 185
col sid for 9999
col serial# for 99999
col username for a20
col osuser for a20
col machine for a30
col program for a30
col module for a30
set trims on
select s.sid||','||s.serial# sess
, username
, to_char (logon_time,'YYYY-MON-DD HH24:MI') logon_time
--,sw.event
, s.osuser, s.program, s.module, s.machine
, sql_id --, plan_hash_value
from v$session s --,v$session_wait sw
where s.sid=&sid
;
