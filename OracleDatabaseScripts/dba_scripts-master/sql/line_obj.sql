define owner=&1
define obj=&2
define line=&3
set lines 185
set pages 100
set feed on
set trims on

col owner for a30
col object_name for a30
col object_type for a30
col subobject_name for a30
col status for a30
col text for a155


select text
from dba_source
where name=upper('&obj')
and owner=upper('&owner')
and line=&line
/
