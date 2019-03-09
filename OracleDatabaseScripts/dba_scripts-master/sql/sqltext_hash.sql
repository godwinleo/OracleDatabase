set pages 0
set feed off
set echo off
set trims on
col sql_text for a180
define hash_val=&1

Select sql_Text
from v$sqltext
where hash_value= '&hash_val'
order by piece
/
