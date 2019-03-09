define owner=&1
define table=&2
define part=&3
col tab for a25 truncated
col partition_name for a15
col subpartition_name for a25
col tablespace_name for a20
col high_value for a20 truncated
col initial_ext for a8
col next_ext for a8
break on report
compute SUM of MB on report
select part.table_owner||'.'||part.table_name tab,part.partition_name, part.subpartition_name,part.tablespace_name
,part.initial_extent/1024||'K' initial_ext ,part.next_extent/1024||'K' next_ext
,nvl(seg.extents,0) extents,nvl(seg.bytes/1024/1024,0) MB
,part.NUM_ROWS ,part.last_analyzed
,part.compression
--, CHAIN_CNT,AVG_ROW_LEN,GLOBAL_STATS,USER_STATS, compression
,part1.high_value
from  dba_segments seg
	, dba_tab_subpartitions part
	, dba_tab_partitions part1
where part.table_owner like upper('&owner')
and part.table_name like upper('&table')
and part.partition_name like upper('&part')
and part.subpartition_name=seg.partition_name (+)
and part.table_name=seg.segment_name (+)
and part.table_owner=seg.owner (+)
--and part.tablespace_name=seg.tablespace_name
and part1.table_owner=part.table_owner
and part1.table_name=part.table_name
and part1.partition_name=part.partition_name
order by part.table_owner,part.table_name,part1.partition_position, part.SUBPARTITION_POSITION 
;
