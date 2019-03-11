define owner=&1
define seg=&2
col tab for a35
col column_name for a30
col tablespace_name for a15
select owner||'.'||table_name tab,column_name, tablespace_name,compression
from dba_lobs
where owner like upper('%&owner%')
and segment_name like '&seg'
/
