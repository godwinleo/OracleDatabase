define owner=&1
define name=&2
col obj for a30
col type for a20
col ref for a40
col referenced_type for a20
col referenced_link_name for a30
col dependency_type for a20
select owner||'.'||name obj,type,referenced_owner||'.'||referenced_name ref
,referenced_type, referenced_link_name, DEPENDENCY_TYPE
from dba_dependencies
where name like upper('&name')
and owner like upper('&owner')
--and referenced_owner!='PUBLIC'
--and referenced_owner like upper('&owner')
order by DEPENDENCY_TYPE,REFERENCED_TYPE,REF
/
