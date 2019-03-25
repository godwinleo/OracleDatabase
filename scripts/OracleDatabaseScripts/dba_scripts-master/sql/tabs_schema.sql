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
select seg.owner,sum(seg.bytes)/1024/1024 MB,seg.segment_name,seg.tablespace_name, sum(seg.extents)
from dba_segments seg
where seg.owner=upper('&owner')
--and extents > 1
group by seg.owner , seg.segment_name, seg.tablespace_name
order by mb
;
