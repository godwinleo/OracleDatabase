define owner=&1
define tab=&2
define col=&3
set lines 185
set pages 200
set feed on
col tab for a40
col column_name for a30
col NUM_DISTINCT for 999,999,999
col density for 9.999999999999
col data_type for a10
col data_length for 999
col data_default for a10 truncated
select tc.owner||'.'||tc.table_name tab,tc.column_name,tc.data_type,tc.data_length,tc.num_distinct,tc.density,tc.histogram,tc.last_analyzed
,nullable,DATA_DEFAULT,num_nulls
from dba_tab_columns tc
where tc.owner like upper('&owner')
and tc.table_name like upper('&tab')
and tc.column_name like upper('&col')
order by tc.table_name,tc.owner,tc.column_id
/
