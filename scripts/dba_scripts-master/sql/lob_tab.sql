define owner=&1
define tab=&2
set head on
col tab for a45
col column_name for a30
col tablespace_name for a15
select owner||'.'||table_name tab,column_name, tablespace_name,compression
from dba_lobs
where owner like upper('%&owner%')
and table_name like upper('&tab')
/
