set pages 200
set lines 185
col sess for a10
col tablespace_name for a15
col event for a30
col osuser for a20
col module for a30 truncated
col username for a15
col machine for a30
col program for a30
col mb for 999,999.99
col start_scn for 99999999999999
col segment_name for a25
col status for a10
set trims on
break on report 
compute sum of MB on report
select undo.tablespace_name,undo.segment_name
   ,s.username ,s.sid||','||s.serial# sess
   ,undo.start_date,undo.start_scn
   ,undo.status,undo.mb
   ,sw.event
   ,s.module
from 
   ( select t.addr,seg.segment_name,seg.bytes/1024/1024 mb,t.status,seg.tablespace_name,t.start_scn,t.start_date
    from
      v$transaction t
      ,v$rollname rn
      ,dba_segments seg
     where
      t.xidusn=rn.usn
      and rn.name=seg.segment_name
     --group by t.addr,t.status,seg.tablespace_name,t.start_scn,t.start_date  
) undo
   ,v$session s
   ,v$session_wait sw
where 
   s.taddr=undo.addr
   and s.sid=sw.sid
order by mb
/
