set lines 185
set pages 200
col tablespace for a20
col username for a20
col osuser for a15
col program for a30 truncated
col sess for a9
col spid for 99999
col status for a25
break on report
compute sum of USED_MB on report
select s.username,s.osuser,s.program,s.sid||','||s.serial# sess,p.spid, su.tablespace,(su.blocks*tb.block_size)/1024/1024 USED_MB,s.status
from 
v$sort_usage su
, v$session s
, dba_tablespaces tb
, v$process p
where 
su.tablespace = tb.tablespace_name
and su.session_addr=s.saddr
and s.paddr=p.addr
order by su.blocks,su.tablespace
;
