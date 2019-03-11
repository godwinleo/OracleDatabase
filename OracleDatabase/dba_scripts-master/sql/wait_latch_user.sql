define user=&1
set pages 200
set lines 185
col sid for 9999
col serial# for 99999
col event for a27
col name for a45
col qcsid for 9999
col Latch for a45
col segment_name for a25
set trims on
select s.sid,s.serial#
, pxs.qcsid 
, sw.event
--, trunc(sofar/totalwork*100,'2') comp --, numtodsinterval(time_remaining,'second') remaining
--, sql.hash_value --,sql.sql_text
--,sw.p1text,sw.p1,sw.p2text,sw.p2,sw.p3text,sw.p3
,sw.p1raw address,sw.p3 tries
,ln.name Latch
,sw.wait_time,sw.seconds_in_wait
from v$session s,v$session_wait sw 
, v$px_session pxs
, v$latchname ln
--, (select * from v$session_longops where sofar < totalwork) slo
--, v$sqlarea sql
where 
s.sid=sw.sid
and s.sid=pxs.sid (+)
and s.username=upper('&user')
and sw.event like 'latch%'
--and slo.sid=s.sid (+)
--and s.sql_address=sql.address (+)
and sw.p2=ln.latch#
order by pxs.qcsid,s.sid
;
