set pages 200
set lines 185
col sess for a10
col event for a30
col obj for a45
col osuser for a15
col username for a20
col machine for a30
col program for a30
col module for a30 truncate
set trims on
select obj.owner||'.'||obj.object_name obj,obj.object_type
,s.sid||','||s.serial# sess
,t.status,t.start_time
, s.username, s.module
,lo.locked_mode
from v$session s, v$transaction t, v$locked_object lo
, dba_objects obj
where 
s.sid=lo.SESSION_ID
and s.taddr=t.addr (+)
and lo.object_id=obj.object_id
order by s.username,s.sid,s.serial#,t.start_time
;
