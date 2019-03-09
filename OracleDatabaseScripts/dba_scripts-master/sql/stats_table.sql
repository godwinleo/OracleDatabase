define owner=&1
define table=&2
set lines 185
set pages 200
col tablespace_name for a20
col table_name for a20
col owner for a15
col table_owner for a15
break on report
compute SUM of MB on report
select --tab.table_name,
tab.owner,tab.tablespace_name,seg.extents,tab.last_analyzed,seg.bytes/1024/1024 MB, NUM_ROWS, CHAIN_CNT,AVG_ROW_LEN,GLOBAL_STATS,USER_STATS,PARTITIONED
,tab.SAMPLE_SIZE
,tab.table_lock
,tab.monitoring
from dba_tables tab, dba_segments seg
where table_name=upper('&table')
and tab.owner like upper('&owner')
and tab.table_name=seg.segment_name
and tab.owner=seg.owner
and tab.tablespace_name=seg.tablespace_name
order by table_name,tab.owner
;
