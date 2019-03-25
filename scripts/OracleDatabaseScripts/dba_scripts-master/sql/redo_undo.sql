set pages 200
set lines 185
col sid for 9999
col serial# for 99999
col tablespace_name for a20
col event for a30
col osuser for a20
col module for a25
col username for a20
col machine for a30
col program for a30
col undo_mb for 999,999.99
set trims on
select s.sid||','||s.serial# sess
   ,s.username,undo.tablespace_name
   ,undo.status,undo.mb undo_mb
   ,io.block_changes
   ,sw.event
   ,s.module
from 
   ( select t.addr,sum(seg.bytes/1024/1024) mb,t.status,seg.tablespace_name
    from
      v$transaction t
      ,v$rollname rn
      ,dba_segments seg
     where
      t.xidusn=rn.usn
      and rn.name=seg.segment_name
     group by t.addr,t.status,seg.tablespace_name  ) undo
   ,v$session s
   ,v$session_wait sw
   ,v$sess_io io
where 
   s.taddr=undo.addr
   and s.sid=sw.sid
   and s.sid=io.sid (+)
order by mb
/
