define user=&1
define obj=&2
set feed on
set trims on

col owner for a25
col object_name for a30
col object_type for a30
col subobject_name for a30
col status for a20


select owner,object_name,object_type,subobject_name,status
,to_char(created,'YYYY-MON-DD HH24:MI') created , to_char(last_ddl_time,'YYYY-MON-DD HH24:MI') last_ddl_time
from dba_objects
where object_name like upper('&obj')
and owner like upper ('&user')
order by owner,object_name
/
