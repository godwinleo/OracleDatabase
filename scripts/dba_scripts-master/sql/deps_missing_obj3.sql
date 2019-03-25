define owner=&1
define name=&2
col obj for a70
col type for a20
col ref for a40
col referenced_type for a20
col referenced_link_name for a10
col dependency_type for a10
select deps.*, obj.status
--, tp.privilege
from 
	(
	select  owner, name 
	--,type
	,referenced_owner, referenced_name
	,referenced_type
	--, referenced_link_name, DEPENDENCY_TYPE
	from 
	(
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
	start with name like upper('&name')
			and owner like upper('&owner')
	connect by name = prior referenced_name
			and owner = prior referenced_owner
			and type = prior REFERENCED_TYPE
	) deps
	, dba_objects obj
where 
    obj.owner=deps.referenced_owner
and obj.object_name=deps.referenced_name
and obj.object_type=deps.referenced_type
and deps.REFERENCED_TYPE!='SYNONYM'
and not exists ( select 1
				 from dba_tab_privs tp
				 where tp.owner=deps.referenced_owner
				 and 	tp.table_name=deps.referenced_name
				 and 	tp.privilege='SELECT'
				 and	tp.grantee=upper('&owner')
				)
and ( referenced_owner != upper('&owner') )
/
