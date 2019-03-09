set pages 200
set lines 185
col sid for 9999
col serial# for 99999
col event for a30
col osuser for a20
col machine for a30
col program for a30
set trims on
 select 'alter system kill session '''||s.sid||','||s.serial#||''';'
 from v$session s,v$session_wait sw, v$transaction t
 where
 s.sid=sw.sid
 and s.taddr=t.addr
 and s.username!='SYS'
;
