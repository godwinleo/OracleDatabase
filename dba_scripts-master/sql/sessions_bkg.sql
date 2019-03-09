set pages 200
set lines 185
col sid for 9999
col serial# for 99999
col username for a20
col event for a27
col sql_text for a35
col remaining for a29
col object_name for a23
col PAR for 9999
col program for a30
col p1text for a10
col p2text for a10
col p3text for a10
col p1 for 9999999999999999
col p1 for 99999999999999999999
col p2 for 9999
col p3 for 9999
set trims on
select s.program,s.sid,s.serial#, sw.event
--, trunc(sofar/totalwork*100,'2') comp --, numtodsinterval(time_remaining,'second') remaining
, sql.hash_value --,sql.sql_text
,sw.p1text,sw.p1,sw.p2text,sw.p2,sw.p3text,sw.p3
from v$session s,v$session_wait sw, v$sqlarea sql
--, (select * from v$session_longops where sofar < totalwork) slo
where 
s.sid=sw.sid
and s.sql_Address=sql.address (+)
--and s.sid=slo.sid (+)
and s.username is null
order by sid
;
