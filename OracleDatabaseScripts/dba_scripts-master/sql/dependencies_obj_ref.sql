define owner=&1
define obj=&2

col REFERENCED_OBJ     for a35
col OWNER                for a25
col NAME                 for a35
col TYPE                 for a15
col REFERENCED_TYPE      for a15
col REFERENCED_LINK_NAME for a15
col DEPENDENCY_TYPE      for a15

select 
REFERENCED_OWNER||'.'||REFERENCED_NAME REFERENCED_OBJ
,OWNER
,NAME
,TYPE
,REFERENCED_TYPE
,REFERENCED_LINK_NAME
,DEPENDENCY_TYPE 
from DBA_DEPENDENCIES
where REFERENCED_OWNER like upper ('&owner')
and REFERENCED_NAME like upper ('&obj')
/