define owner=&1
define table=&2
set lines 185
set pages 200
col tablespace_name for a20
col tab for a38
break on report
compute SUM of MB on report
select tab.owner||'.'||tab.table_name tab
,tab.tablespace_name,seg.extents,tab.last_analyzed,seg.bytes/1024/1024 MB
--, NUM_ROWS, CHAIN_CNT,AVG_ROW_LEN,GLOBAL_STATS,USER_STATS,PARTITIONED,tab.SAMPLE_SIZE
,PCT_FREE
--,PCT_USED,INI_TRANS,MAX_TRANS
,INITIAL_EXTENT/1024 initial_k
,NEXT_EXTENT/1024 next_k
,MIN_EXTENTS
,MAX_EXTENTS
,PCT_INCREASE
,FREELISTS
--,FREELIST_GROUPS
from dba_tables tab, 
(select owner,segment_name,tablespace_name,sum(bytes) bytes,sum(extents) extents from dba_segments
	group by owner,segment_name,tablespace_name
) seg
where table_name like upper('&table')
and tab.owner like upper('&owner')
and tab.table_name=seg.segment_name (+)
and tab.owner=seg.owner (+)
--and tab.tablespace_name=seg.tablespace_name (+)
order by table_name,tab.owner
;
