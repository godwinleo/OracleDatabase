set pages 100
set feed off
set echo off
set trims on
set long 1000000000
col sql_text for a179 word_wrapped
define id=&1

Select sql_text
from DBA_HIST_SQLTEXT
where sql_id= '&id'
/
