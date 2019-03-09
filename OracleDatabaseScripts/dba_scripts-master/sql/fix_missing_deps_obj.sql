define owner=&1
define name=&2

col REFERENCED_OBJ     for a35
col OWNER                for a25
col NAME                 for a35
col TYPE                 for a15
col REFERENCED_TYPE      for a15
col REFERENCED_LINK_NAME for a15
col DEPENDENCY_TYPE      for a15

select 'grant execute on '||decode(REFERENCED_OWNER,'PUBLIC','',REFERENCED_OWNER||'.')||REFERENCED_NAME
||' to '||dep.owner||';'
--, DEPENDENCY_TYPE, REFERENCED_LINK_NAME
--,object_type
from DBA_DEPENDENCIES dep, dba_objects obj2
where dep.REFERENCED_OWNER like upper ('&owner')
and dep.REFERENCED_NAME like upper ('&name')
and exists ( select 1 
				from dba_objects obj 
				where dep.OWNER = obj.OWNER
				and dep.NAME = obj.OBJECT_NAME 
				and status ='INVALID')
and not exists ( select 1 
				from dba_tab_privs privs 
				where dep.REFERENCED_NAME = privs.TABLE_NAME 
				and grantee in (dep.owner,'PUBLIC') )
and referenced_owner !=dep.owner
and dep.REFERENCED_NAME = obj2.OBJECT_NAME 
and dep.REFERENCED_OWNER = obj2.OWNER
--and obj2.object_type not in ('TABLE','VIEW')
and (REFERENCED_NAME not like 'DBA_%' and REFERENCED_NAME not like 'ALL_%' and REFERENCED_NAME not like 'V$%' )
group by REFERENCED_OWNER,REFERENCED_NAME,dep.owner
--, DEPENDENCY_TYPE, REFERENCED_LINK_NAME
--,object_type
order by dep.owner
/