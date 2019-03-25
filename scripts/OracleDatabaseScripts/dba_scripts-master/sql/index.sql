define owner=&1
define index=&2
col tab for a38
col idx for a40
col tablespace_name for a20
col index_type for a22
col table_owner for a15
select table_owner||'.'||table_name tab
,ind.owner||'.'||index_name idx,index_type,UNIQUENESS,ind.tablespace_name,status,partitioned,last_analyzed,compression
,seg.bytes/1024/1024 MB --, seg.initial_extent/1024 initial_ext_K ,seg.next_extent/1024 next_ext_K
from dba_indexes ind
,(select owner,segment_name,sum(bytes) bytes,sum(extents) extents
    from dba_segments
	group by owner,segment_name
) seg
where ind.owner like upper('&owner')
and ind.index_name like upper('&index')
and ind.index_name=seg.segment_name (+)
and ind.owner=seg.owner (+)
order by 
mb,
table_owner,table_name, ind.owner,index_name
;
