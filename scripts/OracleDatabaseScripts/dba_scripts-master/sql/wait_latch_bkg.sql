define user=&1
set pages 200
set lines 185
col program for a30
col sid for 9999
col serial# for 99999
col name for a45
col qcsid for 9999
col Latch for a30
col secs_in_wait for 99999
set trims on
select s.program,s.sid,s.serial#
, pxs.qcsid 
--, sw.event
--, trunc(sofar/totalwork*100,'2') comp --, numtodsinterval(time_remaining,'second') remaining
--, sql.hash_value --,sql.sql_text
--,sw.p1text,sw.p1,sw.p2text,sw.p2,sw.p3text,sw.p3
--,ln.name Latch
,l.name Latch,l.addr,l.gets,l.misses,l.sleeps
,sw.p3 Tries,sw.wait_time,sw.seconds_in_wait secs_in_wait
from v$session s,v$session_wait sw 
, v$px_session pxs
--, v$latchname ln
--, (select * from v$session_longops where sofar < totalwork) slo
--, v$sqlarea sql
,(SELECT addr,name, child#, gets, misses, sleeps
    FROM v$latch_children 
  UNION
  SELECT addr,name, null, gets, misses, sleeps
    FROM v$latch ) l
where 
s.sid=sw.sid
and s.sid=pxs.sid (+)
and s.username is null
and sw.event='latch free'
and sw.p1raw=l.addr
--and slo.sid=s.sid (+)
--and s.sql_address=sql.address (+)
--and sw.p2=ln.latch#
order by pxs.qcsid,l.addr,s.sid
;
