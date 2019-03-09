define owner=&1
define tab=&2
set lines 185
set pages 200
set feed on
col tab for a30
col subpartition_name for a20
col subpartition_position for 99
col tablespace_name for a20
col high_bound for a20
select pkc.user_name||'.'||pkc.table_name tab,subpartition_name,subpartition_position,tablespace_name,high_bound
from dba_subpartition_templates pkc 
where pkc.user_name=upper('&owner')
and pkc.table_name=upper('&tab')
order by pkc.table_name,pkc.user_name,subpartition_position
;
