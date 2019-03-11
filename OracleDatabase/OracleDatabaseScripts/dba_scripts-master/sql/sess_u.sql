define user=&1
set pages 200
set lines 185
col sess for a10
col spid for a9
col event for a27
col sql_id for a13
col remaining for a19 trunc
col object for a30 trunc
col comp for 99.99
col temp_mb for 99,999
col status for a10
set trims on
select s.sid||','||s.serial# sess
,pxs.qcsid PAR,proc.spid
,s.status,sw.event
, O.OBJECT_NAME||':'||O.SUBOBJECT_NAME object
, trunc(sofar/totalwork*100,'2') comp, numtodsinterval(time_remaining,'second') remaining
, round(nvl(su.temp_bytes,0)/1024/1024) TEMP_MB
, sql.sql_id
, sql.plan_hash_value
,round(s.last_call_et/60,2) lc_min
from v$session s
  ,v$session_wait sw
  ,v$px_session pxs
  ,(select * from v$session_longops where sofar < totalwork) slo
  ,(select session_addr,sum(blocks*block_size) temp_bytes
      from v$sort_usage, dba_tablespaces 
      where tablespace=tablespace_name
      group by session_addr,tablespace_name) su
  ,v$sql sql
  ,v$process proc
  ,dba_objects o
where 
  s.sid=sw.sid
  and s.sid=pxs.sid (+)
  and s.sql_id=sql.sql_id (+)
  and s.sql_child_number=sql.CHILD_NUMBER (+)
  and s.paddr=proc.addr (+)
  and s.sid=slo.sid (+)
  and s.row_wait_obj#=o.object_id (+)
  and s.saddr=su.session_addr (+)
  and s.username like upper('&user')
order by pxs.qcsid,s.program,sw.event,o.object_name
/
