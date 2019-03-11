define owner=&1
define name=&2
col obj for a70
col type for a20
col ref for a40
col referenced_type for a20
col referenced_link_name for a10
col dependency_type for a10
select  lpad(' ', 5*(level-1)) ||owner||'.'||name obj
--,type
,referenced_owner||'.'||referenced_name ref
,referenced_type, referenced_link_name, DEPENDENCY_TYPE
from 
(
	select null owner, null name,null type, owner referenced_owner, object_name referenced_name
	,object_type referenced_type, null referenced_link_name, null DEPENDENCY_TYPE
		from dba_objects
		where object_name like upper('&name')
		and owner like upper('&owner')
	union
	select owner, name, type,referenced_owner,referenced_name
		,referenced_type, referenced_link_name, DEPENDENCY_TYPE
		from dba_dependencies
		--where name like upper('&name')
		--and owner like upper('&owner')
		--and referenced_owner!='PUBLIC'
		--and referenced_owner like upper('&owner')
		where referenced_owner!='SYS'
	--order by DEPENDENCY_TYPE,REFERENCED_TYPE,
)
start with name is null
connect by name = prior referenced_name
		and owner = prior referenced_owner
		and type = prior REFERENCED_TYPE
/
