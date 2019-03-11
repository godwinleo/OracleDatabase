define user=&1
set pages 200
set lines 185
col sid for 9999
col serial# for 99999
col event for a27
col name for a45
col qcsid for 9999
col Block for 99999999
col segment_name for a25
set trims on
select /*+ first_rows */ s.sid,s.serial#
, pxs.qcsid 
, sw.event
--, trunc(sofar/totalwork*100,'2') comp --, numtodsinterval(time_remaining,'second') remaining
--, sql.hash_value --,sql.sql_text
--,sw.p1text,sw.p1,sw.p2text,sw.p2,sw.p3text,sw.p3
,df.name
,ext.segment_name
,sw.p2 Block
,wait_time,seconds_in_wait
from v$session s,v$session_wait sw 
, v$px_session pxs
, v$datafile df
--, (select * from v$session_longops where sofar < totalwork) slo
--, v$sqlarea sql
, dba_extents ext
where 
s.sid=sw.sid
and s.sid=pxs.sid (+)
and s.username=upper('&user')
and sw.p1=df.file#
and sw.p1text='file#'
--and slo.sid=s.sid (+)
--and s.sql_address=sql.address (+)
and sw.p1=ext.file_id
and sw.p2 between ext.block_id and (ext.block_id+ext.blocks-1)
--order by pxs.qcsid,s.sid
;
