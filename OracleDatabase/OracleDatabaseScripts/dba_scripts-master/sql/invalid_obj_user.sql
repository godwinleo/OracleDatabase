define user=&1
set lines 185
set pages 100
set feed on
set trims on

col owner for a30
col object_name for a30
col object_type for a30
col subobject_name for a30
col status for a30


select owner,object_name,object_type,subobject_name,status
from dba_objects
where owner like upper('&user')
and status!='VALID'
/
