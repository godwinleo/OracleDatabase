define owner=&1
define table=&2
col tablespace_name for a20
col ind for a40
col blevel for 999
col index_type for a22
col status for a10
select owner||'.'||index_name ind,index_type,UNIQUENESS,tablespace_name,status,partitioned,compression,last_analyzed,blevel,leaf_blocks,distinct_keys,clustering_factor
from dba_indexes ind
where table_name like '&table'
and owner like upper('&owner')
order by table_name,table_owner,tablespace_name
;
