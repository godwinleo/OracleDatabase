define owner=&1
define index=&2
set lines 185
set pages 200
col tablespace_name for a20
col index_name for a30
col index_type for a15
col index_owner for a15
col blevel for 99
col clustering_factor for 99999999
col MB for 999,999.99
col AVG_LEAF_BLOCKS_PER_KEY for 99 name AVG_LBLK
col AVG_DATA_BLOCKS_PER_KEY for 99 name AVG_DBLK
break on report
compute SUM of MB on report
select part.partition_name,part.index_owner,part.status,part.tablespace_name,seg.extents,part.last_analyzed,sum(seg.bytes/1024/1024) MB, NUM_ROWS
, GLOBAL_STATS,USER_STATS,BLEVEL,LEAF_BLOCKS,CLUSTERING_FACTOR
--,AVG_LEAF_BLOCKS_PER_KEY,AVG_DATA_BLOCKS_PER_KEY
from 
--, dba_tab_partitions part
(	
       	select p.index_name,p.partition_name,p.status,nvl(s.subpartition_name,p.partition_name) partition_name_join,p.index_owner,p.tablespace_name,p.last_analyzed,p.num_rows,p.GLOBAL_STATS,p.USER_STATS,p.BLEVEL,p.LEAF_BLOCKS,p.CLUSTERING_FACTOR
--,p.AVG_LEAF_BLOCKS_PER_KEY,p.AVG_DATA_BLOCKS_PER_KEY
	from dba_ind_partitions p
	, dba_ind_subpartitions s
	where p.index_owner=s.index_owner (+) 
	and p.index_name=s.index_name (+)
	and p.partition_name=s.partition_name (+) 
	) part
, dba_segments seg
where index_name like upper ('&index')
and owner like upper('&owner')
and part.partition_name_join=seg.partition_name
and part.index_name=seg.segment_name
and part.index_owner=seg.owner
--and part.tablespace_name=seg.tablespace_name
group by part.index_name,part.partition_name,part.status,part.index_owner,part.tablespace_name,seg.extents,part.last_analyzed
, NUM_ROWS, GLOBAL_STATS,USER_STATS,BLEVEL,LEAF_BLOCKS,CLUSTERING_FACTOR
--,AVG_LEAF_BLOCKS_PER_KEY,AVG_DATA_BLOCKS_PER_KEY
order by index_name,index_owner
;
