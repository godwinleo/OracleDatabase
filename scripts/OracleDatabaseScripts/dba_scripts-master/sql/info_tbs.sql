define tbs=&1
col tablespace_name for a30
select tablespace_name,block_size,initial_extent,next_extent,status,contents,logging,force_logging,extent_management,allocation_type,plugged_in,segment_space_management,def_tab_compression,retention,bigfile
,compress_for
from dba_tablespaces
where tablespace_name like upper('&tbs')
/
