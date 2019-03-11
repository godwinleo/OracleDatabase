define owner=&1
define table=&2
set lines 185
set pages 200
col tablespace_name for a20
col tab for a38
break on report
compute SUM of MB on report
select tab.owner||'.'||tab.table_name tab
,tab.DEF_tablespace_name tablespace_name
--, NUM_ROWS, CHAIN_CNT,AVG_ROW_LEN,GLOBAL_STATS,USER_STATS,PARTITIONED,tab.SAMPLE_SIZE
,DEF_PCT_FREE PCT_FREE
--,PCT_USED,INI_TRANS,MAX_TRANS
,DEF_INITIAL_EXTENT initial_k
,DEF_NEXT_EXTENT next_k
,DEF_MIN_EXTENTS min_extents
,DEF_MAX_EXTENTS max_extents
,DEF_PCT_INCREASE pct_increase
,DEF_FREELISTS freelists
--,DEF_FREELIST_GROUPS
from dba_part_tables tab
where table_name like upper('&table')
and tab.owner like upper('&owner')
--and tab.tablespace_name=seg.tablespace_name (+)
order by table_name,tab.owner
;
