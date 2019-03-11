col sess for a10
col tablespace_name for a20
col event for a30
col osuser for a20
col module for a30 truncated
col username for a20
col machine for a30
col program for a30
col mb for 999,999.99
col start_scn for 99999999999999
set trims on
break on report 
compute sum of MB on report
  
select ADDR, KTUXEUSN, KTUXESLT, KTUXESQN, KTUXESIZ, ktuxesta rollback_segment
, rn.NAME, seg.bytes/1024/1024 mb, seg.tablespace_name
from x$ktuxe trans
, v$rollname rn
, dba_segments seg
where KTUXECFL = 'DEAD'
and KTUXEUSN=rn.usn
and seg.segment_name=rn.name
and KTUXESTA!='INACTIVE'
order by mb
/
