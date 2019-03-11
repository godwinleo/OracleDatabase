define owner=&1
define table=&2
set lines 185
set pages 200
col tablespace_name for a20
col tab for a38
break on report
compute SUM of MB on report
select tab.owner||'.'||tab.table_name tab
,nvl(tab.tablespace_name,tp.tablespace_name),tab.last_analyzed
--, NUM_ROWS, CHAIN_CNT,AVG_ROW_LEN,GLOBAL_STATS,USER_STATS,PARTITIONED,tab.SAMPLE_SIZE
,nvl(tab.PCT_FREE,tp.PCT_FREE) pct_free
--,PCT_USED,INI_TRANS,MAX_TRANS
,nvl(tab.INITIAL_EXTENT,tp.INITIAL_EXTENT)/1024 initial_k
,nvl(tab.NEXT_EXTENT,tp.NEXT_EXTENT)/1024 next_k
,nvl(tab.MIN_EXTENTS,tp.MIN_EXTENT) min_extents
,nvl(tab.MAX_EXTENTS,tp.MAX_EXTENT ) max_extents
,nvl(tab.PCT_INCREASE,tp.PCT_INCREASE) pct_increase
,nvl(tab.FREELISTS,tp.FREELISTS ) freelists
--,FREELIST_GROUPS
from dba_tables tab
, dba_tab_partitions tp
where tab.table_name like upper('&table')
and tab.owner like upper('&owner')
and tab.owner=tp.table_owner (+)
and tab.table_name=tp.table_name (+)
and tp.partition_name like upper('&part')
--and tab.tablespace_name=seg.tablespace_name (+)
order by tab.table_name,tab.owner,tp.partition_position
;
