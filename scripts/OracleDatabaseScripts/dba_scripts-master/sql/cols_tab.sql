define owner=&1
define tab=&2
set lines 185
set pages 200
set feed on
col tab for a30
col column_name for a30
col NUM_DISTINCT for 999,999,999
col density for 9.999999999999
col data_type for a20
col data_length for 999
col data_default for a10 truncated
select tc.owner||'.'||tc.table_name tab,tc.column_name,tc.data_type,tc.data_length,tc.num_distinct,tc.density,tc.histogram,tc.last_analyzed
,nullable,DATA_DEFAULT,num_nulls
from dba_tab_columns tc
where tc.owner=upper('&owner')
and tc.table_name=upper('&tab')
order by tc.table_name,tc.owner,tc.column_id
/
