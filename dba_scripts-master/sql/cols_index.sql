define owner=&1
define index=&2
set lines 185
set pages 200
col idx for a35
col tab for a30
col column_name for a25
col NUM_DISTINCT for 999,999,999
col density for 9.999999999999
col len for 999
col COLUMN_EXPRESSION for a25 truncated
col pos for 99
select ind.table_owner||'.'||ind.table_name tab,ind.owner||'.'||ind.index_name idx 
,ic.COLUMN_POSITION pos
,ic.column_name,tc.data_length len,tc.num_distinct,tc.density
,tc.histogram,tc.last_analyzed
,COLUMN_EXPRESSION
from dba_indexes ind
, dba_ind_columns ic
, dba_tab_columns tc
, dba_ind_expressions ie
where ind.index_name like upper('&index')
and ic.index_owner like upper('&owner')
and ic.index_name=ind.index_name
and ic.index_owner=ind.owner
and ic.table_owner=tc.owner (+)
and ic.table_name=tc.table_name (+)
and ic.column_name=tc.column_name (+)
and ic.INDEX_OWNER=ie.INDEX_OWNER (+)
and ic.index_name=ie.index_name (+)
and ic.COLUMN_POSITION=ie.COLUMN_POSITION (+)
order by ind.table_name,ind.table_owner,ind.index_name,ic.column_position
;
