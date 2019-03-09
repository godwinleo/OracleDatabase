define owner=&1
set lines 185
set pages 200
col MB for 9,999,999.99
col segment_name for a30
col partition_name for a30
col tablespace_name for a20
col segment_type for a17
col next_MB for 999,999.99
break on report
compute SUM of MB on report
select seg.bytes/1024/1024 MB ,seg.segment_type, seg.segment_name, partition_name,seg.tablespace_name, seg.next_extent/1024/1024 next_mb, seg.extents
from dba_segments seg
where seg.owner=upper('&owner')
and extents > 1
order by bytes
;
