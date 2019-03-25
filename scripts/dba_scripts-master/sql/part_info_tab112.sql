define owner=&1
define table=&2
set lines 185
set pages 200
col def_tablespace_name for a20
col def_initial_ext for a10
col def_next_ext for a10
col tab for a40
col owner for a15
col status for a15
col subps for 99
col interval for a30
select owner||'.'||table_name tab,partitioning_type,SUBPARTITIONING_TYPE,def_tablespace_name,def_logging
,DEF_INITIAL_EXTENT def_initial_ext ,DEF_NEXT_EXTENT def_next_ext
,def_compression,def_compress_for,status
,is_nested
,interval
from  dba_part_tables part
where table_name like upper('&table')
and owner like upper('%&owner%')
order by table_name,owner
;
