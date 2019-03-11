define sid=&1
set pages 200
set lines 185
col sid for 9999
col serial# for 99999
col event for a45 word_wrapped
col qcsid for 9999
col comp for 999.99
col p1text for a15
col p2text for a15
col p3text for a10
col p1 for 99999999999999999999
col p2 for 9999999999999
col p3 for 999999
col wait_time for 9999
col secs for 9999
set trims on
select s.sid,s.serial#
, pxs.qcsid 
, sw.event
, trunc(sofar/totalwork*100,'2') comp --, numtodsinterval(time_remaining,'second') remaining
, sql.hash_value --,sql.sql_text
,sw.p1text,sw.p1,sw.p2text,sw.p2,sw.p3text,sw.p3
,sw.wait_time,sw.seconds_in_wait secs
from v$session s,v$session_wait sw, v$sqlarea sql
, (select * from v$session_longops where sofar < totalwork) slo
, v$px_session pxs
where 
s.sid=sw.sid
and s.sql_Address=sql.address (+)
and s.sid=slo.sid (+)
and s.sid=pxs.sid (+)
and s.sid = &sid
order by pxs.qcsid,s.sid
;
