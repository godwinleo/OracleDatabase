define owner=&1
set lines 185
set pages 200
col tablespace_name for a20
col ind for a45
col blevel for 999
col index_type for a10
col status for a10
select ind.owner||'.'||index_name ind,ind.index_type,ind.UNIQUENESS,ind.tablespace_name,ind.status
--, ind.partitioned
,ind.compression,ind.last_analyzed,ind.blevel,ind.leaf_blocks,ind.distinct_keys,ind.clustering_factor
,nvl(seg.bytes,0)/1024/1024 MB
from dba_indexes ind, dba_tables tab
, dba_segments seg
where tab.owner like upper('&owner')
and ind.table_name=tab.table_name
and ind.table_owner=tab.owner
and tab.partitioned='YES'
and ind.partitioned='NO'
and ind.index_name = seg.segment_name (+)
and ind.owner = seg.owner (+)
--and seg.segment_type='INDEX'
order by MB asc,ind.table_name,ind.table_owner,ind.tablespace_name
;
