define tbspace=&1
set lines 185
set pages 200
col MB for 999,999,999.99
col segment_name for a30
col partition_name for a30
col owner for a20
col segment_type for a10
col next_MB for 999,999,999.99
select seg.bytes/1024/1024 MB,seg.segment_name,partition_name,seg.owner,segment_type, seg.next_extent/1024/1024 next_mb
from dba_segments seg
where seg.tablespace_name='&tbspace'
and seg.next_extent > (select sum(bytes) from dba_free_space where tablespace_name ='&tbspace')
order by bytes
;
