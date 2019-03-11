define owner='&1'
define tab='%'

col clause for a185 word_wrapped
col column_name for a15
col DATA_TYPE for a15

select
'DBMS_DATAPUMP.DATA_FILTER (v_dp_job, ''SUBQUERY'', ''WHERE '||decode(tc.DATA_TYPE,'DATE',pkc.column_name,'to_date('||pkc.column_name||',''''YYYYMMDD'''')')||' >= add_months(trunc(sysdate,''''MM''''),0)'', '''||
pkc.name||''', '''||pkc.owner||''');' clause
--, tc.column_name, tc.DATA_TYPE
from dba_part_key_columns pkc
, dba_tab_columns tc
where pkc.owner=upper('&owner')
--and pkc.name like upper('&tab')
--and tc.DATA_TYPE in ('DATE','NUMBER')
and pkc.owner=tc.owner
and pkc.name=tc.table_name
and pkc.column_name=tc.column_name
order by pkc.name,pkc.owner,pkc.column_position
/