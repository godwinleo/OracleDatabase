define owner=&1
define table=&2
col initial_ext for 99999
col next_ext for 99999
col tab for a40
select part.table_owner||'.'||part.table_name tab,part.partition_name,part.tablespace_name,subpartition_count subps
,nvl(seg.extents,0) extents
--,part.last_analyzed, NUM_ROWS
, compression
,compress_for
,seg.initial_ext/1024 initial_ext
,seg.next_ext/1024 next_ext
--,part.initial_extent
--,part.next_extent
,nvl(seg.bytes/1024/1024,0) MB
from dba_tab_partitions part
, ( select s.owner,s.segment_name, p.partition_name, sum(s.bytes) bytes,sum(s.extents) extents, max(s.initial_extent) initial_ext, max(s.NEXT_EXTENT) next_ext
	from dba_segments s, dba_tab_subpartitions p
	where s.segment_type = 'TABLE SUBPARTITION'
	and s.segment_name = p.table_name
	and s.partition_name = p.subpartition_name
	and s.owner = p.table_owner
	group by s.owner,s.segment_name,p.partition_name
	union all
	select s.owner,s.segment_name, s.partition_name, s.bytes, s.extents, initial_extent initial_ext, NEXT_EXTENT next_ext
	from dba_segments s
	where s.segment_type = 'TABLE PARTITION'
	--group by s.owner,s.segment_name,s.partition_name
) seg
where table_name like upper('&table')
and table_owner like upper('&owner')
and part.partition_name=seg.partition_name (+)
and part.table_name=seg.segment_name (+)
and part.table_owner=seg.owner (+)
--and nvl(seg.extents,0) = 0
--and compress_for !='OLTP'
--and part.tablespace_name=seg.tablespace_name
--and seg.initial_ext/1024 >= 8192
order by table_name,table_owner,partition_position
/