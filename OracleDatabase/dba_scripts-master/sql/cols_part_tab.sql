define owner=&1
define tab=&2
set lines 185
set pages 200
set feed on
col tab for a30
col column_name for a20
col NUM_DISTINCT for 999,999,999
col density for 9.999999999999
col data_length for 999
col data_type for a15
select pkc.owner||'.'||pkc.name tab,pkc.column_name
,tc.data_type,tc.data_length
from dba_part_key_columns pkc 
, dba_tab_columns tc
where pkc.owner=upper('&owner')
and pkc.name=upper('&tab')
and pkc.owner=tc.owner
and pkc.name=tc.table_name
and pkc.column_name=tc.column_name
order by pkc.name,pkc.owner,pkc.column_position
;
