define tbs=&1
set lines 185
set pages 200
col MB for 9,999,999.99
col segment_name for a30
col partition_name for a30
col segment_type for a20
col next_MB for 999,999.99
col owner for a25
col max_partition for 999,999.99
col min_partition for 999,999.99
break on report
compute SUM of MB on report
select sum(seg.bytes)/1024/1024 MB,seg.segment_type,seg.owner,seg.segment_name
,max(seg.next_extent)/1024/1024 next_mb, count(partition_name) partitions, sum(seg.extents) extents
,max(seg.bytes)/1024/1024 max_partition ,min(seg.bytes)/1024/1024 min_partition
from dba_segments seg
where seg.tablespace_name=upper('&tbs')
group by seg.owner,seg.segment_type,seg.segment_name
having sum(seg.bytes)/1024/1024 > 100
order by MB
;
