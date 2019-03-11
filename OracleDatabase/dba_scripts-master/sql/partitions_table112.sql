define owner=&1
define table=&2
set lines 185
set pages 200
col tablespace_name for a20
col partition_name for a20
col index_name for a30
col table_name for a20
col index_type for a15
col owner for a15
col table_owner for a15
col subps for 99
break on report
compute SUM of MB on report
select part.partition_name,part.table_owner,part.tablespace_name,subpartition_count subps,nvl(sum(seg.extents),0) extents,part.last_analyzed,nvl(sum(seg.bytes/1024/1024),0) MB, NUM_ROWS
, CHAIN_CNT,AVG_ROW_LEN,GLOBAL_STATS,USER_STATS, compression
,interval
from  dba_segments seg
--, dba_tab_partitions part
	, ( select p.table_name,p.partition_name,p.partition_position,nvl(s.subpartition_name,p.partition_name) partition_name_join
		,p.table_owner,p.tablespace_name
		,p.subpartition_count
		,p.last_analyzed,p.num_rows,p.chain_cnt,p.AVG_ROW_LEN,p.GLOBAL_STATS,p.USER_STATS
		,nvl(s.compression,p.compression) compression
		,p.interval
	from 
		dba_tab_partitions p
		, dba_tab_subpartitions s
	where p.table_owner=s.table_owner (+) 
	and p.table_name=s.table_name (+)
	and p.partition_name=s.partition_name (+) 
	) part
where table_name=upper('&table')
and table_owner like upper('%&owner%')
and part.partition_name_join=seg.partition_name (+)
and part.table_name=seg.segment_name (+)
and part.table_owner=seg.owner (+)
--and part.tablespace_name=seg.tablespace_name
group by part.table_name,part.partition_name,part.partition_position,part.subpartition_count,part.table_owner,part.tablespace_name,part.last_analyzed
, NUM_ROWS, CHAIN_CNT,AVG_ROW_LEN,GLOBAL_STATS,USER_STATS,compression,interval
order by table_name,table_owner,partition_position
;
