set echo off
set trims on
set long 1000000000
col sql_fulltext for a179 word_wrapped
define id=&1

Select sql_fullText
from v$sql
where sql_id= '&id'
and rownum=1
/
