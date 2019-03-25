define owner=&1
define table=&2
set lines 185
set pages 200
col tablespace_name for a20
col partition_name for a29
col compress_for for a5
col MB for 999,999.99
col index_name for a30
col table_name for a20
col index_type for a15
col owner for a15
col table_owner for a15
col subps for 99
col high_value for a20 truncated
set longc 5000
break on report
compute SUM of MB on report
select part.partition_name,part.table_owner,part.tablespace_name,subpartition_count subps,nvl(seg.extents,0) extents,part.last_analyzed,nvl(seg.bytes/1024/1024,0) MB, NUM_ROWS
, CHAIN_CNT,AVG_ROW_LEN,GLOBAL_STATS,USER_STATS, compression
--,compress_for
,high_value
from dba_tab_partitions part
, ( select s.owner,s.segment_name, p.partition_name, sum(s.bytes) bytes,sum(s.extents) extents
	from dba_segments s, dba_tab_subpartitions p
	where s.segment_type = 'TABLE SUBPARTITION'
	and s.segment_name = p.table_name
	and s.partition_name = p.subpartition_name
	and s.owner = p.table_owner
	group by s.owner,s.segment_name,p.partition_name
	union all
	select s.owner,s.segment_name, s.partition_name, sum(s.bytes) bytes,sum(s.extents) extents
	from dba_segments s
	where s.segment_type = 'TABLE PARTITION'
	group by s.owner,s.segment_name,s.partition_name
) seg
where table_name=upper('&table')
and table_owner like upper('%&owner%')
and part.partition_name=seg.partition_name (+)
and part.table_name=seg.segment_name (+)
and part.table_owner=seg.owner (+)
--and seg.extents > 0
--and part.tablespace_name=seg.tablespace_name
order by table_name,table_owner,partition_position
;
