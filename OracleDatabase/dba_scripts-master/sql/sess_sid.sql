define sid=&1
set pages 200
set lines 185
col sess for a10
col event for a27
col sql_id for a13
col remaining for a20 trunc
col object for a35 trunc
col subobject_name for a18 trunc
col comp for 99.99
col temp_mb for 99,999
col status for a20
col username for a20 truncated
col spid for a10
set trims on
select s.sid||','||s.serial# sess
,p.spid,s.username 
,sw.event
, O.OBJECT_NAME||':'||O.SUBOBJECT_NAME object
, trunc(sofar/totalwork*100,'2') comp, numtodsinterval(time_remaining,'second') remaining
, round(nvl(su.temp_bytes,0)/1024/1024) TEMP_MB
, sql.sql_id
, s.status
from v$session s
  ,v$session_wait sw
  ,(select * from v$session_longops where sofar < totalwork) slo
  ,(select session_addr,sum(blocks*block_size) temp_bytes
      from v$sort_usage, dba_tablespaces 
      where tablespace=tablespace_name
      group by session_addr,tablespace_name) su
  ,v$process p
  ,v$sql sql
  ,dba_objects o
where 
  s.sid=sw.sid
  and s.sql_id=sql.sql_id (+)
  and s.sql_child_number=sql.child_number (+)
  and s.sid=slo.sid (+)
  and s.row_wait_obj#=o.object_id (+)
  and s.saddr=su.session_addr (+)
  and s.paddr=p.addr
  and s.sid=&sid
/
