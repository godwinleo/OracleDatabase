define owner=&1
define tab=&2
set head on
col tab for a45
col column_name for a30
col tablespace_name for a15
col partition_name for a20
select table_owner||'.'||table_name tab, PARTITION_NAME, lob_name, column_name, tablespace_name,compression, LOB_INDPART_NAME
from dba_lob_partitions
where table_owner like upper('%&owner%')
and table_name like upper('&tab')
order by 1,2
/
